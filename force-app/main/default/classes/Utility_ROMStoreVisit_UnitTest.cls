@isTest
private class Utility_ROMStoreVisit_UnitTest {
	
	@isTest static void testTrigger() {
		
		// Set Test Data
		APEX_Trigger_Settings__c csAPEX = new APEX_Trigger_Settings__c(Name='ROMReportRollupToAccount',IsActive__c=true);
        insert csAPEX;

		Account acct = new Account(Name='Test Account');
		insert acct;

		Contact cont = new Contact(AccountId=acct.Id, LastName='Test', Email='test@me.com');
		insert cont;

		test.startTest();

		insert new ROM_Store_Visit_Report__c(Account__c=acct.Id, Store_Manager_Name__c=cont.Id);
		insert new ROM_Store_Visit_Report__c(Account__c=acct.Id, Store_Manager_Name__c=cont.Id);

		test.stopTest();

		Account acctVerify = [SELECT Id, ROM_Last_Visit__c FROM Account WHERE Id = :acct.Id];

		System.Assert(acctVerify.ROM_Last_Visit__c != null, 'Trigger did not fire right!');

	}
	
}