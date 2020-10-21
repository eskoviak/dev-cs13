@isTest
public class TravelCalendar_Controller_Tests {
    private static List<Id> setup() 
    {
        RecordType rM3 = [SELECT Id FROM RecordType WHERE Name = 'M3 Store Parent Account' LIMIT 1];
        RecordType r = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1];
        Account store = new Account(
            Name = 'Red Wing Store', 
            Store_Number__c = '137', 
            M3_Location_City__c = 'Red Wing',
            AccountNumber = '1234567',
            IA_Physical_Location_City__c = 'Red Wing',
            RecordTypeId = rM3.Id,
            Truck_Qty__c = 1
        );
        insert store;
        
        Account a = new Account(
        	Name = 'First Avenue', 
            M3_Location_City__c = 'Minneapolis',
            AccountNumber = '7654321',
            IA_Physical_Location_City__c = 'Minneapolis',
            Type = 'Customer',
            RecordTypeId = r.Id,
            Credit_Limit__c = 5000.00
        );
        insert a;
        
        /*Program__c p = new Program__c(
            Account__c = a.Id,
            Type__c = 'Subsidy',
            Processing_Status__c = 'Completed',
            Publish_Status__c = 'Published',
            Active__c = true,
            Name = 'First Ave Program',
            Servicing_Level__c = 'RWSS+',
            Subsidy_Tax__c = 'TaxedUpToSubsidy',
            Activation_Date__c = Date.newInstance(2018, 1, 18),
            Eligibility_Option__c = 'False',
            Subsidy_Type__c = 'dollar',
            Accessories_Allowed_on_Subsidy__c = 'No',
            Number_of_Pairs_Allowed__c = 500,
            Subsidy_Amount__c = 100.00
        );
        insert p;
        
        a.Active__c = true;
        update a;*/
        
        Contact c = new Contact( 
                  AccountId = store.Id,
                  Firstname = 'Andy',
                  Lastname = 'Hall',
                  Role__c = 'Driver',
                  Email = 'andy.hall@fake.com',
                  RWS_Id__c = 'andhall_' + store.AccountNumber,
                  Entity_ID__c = '1112223',
                  EMS_Login__c = 'andhall',
                  Active__c = true
        );
        insert c;
        
        Truck__c t = new Truck__c(
        	IsActive__c = true,
            Truck_Description__c = '137 Truck 1'
        );
        insert t;
        
        Truck_for_Store__c ts = new Truck_for_Store__c(
        	Store__c = store.Id,
            Truck__c = t.Id
        );
        insert ts;
        
        Truck_Run__c tr = new Truck_Run__c(
        	Forecast_Amount__c = 1000.00, 
            Notes__c = 'It was a good run.', 
            Run_Start_Date__c = Date.newInstance(2018, 1, 18),
            Run_End_Date__c = Date.newInstance(2018, 1, 18),
            Start_Time__c = '12:00 PM',
            End_Time__c = '2:00 PM',
            Run_Start_Time__c = Datetime.newInstance(2018, 1, 18, 12, 0, 0), 
            Run_End_Time__c = Datetime.newInstance(2018, 1, 18, 14, 0, 0), 
            Driver__c = c.Id,
            Rwfb_Account__c = a.Id, 
            Store__c = store.Id
        );
        insert tr;
        
