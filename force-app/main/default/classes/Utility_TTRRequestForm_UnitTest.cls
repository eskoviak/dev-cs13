@isTest
private class Utility_TTRRequestForm_UnitTest {

/**
*   {Purpose}  �  Unit Test for Utility_TTRRequestForm
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131203	Andy Boettcher DCS		Created
*   =============================================================================
*/

    static testMethod void testTTRTrigger() {
        
        Map<Id, TTR_Request_Form__c> mapAssert;
        
		// Create Core Data
        Account acct = new Account(Name='Test Account',Store_Ownership_Type__c='Dealer');
        insert acct;
        Account acct2 = new Account(Name='Test Account 2',Store_Ownership_Type__c='Dealer');
        insert acct2;
        APEX_Trigger_Settings__c csAPEX = new APEX_Trigger_Settings__c(Name='manageTTRActiveFlag',IsActive__c=true);
        insert csAPEX;
		
		test.startTest();
		
		// Check for Custom Setting first
        Map<String, Boolean> mapAPEXSettings = new Map<String, Boolean>();
		for(APEX_Trigger_Settings__c ATS : APEX_Trigger_Settings__c.getall().values()) {
			mapAPEXSettings.put(ATS.Name, ATS.IsActive__c);
		}
        System.Assert(mapAPEXSettings.get('manageTTRActiveFlag') != null, 'Custom Setting is not correct!');
		
		// Insert first TTR for Account 1
		TTR_Request_Form__c ttrReq1 = new TTR_Request_Form__c(Account__c=acct.Id,Name='TTRRequest1');
		insert ttrReq1;
		
		mapAssert = new Map<Id, TTR_Request_Form__c>([SELECT Id, Name, Active_Form__c FROM TTR_Request_Form__c]);
		System.Assert(mapAssert.get(ttrReq1.Id).Active_Form__c == true, 'Test 1:  TTR Active Form flag is FALSE and should be TRUE on fresh insert');
		
		// Insert second TTR for Account 1
		TTR_Request_Form__c ttrReq2 = new TTR_Request_Form__c(Account__c=acct.Id,Name='TTRRequest2');
		insert ttrReq2;
		
		mapAssert = new Map<Id, TTR_Request_Form__c>([SELECT Id, Name, Active_Form__c FROM TTR_Request_Form__c]);
		System.Assert(mapAssert.get(ttrReq1.Id).Active_Form__c == false, 'Test 2:  TTR Active Form flag is TRUE and should be FALSE on subsequent record insert');
		System.Assert(mapAssert.get(ttrReq2.Id).Active_Form__c == true, 'Test 2:  TTR Active Form flag is FALSE and should be TRUE on fresh insert with subsequent records');
		
		// Insert first TTR for Account 2 - Account 1 should NOT be affected
		TTR_Request_Form__c ttrReq3 = new TTR_Request_Form__c(Account__c=acct2.Id,Name='TTRRequest3');
		insert ttrReq3;
		
		mapAssert = new Map<Id, TTR_Request_Form__c>([SELECT Id, Name, Active_Form__c FROM TTR_Request_Form__c]);
		System.Assert(mapAssert.get(ttrReq3.Id).Active_Form__c == true, 'Test 3:  TTR Account 2 Active Form flag is FALSE and should be TRUE on fresh insert');
		System.Assert(mapAssert.get(ttrReq1.Id).Active_Form__c == false, 'Test 3:  TTR Account 1 Active Form flag is TRUE and should be FALSE - TTR inserted on Account 2');
		System.Assert(mapAssert.get(ttrReq2.Id).Active_Form__c == true, 'Test 3:  TTR Account 1 Active Form flag is FALSE and should be TRUE - TTR inserted on Account 2');
		
		test.stopTest();
		
		
    }
}