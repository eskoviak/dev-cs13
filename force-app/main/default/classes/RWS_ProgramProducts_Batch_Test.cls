@isTest
private class RWS_ProgramProducts_Batch_Test {
    static testMethod void testBatch() {
       Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);   

        Product2 prod = RWS_TestUtil.createProduct(true);
        List<Product_Style__c> styles = [select Id from Product_Style__c];

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

        Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

        Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);

        List<IA_Feature__c> Iafeature_lst1 = new List<IA_Feature__c>();
        Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Brand',null, 'Footwear', false, false));
        insert Iafeature_lst1;

        List<IA_Feature__c> Iafeature_lst2 = new List<IA_Feature__c>();
        Iafeature_lst2.add(RWS_TestUtil.createIAFeature('Red wing',Iafeature_lst1[0].id, 'Footwear', true, false));
        insert Iafeature_lst2;

        List<Features__c> features_lst1 = new List<Features__c>();
        features_lst1.add(RWS_TestUtil.createFeature('Red wing',Iafeature_lst2[0].id, false));
        insert features_lst1;

        List<Product_Style_Features__c> Product_Features_lst = new List<Product_Style_Features__c>();
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[0].id, styles[0].id, false));

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



        insert new Program_Scheduler__c(Program__c = pr.Id, 
            Program_Template_Name__c = pr.Name, 
            Processed__c = false);

        Test.startTest();
        	Database.executeBatch(new RWS_ProgramProducts_Batch(), 1);
        Test.stopTest(); 
    }
}