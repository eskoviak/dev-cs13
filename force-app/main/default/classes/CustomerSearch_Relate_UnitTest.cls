/**
*   {Purpose}  �  TODO:  Provide Purpose
*
*	{Code Covered}	- Note the triggers/classes that this test covers
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20141114  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
private class CustomerSearch_Relate_UnitTest {
	
	@isTest static void testController() {
		
		EndPoints__c csEndpoint = new EndPoints__c(Name='RelateSearch', EndPoint__c='https://relateservices.tst.redwingshoes.com/soap/RWS/v1_0/CustomerServices');
		insert csEndpoint;

		test.startTest();

		// Constructor
		PageReference prTest = Page.CustomerSearch_Relate;
		prTest.getParameters().put('fn', 'test');

		Test.setCurrentPage(prTest);
		CustomerSearch_Relate_Controller scRelate = new CustomerSearch_Relate_Controller();
		scRelate.clsCriteria.strChosenCustomerId = '64725';

		scRelate.retrieveCustomerTransactionHistory();

		// Post callout, processing results
		scRelate.findSalesforceContacts();

		// Create new SFDC Contact
		scRelate.createNewContact();

		// Update existing contact
		Account acct = [SELECT Id FROM Account LIMIT 1];
		scRelate.idSFDCIdUpdate = acct.Id;
		scRelate.updateExistingContact();



	}
	
}