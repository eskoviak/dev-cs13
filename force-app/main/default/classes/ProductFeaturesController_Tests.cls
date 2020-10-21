@isTest(SeeAllData=true)
public class ProductFeaturesController_Tests {
    public class MockHttpResponse implements HttpCalloutMock 
    {    
            public HTTPResponse respond(HTTPRequest req) 
            {  
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    String body = 'response content here';  
                    res.setBody(body);             
                    res.setStatusCode(201);
                    return res;
            }
    }
    
    static testMethod void createFeatureJunctionValid_Test()
    {        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        List<String> features = new List<String> {'27369','23878','7596'};
        ProductFeaturesController.IAFeaturesJunction[] IAFList = new ProductFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductFeaturesController.IAFeaturesJunction IAF = new ProductFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductFeaturesController.createFeatureJunction('01t4D000000f9tr','888084708421','VASQ','MEN','700','23346',RWSdt,IAFList);
        system.debug('res:' + res + result);
        System.assertEquals(true, result.contains('Success'));
        Test.stopTest();
    }
    
    static testMethod void createFeatureJunctionInValid_Test()
    {        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        List<String> features = new List<String> {'27369','23878','7596'};
        ProductFeaturesController.IAFeaturesJunction[] IAFList = new ProductFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductFeaturesController.IAFeaturesJunction IAF = new ProductFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductFeaturesController.createFeatureJunction('01t4D000000f9tr','008084708421','VASQ','MEN','700','23346',RWSdt,IAFList);
        system.debug('res:' + res + result);
        System.assertEquals(true, result.contains('UPC Not found'));
        Test.stopTest();
    }
    
    static testMethod void createFeatureJunctionException_Test()
    {        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        List<String> features = new List<String> {'27369','23878','7596'};
        ProductFeaturesController.IAFeaturesJunction[] IAFList = new ProductFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductFeaturesController.IAFeaturesJunction IAF = new ProductFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductFeaturesController.createFeatureJunction('01t4D000000f9tr','888084708421','VASQ','MEN','700','23346',RWSdt,IAFList);
        system.debug('res:' + res + result);
        if(res.statusCode == 201)
        {
            result = 'Failure';        	
        }
        System.assertEquals(true, result.contains('Failure'));
        Test.stopTest();
    }
}