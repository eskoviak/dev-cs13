@RestResource(urlMapping='/Product')
global with sharing class RW_Product {
  
    @HttpGet
    global static Product2 doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String productCodes = '23152';//req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Product2 prd = [select Id, Product_Style__c, Parent_Product_Style__c, 
                     Style_Number_Unique_ID__c,
                     SKU__c,
                     Item_Status_Code__c
                     from Product2
                     where Style_Number_Unique_ID__c = '23152' LIMIT 1];
      	return prd;
    }

}