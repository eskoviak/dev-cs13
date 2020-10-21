@isTest 
//(SeeAllData=true)
public class ProductStyleFeaturesController_Tests {
    
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
    
    @testSetup static void setup()
    {
        datetime rwsDt = datetime.newInstanceGmt(2018, 08, 19, 11, 09, 36); //.parse('2017-08-19 11:09:36.933');
                Product2 product = new Product2(
                    Company_Number__c = 100,
                    Name = 'PSF_Test',
                    ProductCode = '00875_Test',
                    IsActive = true,
                    Style_Number_Unique_ID__c = '0009884',
                    UPC__c = 'UPC0009884',
                    SKU__c =  '00875E2115_Test',
                    Brand_Code__c = 'CARH',
                    Gender_Code__c = 'MEN',
                    Retail_Category_Code__c = '500',
                    RWS_Last_Updated_Date__c = rwsDt
                );
                insert product;
        
        Product_Style__c ps = new Product_Style__c(
            	Style_Number_Unique_ID__c = '0009884'
        	);
        	insert ps;
        
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = '0009884' and IsDeleted = false LIMIT 1 FOR UPDATE];
        system.debug('Test prdStyId: ' + prdStyId.Id );
        List<String> features = new List<String> {'23231-T','23358-T','25647-T','25652-T','25659-T','25660-T','25665-T','25973-T','25991-T','27337-T'};
		List<Features__c> insertFeaturesList = new List<Features__c>();
        for(string insertFeat: features)            
        {
			Features__c insFet = new Features__c(
                    RWS_Id__c = insertFeat
                );
                //generate list for upsert                      
                insertFeaturesList.add(insFet);
            system.debug('Features: ' + insertFeaturesList);            
         }
        insert insertFeaturesList;
        //For each IAFeature
        Map<String,String> FeaturesMap = new Map<String,String>();
        for(String fl: features)
        {
            FeaturesMap.put(fl, fl + '- UPC0009884');
        }
        List<Features__c> featuresList = [SELECT IA_Feature__c,Id,RWS_Id__c, Feature_Name__c  FROM Features__c WHERE RWS_Id__c in :FeaturesMap.keySet() and (RWS_Id__c <> '' and RWS_Id__c  <> null) and IsDeleted = false];
        system.debug('Test FeaturesList: ' + featuresList );
     
