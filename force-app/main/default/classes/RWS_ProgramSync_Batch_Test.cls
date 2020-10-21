@isTest
private class RWS_ProgramSync_Batch_Test {
    static testMethod void testBatch() {

    	Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

        Id pricebookId = Test.getStandardPricebookId();

        List<Product2> prod_lst = new List<Product2>();
        prod_lst.add(RWS_TestUtil.createProductwithDetail('Footwear Prod 1','Footwear',false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('Accessories Prod 1','Accessories Apparel and Gear', false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('Workwear Prod 1','Workwear', false));
        prod_lst[0].Style_Number_Unique_ID__c = '0010';
        prod_lst[1].Style_Number_Unique_ID__c = '0012';
        prod_lst[2].Style_Number_Unique_ID__c = '0011';
        insert prod_lst;

        List<Product_Style__c> styles = [select Id from Product_Style__c];

        List<PriceBookEntry> pricebookentry_lst = new List<Pricebookentry>();
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[0].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[1].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[2].Id, false));
        insert pricebookentry_lst;

        List<IA_Feature__c> Iafeature_lst1 = new List<IA_Feature__c>();
        Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Brand',null, 'Footwear', false, false));
        Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Color',null, 'Accessories Apparel and Gear', false, false));
        Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Country Of Origin',null, 'Workwear', false, false));
        insert Iafeature_lst1;

        List<IA_Feature__c> Iafeature_lst2 = new List<IA_Feature__c>();
        Iafeature_lst2.add(RWS_TestUtil.createIAFeature('Red wing',Iafeature_lst1[0].id, 'Footwear', true, false));
        Iafeature_lst2.add(RWS_TestUtil.createIAFeature('Red',Iafeature_lst1[1].id, 'Accessories Apparel and Gear', true, false));
        Iafeature_lst2.add(RWS_TestUtil.createIAFeature('USA',Iafeature_lst1[2].id, 'Workwear', true, false));
        insert Iafeature_lst2;

        List<Features__c> features_lst1 = new List<Features__c>();
        features_lst1.add(RWS_TestUtil.createFeature('Red wing',Iafeature_lst2[0].id, false));
        features_lst1.add(RWS_TestUtil.createFeature('Red',Iafeature_lst2[0].id, false));
        features_lst1.add(RWS_TestUtil.createFeature('USA',Iafeature_lst2[0].id, false));
        insert features_lst1;

        List<Product_Style_Features__c> Product_Features_lst = new List<Product_Style_Features__c>();
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[0].id, styles[0].id, false));
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[1].id, styles[1].id, false));
        
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[2].id, styles[2].id, false));
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[1].id, styles[2].id, false));
        insert product_Features_lst;

		Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

        Filter_Criteria__c fc = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[0].id, false);
        fc.Filter_Number__c = 1;
        fc.Filter_BE_Details__c = JSON.serialize(new Map<String, String>{'Name = \'Red wing\'' => ' AND '}) + 'SEPARATOR[]';

        Filter_Criteria__c fc2 = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[1].id, false);
        fc2.Filter_Number__c = 2;
        fc2.Filter_BE_Details__c = JSON.serialize(new Map<String, String>{'Name = \'Red\'' => ' AND '}) + 'SEPARATOR[]';

        Filter_Criteria__c fc3 = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[2].id, false);
        fc3.Filter_Number__c = 3;
        fc3.Filter_BE_Details__c = JSON.serialize(new Map<String, String>{'Name = \'USA\'' => ' AND '}) + 'SEPARATOR[]';

        Filter_Criteria__c fc4 = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[2].id, false);
        fc4.Filter_Number__c = 4;
        fc4.Filter_BE_Details__c = JSON.serialize(new Map<String, String>{'Name = \'USA\' AND Name = \'Red\'' => ' AND '}) + 'SEPARATOR[]';
        fc4.Discount__c = 20;

        insert new List<Filter_Criteria__c>{fc, fc2, fc3, fc4};

		Test.startTest();
			RWS_ProgramSync_Batch job = new RWS_ProgramSync_Batch();
			job.execute(null);
		Test.stopTest();
        
    }
}