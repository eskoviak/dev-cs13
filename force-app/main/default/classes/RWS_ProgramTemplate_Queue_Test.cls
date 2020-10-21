@isTest
private class RWS_ProgramTemplate_Queue_Test {
    static testMethod void testJob() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);   

        Product2 prod = RWS_TestUtil.createProduct(true);

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

        Pricebook2 customPB = RWS_TestUtil.createCustomPricebook(pr.Id, true);

        PricebookEntry customPrice = RWS_TestUtil.createPricebookEntry(customPB.Id, prod.Id, true);

        List<IA_Feature__c> Iafeature_lst1 = new List<IA_Feature__c>();
        Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Brand',null, 'Footwear', false, false));
        insert Iafeature_lst1;

        List<IA_Feature__c> Iafeature_lst2 = new List<IA_Feature__c>();
        Iafeature_lst2.add(RWS_TestUtil.createIAFeature('Red wing',Iafeature_lst1[0].id, 'Footwear', true, false));
        insert Iafeature_lst2;

        List<Features__c> features_lst1 = new List<Features__c>();
        features_lst1.add(RWS_TestUtil.createFeature('Red wing',Iafeature_lst2[0].id, false));
        insert features_lst1;

        List<Product_Features__c> Product_Features_lst = new List<Product_Features__c>();
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[0].id, prod.id, false));
        insert product_Features_lst;

        List<Filter_Criteria__c> filters = new List<Filter_Criteria__c>();
        Filter_Criteria__c fc = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[0].id, false);
        fc.IA_Feature__c = null;
        fc.Product_Code__c = JSON.serialize(new Set<String>{prod.ProductCode}) + '-FPC-' + JSON.serialize(new Set<String>() );
        fc.Filter_Display__c = 'AND( ABC )';

        Filter_Criteria__c fc2 = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[0].id, false);
        fc2.Filter_Number__c = 0;
        fc2.IA_Feature__c = null;
        fc2.Product_Code__c = JSON.serialize(new Map<String, Decimal>{prod.ProductCode => 40}) + '-FPC-' + JSON.serialize(new Set<String>() );
        fc2.Filter_Display__c = 'Custom List';

        filters.add(fc);
        filters.add(fc2);

        insert filters;

        Test.startTest();
        	System.enqueueJob(new RWS_ProgramTemplate_Queue(pr.Id, pr.Name));
        Test.stopTest();
    }
}