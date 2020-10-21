@RestResource(urlMapping='/IAFeatures')
global with sharing class ProductFeaturesController  {
    
    @TestVisible global class IAFeaturesJunction {
           public String FeatureID;
        }
    
    @TestVisible
    @HttpPost
    global static String createFeatureJunction(String SFDC_ProductID, String UPC, String brandCode, String genderCode, String retailClassCode, String countryOfOriginId,
                                               DateTime RWS_Last_Updated_Date,List<IAFeaturesJunction> IAFeaturesJunction) 
    {
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            String jsonResponse = '';
            
        try{
            List<Product2> SFDC_Prod_ID = [SELECT Id FROM Product2 where RWS_Id__c = :UPC LIMIT 1];
            String SFDC_Id;            
            //System.debug('SFDC Product ID 1:-' + UPC + SFDC_Prod_ID + SFDC_Prod_ID.size());
            if(SFDC_Prod_ID.size() > 0)
            {
            for (Product2 SFDC_Prod: SFDC_Prod_ID)
            {
               SFDC_Id = SFDC_Prod.Id;
               //System.debug('SFDC Product ID:-' + SFDC_Id);
            }
                List<Product_Features__c> deleteFeatures = [SELECT Id FROM Product_Features__c WHERE Product__c = :SFDC_Prod_ID];
                //System.debug('Delete Features:-' + deleteFeatures);
                delete deleteFeatures;
            
            //FeatureJunction add list
                List<Product_Features__c> ProductFeaturesList = new List<Product_Features__c>();
            
            //For each IAFeature
                Map<String,String> IAFeaturesJunctionMap = new Map<String,String>();
                for(IAFeaturesJunction IAFeatureId : IAFeaturesJunction)
                {
                    IAFeaturesJunctionMap.put(IAFeatureId.FeatureID, IAFeatureId.FeatureID + '-' + UPC);
                }
                    IAFeaturesJunctionMap.put(brandCode, brandCode + '-' + UPC);
                    IAFeaturesJunctionMap.put(genderCode, genderCode + '-' + UPC);
                    IAFeaturesJunctionMap.put('C' + retailClassCode, 'C' + retailClassCode + '-' + UPC);
                    IAFeaturesJunctionMap.put(countryOfOriginId, countryOfOriginId + '-' + UPC);
            
                    //System.debug('IA Feat' + IAFeaturesJunctionMap.keySet() + '-' + IAFeaturesJunctionMap.values());
                    List<Features__c> featuresList = [SELECT IA_Feature__c,Id,RWS_Id__c FROM Features__c WHERE RWS_Id__c in :IAFeaturesJunctionMap.keySet() and (RWS_Id__c <> '' and RWS_Id__c  <> null)];
                    if(featuresList.size() > 0){
                            System.debug(featuresList.size());
                        //Loop through Features
                            for(Features__c fea: featuresList){
                                System.debug('Fet ID: ' + fea.Id + ' MAP RWS ID: ' + IAFeaturesJunctionMap.get(fea.RWS_Id__c));
                                if(String.isNotEmpty(fea.Id)){
                                    Product_Features__c prodFea = new Product_Features__c(
                                        Feature__c = fea.Id,
                                        Product__c = SFDC_Id, 
                                        RWS_Id__c = IAFeaturesJunctionMap.get(fea.RWS_Id__c),
                                        RWS_Last_Updated_Date__c = RWS_Last_Updated_Date);
                                    //generate list for upsert                      
                                    ProductFeaturesList.add(prodFea);
                                }
                        }  
                    }
            if(ProductFeaturesList.size() > 0)
            {
                insert ProductFeaturesList;
            }
            //Create success response message
            res.statusCode = 201;
            jsonResponse = Json.serialize('{"response": {"status": "Success", "message": "Successfully inserted records."}}');
            res.responseBody = blob.valueOf(jsonResponse);
        }
            else{
                    res.statusCode = 201;
                    jsonResponse = Json.serialize('{"response": {"status": "Bad Request", "message": "UPC Not found."}}');
                    res.responseBody = blob.valueOf(jsonResponse);
            }
            return jsonResponse;
        }
        catch(exception ex) {
            //Create failure response message
            res.statusCode = 500;
            jsonResponse = Json.serialize('{"response": {"status": "Failure", "message": "Internal Server Error --> " ' + ex + '}}');
            res.responseBody = blob.valueOf(jsonResponse);                                 
            return jsonResponse;
        }
    }
}