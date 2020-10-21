@isTest
private class RWS_UpdateStandardPricebook_Test {
    static testMethod void testController() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Future_Price__c fpb = RWS_TestUtil.createFuturePrice(prod.Id, true);

		PageReference p = Page.RWS_UpdateStandardPricebook;
		p.getParameters().put('id', fpb.Id);

		Test.setCurrentPageReference(p);

		RWS_UpdateStandardPricebookController ppc = new RWS_UpdateStandardPricebookController();
		ppc.updateStandardPricebook();

		standardPrice = [
    		select Id, UnitPrice
    		from PricebookEntry
    		where Pricebook2Id = :pricebookId
    		and IsActive = true
    		and Product2Id = :prod.Id
    	];

		System.assertEquals(1000, standardPrice.UnitPrice, 'Invalid pricebook unit price');
    }
}