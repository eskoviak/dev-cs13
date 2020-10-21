/********************************************************************************
*   PURPOSE :   Publish/Unpublish Price book and Price Book Entry recrods
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/04/2017  Usman Aslam/M360        Initial version
********************************************************************************/
public with sharing class RWS_ProgramPublish_Util {

    // method to publish Price book and Price Book Entry recrods
	@future
    public static void publishPriceBook(Id programId, String publishStatus) {

        if(!isProgramProcessingCompleted(programId)) return;

        // turn off flag to stop program update from Publish PriceBookEntry Trigger
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

        // initialize variable required for logic
        List<Publish_PriceBook__c> pricebookUpdateList = new List<Publish_PriceBook__c>();
        List<Publish_PriceBook_Entry__c> pricebookEntryUpdateList = new List<Publish_PriceBook_Entry__c>();
    
        Map<Id, Id> pricebookIds = new Map<Id, Id>();

        /*
        // get program pricebook Id
        Set<Id> stdPricebookIds = new Map<Id, Pricebook2>(
                [select Id from Pricebook2 where Program__c = :programId]
            ).keySet();


        // get program price book entries
        Set<Id> stdPricebookEntryIds = new Map<Id, PricebookEntry>(
                [select Id from PricebookEntry where Pricebook2Id in :stdPricebookIds]
            ).keySet(); 
		*/

        // get publish price book records that are in waiting or deactivated status
        for(Publish_PriceBook__c ppb : [select id, Name, Publish_Status__c, 
                                Outbound_Message_Type__c, Active_PriceBook__c, Program__c 
                                from Publish_PriceBook__c 
                                Where Program__c = :programId 
                                and (Publish_Status__c = 'Waiting' Or Publish_Status__c = 'Deactivated')]) {

            // set new values
            ppb.Publish_Status__c = publishStatus;
            ppb.Outbound_Message_Type__c = 'Update Pricebook';
            pricebookUpdateList.add(ppb); 
            pricebookIds.put(ppb.Id, programId); 
        }  

        Map<Decimal, Filter_Criteria__c> filterNumberToFC = getFilterNumberToFCMap(programId);

        Map<String, Decimal> productCodesCustomList = new Map<String, Decimal>();

        Map<String, Decimal> productCodeToFilterNumber = new Map<String, Decimal>();

        Map<String, Decimal> productCodeToDiscount = new Map<String, Decimal>();

        for(Filter_Criteria__c fc : filterNumberToFC.values()) {

            if(String.isBlank(fc.Product_Code__c)) continue;

            String codesSet = fc.Product_Code__c.split('-FPC-')[0];

            if(fc.Filter_Number__c > 0 ) {
                Set<String> productCodes = (Set<String>) JSON.deserialize(codesSet, Set<String>.class);

                for(String pc : productCodes) {
                    productCodeToFilterNumber.put(pc, fc.Filter_Number__c);
                    productCodeToDiscount.put(pc, fc.Discount__c);
                }
            } else {
                productCodesCustomList = (Map<String, Decimal>) JSON.deserialize(codesSet, Map<String, Decimal>.class);
            }
        }

        Set<String> processedCodes = new Set<String>();
        // get publish price book entry records that are in waiting or deactivated status
        for(Publish_PriceBook_Entry__c ppbe : [select id, Name, Publish_Status__c, 
                                    Outbound_Message_Type__c, Expiration_Date__c ,
                                    Active__c, Publish_PriceBook__c, Style_Number__c,
                                    Discount__c, Filter_Number__c
                                from Publish_PriceBook_Entry__c 
                                where Publish_PriceBook__c in :pricebookIds.keySet()
                                and (Publish_Status__c = 'Waiting' Or Publish_Status__c = 'Deactivated')
                                and (Style_Number__c in :productCodesCustomList.keySet() or 
                                    Style_Number__c in :productCodeToFilterNumber.keySet())
                                order by Filter_Number__c asc NULLS LAST, Id desc])
        {

            if(processedCodes.contains(ppbe.Style_Number__c)) continue;

            if(productCodesCustomList.containsKey(ppbe.Style_Number__c) ) {
                ppbe.Filter_Number__c = 0;
                //ppbe.Discount__c = productCodesCustomList.get(ppbe.Style_Number__c);
            } else if (productCodeToFilterNumber.containsKey(ppbe.Style_Number__c)){
                ppbe.Filter_Number__c = productCodeToFilterNumber.get(ppbe.Style_Number__c);
                //ppbe.Discount__c = productCodeToDiscount.get(ppbe.Style_Number__c);
            }

            processedCodes.add(ppbe.Style_Number__c);

            // set new values
            ppbe.Publish_Status__c = publishStatus;
            ppbe.Outbound_Message_Type__c = 'Update Pricebook Entry';
            ppbe.Expiration_Date__c = null;
            ppbe.Active__c = true;
            pricebookEntryUpdateList.add(ppbe); 
        }

        for(Filter_Criteria__c fc : filterNumberToFC.values()) {
            if(fc.Program__r.Active__c && fc.Program__r.Publish_Status__c == 'Published') fc.Product_Code__c = null;
        }

        update filterNumberToFC.values();

        // update publish price book records
        if(!pricebookUpdateList.isEmpty()) update pricebookUpdateList;

        // update publish price book entry records
        if(!pricebookEntryUpdateList.isEmpty()) updateRecords(pricebookEntryUpdateList);
    }

    // method to unpublish Price book and Price Book Entry recrods
	@future
    public static void unpublishPriceBook(Id programId) {
        if(!isProgramProcessingCompleted(programId)) return;

        // turn recursion flag off, so the code in PriceBook Trigger is not executed
        RWS_PriceBookTrigger_Handler.RUN_UPDATE = false;

        // initialize variable required for logic
        List<Publish_PriceBook__c> pricebookUpdateList = new List<Publish_PriceBook__c>();
        List<Publish_PriceBook_Entry__c> pricebookEntryUpdateList = new List<Publish_PriceBook_Entry__c>();
    
        // get program pricebook Id
        Set<Id> stdPricebookIds = new Map<Id, Pricebook2>(
                [select Id from Pricebook2 where Program__c = :programId]
            ).keySet();


        // get program pricebook entry IDs
        Set<Id> stdPricebookEntryIds = new Map<Id, PricebookEntry>(
                [select Id from PricebookEntry where Pricebook2Id in :stdPricebookIds]
            ).keySet(); 

        Set<Id> pricebookIds = new Set<Id>();

        // get Publish price book records
        for(Publish_PriceBook__c ppb : [select id, Name, Publish_Status__c, 
                                Outbound_Message_Type__c, Active_PriceBook__c 
                                from Publish_PriceBook__c 
                                Where Program__c = :programId]) {


            // set new values
            ppb.Publish_Status__c = 'Deactivated';
            ppb.Outbound_Message_Type__c = 'Update Pricebook';
            pricebookUpdateList.add(ppb); 
            pricebookIds.add(ppb.Id);
        }  

        Map<Decimal, Filter_Criteria__c> filterNumberToFC = getFilterNumberToFCMap(programId);

        Map<String, Decimal> productCodesCustomList = new Map<String, Decimal>();

        Map<Decimal, Set<String>> filterProductCodes = new Map<Decimal, Set<String>>();

        Set<String> fixedProductCodes = new Set<String>();
        
        /*
        // get Publish price book entry records
        for(Publish_PriceBook_Entry__c ppbe : [select Id, Name, Publish_Status__c, 
                                    Outbound_Message_Type__c, Expiration_Date__c,
                                    Active__c,
                                    Filter_Number__c,
                                    Style_Number__c,
                                    Discount__c
                                from Publish_PriceBook_Entry__c 
                                where Publish_PriceBook__c in :pricebookIds 
                                and (Publish_Status__c = 'Waiting' or Publish_Status__c = 'Published')
                                and Filter_Number__c != null
                                and Filter_Number__c in :filterNumberToFC.keySet()])
        {
		*/
        /*
        String waiting = 'Waiting';
        String published = 'Published';
        
        
        String query = 'SELECT Id, Name, Publish_Status__c, Outbound_Message_Type__c, Expiration_Date__c, Active__c, Filter_Number__c, Style_Number__c, Discount__c';
        query += ' FROM Publish_PriceBook_Entry__c';
        query += ' WHERE Publish_PriceBook__c in :pricebookIds';
        query += ' AND (Publish_Status__c = :waiting OR Publish_Status__c = :published)';        
        if (!filterNumberToFC.isEmpty()){                                
            Set<Decimal> keySet = filterNumberToFC.keySet();
            query += ' AND Filter_Number__c != null';
            query += ' AND Filter_Number__c in : keySet';
        } */
        
         // get Publish price book entry records
        for(Publish_PriceBook_Entry__c ppbe : [select Id, Name, Publish_Status__c, 
                                    Outbound_Message_Type__c, Expiration_Date__c,
                                    Active__c,
                                    Filter_Number__c,
                                    Style_Number__c,
                                    Discount__c
                                from Publish_PriceBook_Entry__c 
                                where Publish_PriceBook__c in :pricebookIds 
                                and (Publish_Status__c = 'Waiting' or Publish_Status__c = 'Published')]){
            
            If(filterNumberToFC.containsKey(PPBE.Filter_Number__c)) {                        
                if(ppbe.Filter_Number__c == 0) {
                    productCodesCustomList.put(ppbe.Style_Number__c, ppbe.Discount__c);
                } else {
                    Set<String> productCodes = filterProductCodes.get(ppbe.Filter_Number__c);
    
                    if(productCodes == null) {
                        productCodes = new Set<String>();
    
                        filterProductCodes.put(ppbe.Filter_Number__c, productCodes);
                    }
    
                    productCodes.add(ppbe.Style_Number__c);
                }
            }
            // set new values
            ppbe.Publish_Status__c = 'Deactivated';
            ppbe.Outbound_Message_Type__c = 'Update Pricebook Entry';
            ppbe.Expiration_Date__c = Date.today();
            ppbe.Active__c = false;
            pricebookEntryUpdateList.add(ppbe); 
        }

        for(Filter_Criteria__c fc : filterNumberToFC.values()) {
            if(fc.Filter_Number__c == 0) {
                fc.Product_Code__c = JSON.serialize(productCodesCustomList) + '-FPC-' + JSON.serialize(fixedProductCodes);
            } else {
                Set<String> productCodes = filterProductCodes.get(fc.Filter_Number__c);

                if(productCodes == null) continue;

                fc.Product_Code__c = JSON.serialize(productCodes) + '-FPC-' + JSON.serialize(fixedProductCodes);
            }
        }

        update filterNumberToFC.values();

        // update publish price book records
        if(!pricebookUpdateList.isEmpty()) update pricebookUpdateList;

        // update publish price book entry records
        if(!pricebookEntryUpdateList.isEmpty()) updateRecords(pricebookEntryUpdateList);

        // turn flag ON
        RWS_PriceBookTrigger_Handler.RUN_UPDATE = true;
    }


    private static Map<Decimal, Filter_Criteria__c> getFilterNumberToFCMap(Id programId) {
        Map<Decimal, Filter_Criteria__c> filterNumberToFC = new Map<Decimal, Filter_Criteria__c>(); 
        for(Filter_Criteria__c fc : [select Id, Discount__c, Product_Code__c, Filter_Number__c,
                                        Program__r.Active__c, Program__r.Publish_Status__c
                                    from Filter_Criteria__c 
                                    Where Program__c = :programId]) {

            filterNumberToFC.put(fc.Filter_Number__c, fc);
        }

        return filterNumberToFC;
    }

    private static Boolean isProgramProcessingCompleted(Id programId) {
        return [select Processing_Status__c from Program__c where Id = :programId limit 1].Processing_Status__c == 'Completed';
    }
    // update publish price book entry records
    // try five time if an attempt is failed due to ROW locking
    private static void updateRecords(List<Publish_PriceBook_Entry__c> pbes) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                update pbes; 
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    }
}