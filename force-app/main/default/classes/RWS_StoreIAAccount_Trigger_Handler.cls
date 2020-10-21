public with sharing class RWS_StoreIAAccount_Trigger_Handler {
	public static void beforeDelete(List<Store_IA_Account__c> oldRecords) {
		Set<Id> storeAccountIds = new Set<Id>();
		Set<Id> iaAccountIds = new Set<Id>();

		for(Store_IA_Account__c s : oldRecords) {
			if(s.Store_Account__c == null) continue;

			storeAccountIds.add(s.Store_Account__c);

			if(s.IA_Account__c != null) iaAccountIds.add(s.IA_Account__c);
		}

		if(storeAccountIds.isEmpty()) return;

		Set<Id> userIds = new Map<Id, User>([select Id from User where AccountId in :storeAccountIds]).keySet();


		delete [select Id from AccountShare where AccountId in :iaAccountIds and UserOrGroupId in :userIds];
	}
}