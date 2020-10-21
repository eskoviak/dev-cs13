/********************************************************************************
*   PURPOSE : To stage Pricebook records into Publish_PriceBook__c for outbound publishing.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   			M360			        Initial version
*	03/08/18	Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_PriceBookTrigger_Handler {

    public static Boolean RUN_UPDATE = true;

    public static void beforeInsert(List<Pricebook2> newList) {
        for(Pricebook2 pb : newList) {
            if(pb.Name != null && pb.Name.length() > 80) pb.Name = pb.Name.left(80);
        }
    }

    public static void beforeUpdate(List<Pricebook2> newList, Map<Id, Pricebook2> oldMap) {
        for(Pricebook2 pb : newList) {
            if(pb.Name != null && pb.Name.length() > 80) pb.Name = pb.Name.left(80);
        }
    }

    /* commented out by BW
    // method to handle after insert event of the trigger
    public static void afterInsert(List<Pricebook2> newList) {
        insertPublishPricebook(newList);

        setPricebookIdOnProgram(newList, false);
    }

    // method to handle after update event of the trigger
    public static void afterUpdate(List<Pricebook2> newList, Map<Id, Pricebook2> oldMap) {
        updatePublishPricebook(newList, oldMap);
        setPricebookIdOnProgram(newList, oldMap);
    }

    // handles before delete event
    public static void beforeDelete(List<Pricebook2> newList) {
        setPricebookIdOnProgram(newList, true);
    }
    
    // handles after undelete event
    public static void afterUndelete(List<Pricebook2> newList) {
        setPricebookIdOnProgram(newList, false);
    }
	
    private static void insertPublishPricebook(List<Pricebook2> newList) {
         // Create Publish Pricebook records
        List<Publish_PriceBook__c> recordsToInsert = new List<Publish_PriceBook__c>();
        for(Pricebook2 pb : newList) {
            recordsToInsert.add(
                new Publish_PriceBook__c(
                    Price_Book__c = pb.Id,
                    Discount__c = pb.Discount__c,
                    Name = (pb.Name != null && pb.Name.length() > 80 ? pb.Name.left(80) : pb.Name)
                )
            );
        }

        insert recordsToInsert;
    }

    private static void setPricebookIdOnProgram(List<Pricebook2> newList, Map<Id, Pricebook2> oldMap) {
        List<Pricebook2> relatedRecords = new List<Pricebook2>();

        for(Pricebook2 pb : newList) {
            //if(pb.IsActive == oldMap.get(pb.Id).IsActive)  continue;

            relatedRecords.add(pb);
        }

        if(relatedRecords.isEmpty()) return;

        setPricebookIdOnProgram(relatedRecords, false);
    }

    private static void setPricebookIdOnProgram(List<Pricebook2> newList, Boolean isDelete) {
        Map<Id, Program__c> programsToUpdate = new Map<Id, Program__c>();

        Set<Id> programIds = new Set<Id>();

        for(Pricebook2 pb : newList) {
            if(pb.Program__c == null) continue;

            programIds.add(pb.Program__c);
        }

        if(programIds.isEmpty()) return;

        List<Pricebook2> otherPriceBooks = [select Id, Program__c from Pricebook2 
            where Program__c != null and Program__c in :programIds and Id not in :newList];

        Set<Id> programAlreadyHavingPricebook = new Set<Id>();

        for(Pricebook2 pb : otherPriceBooks) {
            programAlreadyHavingPricebook.add(pb.Program__c);
        }

        for(Pricebook2 pb : newList) {
            if(pb.Program__c == null) continue;

            if(programAlreadyHavingPricebook.contains(pb.Program__c) && (!isDelete) ) pb.addError('Program already have a Pricebook.');

            programsToUpdate.put(pb.Program__c, new Program__c(Id = pb.Program__c, 
                                                    Price_Book_ID__c = isDelete ? null : pb.Id //,
                                                    //HasPricebook__c = isDelete ? false : pb.IsActive
    												));
        }

        if(!programsToUpdate.isEmpty()) update programsToUpdate.values();
    }

    private static void updatePublishPricebook(List<Pricebook2> newList, Map<Id, Pricebook2> oldMap) {
        if(!RUN_UPDATE) return;
        
        Set<Id> pbIds = new Set<Id>();

        // process records if name or discount is changed
        for(Pricebook2 pb : newList) {
            if(pb.Name != oldMap.get(pb.Id).Name ||
                pb.Discount__c != oldMap.get(pb.Id).Discount__c ||
                pb.IsActive != oldMap.get(pb.Id).IsActive) {

                pbIds.add(pb.Id);
            }
        }

        if(pbIds.isEmpty()) return;


        Map<Id, Pricebook2> newMap = new Map<Id, Pricebook2>(newList);

        // get existing records
        List<Publish_PriceBook__c> recordsToUpdate = [
            select Id, Discount__c, Publish_Status__c, Name,
                    Price_Book__c
            from Publish_PriceBook__c 
            where Price_Book__c in :pbIds
        ];


        // update information
        for(Publish_PriceBook__c ppb : recordsToUpdate) {
            Pricebook2 pb = newMap.get(ppb.Price_Book__c);

            ppb.Name = pb.Name;
            ppb.Discount__c = pb.Discount__c;
        }

        // update records
        update recordsToUpdate;
    }*/


}