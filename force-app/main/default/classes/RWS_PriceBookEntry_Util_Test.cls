@isTest
private class RWS_PriceBookEntry_Util_Test {
    static testMethod void testUtil() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);
        
		Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);
        
		RWS_PriceBookEntry_Util.createPublicPriceBookEntries(new List<Publish_PriceBook_Entry__c>{customPrice});

		List<Publish_PriceBook_Entry__c> ppbes = [
    		select Id, Discount__c, Publish_Status__c
    		from Publish_PriceBook_Entry__c 
    		where Publish_PriceBook__c = :customPB.Id
    	];

		System.assertEquals(1, ppbes.size(), 'Issue with public price book entry');
		System.assertEquals(customPB.Discount__c, ppbes[0].Discount__c, 'Incorrect discount');
        

    }
}