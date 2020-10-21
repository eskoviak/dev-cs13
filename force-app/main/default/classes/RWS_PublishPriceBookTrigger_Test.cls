@isTest
private class RWS_PublishPriceBookTrigger_Test {
    static testMethod void testTrigger() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

		Publish_PriceBook__c ppb = new Publish_PriceBook__c();
		ppb.Name = customPB.Name;
		ppb.Discount__c = customPB.Discount__c;
		ppb.Publish_Status__c = 'Failed';
		//ppb.Price_Book__c = customPB.Id;
		insert ppb;

		Publish_PriceBook__c ppb2 = new Publish_PriceBook__c();
		ppb2.Name = customPB.Name;
		ppb2.Discount__c = customPB.Discount__c;
		ppb2.Publish_Status__c = 'ReadyToPublish';
		//ppb2.Price_Book__c = customPB.Id;
		insert ppb2;

		ppb2.Publish_Status__c = 'Failed';
		update ppb2;
    }
}