		List<Product_Style_Features__c> ProductStyleFeaturesList = new List<Product_Style_Features__c>();
        for(Features__c feat: featuresList)
        {
                Product_Style_Features__c PSF = new Product_Style_Features__c(
                    Feature__c = feat.Id,
                    Product_Style__c = prdStyId.Id,
                    RWS_Last_Updated_Date__c = rwsDt
                );
                //generate list for upsert                      
                ProductStyleFeaturesList.add(PSF);
            system.debug('List Feature: ' + ProductStyleFeaturesList);
        }
        insert ProductStyleFeaturesList;
    }
    
    
    //Working -- done
    static testMethod void createFeatureJunctionValid_Test()
    {        
              
        Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
    DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        //List<String> features = new List<String> {'27369','23878','7596'};
        List<String> features = new List<String> {'23231','23358','25647','25652','25659','25660','25665','25973','25991','27337'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
          IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/PrdStyFeatures';  
      req.httpMethod = 'POST';
               
       RestContext.request = req;
      RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500','23346',RWSdt,IAFList);
        //system.debug('res:' + res + result);
        System.assertEquals(true, result.contains('Success'));
        Test.stopTest();
    }
    //Working -- done
    static testMethod void createFeatureJunctionInValid_Test()
    {        
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
		
        Test.startTest();
        //system.debug('***Start of createFeatureJunctionInValid_Test****');
    DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        //List<String> features = new List<String> {'27369','23878','7596'};
        List<String> features = new List<String> {'23231','23358','25647','25652','25659','25660','25665','25973','25991','27337'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
          IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
      req.httpMethod = 'POST';
               
       RestContext.request = req;
      RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction('0180U000000jzq','00033581078','12345', '09484', 'VASQ','MEN','700','23346','3', RWSdt,IAFList);
        //system.debug('Invalid Test res:' + res + result);
        System.assertEquals(true, result.contains('Bad Request'));
        //system.debug('***End of createFeatureJunctionInValid_Test****');
        Test.stopTest();
    }
    //Working -- done
    static testMethod void createFeatureJunctionException_Test()
    {    
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
    DateTime RWSdt = (DateTime) JSON.deserialize('"2017-04-19T01:09:36.933"', DateTime.class);
        List<String> features = new List<String> {'27369','23878','7596'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
          IAFList.add(IAF);            
        }
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
      req.httpMethod = 'POST';
               
       RestContext.request = req;
      RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','12345', '1', 'VASQ','MEN','700','23346','3', RWSdt,IAFList);
        system.debug('res:' + res + result);
        if(res.statusCode == 201)
        {
            result = 'Failure';          
        }
        System.assertEquals(true, result.contains('Failure'));
        Test.stopTest();
    }
    
	//Working -- done
    static testMethod void deleteAndNoInsertPSF_Test()
    {        
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('deleteAndNoInsertPSF_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        system.debug('Start deleteAndNoInsertPSF_Test');
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2017-08-19T01:09:36.933"', DateTime.class);
        //System.debug(RWSdt);
        //	List<String> features = new List<String> {'23054','23095','23145','23878','23178'};
        List<String> features = new List<String> {'23358-T','25647-T','25652-T','25659-T','25660-T','25665-T','25973-T','25991-T'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00875E2115_Test','RWLS','MEN','500','23346',RWSdt,IAFList);
        system.debug('res deleteAndNoInsertPSF_Test:' + res + result);
        System.assertEquals(true, result.contains('Successfully deleted invalid feature records.'));
        Test.stopTest();
    }
	//Working -- done with false
    static testMethod void insertAndDeletePSF_Test()
    {        
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('new insertAndDeletePSF_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2019-08-19T01:09:36.933"', DateTime.class);
        
        /*Product_Style__c psId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = '0009884' and IsDeleted = false LIMIT 1 FOR UPDATE];
        List<Product_Style_Features__c>  prdStyFeatId = [SELECT  Id,Feature_Name__c, Feature__c, RWS_Last_Updated_Date__c ,Style_Number_Unique_ID__c, IsDeleted FROM Product_Style_Features__c where Product_Style__c  = :psId.Id and IsDeleted = false order by RWS_Last_Updated_Date__c DESC];//= 'a2YW0000000M7DGMA0'];                  
         Set<String> prdStyFeatIdSet = new Set<String>();
         Map<String,String> prdStyFeatIdMap = new Map<String,String>();
        if(prdStyFeatId.size() > 0)
        {
            System.debug('Test prdStyFeatId ' + prdStyFeatId);
            for(Product_Style_Features__c SF : prdStyFeatId)
            {
                //prdStyFeatIdMap.put(SF.Feature__c, SF.Feature_Name__c);
                prdStyFeatIdSet.add(SF.Feature__c);
                prdStyFeatIdMap.put(SF.Feature__c,SF.Id);
            }
            System.debug('Test prdStyFeatId Set' + prdStyFeatIdSet);
            System.debug('Test prdStyFeatId Map' + prdStyFeatIdMap);
        }
        List<Product_Style_Features__c> Delete_PSFList = new List<Product_Style_Features__c>();
        for(String PSFea : prdStyFeatIdSet)
        { 
            System.debug('Test Prod Style Feat not in Item ' + PSFea);     
                Product_Style_Features__c Delete_PSF = new Product_Style_Features__c(
                    Id = prdStyFeatIdMap.get(PSFea)
                );
                //generate list for Delete                      
                Delete_PSFList.add(Delete_PSF);     
        	    System.debug('Test Prod Style Feat delete list is ready ' + Delete_PSFList.add(Delete_PSF));
        }
        delete Delete_PSFList;*/
        //System.debug(RWSdt);
        //List<String> features = new List<String> {'23095','23145','23878','23178','23289'};
        List<String> features = new List<String> {'29032-T','23158-T','23231-T','25647-T','25652-T','25659-T','25660-T','25665-T','25973-T','25991-T','27337-T'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','VASQ','MEN','500',null,RWSdt,IAFList);
        system.debug('res new insertAndDeletePSF_Test:' + res + result);
        System.assertEquals(false, result.contains('Successfully inserted & deleted features.'));
        Test.stopTest();
    }
    //Working -- done with false
	static testMethod void insertAndNoDeletePSF_Test()
    {        
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2018-08-19T01:09:36.933"', DateTime.class);
        //System.debug('insertAndNoDeletePSF_Test');
        //List<String> features = new List<String> {'23095','23145','23878','23178','23289','23840','23889','23356','23291','29218','27337','23228','23834'};
      		List<String> features = new List<String> {'23231-T','23358-T','25647-T','25652-T','25659-T','25660-T','25665-T','25973-T','25991-T','27337-T'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500','23346',RWSdt,IAFList);
        //system.debug('res insertAndNoDeletePSF_Test:' + res + result);
        System.assertEquals(false, result.contains('Successfully inserted features.'));
        //System.debug('end insertAndNoDeletePSF_Test');
        Test.stopTest();
    }
    //Working -- Done
	static testMethod void upToDatePSF_Test()
    {        
        Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2018-03-30T00:28:18.000"', DateTime.class);
        //System.debug('upToDatePSF_Test');
        //List<String> features = new List<String> {'23889','23356','23291','29218','27337','23228','23834'};
        List<String> features = new List<String> {'23231','23358','25647','25652','25659','25660','25665','25973','25991','27337'};

        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500','23346',RWSdt,IAFList);
        //system.debug('res upToDatePSF_Test:' + res + result);
        System.assertEquals(true, result.contains('Features are upto date.'));
         //System.debug('end upToDatePSF_Test');
        Test.stopTest();
    }
     //Working - Done
    static testMethod void PSFDateIsGreater_Test()
    {        
        Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2017-03-30T00:28:18.000"', DateTime.class);
        //System.debug('upToDatePSF_Test');
        //List<String> features = new List<String> {'23889','23356','23291','29218','27337','23228','23834'};
        List<String> features = new List<String> {'23231','23358','25647','25652','25659','25660','25665','25973','25991','27337'};

        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500','23346',RWSdt,IAFList);
        //system.debug('res upToDatePSF_Test:' + res + result);
        System.assertEquals(true, result.contains('Features are upto date.'));
         //System.debug('end upToDatePSF_Test');
        Test.stopTest();
    
    }
	//working -- Done
    static testMethod void DtNullAndExcep_Test()
    {        
        Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		//DateTime RWSdt = (DateTime) JSON.deserialize(null, DateTime.class);
        //System.debug('DtNullAndExcep_Test');
        //List<String> features = new List<String> {'23889','23356','23291','29218','27337','23228','23834'};
        List<String> features = new List<String> {'23231-T','23358-T','25647-T','25652-T','25659-T','25660-T','25665-T','25973-T','25991-T','27337-T'};

        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500','23346',null,IAFList);
        //system.debug('res DtNullAndExcep_Test:' + res + result);
        System.assertEquals(true, result.contains('Internal Server Error'));
         //System.debug('end DtNullAndExcep_Test');
        Test.stopTest();
    
    }
    //working -- done with false
    static testMethod void RW_PSFDtIsGreater_Test()
    {        
          Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2018-08-30T00:28:18.000"', DateTime.class);
        System.debug('RW_PSFDtIsGreater_Test');
        List<String> features = new List<String> {}; //'23889','23356','23291','29218','27337','23228','23834'
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','RWLS','MEN','500',null,RWSdt,IAFList);
        system.debug('res RW_PSFDtIsGreater_Test:' + res + result);
        System.assertEquals(false, result.contains('Successfully inserted & deleted features.'));
         System.debug('end RW_PSFDtIsGreater_Test');
        Test.stopTest();
    
    }
    
    //working -- done with false
    static testMethod void newlyInsertingFeatures_Test()
    {        
        Product2 product = [SELECT Id,Style_Number_Unique_ID__c,RWS_Last_Updated_Date__c FROM Product2 WHERE Name='PSF_Test' LIMIT 1];
        Product_Style__c prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :product.Style_Number_Unique_ID__c and IsDeleted = false LIMIT 1 FOR UPDATE];
        System.debug('newlyInsertingFeatures_Test-test -- ID: ' + product.Id+ '-' + product.RWS_Last_Updated_Date__c + ' product Style Id: ' + prdStyId.Style_Number_Unique_ID__c);
        Test.startTest();
		DateTime RWSdt = (DateTime) JSON.deserialize('"2018-08-20T11:09:36"', DateTime.class);
        System.debug('newlyInsertingFeatures_Test-test - dt:' + RWSdt);
        List<String> features = new List<String> {'23231','23358','25647','25652','25659','25660','25665','25973','25991','27337','25649'};
        ProductStyleFeaturesController.IAFeaturesJunction[] IAFList = new ProductStyleFeaturesController.IAFeaturesJunction[] {};
        for(String Feat: features)
        { 
            ProductStyleFeaturesController.IAFeaturesJunction IAF = new ProductStyleFeaturesController.IAFeaturesJunction();
            IAF.FeatureID = Feat;  
        	IAFList.add(IAF);            
        }
        //System.debug('IAFList:' + IAFList);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IAFeatures';  
    	req.httpMethod = 'POST';
               
   		RestContext.request = req;
    	RestContext.response = res;
        string result = ProductStyleFeaturesController.createFeatureJunction(product.Id,'UPC0009884','00875_Test', '0009884','00039M 020','CARH','MEN','500','23346',RWSdt,IAFList);
        system.debug('res newlyInsertingFeatures_Test-test:' + res + result);
        System.assertEquals(false, result.contains('Successfully inserted features.'));
         System.debug('end newlyInsertingFeatures_Test-test');
        Test.stopTest();
    }
        
}