@isTest
private class RWS_Print_ProgramPricelistContTest 
{
    static testMethod void printTess() 
    {
    	PageReference pageRef = Page.RWS_Print_ProgramPricelist;

        Program__c pr = [select Id, Name, Auto_Update_Price__c, Auto_Add_Products__c from Program__c limit 1];

        pageRef.getParameters().put('ProgramId', pr.Id);
        pageRef.getParameters().put('pn', '0');

        Test.setCurrentPageReference(pageRef);
        RWS_Print_ProgramPricelistCont con = new RWS_Print_ProgramPricelistCont();
        pageRef.getParameters().put('pn', '1');
        
        con = new RWS_Print_ProgramPricelistCont();
        con.getProgramDetails();

    }

    @TestSetup
    static void setupData() { 
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        Account acc = RWS_TestUtil.createAccount(rtId, true);
        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);
        Id pricebookId = Test.getStandardPricebookId();

        Product_Style__c ps = new Product_Style__c(Category__c= 'Footwear', Style_Number_Unique_ID__c = '06001');
        insert ps;

        List<Product2> prod_lst = new List<Product2>();
        Product2 fw1 = RWS_TestUtil.createProductwithDetail('Footwear Prod 1','Footwear',false);
        fw1.ProductCode = '0001';
        fw1.Item_Status_Code__c = '20';
        fw1.Item_Status__c = 'Active';
        fw1.Product_Style__c = ps.Id ;

        Product2 fw2 = RWS_TestUtil.createProductwithDetail('Footwear Prod 1','Footwear',false);
        fw2.ProductCode = '0001';
        fw2.Item_Status_Code__c = '80';
        fw2.Item_Status__c = 'Active';
        fw2.Product_Style__c = ps.Id ;

        prod_lst.add(fw1);
        prod_lst.add(fw2);
        
        Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);
		Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, fw1.Id, true);
        Publish_PriceBook_Entry__c customPrice2 = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, fw2.Id, true);

        prod_lst.add(RWS_TestUtil.createProductwithDetail('Accessories Prod 1','Accessories Apparel and Gear', false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('Workwear Prod 1','Workwear', false));
        prod_lst.add(RWS_TestUtil.createProductwithDetail('OL Prod 1','Outside Lines', false));
        insert prod_lst;

        List<PriceBookEntry> pricebookentry_lst = new List<Pricebookentry>();
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[0].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[1].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[2].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[3].Id, false));
        pricebookentry_lst.add(RWS_TestUtil.createPricebookEntry(pricebookId, prod_lst[4].Id, false));
        insert pricebookentry_lst;

    }

}