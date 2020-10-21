/********************************************************************************
*   PURPOSE :   Migrate data from historical PricebookEntry records to related 
*               Published Pricebook Entry records.
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   03/08/2018  Brandon Willard/M360    Initial version
********************************************************************************/
global class RWS_MigrateProductsFromPBE_Batch implements 
    Database.Batchable<sObject>, Database.Stateful {
  
        

    global Integer pricebookRecordsProcessed = 0;
    global Integer pricebookEntryRecordsProcessed = 0;


    //get all standard Pricebooks and related PricebookEntry records that currently contain the data to be migrated
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, IsStandard FROM PriceBook2 Where IsStandard = false'
        );
    }

    // intialize the batch job
    global void execute(Database.BatchableContext bc, List<PriceBook2> scope){
       
/* begin comment out method
        
        //Set of pricebook Ids        
        Set<Id> pbIds = new Set<Id>();
        //Map of product style to product Id
        Map<String, Id> styleProductIdMap = new Map<String, Id>();
        //Map of product Id to filter number
        Map<Id, Decimal> productIdFilterNumMap = new Map<Id, Decimal>();
        
        
        //Iterate standard pricebook records
        for (PriceBook2 pb : scope) {
            pbIds.add(pb.Id);
            pricebookRecordsProcessed = pricebookRecordsProcessed + 1;
        } 
        
        Set<Id> pbeIds = new Set<Id>();
        if (!pbIds.isEmpty()){            
            for (PriceBookEntry pbe : [SELECT Id, ProductCode, Product2Id, Filter_Number__c FROM PricebookEntry WHERE Pricebook2Id IN :pbIds]) {
                    //Fill maps
                    styleProductIdMap.put(pbe.ProductCode, pbe.Product2Id); 
                    productIdFilterNumMap.put(pbe.Product2Id, pbe.Filter_Number__c);
                    pbeIds.add(pbe.Id);
                    pricebookEntryRecordsProcessed = pricebookEntryRecordsProcessed + 1;
            }
        }
        
       
        Set<Id> ppbIds = new Set<Id>();
        
        if (!pbIds.isEmpty()){
            //Get all publish pricebooks that are related to standard pricebooks (related during creation of published pricebooks from standard pricebooks)
            //and add Ids to set
            for (Publish_Pricebook__c ppb : [SELECT Id, Price_Book__c FROM Publish_PriceBook__c WHERE Price_Book__c IN : pbIds]){
                ppbIds.add(ppb.Id);
            }
        }
       
        if (!ppbIds.isEmpty()){
            //Get all publish pricebook entry records for all relevant publish pricebooks
            List<Publish_PriceBook_Entry__c> ppbes = [SELECT Id, Product_ID__c, Style_Number__c, Publish_PriceBook__c, Publish_PriceBook__r.Price_Book__c, Filter_Number__c, Pricebook_Entry_ID__c FROM Publish_PriceBook_Entry__c WHERE Publish_PriceBook__c IN : ppbIds];
            
            List<Publish_Pricebook_Entry__c> PPBEsToUpdate = new List<Publish_Pricebook_Entry__c>();
            //Populate publish pricebook entry fields with migrated data
            for (Publish_Pricebook_Entry__c ppbe : ppbes){
                Id productId = styleProductIdMap.get(ppbe.Style_Number__c); 
                Decimal filterNum = productIdFilterNumMap.get(productId);
                System.debug('*************filterNum :'+filterNum);
                ppbe.Product_ID__c = productId;
                ppbe.Filter_Number__c =  filterNum;
                if(ppbe.Pricebook_Entry_ID__c != null)
                    ppbe.Historic_Pricebook_Entry_ID__c = ppbe.Pricebook_Entry_ID__c;
                
                PPBEsToUpdate.add(ppbe);
            }
            
            //Update list of modified publish pricebook entries
            update PPBEsToUpdate;
        }

  */ 
    }    

    global void finish(Database.BatchableContext bc){
        
/* begin comment out method                  

        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        
        System.debug('Number of errors: '+job.NumberOfErrors);
        System.debug(job.JobItemsProcessed+' job(s) processed of '+job.TotalJobItems+' total job(s)');
        System.debug(pricebookRecordsProcessed + ' pricebook records processed');
        System.debug(pricebookEntryRecordsProcessed + ' pricebook entry records processed');
        // call some utility to send email
       // EmailUtils.sendMessage(a, recordsProcessed);
       
*/ 
       
    } 
        
 
   
}