public class TravelCalendar_Controller {
    public Boolean includeMyEvents {get;set;}
    public list<calEvent> events {get;set;}
    public boolean eventColor {get;set;}
    private Truck_Run__c addTruckRun;
    public List<Truck_Run__c> AddTruckRunList = new List<Truck_Run__c>();   
    @TestVisible private List<Account> AccountTemp;
    @TestVisible private List<Truck_for_Store__c> TruckTemp;
    @TestVisible private List<Contact> DriverTemp;
    public string SelectedAccountId
    {
        get 
        {
            if(SelectedAccountId == null)
        	{
            	SelectedAccountId = getStoreIdForUser();
        	} 
            return SelectedAccountId;
        }
     	set;
    }
    public string SelectedTruckId {get; set;}
    public string SelectedDriverId {get; set;}    
    public String newTruckRunId {get;set;}
    public string truckRunURL {get;set;}

    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated
    public boolean ShowTruckSection {get; set;} //correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';
    

    //constructor
    public TravelCalendar_Controller() {
        //Default showing my events to on
        includeMyEvents = false;
        eventColor = false;
        ShowTruckSection = true;
    }
    
    public String getStoreIdForUser()
    {
        String storeNum = [SELECT Contact.Account_Store_Number__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0].Contact.Account_Store_Number__c;
        if(storeNum == null)
        {
            return 'all';
        }
        Id storeId = [SELECT Id FROM Account WHERE Store_Number__c = :storeNum LIMIT 1][0].Id;
        return String.valueOf(storeId);
    }
    
