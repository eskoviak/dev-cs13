/********************************************************************************
*   PURPOSE :   Test Class for RWS_MigrateProductsFromPBE_Batch
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   03/08/2018  Brandon Willard/M360    Initial version
********************************************************************************/
@isTest
public class RWS_MigrateProductsFromPBE_Batch_Test {

/* begin comment out class
    
    @testSetup 
    static void setup() {
        List<PriceBook2> pbs = new List<PriceBook2>();
        List<Publish_PriceBook__c> ppbs = new List<Publish_PriceBook__c>();
        List<PriceBookEntry> pbes = new List<PriceBookEntry>();
        List<Publish_PriceBook_Entry__c> ppbes = new List<Publish_PriceBook_Entry__c>();
        List<Product2> prods = new List<Product2>();
        
        //Set standard pricebook Id for test
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create products
        for (Integer i=0;i<5;i++) {            
            prods.add(new Product2( Name = 'RW Shoes' + i, 
                                     Family = 'Hardware',
                                     IsActive = true,
                                     Category__c = 'Footwear',
                                     Style_Number_Unique_Id__c = '00110' + i,
                                     Item_Status__c = 'Active' ,
                                     Item_Status_Code__c = '20',
                                     ProductCode = 'PC00110' + i));
        }        
        insert prods;
        
        //Create standard pricebook
        List<PricebookEntry> standardPbe = new List<PricebookEntry>();       
        
        //Create standard pricebooke entries for standard pricebook
        for (Integer i=0;i<5;i++) {           
           standardPbe.add(new PricebookEntry(Pricebook2Id = pricebookId, 
                                              Product2Id = prods[i].Id,
                                              UnitPrice = 1000, 
                                              IsActive = true));            
        }
        insert standardPbe;
        
        //Create custom standard pricebooks to simulate historical pricebook
        for (Integer i=0; i<5; i++) {
            pbs.add(new PriceBook2(name='PB '+i, isActive=true));
        }
        insert pbs;
        
        //For each custom standard pricebook, create a related publish pricebook and pricebookEntries for each product
        for (Pricebook2 pb : [select id from Pricebook2]) {
            Integer i = 0;
            ppbs.add(new Publish_PriceBook__c(Name='PPB '+i, IsActive__c=true, Price_Book__c=pb.Id));                        
            i++;  
            for (Integer j=0; j<prods.size(); j++){
                pbes.add(new PricebookEntry(Pricebook2Id = pb.Id, 
                                            Product2Id = prods[j].Id,
                                            UnitPrice = 900,
                                            Filter_Number__c = 1,
                                            IsActive = true));              
            }
        }
        insert ppbs;
        insert pbes;
        
        //For each publish pricebook create publish pricebook entries with fields to be populated set to null
        for (Publish_Pricebook__c ppb: [Select Id from Publish_Pricebook__c]){
            for (Integer i=0; i<prods.size(); i++){ 
                ppbes.add(new Publish_Pricebook_Entry__c(Publish_PriceBook__c = ppb.Id, 
                                                         Style_Number__c = prods[i].ProductCode,
                                                         List_Price__c = 900, 
                                                         Active__c = true,
                                                         Historic_Pricebook_Entry_ID__c = null,
                                                         Pricebook_Entry_ID__c = pbes[i].Id,                                                        
                                                         Product_ID__c = null,
                                                         MSRP_Effective_Date__c = Date.today()));
            }
            
        }
       
        insert ppbes;
        
        for (Integer i=0; i<ppbes.size(); i++){ 
        }
       
    }

    static testmethod void testBatchClass() {        
        Test.startTest();
        //Run batch job
        RWS_MigrateProductsFromPBE_Batch batchClass = new RWS_MigrateProductsFromPBE_Batch();
        Id batchId = Database.executeBatch(batchClass);
        Test.stopTest();
        
        
        //asserts that product Id and Historic Pricebook Entry Id fields are populated by the batch job
        System.assertEquals(25, [select count() from Publish_Pricebook_Entry__c where Product_ID__c != null]);
        System.assertEquals(25, [select count() from Publish_Pricebook_Entry__c where Historic_Pricebook_Entry_ID__c != null]); 
        System.assertEquals(25, [select count() from Publish_Pricebook_Entry__c where Filter_Number__c = 1]); 

    }
    
  */
    
}