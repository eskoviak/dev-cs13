@isTest
private class RWS_UseTemplateController_Test {
    static testMethod void testController() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);   
        pr.Processing_Status__c = 'Completed';
        insert pr;

        Product2 prod = RWS_TestUtil.createProduct(true);
        Product2 prod2 = RWS_TestUtil.createProduct('2', true);

        Id pricebookId = Test.getStandardPricebookId(); 

        RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

        RWS_TestUtil.createPricebookEntry(pricebookId, prod2.Id, true);

        Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

        Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, false);
        customPrice.Fixed_Price__c = true;
        customPrice.Filter_Number__c = 0;
        insert customPrice;

        Publish_PriceBook_Entry__c customPrice2 = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod2.Id, false);
        customPrice2.Filter_Number__c = 1;
        insert customPrice2;

        List<Filter_Criteria__c> filters = new List<Filter_Criteria__c>();
        filters.add(RWS_TestUtil.createFilterCriteria(pr.Id, null, false));
        insert filters;

        Test.startTest();

            PageReference pg = Page.RWS_UseTemplate;
            pg.getParameters().put('id', pr.Id);
            Test.setCurrentPageReference(pg);

            RWS_UseTemplateController psc = new RWS_UseTemplateController();
            psc.createClone();

        Test.stopTest();
    }
}