        List<Id> ids = new List<Id>{store.Id, c.Id, t.Id, a.Id, tr.Id};
        return ids;
    }
    
	static TestMethod void constructorTest()
    {
        TravelCalendar_Controller control = new TravelCalendar_Controller();
        System.assertEquals(false, control.includeMyEvents);
        System.assertEquals(false, control.eventColor);
        System.assertEquals(true, control.ShowTruckSection);
    }
    
    static TestMethod void loadAllRunsTest()
    {
        Test.startTest();
        setup();
        Truck_Run__c tr = new Truck_Run__c(
        	Forecast_Amount__c = 1000.00, 
            Notes__c = 'It was a good run.', 
            Run_Start_Date__c = Date.newInstance(2018, 1, 18),
            Run_End_Date__c = Date.newInstance(2018, 1, 18),
            Start_Time__c = '4:00 PM',
            End_Time__c = '6:00 PM'
        );
        insert tr;
        
        TravelCalendar_Controller control = new TravelCalendar_Controller();
        System.assertEquals(null, control.events);
        control.pageLoad();
        System.assertEquals(2, control.events.size());
        Test.stopTest();
    }
    
   static TestMethod void matchPageLoadTest()
   {
        Test.startTest();
        List<Id> ids = setup();
        Truck_Run__c tr = new Truck_Run__c(
        	Forecast_Amount__c = 1000.00, 
            Notes__c = 'It was a good run.', 
            Run_Start_Date__c = Date.newInstance(2018, 1, 18),
            Run_End_Date__c = Date.newInstance(2018, 1, 18),
            Start_Time__c = '4:00 PM',
            End_Time__c = '6:00 PM'
        );
        insert tr;
        TravelCalendar_Controller control = new TravelCalendar_Controller();
        control.SelectedAccountId = ids.get(0);
        control.SelectedDriverId = ids.get(1);
        //control.SelectedTruckId = ids.get(2);
        
        System.assertEquals(null, control.events);
        control.pageLoad();
        System.assertEquals(1, control.events.size());
        Test.stopTest();
   }
    
   static TestMethod void getAccountsTest()
   {
       Test.startTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       System.assertEquals(null, control.AccountTemp);
       List<SelectOption> a = control.getAccounts();
       System.assertEquals(1, control.AccountTemp.size());
       System.assertEquals(2, a.size());
       Test.stopTest();
   }
    
   static TestMethod void getTrucksTest()
   {
       Test.startTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       control.SelectedAccountId = ids.get(0);
       System.assertEquals(null, control.TruckTemp);
       List<SelectOption> t = control.getTrucks();
       System.assertEquals(1, control.TruckTemp.size());
       System.assertEquals(2, t.size());
       Test.stopTest();
   }
    
   static TestMethod void getDriversTest()
   {
       Test.startTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       control.SelectedAccountId = ids.get(0);
       System.assertEquals(null, control.DriverTemp);
       List<SelectOption> d = control.getDrivers();
       System.assertEquals(1, control.DriverTemp.size());
       System.assertEquals(2, d.size());
       Test.stopTest();
   }
    
   static TestMethod void toggleMyEventsTest()
   {
       Test.startTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       control.toggleMyEvents();
       System.assertEquals(true, control.includeMyEvents);
       
       control.toggleMyEvents();
       System.assertEquals(false, control.includeMyEvents);
       Test.stopTest();
   }

   static TestMethod void updateEventExistingTest()
   {
       Test.StartTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       Datetime startDate = Datetime.newInstance(2018, 1, 1, 13, 0, 0);
       Datetime endDate = Datetime.newInstance(2018, 1, 1, 16, 0, 0);
       
       Date sDt = Date.newInstance(2018, 1, 1);
       string sTi = '2:00 PM';
       
        Date eDt = Date.newInstance(2018, 1, 1);
       string eTi = '5:00 PM';
       
       PageReference pageRef = Page.TruckControllerCal;
       pageRef.getParameters().put('eventID', String.valueOf(ids.get(4)));
       pageRef.getParameters().put('startDate', String.valueOf(startDate));
       pageRef.getParameters().put('endDate', String.valueOf(endDate));
             
       Test.setCurrentPage(pageRef);
       control.updateEvent();
       Truck_Run__c updated = [SELECT Run_Start_Time__c, Run_End_Time__c, Run_Start_Date__c, Start_Time__c , Run_End_Date__c, End_Time__c FROM Truck_Run__c WHERE Id = :ids.get(4) LIMIT 1];
       System.assertEquals(updated.Run_Start_Time__c, startDate);
       System.assertEquals(updated.Run_End_Time__c, endDate);
       System.assertEquals(updated.Run_Start_Date__c, sDt);
       System.assertEquals(updated.Start_Time__c, sTi);
       System.assertEquals(updated.Run_End_Date__c, eDt);
       System.assertEquals(updated.End_Time__c, eTi);
 	   Test.StopTest();     
   }
    
   static TestMethod void updateEventNewTest()
   {
       Test.StartTest();
       List<Id> ids = setup();
       TravelCalendar_Controller control = new TravelCalendar_Controller();
       Datetime startDate = Datetime.newInstance(2018, 1, 1, 13, 0, 0);
       Datetime endDate = Datetime.newInstance(2018, 1, 1, 16, 0, 0);
       
       Date sDt = Date.newInstance(2018, 1, 1);
       string sTi = '2:00 PM';
       
        Date eDt = Date.newInstance(2018, 1, 1);
       string eTi = '5:00 PM';
       
       PageReference pageRef = Page.TruckControllerCal;
       pageRef.getParameters().put('eventId', 'false');
       pageRef.getParameters().put('startDate', String.valueOf(startDate));
       pageRef.getParameters().put('endDate', String.valueOf(endDate));
       control.SelectedAccountId = ids.get(0);
       control.SelectedDriverId = ids.get(1);
       
       Test.setCurrentPage(pageRef);
       control.updateEvent();
       Truck_Run__c updated = [SELECT Run_Start_Time__c, Run_End_Time__c, Run_Start_Date__c, Start_Time__c , Run_End_Date__c, End_Time__c, Store__r.Id, Driver__r.Id FROM Truck_Run__c WHERE Id = :control.AddTruckRunList.get(0).Id LIMIT 1];
       System.assertEquals(updated.Run_Start_Time__c, startDate);
       startDate = startDate.addHours(4);
       System.assertEquals(updated.Run_End_Time__c, startDate);       
       System.assertEquals(updated.Run_Start_Date__c, sDt);
       System.assertEquals(updated.Start_Time__c, sTi);
       System.assertEquals(updated.Run_End_Date__c, eDt);
       System.assertEquals(updated.End_Time__c, eTi);
       System.assertEquals(ids.get(0), updated.Store__r.Id);
       System.assertEquals(ids.get(1), updated.Driver__r.Id);
 	   Test.StopTest();     
   }
}