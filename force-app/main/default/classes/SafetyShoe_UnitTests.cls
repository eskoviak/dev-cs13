/**
*   {Purpose}  �  Provides coverage for Safety Shoe Participant Searching
*
*	{Code Covered}	- SafetyShoeSearchController / SafetyShoeSearch
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20141116  	Andy Boettcher DCS		Created
*   20151119	James Loghry DCS 		Updated to support cities searches
*   20160902    James Loghry DCS        Updated to support Store Locator Refactoring
*   =============================================================================
*/
@isTest
private class SafetyShoe_UnitTests {

	static testmethod void testController() {
		List<Account> accts = new List<Account>{
			new Account(
				Name='Test Account Source'
				,Active_Store__c = true
				,National_Account_Participant__c = true
				,Latitude__c = 44.72448
				,Longitude__c = -93.09591
				,Store_Ownership_Type__c = 'Branded'
			),
			new Account(
				Name='Alaska'
				,Active_Store__c = true
				,National_Account_Participant__c = true
				,Latitude__c = 1
				,Longitude__c = 1
				,Store_Ownership_Type__c = 'Branded'
			)
		};
		insert accts;

		List<ZipCodeLatAndLong__c> lstZipInsert = new List<ZipCodeLatAndLong__c>{
			new ZipCodeLatAndLong__c(
				Name = '55068'
				,Latitude__c = '44.72448'
				,Longitude__c = '-93.09591'
				,City__c = 'San Andreas'
				,State__c = 'CA'
			),
			new ZipCodeLatAndLong__c(
				Name = '00000'
				,Latitude__c = '0'
				,Longitude__c = '0'
				,City__c = 'Arctic Circle City'
				,State__c = 'AK'
			)
		};
		insert lstZipInsert;

		Test.startTest();

		// Empty Constructor
		SafetyShoeSearchController sssc = new SafetyShoeSearchController();
		sssc.radius = 10;

		SafetyShoeSearchController.ZipcodeInfoWrapper result1 = 
			SafetyShoeSearchController.getZipcodeInformation(
				new List<String>{'55068'}
				,'zipcode'
				,100
			);

		SafetyShoeSearchController.ZipcodeInfoWrapper result2 = 
			SafetyShoeSearchController.getZipcodeInformation(
				new List<String>{'Arctic Circle City,AK'}
				,'city'
				,100
			);
		Test.stopTest();

		System.assertEquals(1,result1.zipResults.size());
		System.assertEquals(2,result1.accountResults.size());
		System.assertEquals(1,result2.zipResults.size());
		System.assertEquals(2,result2.accountResults.size());
	}
}