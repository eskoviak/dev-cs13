@isTest
private class RWS_Production_Selection_Controller_Test {

    @TestSetup
    static void setupData() { 
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        Account acc = RWS_TestUtil.createAccount(rtId, true);
        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);
        Id pricebookId = Test.getStandardPricebookId();

        List<Product2> prod_lst = new List<Product2>();
        Product2 fw1 = RWS_TestUtil.createProductwithDetail('Footwear Prod 1','Footwear',false);
        fw1.ProductCode = '0001';
        fw1.Item_Status_Code__c = '20';
        fw1.Item_Status__c = 'Active';

        Product2 fw2 = RWS_TestUtil.createProductwithDetail('Footwear Prod 1','Footwear',false);
        fw2.ProductCode = '0001';
        fw2.Item_Status_Code__c = '80';
        fw2.Item_Status__c = 'Active';

        prod_lst.add(fw1);
        prod_lst.add(fw2);

        prod_lst.add(RWS_TestUtil.createProductwithDetail('Accessories Prod 1','Accessories Apparel and Gear', false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('Workwear Prod 1','Workwear', false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('OL Prod 1','Outside Lines', false));
        insert prod_lst;

        //List<Product_Style__c> styles = [select Id from Product_Style__c];

        List<PriceBookEntry> pricebookentry_lst = new List<Pricebookentry>();
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[0].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[1].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[2].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[3].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[4].Id, false));
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

        List<IA_Feature__c> Iafeature_lst3 = new List<IA_Feature__c>();
        Iafeature_lst3.add(RWS_TestUtil.createIAFeature('Red wing 1',Iafeature_lst2[0].id, 'Footwear', true, false));
        Iafeature_lst3.add(RWS_TestUtil.createIAFeature('Dark Red',Iafeature_lst2[1].id, 'Accessories Apparel and Gear', true, false));
        Iafeature_lst3.add(RWS_TestUtil.createIAFeature('New York',Iafeature_lst2[2].id, 'Workwear', true, false));
        insert Iafeature_lst3;

        List<Features__c> features_lst1 = new List<Features__c>();
        features_lst1.add(RWS_TestUtil.createFeature('Red wing',Iafeature_lst2[0].id, false));
        features_lst1.add(RWS_TestUtil.createFeature('Red',Iafeature_lst2[0].id, false));
        features_lst1.add(RWS_TestUtil.createFeature('USA',Iafeature_lst2[0].id, false));
        insert features_lst1;

        List<Features__c> features_lst2 = new List<Features__c>();
        features_lst2.add(RWS_TestUtil.createFeature('Red wing 1',Iafeature_lst3[0].id,false));
        features_lst2.add(RWS_TestUtil.createFeature('Dark Red',Iafeature_lst3[1].id, false));
        features_lst2.add(RWS_TestUtil.createFeature('New York',Iafeature_lst3[2].id,false));
        insert features_lst2;

        /*
        List<Product_Style_Features__c> Product_Features_lst = new List<Product_Style_Features__c>();
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst2[0].id, styles[0].id, false));
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst2[1].id, styles[1].id, false));
        
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst2[2].id, styles[2].id, false));
        Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst2[1].id, styles[2].id, false));
        insert product_Features_lst;
        */
        
        //Added by BW : 8/18/17
        //Creates IA_Feature__c (filters) with the Tandem__c field set
        List<IA_Feature__c> featureLst = new List<IA_Feature__c>();
        
        IA_Feature__c filter1 = new IA_Feature__c();
        filter1.Name = 'TandemTest1';
        filter1.Feature_Name__c = 'TandemTest1';
        filter1.Parent_IA_Feature__c = Iafeature_lst1[0].id;
        filter1.Tandem__c = true;
        filter1.Category__c = 'Outside Lines';
        filter1.Selectable__c = true;
        featureLst.add(filter1);        
        
