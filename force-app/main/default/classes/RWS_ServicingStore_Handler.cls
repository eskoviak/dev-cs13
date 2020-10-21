public with sharing class RWS_ServicingStore_Handler {

	public static void afterInsert(List<Servicing_Store__c> newRecords) {
		publishServicingStores(newRecords, null, false);
	}

	public static void afterUpdate(List<Servicing_Store__c> newRecords, Map<Id, Servicing_Store__c> oldRecords) {
		publishServicingStores(newRecords, oldRecords, true);
	}

    private static void publishServicingStores(List<Servicing_Store__c> newRecords, Map<Id, Servicing_Store__c> oldRecords, Boolean isUpdate) {
        Set<Id> proIdSet = new Set<Id>();
        List<Servicing_Store__c> progList = new List<Servicing_Store__c>();
        List<Servicing_Store__c> progupdateList = new List<Servicing_Store__c>();
        

        for(Servicing_Store__c pro : newRecords){
            proIdSet.add(pro.Id);
        }       

        progList = [select id, Publish_Status__c,
                                Outbound_Message_Type__c,
                                Servicing_Status__c,
                                Program__r.Publish_Status__c,
                                Program__r.Active__c
                    from Servicing_Store__c where Id in :proIdSet];

                    
        Set<String> programsProcessedIds = new Set<String>();

        for(Servicing_Store__c ssObj : progList){
            
            // if status is ReadyToPublish or  Waiting or just changed to published, do nothing
            if((ssObj.Publish_Status__c == 'ReadyToPublish') || (ssObj.Publish_Status__c == 'Waiting') ||
                (isUpdate && ssObj.Publish_Status__c == 'Published' && 
                    ssObj.Publish_Status__c != oldRecords.get(ssObj.id).Publish_Status__c))
                continue;

            if (ssObj.Program__r.Active__c 
            	&& ssObj.Program__r.Publish_Status__c == 'Published' 
            	&& ssObj.Servicing_Status__c == 'Active'){

                ssObj.Outbound_Message_Type__c = 'Update Servicing Store';
                ssObj.Publish_Status__c = 'ReadyToPublish';  
                progupdateList.add(ssObj);

            } else if ((ssObj.Program__r.Active__c == false || ssObj.Program__r.Publish_Status__c == 'Published') 
            	&& ssObj.Servicing_Status__c == 'Active' 
                && ssObj.Publish_Status__c != 'Waiting' ){
                ssObj.Publish_Status__c = 'Waiting';  
                progupdateList.add(ssObj);
            }    
        }

        if(!progupdateList.isEmpty()){
            update progupdateList;
        }
    }
}