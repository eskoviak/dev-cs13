/********************************************************************************
*   PURPOSE :   Update PriceBook Entries relate to a Program where Auto Update is checked 
                when Standard Entries are changed.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/01/2016  Usman Aslam/M360        Initial version
*	03/08/2018	Brandon Willard/M360    Modified for RWCP-3449
********************************************************************************/
global class RWS_PriceUpdateJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    // map to hold MSRP price
    global Map<String, Double> prodIdToUnitPriceMap;
    global Set<Id> productIds;
    global Set<Id> activeProductIds;
    global RWS_PriceUpdateJob() {
        // populate a map that is related Standard PB Entries that got modified yesterday.
        // this job maintains state between batches executation, so populated the map onece
        if(prodIdToUnitPriceMap == null) {

            // get the standard pricebook id
            Id stdPriceBookId = getStandardPricebookId();
            prodIdToUnitPriceMap = new Map<String, Double>();
            productIds = new Set<Id>();
            //activeProductIds = new Set<Id>();
            List<PricebookEntry> pbes = Database.query(
                    'SELECT Product2Id, ' +
                                'UnitPrice, CurrencyIsoCode ' +
                                'FROM PricebookEntry ' +
                                'WHERE Pricebook2Id = :stdPriceBookId ' +
                                'AND IsActive = true ' +
                                'AND LastModifiedDate >= ' + (Test.isRunningTest() ? ' TODAY ' : ' YESTERDAY ')
                );

            // fill the map
            for(PricebookEntry pbe : pbes) {
                prodIdToUnitPriceMap.put(String.valueOf(pbe.Product2Id) + pbe.CurrencyIsoCode, 
                            pbe.UnitPrice);

                productIds.add(pbe.Product2Id);
            }
            
           /* for (Product2 prod: [Select Id FROM Product2 WHERE IsActive=true AND Id IN :productIds]){
                activeProductIds.add(prod.Id);
            }*/
            
            
        }
    }

    // intialize the batch job
    global void execute(SchedulableContext sc) {
        // execute batch job and process 200 records in a batch
        Database.executeBatch(new RWS_PriceUpdateJob(), 200);
    }

    // get the records that needs to be updated
    global Database.QueryLocator start(Database.BatchableContext bc) { 

        // get Custom Pricebook Entries that are related to changed Standard Pricebook Entries
        return Database.getQueryLocator([SELECT Id, Product_Id__c,
                                         Discount__c,
                                         List_Price__c,
                                         CurrencyIsoCode,
                                         Publish_PriceBook__r.CurrencyIsoCode
                                         FROM Publish_PriceBook_Entry__c 
                                         //WHERE Pricebook2.IsStandard = false
                                         WHERE Active__c = true
                                         //AND Product2.IsActive = true 
                                         AND Fixed_Price__c = false
                                         AND Discount__c != null
                                         AND Publish_PriceBook__r.Program__r.Auto_Update_Price__c = true
                                         AND Product_Id__c in : productIds /*activeProductIds*/]);
        
        
      
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Publish_PriceBook_Entry__c> ppbes = (List<Publish_PriceBook_Entry__c>) scope;

        for(Publish_PriceBook_Entry__c ppbe : ppbes) {

            // get standard price
            Double stdUnitPrice = prodIdToUnitPriceMap.get(String.valueOf(ppbe.Product_Id__c) + ppbe.Publish_PriceBook__r.CurrencyIsoCode);

            if(stdUnitPrice == null) continue;

            // set on program pricebook entry
            ppbe.List_Price__c = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (ppbe.Discount__c / 100) * stdUnitPrice);
        }

        // update pricebook entry records
        RWS_PriceBookEntry_Util.insertUpdateRecords(ppbes, false);


        // set the flag to false so HasPricebook__c logic is NOT executed in the same invocation
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

        // update unit price/discount on the Publish Pricebook Entries and publish them
        RWS_PriceBookEntry_Util.publishPublicPriceBookEntries(ppbes);
    }

    global void finish(Database.BatchableContext BC) { }

    // util method to get standard price book id
    private Id getStandardPriceBookId() {
        if(Test.isRunningTest())
            return Test.getStandardPricebookId();
        else 
            return [select Id, Name from Pricebook2 where IsStandard = true limit 1].Id;
            
    }
}