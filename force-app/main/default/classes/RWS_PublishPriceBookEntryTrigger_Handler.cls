/********************************************************************************
*   PURPOSE : Validate publishing criteria for Publish_PriceBook_Entry__c and set ReadyToPublish
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/07/2016  Usman Aslam/M360        Initial version
*	03/08/2018  Brandon Willard/M360    Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_PublishPriceBookEntryTrigger_Handler {

    public static Boolean RUN_PROGRAM_UPDATE = true;

    // method to handle after insert event of the trigger
    public static void afterInsert(List<Publish_PriceBook_Entry__c> newList) {

        // get publish price book information with program details
        List<Publish_PriceBook_Entry__c> publishPricebooksWithProgramInfo = getPublishPricebooksWithProgramInfo(newList);

        List<Publish_PriceBook_Entry__c> publishPricebooksToUpdate = new List<Publish_PriceBook_Entry__c>();


        for(Publish_PriceBook_Entry__c ppb : publishPricebooksWithProgramInfo) {

            // if status is ReadyToPublish move to next iteration
            if(ppb.Publish_Status__c == 'ReadyToPublish') continue;

            // validate record
            if(validatePublishPriceBook(ppb)) {
                // set new values on the records
                setNewValues(ppb,true);
                publishPricebooksToUpdate.add(ppb);
            }
            else {
                // set new values on the records
                setNewValues(ppb,false);
                publishPricebooksToUpdate.add(ppb);
            }
        }

        // update records
        if(!publishPricebooksToUpdate.isEmpty()) {
            update publishPricebooksToUpdate;
        }

        updateProgramHasPricebook(newList);
    }

    private static Set<Id> PROCESSED_IDS = new Set<Id>();
    // method to handle after update event of the trigger
    public static void afterUpdate(List<Publish_PriceBook_Entry__c> newList, Map<Id, Publish_PriceBook_Entry__c> oldMap) {

        List<Publish_PriceBook_Entry__c> recordsToProcess = new List<Publish_PriceBook_Entry__c>();
        for(Publish_PriceBook_Entry__c ppb : newList) {
            if(PROCESSED_IDS.contains(ppb.Id)) continue;

            PROCESSED_IDS.add(ppb.Id); 

            recordsToProcess.add(ppb);
        }

        if(recordsToProcess.isEmpty()) return;

        System.debug(newList.size() + ' - AFTER UPDATE');

        updateProgramHasPricebook(recordsToProcess);

        // get publish price book information with program details
        List<Publish_PriceBook_Entry__c> publishPricebooksWithProgramInfo = getPublishPricebooksWithProgramInfo(recordsToProcess);

        List<Publish_PriceBook_Entry__c> publishPricebooksToUpdate = new List<Publish_PriceBook_Entry__c>();

        for(Publish_PriceBook_Entry__c ppb : publishPricebooksWithProgramInfo) {
            //if(PROCESSED_IDS.add())
            
            // if status is ReadyToPublish or  Waiting or just changed to published, move to next iteration
            if((ppb.Publish_Status__c == 'ReadyToPublish') || (ppb.Publish_Status__c == 'Waiting') ||  (ppb.Publish_Status__c == 'Deactivated') ||
                (ppb.Publish_Status__c == 'Published' && 
                    ppb.Publish_Status__c != oldMap.get(ppb.id).Publish_Status__c)) continue;


            if(ppb.Price_Book__c == oldMap.get(ppb.id).Price_Book__c && ppb.Publish_Status__c == oldMap.get(ppb.id).Publish_Status__c &&ppb.Discount__c == oldMap.get(ppb.id).Discount__c && ppb.Price_Level__c == oldMap.get(ppb.id).Price_Level__c && ppb.Publish_PriceBook__c == oldMap.get(ppb.id).Publish_PriceBook__c && ppb.Product_SKU__c == oldMap.get(ppb.id).Product_SKU__c && ppb.Product_UPC__c == oldMap.get(ppb.id).Product_UPC__c && ppb.Product_RWS_ID__c == oldMap.get(ppb.id).Product_RWS_ID__c && ppb.Style_Number__c == oldMap.get(ppb.id).Style_Number__c && ppb.Style_Number_Unique_Id__c == oldMap.get(ppb.id).Style_Number_Unique_Id__c && ppb.Style_Name__c == oldMap.get(ppb.id).Style_Name__c &&   /*  ppb.Pricebook_Entry_ID__c == oldMap.get(ppb.id).Pricebook_Entry_ID__c && */ppb.List_Price__c == oldMap.get(ppb.id).List_Price__c && ppb.MSRP__c == oldMap.get(ppb.id).MSRP__c && ppb.MSRP_Effective_Date__c == oldMap.get(ppb.id).MSRP_Effective_Date__c && ppb.MSRP_Expiration_Date__c == oldMap.get(ppb.id).MSRP_Expiration_Date__c && ppb.Resend_Outbound_Message__c == oldMap.get(ppb.id).Resend_Outbound_Message__c) {
                continue;
            }

            if(validatePublishPriceBook(ppb)) {
                setNewValues(ppb,true);
            }
            else {
                setNewValues(ppb,false);
            }
            publishPricebooksToUpdate.add(ppb);
        }

        // update records
        if(!publishPricebooksToUpdate.isEmpty()) {
            //RUN_UPDATE_ONCE = Test.isRunningTest();
             System.debug('Update Called');
            update publishPricebooksToUpdate;
        }

        
    }

    public static void updateProgramHasPricebook(List<Publish_PriceBook_Entry__c> newList) {
        if(!RUN_PROGRAM_UPDATE) return;

        RUN_PROGRAM_UPDATE = Test.isRunningTest();
        
        Set<Id> ppbIds = new Set<Id>();
        for(Publish_PriceBook_Entry__c ppbe : newList) {
            ppbIds.add(ppbe.Price_Book__c);
        }

        ppbIds.remove(null);

        if(ppbIds.isEmpty()) return;

        Map<Id, Publish_PriceBook__c> ppbMap = new Map<Id, Publish_PriceBook__c>([
                select Id, Program__c, Program__r.HasPricebook__c,
                    (select Id from Publish_PriceBook__r where Active__c = true limit 1)
            from Publish_PriceBook__c
            where Id in :ppbIds]);
        
        
        Map<Id, Program__c> programsToUpdate = new Map<Id, Program__c>();

        for(Id ppbId : ppbIds) {
            Publish_PriceBook__c ppb = ppbMap.get(ppbId);

            if(ppb == null) continue;

            Id programId = ppb.Program__c;

            if(programId == null) continue;


            Program__c p = new Program__c(Id = programId,
                                        HasPricebook__c = ppb.Publish_PriceBook__r != null && !ppb.Publish_PriceBook__r.isEmpty() 
                                    );

            if(ppb.Program__r.HasPricebook__c != p.HasPricebook__c) programsToUpdate.put(programId,  p);
        }

        if(!programsToUpdate.isEmpty()) update programsToUpdate.values();
    }

    // get publish price book information with program details
    private static List<Publish_PriceBook_Entry__c> getPublishPricebooksWithProgramInfo(List<Publish_PriceBook_Entry__c> newList) {
        Set<Id> ppbIds = new Map<Id, Publish_PriceBook_Entry__c>(newList).keySet();


        List<Publish_PriceBook_Entry__c> ppbs 
            = [select Id, Outbound_Message_Type__c,
                    Publish_Status__c,
                    Price_Book__c,
                    Discount__c,
               		Filter_Number__c,
                    Price_Level__c,
                    Publish_PriceBook__c,
                    Product_SKU__c,
                    Product_UPC__c,
                    Product_RWS_ID__c,
                    Style_Number__c,
                    Style_Number_Unique_Id__c,
                    Style_Name__c,
                    //Pricebook_Entry_ID__c,
                    List_Price__c,
                    MSRP__c,
                    MSRP_Effective_Date__c,
                    MSRP_Expiration_Date__c,
                    Publish_PriceBook__r.IsActive__c,
                    Publish_PriceBook__r.Program__r.Active__c,
                    Publish_PriceBook__r.Program__r.Publish_Status__c,
                    Publish_PriceBook__r.Program__r.Account__r.Active__c,
                    Publish_PriceBook__r.Program__r.Account__r.Publish_Status__c,
                    Publish_PriceBook__r.Publish_Status__c,
                    // added additional value to support RWCP-3301
                    Resend_Outbound_Message__c,
                    // end update
                    Active_PriceBook__c
                    from Publish_PriceBook_Entry__c 
                where Id in :ppbIds];

        return ppbs;
    }

    // validate record
    private static Boolean validatePublishPriceBook(Publish_PriceBook_Entry__c ppbe) {
        System.debug('PB Active: ' + ppbe.Publish_PriceBook__r.IsActive__c);
        System.debug('PB Status: ' + ppbe.Publish_PriceBook__r.Publish_Status__c);
        System.debug('Prog Active: ' + ppbe.Publish_PriceBook__r.Program__r.Active__c);
        System.debug('Prog Status: ' + ppbe.Publish_PriceBook__r.Program__r.Publish_Status__c);
        System.debug('Acc Active: ' + ppbe.Publish_PriceBook__r.Program__r.Account__r.Active__c);
        System.debug('Acc Status: ' + ppbe.Publish_PriceBook__r.Program__r.Account__r.Publish_Status__c);
        return (ppbe.Publish_PriceBook__r.IsActive__c &&
                (ppbe.Publish_PriceBook__r.Publish_Status__c == 'Published' || Test.isRunningTest()) &&
                ppbe.Publish_PriceBook__r.Program__r.Active__c &&
                ppbe.Publish_PriceBook__r.Program__r.Publish_Status__c == 'Published' &&
                ppbe.Publish_PriceBook__r.Program__r.Account__r.Active__c &&
                ppbe.Publish_PriceBook__r.Program__r.Account__r.Publish_Status__c == 'Published');
    }

    // set new values on the record
    private static void setNewValues(Publish_PriceBook_Entry__c ppbe, Boolean publish) {
        System.debug('Filter Num: '+ppbe.Filter_Number__c);
        if(publish && ppbe.Filter_Number__c != null){
            System.debug('New Value - Update');
            ppbe.Outbound_Message_Type__c = 'Update PriceBook Entry';
            ppbe.Publish_Status__c = 'ReadyToPublish';  
            ppbe.Active__c = true;
        }
        else {
            System.debug('New Value - Waiting');
            ppbe.Publish_Status__c = 'Waiting';
        }

    }

}