@isTest
private class RWS_PriceUpdateJob_Test {
    static testMethod void testBatch() {

    	Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

		Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, false);
		customPrice.List_Price__c = 72;
		customPrice.Discount__c = 20;
		insert customPrice;

		Test.startTest();
			RWS_PriceUpdateJob job = new RWS_PriceUpdateJob();
			job.execute(null);
		Test.stopTest();

		System.assertEquals(80, [select Id, List_Price__c from Publish_PriceBook_Entry__c where Id = :customPrice.Id limit 1].List_Price__c, 'Invalid Unit Price');

    }
}