    public void pageLoad() {    
        events = new list<calEvent>();
        String query = 'Select Id, Forecast_Amount__c , Truck_for_Run__c, Notes__c, Run_End_Date__c,End_Time__c, Run_Start_Date__c,Start_Time__c, Run_Start_Time__c, Run_End_Time__c , Driver__r.Name, Driver__r.Truck_Run_Calendar_Color__c, Driver__r.Title, Rwfb_Account__r.Name, Store__r.Store_Number__c, Store__r.Id  From Truck_Run__c Where Truck_Run_Status__c != \'Cancelled\'';

        //if the user didn't choose the all option, add the store id to the query
        if(!SelectedAccountId.equals('all'))
        {
            query += ' AND Store__r.Id = \'' + SelectedAccountId + '\'';
        }
        
        if(SelectedTruckId != null && SelectedTruckId != '')
        {
            query += ' And Truck_for_Run__r.Id = \'' + SelectedTruckId + '\'';
        }
        if(SelectedDriverId != null && SelectedDriverId != '')
        {
            query += ' And Driver__r.Id = \'' + SelectedDriverId + '\'';
        }
        System.debug('query=' + query);
        system.debug('NewID=' + newTruckRunId);
        
        //Get My Travel
        for(List<Truck_Run__c> truckRuns : Database.query(query))
        {
            for(Truck_Run__c myTruck : truckRuns)
            {
                system.debug('Truck Run ID: ' + myTruck.Id + myTruck.Run_Start_Date__c + myTruck.Run_End_Date__c);
                TimeZone tz = UserInfo.getTimeZone();
                if(mytruck.Run_Start_Date__c == null)
                {
                    continue;
                }
                DateTime sDate = mytruck.Run_Start_Date__c;
                string sTime = mytruck.Start_Time__c;
                DateTime startDT;
                
                DateTime eDate = mytruck.Run_End_Date__c;
                string eTime = mytruck.End_Time__c;
                DateTime endDT;
                
                if(sDate != null && sTime != null){                    
                	string sD = '01/01/18 ' + sTime;
                	DateTime getSTime = Datetime.parse(sD);
                	Datetime startDtAndTi = Datetime.newInstance(sDate.dateGmt(),getSTime.time());
                    	system.debug('DT: ' + startDtAndTi + ' ' + myTruck.Id);
                    startDT = startDtAndTi.addSeconds(tz.getOffset(startDtAndTi)/1000);
                    system.debug('Modi SDT: ' + startDT + myTruck.Id);
                        system.debug('sdt - ' + startDtAndTi.format(dtFormat) + myTruck.Id);
                }
                else
                {
                	startDT = mytruck.Run_Start_Time__c.AddSeconds(tz.getOffset(mytruck.Run_Start_Time__c)/1000);
                }
                if(eDate != null && eTime != null)
                {
                    string eD = '01/01/18 ' + eTime;
	                DateTime getETime = Datetime.parse(eD);  
                	Datetime endDtAndTi = Datetime.newInstance(eDate.dateGmt(),getETime.time());
                    endDT = endDtAndTi.addSeconds(tz.getOffset(endDtAndTi)/1000);
                    system.debug('Modi EDT: ' + endDT + myTruck.Id);
                    system.debug('edt - ' + endDT.format(dtFormat) + myTruck.Id);
                }
                else
                {
                	endDT = mytruck.Run_End_Time__c.AddSeconds(tz.getOffset(mytruck.Run_End_Time__c)/1000);
                }
                DateTime nowDT = DateTime.now().AddSeconds(tz.getOffset(DateTime.now())/1000);
                string EventColor = mytruck.Driver__r.Truck_Run_Calendar_Color__c;

                string DriName = '';
                    if(mytruck.Driver__r.Name != null){
                      DriName = 'Driver - ' + mytruck.Driver__r.Name + '; ' ;
                    }
                string AcctName = '';
                    if(mytruck.Rwfb_Account__r.Name != null){
                        AcctName = 'Account - '+ mytruck.Rwfb_Account__r.Name + '; ';
                    }
                string StoreNumber = '';
                    if(mytruck.Store__r.Store_Number__c != null){
                        StoreNumber = 'Store# - ' + mytruck.Store__r.Store_Number__c + '; ' ;
                    }
                
                string TruckTFSId = '';
                if(mytruck.Truck_for_Run__c != null){
                    String truckIdquery = 'Select Id, Name From Truck_for_Store__c';           
                    truckIdquery += ' where Id = \'' + mytruck.Truck_for_Run__c + '\'';
                     Truck_for_Store__c truckId = Database.query(truckIdquery);
                     system.debug('Truck Id: ' + truckId.Id);  
                    TruckTFSId = 'Truck - ' + truckId.Name + '; ';//'Truck TFS Id';//mytruck.Truck_for_Store__c.Name;
                }
                
                string notes = '';
                if (mytruck.Notes__c != null)
                {
                    notes = 'Notes - ' + mytruck.Notes__c;
                } 
                calEvent mytravEvent = new calEvent();  
                mytravEvent.title = 'Trip: '+ AcctName + DriName + StoreNumber + TruckTFSId + notes ;
                mytravEvent.allDay = false;                                   
                mytravEvent.startString = startDT.format(dtFormat);
                
                mytravEvent.endString = endDT.format(dtFormat);
                            
                mytravEvent.url = '/' + mytruck.Id;
                mytravEvent.eId = mytruck.Id;
                mytravEvent.colorCode = EventColor;
                mytravEvent.driver = DriName;
                
                if(startDT < nowDT && endDT < nowDT)
                {
                    mytravEvent.className = 'event-mytravel';
                }
                else if ((startDT == nowDT || startDT < nowDT) && endDT >= nowDT)
                {
                    mytravEvent.className = 'event-sbtravel';
                }
                else if(startDT > nowDT)
                {
                    mytravEvent.className = 'event-trtravel';
                }
                events.add(mytravEvent);
            }
    	}
    }
    
