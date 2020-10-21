global class RWS_FutureBatchJob implements Database.Batchable<sObject>, Schedulable {
    private Id stdPbId;



    // intialize the batch job
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_FutureBatchJob(), 1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, CurrencyIsoCode, Active__c, 
                                                MSRP__c, Product__c, Effective_Date__c 
                                            FROM Future_Price__c
                                            WHERE Active__c = true 
                                            AND Product__c != null
                                            AND Effective_Date__c = TODAY]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        // get standard pricebook id
        if(Test.isRunningTest()) 
            stdPbId = Test.getStandardPricebookId();
        else
            stdPbId = [select id, name from Pricebook2 where IsStandard = true limit 1].id;

        List<Future_Price__c> entries = (List<Future_Price__c>) scope;

        Set<Id> productIds = new Set<Id>();

        for(Future_Price__c pbe : entries) {
            productIds.add(pbe.Product__c);
        }

        // get standard price book entries
        List<PricebookEntry> stdEntries = [SELECT Id, Name, Product2Id, 
                                         UnitPrice, 
                                        UseStandardPrice, Discount__c, 
                                        MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                                        IsActive,
                                        CurrencyIsoCode
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :stdPbId
                                    AND Product2Id in :productIds];

        // populate Product Id to Pricebook Entry Map
        Map<String, PricebookEntry> prodToPbeMap = new Map<String, PricebookEntry>();
        for(PricebookEntry pb : stdEntries) {
            prodToPbeMap.put(String.valueOf(pb.Product2Id) + pb.CurrencyIsoCode,  pb);
        }

        // update standard pricebook entries
        for(Future_Price__c pb : entries) {
        
            PricebookEntry spb = prodToPbeMap.get(String.valueOf(pb.Product__c) + pb.CurrencyIsoCode);

            if(spb == null) continue;

            spb.UnitPrice = pb.MSRP__c;
            spb.IsActive = true;

            pb.Active__c = false;
        }

        update prodToPbeMap.values();

        update entries;
    }

    global void finish(Database.BatchableContext BC) { }
}