        IA_Feature__c filter2 = new IA_Feature__c();
        filter2.Name = 'TandemTest1';
        filter2.Feature_Name__c = 'TandemTest2';
        filter2.Parent_IA_Feature__c = Iafeature_lst1[0].id;
        filter2.Tandem__c = true;
        filter2.Category__c = 'Outside Lines';
        filter2.Selectable__c = true;
        featureLst.add(filter2);
        
        IA_Feature__c filter3 = new IA_Feature__c();
        filter3.Name = 'NonTandemTest';
        filter3.Feature_Name__c = 'NonTandemTest';
        filter3.Parent_IA_Feature__c = Iafeature_lst1[0].id;
        filter3.Tandem__c = false;
        filter3.Category__c = 'Outside Lines';
        filter3.Selectable__c = true;
        featureLst.add(filter3);    
            
        insert featureLst;  
    }
    
   
    static testMethod void testProgramValidate() {
        RWS_Production_Selection_Controller c = new RWS_Production_Selection_Controller();
        c.validateProgram();

        System.assert(!c.showPage);
    }

   static testMethod void testMethod1() {
       PageReference pageRef = Page.RWS_Account_Creation;

       Program__c pr = [select Id, Name, Auto_Update_Price__c, Auto_Add_Products__c from Program__c limit 1];

       pageRef.getParameters().put('proid', pr.Id);

       Test.setCurrentPageReference(pageRef);

       RWS_Production_Selection_Controller cntrl = new RWS_Production_Selection_Controller();

       List<RWS_Production_Selection_Controller.ProductWrapperClass> cProds = new List<RWS_Production_Selection_Controller.ProductWrapperClass>();

       List<Product2> prod_lst = [select Id, Name, ProductCode, Category__c from Product2];

       Boolean hasFW = false;
       for(Product2 p : prod_lst) {

           if(p.Category__c == 'Footwear' && hasFW) continue;

           cProds.add(new RWS_Production_Selection_Controller.ProductWrapperClass(
                   String.isBlank(p.ProductCode) ? string.valueOf(p.Id) : p.ProductCode,
                   p.Name,
                   '100',
                   '2',
                   '98',
                   p.Id,
                   false
               ));

           if(p.Category__c == 'Footwear') hasFW = true;
       }

       cntrl.createdProgram = pr;

       cntrl.prdresult = JSON.serialize(cProds);
       cntrl.addProgram();

       cntrl.productsListbyFeature();
       cntrl.featureFWWrapperLst[0].childfeatureLst[0].selected = true;
       cntrl.featureFWWrapperLst[0].childfeatureLst[0].grandchildfeatureLst[0].selected = true;
        //cntrl.checkselectall();
       cntrl.productsListbyFeature();


       Test.startTest();
           Set<Id> fIds = new Map<Id, IA_Feature__c>([select Id from IA_Feature__c]).keySet();

           cntrl.createfiltercriteira(cProds, fIds, pr.Id, 2);
           cntrl.createfiltercriteira(cProds, fIds, pr.Id, 2);

           cntrl.createCustomListFilterCriteria(cProds, pr.Id);

           Publish_PriceBook__c cpb = [select Id From Publish_PriceBook__c where Program__c = :pr.Id limit 1];

           Publish_PriceBook_Entry__c prod = RWS_TestUtil.createPublishPricebookEntry(cpb.Id, [select Id from Product2 limit 1].Id, false);
           prod.Filter_Number__c = 1;
           insert prod;

           RWS_TestUtil.createFilterCriteria(pr.Id, [select Id from IA_Feature__c limit 1].Id, true);

           cntrl.selectedFilter = '1';

           cntrl.initializeSelectionView();

           cntrl.selectedFilter = '2';

           cntrl.initializeSelectionView();

           Product2 p = [select Id, Category__c, ProductCode from Product2 limit 1];
           IA_Feature__c iaf = [select Id from IA_Feature__c where Category__c = :p.Category__c limit 1];

           Filter_Criteria__c fc = RWS_TestUtil.createFilterCriteria(pr.Id, null, false);
           fc.Filter_Number__c = 3;
           fc.Filter_BE_Details__c = JSON.serialize(new Map<String, String>{'Name = \'Red wing\'' => ' AND '}) + 'SEPARATOR["' + iaf.Id + '"]';

           fc.Product_Code__c = '["' + p.ProductCode + '"]-FPC-["' + p.ProductCode + '"]';

           insert fc;

           cntrl.selectedFilter = '3';

           cntrl.initializeSelectionView();

           cntrl.searchKeyword = '0001';

           cntrl.searchByKeyword();

           Set<Id> styleIds = new Map<Id, Product_Style__c>([select Id from Product_Style__c]).keySet();

           cntrl.productsList(styleIds);

           cntrl.removePricebookEntries(null, 1, new Set<Id>());

       Test.stopTest();


       
   }
    
    static testMethod void testMethod2() {
        RWS_Production_Selection_Controller cntrl = new RWS_Production_Selection_Controller();
        cntrl.TabCategory = 'Accessories Apparel and Gear';
        cntrl.productsListbyFeature();
        cntrl.featureACWrapperLst[0].childfeatureLst[0].selected = true;
        cntrl.featureACWrapperLst[0].childfeatureLst[0].grandchildfeatureLst[0].selected = true;
        cntrl.productsListbyFeature();
        //cntrl.checkselectall();
    }
    
    static testMethod void testMethod3() {
        RWS_Production_Selection_Controller cntrl = new RWS_Production_Selection_Controller();
        cntrl.TabCategory = 'Workwear';
        cntrl.productsListbyFeature();
        cntrl.featureWWWrapperLst[0].childfeatureLst[0].selected = true;
        cntrl.featureWWWrapperLst[0].childfeatureLst[0].grandchildfeatureLst[0].selected = true;
        cntrl.productsListbyFeature();
        //cntrl.checkselectall();
    }
    
    //Added by BW : 8/18/17
    //This method checks to make sure controller variable returns true when tandem filters are used without at least one non-tandem 
     static testMethod void testTandemOnlyFilters() {   
        List<String> checkFilters = new List<String>(); 
        List<IA_Feature__c> filters = [SELECT Id FROM IA_Feature__c WHERE Tandem__c = true];
      
        for(IA_Feature__c filter : filters){
            checkFilters.add('chkStyle '+filter.Id);
        }

        String mockFilters = JSON.serializePretty(checkFilters);
        
        PageReference pageRef = Page.RWS_NewProgramSetup;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('checkedFiltersJSON', mockFilters);        
        RWS_Production_Selection_Controller cntrl = new RWS_Production_Selection_Controller();
        
        Test.startTest();
        cntrl.validateFilters();
        Test.stopTest();
        System.assertEquals(true, cntrl.chooseMoreFilters);
     }
    
    //Added by BW : 8/18/17
    //This method checks to make sure controller variable returns false when tandem filters are used with at least one non-tandem   
     static testMethod void testBothFilters() { 
        List<String> checkFilters = new List<String>(); 
        List<IA_Feature__c> filters = [SELECT Id FROM IA_Feature__c WHERE Category__c LIKE 'Outside Lines'];
        for(IA_Feature__c filter : filters){
            checkFilters.add('chkStyle '+filter.Id);
        }
        
        String mockFilters = JSON.serializePretty(checkFilters);
        
        PageReference pageRef = Page.RWS_NewProgramSetup;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('checkedFiltersJSON', mockFilters);        
        RWS_Production_Selection_Controller cntrl = new RWS_Production_Selection_Controller();
        
        Test.startTest();
        cntrl.validateFilters();
        Test.stopTest();
        System.assertEquals(false, cntrl.chooseMoreFilters);
     }  
}