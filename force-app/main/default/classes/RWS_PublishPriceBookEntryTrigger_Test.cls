@isTest
private class RWS_PublishPriceBookEntryTrigger_Test {
    static testMethod void testTrigger() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);
    	pr.Publish_Status__c = 'Published';
    	insert pr;

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

		Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);

		Publish_PriceBook__c pp = [SELECT Publish_Status__c, Published_Date__c /*, Price_Book__c*/ FROM Publish_PriceBook__c /* where Price_Book__c = :customPB.Id */limit 1];
		pp.Publish_Status__c = 'Published';
		update pp;


		Publish_PriceBook_Entry__c ppb2 = new Publish_PriceBook_Entry__c();
		ppb2.Discount__c = customPB.Discount__c;
		ppb2.Publish_Status__c = '';
		//ppb2.Price_Book__c = customPB.Id;
		ppb2.Publish_PriceBook__c = customPB.Id;

		Test.startTest();
			insert ppb2;

			ppb2.Publish_Status__c = 'Published';
			ppb2.Published_Date__c = date.today();

			update ppb2;

			delete ppb2;

			undelete ppb2;
		Test.stopTest();

    }
}