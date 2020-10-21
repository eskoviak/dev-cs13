@isTest
private class RWS_ProductStyle_Batch_Test {
    static testMethod void testBatch() {
        
        Product2 prod = RWS_TestUtil.createProductwithDetail('Product 1', 'Footwear', false);
        prod.Style_Number_Unique_ID__c = '00011';
        prod.Item_Status__c = 'Active';
        prod.Item_Status_Code__c = '20';

        Product2 prod2 = RWS_TestUtil.createProductwithDetail('Product 2', 'Footwear', false);
        prod2.Style_Number_Unique_ID__c = '00011';
        prod2.Item_Status__c = 'Active';
        prod2.Item_Status_Code__c = '50';

        Product2 prod3 = RWS_TestUtil.createProductwithDetail('Product 3', 'Workwear', false);
        prod3.Style_Number_Unique_ID__c = '00011';
        prod3.Item_Status__c = 'Active'; 
        prod3.Item_Status_Code__c = '40';

        insert new List<Product2>{prod, prod3, prod2};
            
        System.assert([select Id from Product_Style__c where Style_Number_Unique_ID__c = '00011' and Category__c = 'Footwear' ].size() == 1);
        System.assert([select Id from Product_Style__c where Style_Number_Unique_ID__c = '00011' and Category__c = 'Workwear' ].size() == 1);
        
        Test.startTest();
        
        RWS_ProductStyle_Batch b = new RWS_ProductStyle_Batch();
        b.execute(null);
        
        Test.stopTest();
        
        for(Product_Style__c p : [select Id, Item_Status_Code__c, 
                                  	Style_Number_Unique_ID__c, Category__c 
                                 from Product_Style__c]) {
            if(p.Style_Number_Unique_ID__c == '00011' && p.Category__c == 'Footwear')
                System.assertEquals('20', p.Item_Status_Code__c);
                                     
            if(p.Style_Number_Unique_ID__c == '00011' && p.Category__c == 'Workwear')
                System.assertEquals('40', p.Item_Status_Code__c);
        }
    }
}