    public List<SelectOption> getAccounts()
    {
        //Use the already queried account list if we have it
        if(AccountTemp == null)
        {
            AccountTemp = [Select Name, Store_Number__c, Id, Truck_Qty__c, ParentId From Account Where RecordType.Name = 'M3 Store Parent Account' AND Truck_Qty__c > 0 ORDER BY Store_Number__c ASC NULLS LAST];
        }
        List<SelectOption> accounts = new List<SelectOption>();
        accounts.add(new SelectOption('all','-All-'));
        for(Account temp : AccountTemp)
        {
            accounts.add(new SelectOption(String.valueOf(temp.Id), temp.Store_Number__c + ' - ' + temp.Name));
        }
        return accounts;
    }
    
    public String allTruckRunsUrl()
    {
        list<EndPoints__c> truckRunURL = [SELECT Name,EndPoint__c FROM EndPoints__c WHERE Name='AllTruckRuns'];
        return truckRunURL[0].EndPoint__c;   
    }
    
    public List<SelectOption> getTrucks()
    {
        String query = 'Select t.Store__r.Id, t.Truck__r.Id, t.Truck__r.Truck_Description__c From Truck_for_Store__c t Where t.Truck_Is_Active__c = true';
        if(!SelectedAccountId.equals('all'))
        {
            query += ' And t.Store__r.Id = \'' + SelectedAccountId + '\'';
        }
        TruckTemp = Database.query(query);
        List<SelectOption> trucks = new List<SelectOption>();
        trucks.add(new SelectOption('','-All-'));
        for(Truck_for_Store__c temp : TruckTemp)
        {
            trucks.add(new SelectOption(String.valueOf(temp.Store__r.Id), temp.Truck__r.Truck_Description__c));
        }
        return trucks;
    }
    
    public List<SelectOption> getDrivers()
    {
        String query = 'Select Id, Name From Contact Where Role__c INCLUDES (\'Driver\')  And Active__c = true';
        if(!SelectedAccountId.equals('all'))
        {
            query += ' And Account.Id = \'' + SelectedAccountId + '\'';
        }
        DriverTemp = Database.query(query);
        List<SelectOption> drivers = new List<SelectOption>();
        drivers.add(new SelectOption('','-All-'));
        for(Contact temp : DriverTemp)
        {
            drivers.add(new SelectOption(String.valueOf(temp.Id), temp.Name));
        }
        return drivers;
    }
    
    public void toggleMyEvents() {
        if(includeMyEvents){
            includeMyEvents = false;
        }
        else{
            includeMyEvents = true;
        }
        pageload();
    }
    
    public String newTruckRunURL()
    {
        list<EndPoints__c> truckRunURL = [SELECT Name,EndPoint__c FROM EndPoints__c WHERE Name='NewTruckRun'];
         system.debug('url- ' + truckRunURL[0].EndPoint__c);
        return truckRunURL[0].EndPoint__c;
    }
    
