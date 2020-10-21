@isTest
private class RWS_PublishPricebookController_Test {
    static testMethod void testTestController() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

		Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);

		PageReference p = Page.RWS_PublishPricebook;
		p.getParameters().put('id', customPB.Id);

		Test.setCurrentPageReference(p);

		RWS_PublishPricebookController ppc = new RWS_PublishPricebookController();
		ppc.publishPricebookEntries();

		List<Publish_PriceBook_Entry__c> ppbs = [
    		select Id, Discount__c, Publish_Status__c
    		from Publish_PriceBook_Entry__c 
    		where Publish_PriceBook__c = :customPB.Id
    		//and Pricebook_Entry_ID__c = :customPrice.Id
    	];

		System.assertEquals(1, ppbs.size(), 'Issue with public price book entry');
		System.assertEquals(customPB.Discount__c, ppbs[0].Discount__c, 'Incorrect discount');
    }
}