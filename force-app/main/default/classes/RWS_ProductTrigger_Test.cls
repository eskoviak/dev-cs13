@isTest
private class RWS_ProductTrigger_Test {
    static testMethod void testTrigger() {

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
        prod3.Item_Status_Code__c = '20';

        insert new List<Product2>{prod, prod3, prod2};
           

        System.assert([select Id from Product_Style__c where Style_Number_Unique_ID__c = '00011' and Category__c = 'Footwear' ].size() == 1);
        System.assert([select Id from Product_Style__c where Style_Number_Unique_ID__c = '00011' and Category__c = 'Workwear' ].size() == 1);


        prod.IsActive = false;

        update prod;

        prod.IsActive = true;

        update prod;

        
    }
}