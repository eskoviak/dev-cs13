@RestResource(urlMapping='/PrdStyFeatures')
global with sharing class ProductStyleFeaturesController {
    
    @TestVisible global class IAFeaturesJunction {
           public String FeatureID;
        }
    
    @TestVisible
    @HttpPost
    global static String createFeatureJunction(String SFDC_ProductID, String UPC, String styleNumber, String styleNumberId, String retailSku,
                                               String brandCode, String genderCode, String retailClassCode, String countryOfOriginId,
                                               DateTime RWS_Last_Updated_Date,List<IAFeaturesJunction> IAFeaturesJunction) 
    {
            RestResponse res = RestContext.response;
            res.addHeader('Content-Type', 'application/json');
            String jsonResponse = '';            
        try{
            //String SFDC_Id;   
            String PS_Id;
            String PS_SUId; //Style Unique ID from ProductStyle Object
            //List<Product2> SFDC_Prod_ID = [SELECT Id FROM Product2 where RWS_Id__c = :UPC LIMIT 1 FOR UPDATE];              
            //System.debug('SFDC Product ID 1:-' + UPC + SFDC_Prod_ID + SFDC_Prod_ID.size());
            //if(SFDC_Prod_ID.size() > 0)
            //{
                //for (Product2 SFDC_Prod: SFDC_Prod_ID)
                //{
                  // SFDC_Id = SFDC_Prod.Id;
                   //System.debug('SFDC Product ID:-' + SFDC_Id);
                //}
                List <Product_Style__c> prdStyId= [SELECT Id, Style_Number_Unique_ID__c  FROM Product_Style__c where Style_Number_Unique_ID__c = :styleNumberId and IsDeleted = false LIMIT 1 FOR UPDATE];
                System.debug('SFDC Style SF Size:-' + prdStyId.size() + prdStyId);
                if(prdStyId.size() > 0)
                {
                    for(Product_Style__c PS: prdStyId)
                    {
                        PS_Id = PS.Id;
                        PS_SUId = PS.Style_Number_Unique_ID__c;
                     }
            
                    //FeatureJunction add list
                       // List<Product_Features__c> ProductFeaturesList = new List<Product_Features__c>();
                     List<Product_Style_Features__c> ProductStyleFeaturesList = new List<Product_Style_Features__c>();
                     List<Product_Style_Features__c> Delete_PSFList = new List<Product_Style_Features__c>();
                    //For each IAFeature
                        Map<String,String> FeaturesMap = new Map<String,String>();
                        for(IAFeaturesJunction IAFeatureId : IAFeaturesJunction)
                        {
                            FeaturesMap.put(IAFeatureId.FeatureID, IAFeatureId.FeatureID + '-' + UPC);
                        }
                            FeaturesMap.put(brandCode, brandCode + '-' + UPC);
                            FeaturesMap.put(genderCode, genderCode + '-' + UPC);
                            FeaturesMap.put('C' + retailClassCode, 'C' + retailClassCode + '-' + UPC);
                            FeaturesMap.put(countryOfOriginId, countryOfOriginId + '-' + UPC);
                    
                            //System.debug('IA Feat' + IAFeaturesJunctionMap.keySet() + '-' + IAFeaturesJunctionMap.values());
                            List<Product_Style_Features__c>  prdStyFeatId = [SELECT  Id,Feature_Name__c, Feature__c, RWS_Last_Updated_Date__c ,Style_Number_Unique_ID__c, IsDeleted FROM Product_Style_Features__c where Product_Style__c  = :PS_Id and IsDeleted = false order by RWS_Last_Updated_Date__c DESC];//= 'a2YW0000000M7DGMA0'];                  
                    		System.debug('PSF Ids with Deleted field: ' + prdStyFeatId);
                                 Set<String> prdStyFeatIdSet = new Set<String>();
                    			 Map<String,String> prdStyFeatIdMap = new Map<String,String>();
                    			 datetime PSFDt;
                            if(prdStyFeatId.size() > 0)
                            {
                    			PSFDt = prdStyFeatId[0].RWS_Last_Updated_Date__c;
                    			System.debug('PSF Date ' + PSFDt);
                                for(Product_Style_Features__c SF : prdStyFeatId)
                                {
                                    //prdStyFeatIdMap.put(SF.Feature__c, SF.Feature_Name__c);
                                    prdStyFeatIdSet.add(SF.Feature__c);
                                    prdStyFeatIdMap.put(SF.Feature__c,SF.Id);
                                }
                            }
                    			List<Features__c> featuresList = [SELECT IA_Feature__c,Id,RWS_Id__c, Feature_Name__c  FROM Features__c WHERE RWS_Id__c in :FeaturesMap.keySet() and (RWS_Id__c <> '' and RWS_Id__c  <> null) and IsDeleted = false FOR UPDATE];
                                    Map<String,String> ItemFeatListMap = new Map<String,String>();
                                    Set<String> ItemFeatListSet = new Set<String>();
                                    //ItemFeatListSet.add(featuresList);
                            if(featuresList.size() > 0)
                            {
                                for(Features__c Fea : featuresList)
                                {
                                    ItemFeatListMap.put(Fea.RWS_Id__c, Fea.Id);
									System.debug('Item Feat List MAP' + ItemFeatListMap);
                                    ItemFeatListSet.add(Fea.Id);
                                }
                                System.debug('Features readly list size' + featuresList.size());
                                //Map<String,String> prdStyFeatIdMap = new Map<String,String>();
                                System.debug('Prod Style Feat ID list ' + prdStyFeatId);
                                if(prdStyFeatId.size() > 0 && PSFDt != null && RWS_Last_Updated_Date != null)
                                {
                                     if(PSFDt < RWS_Last_Updated_Date)
                                     {
                                        if(prdStyFeatId.size() > 0)
                                        {
                                          //  if(prdStyFeatId.size() == featuresList.size())
                                            //{
                                              //  System.debug('Both objects are equal ' + prdStyFeatId.size() + ', ' + featuresList.size());
                                              //  res.statusCode = 200;
                                              //  jsonResponse = '{"response": {"status": "Success", "message": "Features are upto date."}}';
                                              //  res.responseBody = blob.valueOf(jsonResponse);
                                            //}
                                            //else
                                            //{
                                                for(String IFea : ItemFeatListSet)
                                                {
                                                    System.debug('Item Fea ' + IFea);  
                                                    if(!prdStyFeatIdSet.contains(IFea))
                                                    {
                                                        System.debug('Item Fea not in Prod Style Feat ' + IFea);     
                                                        Product_Style_Features__c PSF = new Product_Style_Features__c(
                                                            Feature__c = IFea,
                                                            Product_Style__c = PS_Id,
                                                            RWS_Last_Updated_Date__c = RWS_Last_Updated_Date
                                                            );
                                                         //generate list for upsert                      
                                                        ProductStyleFeaturesList.add(PSF);
                                                    } 
                                                }
                                                for(String PSFea : prdStyFeatIdSet)
                                                {
                                                    System.debug('PS Fea ' + PSFea);  
                                                    if(!ItemFeatListSet.contains(PSFea))
                                                    {
                                                        System.debug('Prod Style Feat not in Item ' + PSFea);     
                                                        Product_Style_Features__c Delete_PSF = new Product_Style_Features__c(
                                                            Id = prdStyFeatIdMap.get(PSFea)
                                                            /*IsDeleted = true
                                                            Feature__c = PSFea,
                                                            Product_Style__c = PS_Id,
                                                            RWS_Last_Updated_Date__c = RWS_Last_Updated_Date*/
                                                            );
                                                         //generate list for Delete                      
                                                        Delete_PSFList.add(Delete_PSF);     
                                                        System.debug('Prod Style Feat delete list is ready ' + prdStyFeatIdMap.get(PSFea));
                                                    } 
                                                }
                                            //}
                                        }
                                        else
                                        {
                                            for(Features__c feat: featuresList)
                                            {
                                                if(String.isNotEmpty(feat.Id))
                                                {
                                                    Product_Style_Features__c PSF = new Product_Style_Features__c(
                                                        Feature__c = feat.Id,
                                                        Product_Style__c = PS_Id,
                                                        RWS_Last_Updated_Date__c = RWS_Last_Updated_Date
                                                    );
                                                     //generate list for upsert                      
                                                    ProductStyleFeaturesList.add(PSF);
                                                }
                                            }                                       
                                        }
                                     }
                                     else
                                     {
                                         List<String> a = new List<String>{brandCode,genderCode,retailClassCode,countryOfOriginId};
										 System.debug('list:' + a );                                                                                  
                                         for(String ILD : a)
                                         {
                                        	System.debug('For list:' + ILD);                                         
                                             if (ItemFeatListMap.containsKey(ILD) && ILD != null && prdStyFeatIdMap.containsKey(ItemFeatListMap.get(ILD)))
                                             {
                                                 System.debug('No Action needed for item level features: ' + ILD + '-' + ItemFeatListMap.get(ILD) + '-' + prdStyFeatIdMap.get(ItemFeatListMap.get(ILD)));
                                                 /*Product_Style_Features__c PSF = new Product_Style_Features__c(
                                                        Feature__c = ItemFeatListMap.get(ILD),
                                                        Product_Style__c = PS_Id,
                                                        RWS_Last_Updated_Date__c = RWS_Last_Updated_Date
                                                    );
                                                     //generate list for upsert                      
                                                    ProductStyleFeaturesList.add(PSF);
                                                    System.debug('Prod Style Feat @ equal list is ready ' + ProductStyleFeaturesList);
													*/
                                             }
                                             else if (ItemFeatListMap.containsKey(ILD) && ILD != null && !prdStyFeatIdMap.containsKey(ItemFeatListMap.get(ILD)))
                                             {
                                                 Product_Style_Features__c PSF = new Product_Style_Features__c(
                                                        Feature__c = ItemFeatListMap.get(ILD),
                                                        Product_Style__c = PS_Id,
                                                        RWS_Last_Updated_Date__c = RWS_Last_Updated_Date
                                                    );
                                                     //generate list for upsert                      
                                                    ProductStyleFeaturesList.add(PSF);
                                                    System.debug('Prod Style Feat @ equal list is ready ' + ProductStyleFeaturesList);
                                             }
                                             else if (!ItemFeatListMap.containsKey(ILD) && ILD != null && Delete_PSFList.size() == 0)
                                             {
                                                 System.debug('Clear Delete list: ' + Delete_PSFList);
                                                 //Delete_PSFList.clear();
                                                 System.debug('PS Fea ' + prdStyFeatIdSet);
                                                for(String PSFea : prdStyFeatIdSet)
                                                {
                                                    System.debug('PS Fea ' + PSFea);  
                                                    if(!ItemFeatListSet.contains(PSFea))
                                                    {
                                                        System.debug('Prod Style Feat not in Item ' + PSFea);     
                                                        Product_Style_Features__c Delete_PSF = new Product_Style_Features__c(
                                                            Id = prdStyFeatIdMap.get(PSFea)
                                                            );
                                                         //generate list for Delete                      
                                                        Delete_PSFList.add(Delete_PSF);     
                                                        System.debug('Prod Style Feat delete list is ready ' + prdStyFeatIdMap.get(PSFea));
                                                    } 
                                                }
                                             }
                                         }
                                         /*System.debug('Both objects are equal ' + prdStyFeatId.size() + ', ' + featuresList.size());
                                         res.statusCode = 200;
                                         jsonResponse = '{"response": {"status": "Success", "message": "Both objects are equal Features are up to date."}}';
                                         res.responseBody = blob.valueOf(jsonResponse);
										*/
                                     }
                                }
                                else
                                {
                                	for(Features__c feat: featuresList)
                                    {
                                        delete prdStyFeatId;
                                        System.debug('Deleted PSF');
                                        if(String.isNotEmpty(feat.Id))
                                        {
                                            Product_Style_Features__c PSF = new Product_Style_Features__c(
                                                Feature__c = feat.Id,
                                                Product_Style__c = PS_Id,
                                                RWS_Last_Updated_Date__c = RWS_Last_Updated_Date
                                            );
                                            //generate list for upsert                      
                                            ProductStyleFeaturesList.add(PSF);
                                        }
                                    }                                       
                                }
                           }
                    //Final Process
                    if(ProductStyleFeaturesList.size() > 0 && Delete_PSFList.size() > 0)
                    {
                        delete Delete_PSFList;
                        insert ProductStyleFeaturesList;
                        //Create success response message
                        res.statusCode = 200;
                        jsonResponse = '{"response": {"status": "Success", "message": "Successfully inserted & deleted features."}}';
                        res.responseBody = blob.valueOf(jsonResponse);
                    }
                    else if(ProductStyleFeaturesList.size() == 0 && Delete_PSFList.size() == 0)
                    {
                       res.statusCode = 200;
                       jsonResponse = '{"response": {"status": "Success", "message": "Features are upto date."}}';
                       res.responseBody = blob.valueOf(jsonResponse); 
                    } 
                    else if(ProductStyleFeaturesList.size() > 0 && Delete_PSFList.size() == 0)
                    {
                        insert ProductStyleFeaturesList;
                        //Create success response message
                        res.statusCode = 200;
                        jsonResponse = '{"response": {"status": "Success", "message": "Successfully inserted features."}}';
                        res.responseBody = blob.valueOf(jsonResponse);
                    }
                    else if(ProductStyleFeaturesList.size() == 0 && Delete_PSFList.size() > 0)
                    {
                        delete Delete_PSFList;
                        //Create success response message
                        res.statusCode = 200;
                        jsonResponse = '{"response": {"status": "Success", "message": "Successfully deleted invalid feature records."}}';
                        res.responseBody = blob.valueOf(jsonResponse);
                    }     
                }
                else
                {
                    res.statusCode = 201;
                    //jsonResponse = Json.serialize('{"response": {"status": "Bad Request", "message": "UPC Not found."}}');
                    jsonResponse = '{"response": {"status": "Bad Request", "message": "Style Unique ID "' + styleNumberId + '"not found in Product Style Object."}}';
                    res.responseBody = blob.valueOf(jsonResponse);
                }
            //}
            //else
              //  {
                //    res.statusCode = 201;
                    //jsonResponse = Json.serialize('{"response": {"status": "Bad Request", "message": "UPC Not found."}}');
                  //  jsonResponse = '{"response": {"status": "Bad Request", "message": "UPC Not found."}}';
                  //  res.responseBody = blob.valueOf(jsonResponse);
                //}
            return jsonResponse;
        }
        catch(exception ex) {
            //Create failure response message
            res.statusCode = 500;
            jsonResponse = '{"response": {"status": "Failure", "message": "Internal Server Error --> " ' + ex + '}}';
            res.responseBody = blob.valueOf(jsonResponse);                                 
            return jsonResponse;
        }
    }
}