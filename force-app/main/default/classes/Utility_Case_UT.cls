/**
*   {Purpose}  �  Coverage for TriggerController_Case
*
*	{Code Covered}	- TriggerController_Case
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20140708  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class Utility_Case_UT {
	
	@isTest static void testController() {
		
		// Prep Test Data
		Profile p = [select id from profile where name='Standard User']; 
        User uTest = new User(alias = 'rwstestu', email='standarduser@redwingshoes-test.com', 
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
			localesidkey='en_US', profileid = p.Id, 
			timezonesidkey='America/Los_Angeles', username='standarduserrwstest@redwingshoes-test.com');
       	insert uTest;

		APEX_Trigger_Settings__c apexSetting = new APEX_Trigger_Settings__c(Name='escalateCustomerComplaintToROM', IsActive__c=true);
		insert apexSetting;

		Account acct = new Account(Name='Test Account');
		insert acct;

		AccountTeamMember atm = new AccountTeamMember();
		atm.AccountId=acct.Id;
		atm.TeamMemberRole='Retail Operations Manager';
		atm.UserId = uTest.Id;
		insert atm;

		test.startTest();

		Case cseRoot = new Case(AccountId=acct.Id,OwnerId=UserInfo.getUserId());
		cseRoot.Subject='Test Case';
		cseRoot.Type='Consumer Complaint';
		insert cseRoot;

		Case cseRootPositive = [SELECT OwnerId, IsROMEscalation__c FROM Case LIMIT 1];

		test.stopTest();

		System.Assert(cseRootPositive.OwnerId == uTest.Id, 'Owner was not reassigned properly!');
		System.Assert(cseRootPositive.IsROMEscalation__c == true, 'Assignment Flag was not assigned properly!');

	}
	
}