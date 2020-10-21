public class TravelCalendars_Controller {
    
    private final Account acct;
    public TravelCalendars_Controller(ApexPages.StandardController stdcontroller) {
     this.acct = (Account)stdController.getRecord();
     system.debug('Store Id in Cal Contr:' + this.acct);
     pageload();
    }
    
    public Boolean includeMyEvents {get;set;}
    public list<calEvent> events {get;set;}

    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';

    //constructor
   /* public TravelCalendars_Controller() {

        //Default showing my events to on
		system.debug('loading');
        includeMyEvents = true;

    }*/
    public PageReference pageLoad() {
        events = new list<calEvent>();
 		system.debug('Pageload');
        //Get My Travel

        for(Truck_Run__c mytruck : [select Id, Forecast_Amount__c , Notes__c, Run_Start_Time__c, Run_End_Time__c , Driver__r.Name, Rwfb_Account__r.Name,Truck_for_Run__r.Store__r.Store_Number__c from Truck_Run__c ])//where IsDeleted  = 'Approved' and OwnerID = :UserInfo.getUserId() ])
        {
            TimeZone tz = UserInfo.getTimeZone();
            if(mytruck.Run_Start_Time__c != null)
            {
            DateTime startDT = mytruck.Run_Start_Time__c.AddSeconds(tz.getOffset(mytruck.Run_Start_Time__c)/1000);
            DateTime endDT = mytruck.Run_End_Time__c.AddSeconds(tz.getOffset(mytruck.Run_End_Time__c)/1000);
            DateTime nowDT = DateTime.now().AddSeconds(tz.getOffset(DateTime.now())/1000);
            string DriName = mytruck.Driver__r.Name;
            string AcctName = mytruck.Rwfb_Account__r.Name;
			string StoreNumber = mytruck.Truck_for_Run__r.Store__r.Store_Number__c ;
            string notes = '';
            if (mytruck.Notes__c != null)
            {
                notes = '; Notes - ' + mytruck.Notes__c;
             } 
            calEvent mytravEvent = new calEvent();             
            mytravEvent.title = 'Trip: Account - '+ AcctName + '; Driver - ' + DriName + '; Store# - ' + StoreNumber + notes; //+ ' ' + myTrav.Owner.FirstName+ ' ' + myTrav.Owner.LastName;
            mytravEvent.allDay = false;
            mytravEvent.startString = startDT.format(dtFormat);
            mytravEvent.endString = endDT.format(dtFormat);
            mytravEvent.url = '/' + mytruck.Id;
            
            system.debug(startDt + '- ' + nowDT + '- ' +  endDT);
            if(startDt < nowDT && endDT < nowDT)
            {
            	mytravEvent.className = 'event-mytravel';
            }
            else if ((startDt == nowDT || startDt < nowDT) && endDT >= nowDT)
            {
                mytravEvent.className = 'event-sbtravel';
            }
            else if(startDt > nowDT)
            {
                mytravEvent.className = 'event-trtravel';
            }
            //mytravEvent.className.style = '.event-mytravel {background:#00447b;border-color:#00447b;}';
            events.add(mytravEvent);
            }
        }
         //Get School Bus Travel

 /*       for(Travel__c sbtrav : [select Id, Owner.FirstName, Owner.LastName, Name, Departure_Date__c, Return_Date__c, Owner_Territory__c from Travel__c where Approval_Status__c = 'Approved' and  Owner_Division__c = 'School Bus' and OwnerID != :UserInfo.getUserId() ]){

            DateTime startDT = sbTrav.Departure_Date__c;

            DateTime endDT = sbTrav.Return_Date__c;

            calEvent sbtravEvent = new calEvent();

            

            sbtravEvent.title = 'Trip:'+ ' ' + sbTrav.Name+ ' ' + sbTrav.Owner.FirstName+ ' ' + sbTrav.Owner.LastName;

            sbtravEvent.allDay = true;

            sbtravEvent.startString = startDT.format(dtFormat);

            sbtravEvent.endString = endDT.format(dtFormat);

            sbtravEvent.url = '/' + sbTrav.Id;

            sbtravEvent.className = 'event-sbtravel';

            events.add(sbtravEvent);

        }
 
         //Get Transit Travel

        for(Travel__c trtrav : [select Id, Owner.FirstName, Owner.LastName, Name, Departure_Date__c, Return_Date__c, Owner_Territory__c from Travel__c where Approval_Status__c = 'Approved' and  Owner_Division__c = 'Transit' and  OwnerID != :UserInfo.getUserId() ]){

            DateTime startDT = trTrav.Departure_Date__c;

            DateTime endDT = trTrav.Return_Date__c;

            calEvent trtravEvent = new calEvent();

            

            trtravEvent.title = 'Trip:'+ ' ' + trTrav.Name+ ' ' + trTrav.Owner.FirstName+ ' ' + trTrav.Owner.LastName;

            trtravEvent.allDay = true;

            trtravEvent.startString = startDT.format(dtFormat);

            trtravEvent.endString = endDT.format(dtFormat);

            trtravEvent.url = '/' + trTrav.Id;

            trtravEvent.className = 'event-trtravel';

            events.add(trtravEvent);

        }
        



//Get Other Travel

        for(Travel__c ottrav : [select Id, Owner.FirstName, Owner.LastName, Name, Departure_Date__c, Return_Date__c, Owner_Territory__c from Travel__c where Approval_Status__c = 'Approved' and  Owner_Division__c != 'School Bus' and  Owner_Division__c != 'Transit'and OwnerID != :UserInfo.getUserId() ]){

            DateTime startDT = otTrav.Departure_Date__c;

            DateTime endDT = otTrav.Return_Date__c;

            calEvent ottravEvent = new calEvent();

            

            ottravEvent.title = 'Trip:'+ ' ' + otTrav.Name+ ' ' + otTrav.Owner.FirstName+ ' ' + otTrav.Owner.LastName;

            ottravEvent.allDay = true;

            ottravEvent.startString = startDT.format(dtFormat);

            ottravEvent.endString = endDT.format(dtFormat);

            ottravEvent.url = '/' + otTrav.Id;

            ottravEvent.className = 'event-ottravel';

            events.add(ottravEvent);

        }

//Get my Events if we have selected the correct option

        if(includeMyEvents){

            for(Event evnt: [select Id, Subject, isAllDayEvent, StartDateTime, EndDateTime from Event where OwnerID = :UserInfo.getUserId()]){

                DateTime startDT = evnt.StartDateTime;

                DateTime endDT = evnt.EndDateTime;

                calEvent myEvent = new calEvent();

                

                myEvent.title = evnt.Subject;

                myEvent.allDay = evnt.isAllDayEvent;

                myEvent.startString = startDT.format(dtFormat);

                myEvent.endString = endDT.format(dtFormat);

                myEvent.url = '/' + evnt.Id;

                myEvent.className = 'event-personal';

                events.add(myEvent);

            }

        }*/

        return null;

    }

    public PageReference toggleMyEvents() {
        if(includeMyEvents){
            includeMyEvents = false;
        }
        else{
            includeMyEvents = true;
        }

        pageload();

        return null;

    }


    //Class to hold calendar event data

    public class calEvent{

        public String title {get;set;}

        public Boolean allDay {get;set;}

        public String startString {get;private set;}

        public String endString {get;private set;}

        public String url {get;set;}

        public String className {get;set;}
    }

}