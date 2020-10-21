/********************************************************************************
*   PURPOSE : Validate publishing criteria for Publish_PriceBook__c and set ReadyToPublish
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/07/2016  Usman Aslam/M360        Initial version
*   03/01/2018  Brandon Willard/M360    Removed standard pricebook references and added in
*										functionality to copy publish pricebook Id to the program
*										instead of pricebook Id - RWCP-3449
********************************************************************************/

public with sharing class RWS_PublishPriceBookTrigger_Handler {
    
    //Is the below needed for Publish Pricebooks? 
    //--Start--    
    public static void beforeInsert(List<Publish_PriceBook__c> newList) {
        for(Publish_PriceBook__c ppb : newList) {
            if(ppb.Name != null && ppb.Name.length() > 80) ppb.Name = ppb.Name.left(80);
        }
    }

    public static void beforeUpdate(List<Publish_PriceBook__c> newList, Map<Id, Publish_PriceBook__c> oldMap) {
        for(Publish_PriceBook__c ppb : newList) {
            if(ppb.Name != null && ppb.Name.length() > 80) ppb.Name = ppb.Name.left(80);
        }
    }
    //--End--
    

    public static void afterInsert(List<Publish_PriceBook__c> newList) {
        // get publish price book information with program details
    	List<Publish_PriceBook__c> publishPricebooksWithProgramInfo = getPublishPricebooksWithProgramInfo(newList);

    	List<Publish_PriceBook__c> publishPricebooksToUpdate = new List<Publish_PriceBook__c>();


    	for(Publish_PriceBook__c ppb : publishPricebooksWithProgramInfo) {

            // if status is ReadyToPublish move to next iteration
    		if(ppb.Publish_Status__c == 'ReadyToPublish') continue;

            // validate records and set new values
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
            update publishPricebooksToUpdate;
        }
        
        setPublishPricebookIdOnProgram(newList, false);
    }

    private static Boolean RUN_UPDATE_ONCE = true;
    public static void afterUpdate(List<Publish_PriceBook__c> newList, Map<Id, Publish_PriceBook__c> oldMap) {
    	if(!RUN_UPDATE_ONCE) return;

        // get publish price book information with program details
    	List<Publish_PriceBook__c> publishPricebooksWithProgramInfo = getPublishPricebooksWithProgramInfo(newList);

    	List<Publish_PriceBook__c> publishPricebooksToUpdate = new List<Publish_PriceBook__c>();

    	for(Publish_PriceBook__c ppb : publishPricebooksWithProgramInfo) {

            // if status is ReadyToPublis,  Waiting , Deactivated or just changed to published, move to next iteration
    		if((ppb.Publish_Status__c == 'ReadyToPublish') || (ppb.Publish_Status__c == 'Waiting') || (ppb.Publish_Status__c == 'Deactivated') ||
    			(ppb.Publish_Status__c == 'Published' && 
    				ppb.Publish_Status__c != oldMap.get(ppb.id).Publish_Status__c)) continue;

            // validate records and set new values
            //if(ppb.Active_PriceBook__c != oldMap.get(ppb.id).Active_PriceBook__c) {
            if(ppb.Active_PriceBook__c != oldMap.get(ppb.id).Active_PriceBook__c && !ppb.Active_PriceBook__c) {
                //No need to set here: When Pricebook is deactivated, it is already set in RWS_ProgramTrigger_Handler               
                //ppb.Outbound_Message_Type__c = 'Update PriceBook';
                //ppb.Publish_Status__c = 'ReadyToPublish';
            } else if(validatePublishPriceBook(ppb)) {
    			setNewValues(ppb,true);
    		}
            else {
                setNewValues(ppb,false);
            }
            publishPricebooksToUpdate.add(ppb);

    	}

        // update records
        if(!publishPricebooksToUpdate.isEmpty()) {
        	RUN_UPDATE_ONCE = Test.isRunningTest();
            update publishPricebooksToUpdate;
        }
        
        setPublishPricebookIdOnProgram(newList, oldMap);
    	
    }
    
    // handles before delete event
    public static void beforeDelete(List<Publish_PriceBook__c> newList) {
        setPublishPricebookIdOnProgram(newList, true);
    }
    
    // handles after undelete event
    public static void afterUndelete(List<Publish_PriceBook__c> newList) {
        setPublishPricebookIdOnProgram(newList, false);
    }

    // get publish price book information with program details
    private static List<Publish_PriceBook__c> getPublishPricebooksWithProgramInfo(List<Publish_PriceBook__c> newList) {
    	Set<Id> ppbIds = new Map<Id, Publish_PriceBook__c>(newList).keySet();

    	List<Publish_PriceBook__c> ppbs 
    		= [select Id, Publish_Status__c,
    	 			Outbound_Message_Type__c,
    	 			IsActive__c,
    	 			Program__r.Active__c,
    	 			Program__r.Publish_Status__c,
    	 			Program__r.Account__r.Active__c,
    	 			Program__r.Account__r.Publish_Status__c,
                    Active_PriceBook__c
    	 			from Publish_PriceBook__c 
    	 		where Id in :ppbIds];

    	return ppbs;
    }

    // validate record
    private static Boolean validatePublishPriceBook(Publish_PriceBook__c ppb) {

    	return (ppb.IsActive__c &&
    			ppb.Program__r.Active__c &&
                ppb.Program__r.Publish_Status__c == 'Published' && //Jas- added Program Publish_status
    			ppb.Program__r.Account__r.Active__c &&
    			ppb.Program__r.Account__r.Publish_Status__c == 'Published');
    }

    // set new values on the record
    private static void setNewValues(Publish_PriceBook__c ppb, Boolean publish) {
        if(publish){
    	    ppb.Outbound_Message_Type__c = 'Update PriceBook';
            ppb.Publish_Status__c = 'ReadyToPublish';  
        }
        else
            ppb.Publish_Status__c = 'Waiting';  
    }
	
    private static void setPublishPricebookIdOnProgram(List<Publish_PriceBook__c> newList, Map<Id, Publish_PriceBook__c> oldMap) {
        List<Publish_PriceBook__c> relatedRecords = new List<Publish_PriceBook__c>();

        for(Publish_PriceBook__c ppb : newList) {
            //if(pb.IsActive == oldMap.get(pb.Id).IsActive)  continue;

            relatedRecords.add(ppb);
        }

        if(relatedRecords.isEmpty()) return;

        setPublishPricebookIdOnProgram(relatedRecords, false);
    }

    private static void setPublishPricebookIdOnProgram(List<Publish_PriceBook__c> newList, Boolean isDelete) {
        Map<Id, Program__c> programsToUpdate = new Map<Id, Program__c>();

        Set<Id> programIds = new Set<Id>();

        for(Publish_PriceBook__c ppb : newList) {
            if(ppb.Program__c == null) continue;

            programIds.add(ppb.Program__c);
        }

        if(programIds.isEmpty()) return;

        List<Publish_PriceBook__c> otherPriceBooks = [select Id, Program__c from Publish_PriceBook__c 
            where Program__c != null and Program__c in :programIds and Id not in :newList];

        Set<Id> programAlreadyHavingPricebook = new Set<Id>();

        for(Publish_PriceBook__c pb : otherPriceBooks) {
            programAlreadyHavingPricebook.add(pb.Program__c);
        }

        for(Publish_PriceBook__c pb : newList) {
            if(pb.Program__c == null) continue;

            if(programAlreadyHavingPricebook.contains(pb.Program__c) && (!isDelete) ) pb.addError('Program already has a Pricebook.');

            programsToUpdate.put(pb.Program__c, new Program__c(Id = pb.Program__c, 
                                                    Price_Book_ID__c = isDelete ? null : pb.Id ,
                                                    HasPricebook__c = isDelete ? false : pb.IsActive__c ));
        }

        if(!programsToUpdate.isEmpty()) update programsToUpdate.values();
    }

}