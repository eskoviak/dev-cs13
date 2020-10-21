@isTest
public class RW_Product_Test {
	static testMethod void testProductGet()
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();        
        //req.requestURI = 'https://cs9.salesforce.com/services/apexrest/v.9/member/me/results/today';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        String productCodes = '23152';
        
        Test.startTest();
        RW_Product.doGet();
        Test.stopTest();
        string prdBlob = res.responseBody.toString();

       System.assert(prdBlob.contains(productCodes));
    }
}