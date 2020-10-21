@isTest
private class RWS_ProgramPublishProducts_Queue_Test {
    static testMethod void testQueueableApex() {
    	Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
    	Account acc = RWS_TestUtil.createAccount(rtId, true);
        Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);   
        pr.Processing_Status__c = 'Completed';
        insert pr;

        Product2 prod = RWS_TestUtil.createProduct(true);

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

        Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

        Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);

        Test.startTest();
        	System.enqueueJob(new RWS_ProgramPublishProducts_Queue(customPb.Id, customPb.Id, new Set<Id>{prod.Id}));
        Test.stopTest();
    }
}