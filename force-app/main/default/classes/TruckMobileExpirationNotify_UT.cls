@isTest
private class TruckMobileExpirationNotify_UT {

/**
*   {Purpose}  �  Unit Test for TruckMobileExpirationNotify, some of Util, and schedule_ContractExpiration
*                 
*   {Function}  � Unit Test
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131008  	Andy Boettcher DCS		Created
*   =============================================================================
*/

	static testMethod void testNotificationScheduler() {
		
		test.startTest();
		
		// Create AENs
		createAENs();
		
		// Execute Scheduler
		TruckMobileExpirationNotify.scheduleJobs();
		
		test.stopTest();
		
	}

    static testMethod void testNotifications() {
        
        // Create Profile and User
        Profile prf = [SELECT Id FROM Profile WHERE Name='System Administrator'];
	    User usr = new User(Alias = 'RWSTEST', Email='RWSTEST@redwingshoes.local', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = prf.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='RWSTEST@redwingshoes.com.local');
		insert usr;
        
        // Create Core Data
        Account acct = new Account(Name='Test Account',Store_Ownership_Type__c='Dealer',Dealer_Next_Renewal_Date__c=System.Now().addDays(100).Date());
        insert acct;
        Account acct2 = new Account(Name='Test Account 2',Store_Ownership_Type__c='Dealer',Dealer_Next_Renewal_Date__c=System.Now().addDays(30).Date());
        insert acct2;
        
        // Create Account Team
        List<AccountTeamMember> lstATMs = new List<AccountTeamMember>();
        lstATMs.add(new AccountTeamMember(AccountId = acct.Id,TeamMemberRole = 'Sales Rep',UserId = usr.Id));
        lstATMs.add(new AccountTeamMember(AccountId = acct.Id,TeamMemberRole = 'Region Director',UserId = usr.Id));
        lstATMs.add(new AccountTeamMember(AccountId = acct2.Id,TeamMemberRole = 'Sales Rep',UserId = usr.Id));
        lstATMs.add(new AccountTeamMember(AccountId = acct2.Id,TeamMemberRole = 'Region Director',UserId = usr.Id));
        insert lstATMs;
        
        // Create Truck
        Truck__c trk = new Truck__c();
        trk.Name = 'Test TRUCK!';
        trk.Mobile_Agreement_Expiration_Date__c = System.Now().addDays(30).Date();
        insert trk;
        Truck__c trk2 = new Truck__c();
        trk2.Name = 'Test TRUCK2!';
        trk2.Mobile_Agreement_Expiration_Date__c = System.Now().addDays(30).Date();
        insert trk2;
        
        Truck_for_Store__c tfsLink = new Truck_for_Store__c(Truck__c=trk.Id,Store__c=acct.Id);
        insert tfsLink;
        Truck_for_Store__c tfsLink2 = new Truck_for_Store__c(Truck__c=trk2.Id,Store__c=acct2.Id);
        insert tfsLink2;
        
		/******************************
		** START TEST
		******************************/
        
		test.startTest();
		
		Integer intAENs = createAENs();
		
		List<AutomatedEmailNotifications__c> lstAENs = AutomatedEmailNotifications__c.getAll().values();
		System.Assert(lstAENs.size() == intAENs, 'Custom Settings were not inserted properly, check the Test Class *createAENs*');
		
		// NEGATIVE TEST - BAD NAME
		TruckMobileExpirationNotify.processExpirations('BAD TEST');
		
		// POSITIVE TEST - LOOP THROUGH AENS
		for(AutomatedEmailNotifications__c aen : lstAENs) {
			if(aen.IsActive__c) {
				TruckMobileExpirationNotify.processExpirations(aen.Name);
			}
		}
		
		test.stopTest();
		
		/******************************
		** STOP TEST
		******************************/
		
    }
    
    static Integer createAENs() {  	
    	
    	List<AutomatedEmailNotifications__c> lstAENs = new List<AutomatedEmailNotifications__c>();
        
        AutomatedEmailNotifications__c aenMobile120 = new AutomatedEmailNotifications__c();
        aenMobile120.Name = '120DayMobileExpiration';
        aenMobile120.Account_Types__c = 'Dealer|Branded';
        aenMobile120.IsActive__c = true;
        aenMobile120.Email_Template_ID__c = '00XA0000000xewR';
        aenMobile120.Expiration_Field_API_Name__c = 'Truck__r.Mobile_Agreement_Expiration_Date__c';
        aenMobile120.Expiration_Sent__c = false;
        aenMobile120.Expiration_Sent_API_Name__c = 'Truck__r.IsExpirationEmailSent__c';
        aenMobile120.OrgWide_Email_Id__c = '';
        aenMobile120.Team_Member_Roles__c = 'Region Director|Industrial Sales Manager|Retail Operations Manager|Sales Rep';
        aenMobile120.Timeframe__c = 120;
        aenMobile120.Timeframe_Criteria__c = '<=';
        lstAENs.add(aenMobile120);
        
        AutomatedEmailNotifications__c aenAccount120 = new AutomatedEmailNotifications__c();
        aenAccount120.Name = 'AccountNextRenewalDate';
        aenAccount120.Account_Types__c = 'Dealer|Branded';
        aenAccount120.IsActive__c = true;
        aenAccount120.Email_Template_ID__c = '00XA0000000xewR';
        aenAccount120.Expiration_Field_API_Name__c = 'Store__r.Dealer_Next_Renewal_Date__c';
        aenAccount120.Expiration_Sent__c = false;
        aenAccount120.Expiration_Sent_API_Name__c = 'Store__r.IsDealerExpirationEmailSent__c';
        aenAccount120.OrgWide_Email_Id__c = '';
        aenAccount120.Team_Member_Roles__c = 'Region Director|Industrial Sales Manager|Retail Operations Manager|Sales Rep';
        aenAccount120.Timeframe__c = 120;
        aenAccount120.Timeframe_Criteria__c = '<=';
        lstAENs.add(aenAccount120);

        insert lstAENs;
        return lstAENs.size();
    	
    }
}