     public PageReference updateEvent() {
           system.debug('called updateEvent');
        String eId=Apexpages.currentPage().getParameters().get('eventID');
       
      // Start Date and Time formatting 
         String sDateTime=Apexpages.currentPage().getParameters().get('startDate');
      //for community check   
         String community=Apexpages.currentPage().getParameters().get('community');
         system.debug('sDateTime: ' + sDateTime + community);
         DateTime sDtT;
         string sTime;
         Date sDt;
         string sDt_format;
         if(sDateTime != null && sDateTime != '')
         {
            sDtT = DateTime.Valueof(sDateTime.replace('T', ' ')); 
                    system.debug('sDT & StartDate:' + sDateTime + sDtT );
            sDt_format = sDtT.format('YYYY-MM-dd');
            sDt = date.valueOf(sDt_format);         
            sTime = sDtT.format('hh:mm a');
                    system.debug('Start Time' + sTime );
         }
         
    // End Date and Time formatting
         String eDateTime=Apexpages.currentPage().getParameters().get('endDate');
         DateTime eDtT;
         string eTime;
         Date eDt;
         string eDt_format;
        if(eDateTime != null && eDateTime != '')
        {
            eDtT = DateTime.Valueof(eDateTime.replace('T', ' ')); 
                     system.debug('sDT & EndDateTime:' + eDateTime + eDtT );
            eDt_format = eDtT.format('YYYY-MM-dd');
            eDt = date.valueOf(eDt_format);
            eTime = eDtT.format('hh:mm a');
                    system.debug('End Time' + eTime );
        }
         
        String StoreId = '';
        String TruckGUId = ''; 
         system.debug('SelectedTruckId: ' + SelectedTruckId);

// Add or Update Truck Run  
         String truckIdquery = 'Select Id, Name, t.Store__r.Id, t.Truck__r.Id, t.Truck__r.Truck_Description__c From Truck_for_Store__c t';
         if(eId != 'false')
         {
            Truck_Run__c updateMyTruckRun = [select Id, Forecast_Amount__c , Notes__c, Run_Start_Date__c, Start_Time__c, Run_End_Date__c, End_Time__c, Run_Start_Time__c, Run_End_Time__c , Driver__r.Name, Rwfb_Account__r.Name,Truck_for_Run__r.Store__r.Store_Number__c from Truck_Run__c where Id  = :eId];
            updateMyTruckRun.Run_Start_Time__c = sDtT;
            updateMyTruckRun.Run_End_Time__c = eDtT;
            updateMyTruckRun.Run_Start_Date__c = sDt;
            updateMyTruckRun.Run_End_Date__c = eDt;
            updateMyTruckRun.Start_Time__c = sTime;
            updateMyTruckRun.End_Time__c = eTime;             
            //updateMyTruckRun.Truck_for_Run__c = TruckGUId;
            upsert updateMyTruckRun;
         }
         else
         {    
             if (sDateTime != '' && eDateTime != '')
             {
                 eDtT = sDtT.addHours(4);
                 eDt_format = eDtT.format('YYYY-MM-dd');
                 eDt = date.valueOf(eDt_format);
                 eTime = eDtT.format('hh:mm a');
                 system.debug('EDT: ' + eTime);
                 if(SelectedAccountId != '')
                 {
                     StoreId = SelectedAccountId;
                 }
                 
                 if(SelectedTruckId != null)
                 {
                     truckIdquery += ' where t.Store__r.Id = \'' + SelectedTruckId + '\'';
                     Truck_for_Store__c truckId = Database.query(truckIdquery);
                     system.debug('Truck Id: ' + truckId.Id);  
                     TruckGUId = truckId.Id;
                     addTruckRun = new Truck_Run__c(
                         Store__c = SelectedAccountId,
                         Driver__c = SelectedDriverId,
                         Truck_for_Run__c = TruckGUId,
                         Run_Start_Time__c = sDtT, 
                         Run_End_Time__c = eDtT,
                         Run_Start_Date__c = sDt,
                         Start_Time__c = sTime,
                         Run_End_Date__c = eDt,
                         End_Time__c = eTime
                     );
                 } 
                 else
                 {
                     addTruckRun = new Truck_Run__c(
                         Store__c = SelectedAccountId,
                         Driver__c = SelectedDriverId,
                         Run_Start_Time__c = sDtT, 
                         Run_End_Time__c = eDtT,
                         Run_Start_Date__c = sDt,
                         Start_Time__c = sTime,
                         Run_End_Date__c = eDt,
                         End_Time__c = eTime
                     );               
                 }
             }
             else 
             {                 
                 system.debug('New: ' + SelectedAccountId.length());
                 if(SelectedTruckId != null && SelectedTruckId != 'all')
                 {
                     truckIdquery += ' where t.Store__r.Id = \'' + SelectedTruckId + '\'';
                     Truck_for_Store__c truckId = Database.query(truckIdquery);
                     system.debug('Truck Id: ' + truckId.Id);  
                     TruckGUId = truckId.Id;
                 }
                 if((SelectedAccountId != null && SelectedDriverId != null && TruckGUId != null) && (SelectedAccountId != 'all' && SelectedDriverId != 'all' && TruckGUId != ''))
                 {
                     addTruckRun = new Truck_Run__c(
                         Store__c = SelectedAccountId,
                         Driver__c = SelectedDriverId,
                         Truck_for_Run__c = TruckGUId
                     );
                 }
                 else if ((TruckGUId != null) && (TruckGUId != ''))
                 {
                     if((SelectedAccountId != null && SelectedAccountId != 'all') && (SelectedDriverId == null || SelectedDriverId == 'all'))
                     {
                         addTruckRun = new Truck_Run__c(
                             Store__c = SelectedAccountId,
                             //Driver__c = SelectedDriverId,
                             Truck_for_Run__c = TruckGUId
                         );
                     }
                     else if((SelectedAccountId == null || SelectedAccountId == 'all') && (SelectedDriverId != null && SelectedDriverId != 'all'))
                     {
                         addTruckRun = new Truck_Run__c(
                             //Store__c = SelectedAccountId,
                             Driver__c = SelectedDriverId,
                             Truck_for_Run__c = TruckGUId
                         );
                     }
                     else
                     {
                         addTruckRun = new Truck_Run__c(
                             Truck_for_Run__c = TruckGUId
                         );
                     }
                 }
                 else 
                 {
                     if((SelectedAccountId != null && SelectedAccountId != 'all') && (SelectedDriverId != null && SelectedDriverId != 'all'))
                     {
                         addTruckRun = new Truck_Run__c(
                             Store__c = SelectedAccountId,
                             Driver__c = SelectedDriverId
                         );
                     }
                     else if((SelectedAccountId != null && SelectedAccountId != 'all') && (SelectedDriverId == null || SelectedDriverId == 'all'))
                     {
                         addTruckRun = new Truck_Run__c(
                             Store__c = SelectedAccountId
                         );
                     }
                     else if((SelectedAccountId == null || SelectedAccountId == 'all') && (SelectedDriverId != null && SelectedDriverId != 'all'))
                     {
                         addTruckRun = new Truck_Run__c(
                             //Store__c = SelectedAccountId,
                             Driver__c = SelectedDriverId
                         );
                     }
                 }

             }
             //generate list for upsert                      
             AddTruckRunList.add(addTruckRun);
             insert AddTruckRunList; 
             newTruckRunId = addTruckRun.Id;
             if(community != 'Yes')
             {
             truckRunURL = System.URL.getSalesforceBaseURL().toExternalForm();
             }
             else{
                 truckRunURL = System.URL.getSalesforceBaseURL().toExternalForm();
             }
             system.debug('ID=' + newTruckRunId);
         }   
         return null;
    } 
    
    public boolean displayPopup {get; set;} 
    public boolean displayError {get; set;}
    public void saveAndClosePopup() {   
        displayPopup = false;    
    } 
    public void closePopup() {        
        displayPopup = false;    
        displayError = false;
    }     
    public void showPopup() {  
        if(SelectedAccountId.equals('all'))
        {
            displayError = true;
        }
        else
        {
            newStore = SelectedAccountId;
            newTruck = SelectedTruckId;
            newDriver = SelectedDriverId;
            displayPopup = true; 
        }
    }
    
    public String newStore {get; set;}
    public String newTruck {get; set;}
    public String newDriver {get; set;}
    public String newAccount {get; set;}
    public String newStartTime {get; set;}
    public String newEndTime {get; set;}
    public String newStartDate {get; set;}
    public String newEndDate {get; set;}
    public String newForecastQuantity {get; set;}
    public String newNotes {get; set;}
     
    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;private set;}
        public String endString {get;private set;}
        public String url {get;set;}
        public String className {get;set;}
        public String eId {get;set;}        
        public String colorCode {get;set;}        
        public String driver {get;set;}        
    }

}