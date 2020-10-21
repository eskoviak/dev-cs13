@isTest
private class RWS_FutureBatchJob_Test {
    static testMethod void testBatch() {
         Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

		Future_Price__c fpb = RWS_TestUtil.createFuturePrice(prod.Id, true);

		Test.startTest();
			RWS_FutureBatchJob fbj = new RWS_FutureBatchJob();
			fbj.execute(null);
		Test.stopTest();

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