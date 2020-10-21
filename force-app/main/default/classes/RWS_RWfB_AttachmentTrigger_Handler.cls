public with sharing class RWS_RWfB_AttachmentTrigger_Handler {

	private static Id SYS_ADMIN_PROFILE_ID = [select Id from Profile where Name = 'System Administrator'].Id;

	public static void beforeUpdate(List<RWfB_Attachment__c> newRecords, Map<Id, RWfB_Attachment__c> oldMap) { 
		if(UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID )  return;

		for(RWfB_Attachment__c att : newRecords ) {
			if(oldMap.get(att.Id).Document_for_Credit_Application__c && 
				(att.Type__c != oldMap.get(att.Id).Type__c || 
					att.Public__c != oldMap.get(att.Id).Public__c  || 
					att.Document_for_Credit_Application__c != oldMap.get(att.Id).Document_for_Credit_Application__c ||
					att.CurrencyIsoCode != oldMap.get(att.Id).CurrencyIsoCode )) {
				//att.addError('System Administrators can update RWfB Attachments that are flagged as Document for Credit Application');
				}
		}
	}

	public static void beforeDelete(List<RWfB_Attachment__c> oldRecords) { 
		if(UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID )  return;

		for(RWfB_Attachment__c att : oldRecords ) {
			if(att.Document_for_Credit_Application__c)
				att.addError('System Administrators can delete RWfB Attachments that are flagged as Document for Credit Application');
		}
	}

	/*
	public static void afterInsert(List<RWfB_Attachment__c> newRecords) { 
		updateAccount(newRecords);
	}
	*/

	public static void afterUpdate(List<RWfB_Attachment__c> newRecords, Map<Id, RWfB_Attachment__c> oldMap) { 
		List<RWfB_Attachment__c> relevantRecords = new List<RWfB_Attachment__c> ();

		for(RWfB_Attachment__c att : newRecords) {
			if(att.Type__c != oldMap.get(att.Id).Type__c) {
				relevantRecords.add(att);
			}
		}

		updateAccount(relevantRecords);
	}

	public static void afterDelete(List<RWfB_Attachment__c> oldRecords) { 
		updateAccount(oldRecords);
	}

	public static void afterUndelete(List<RWfB_Attachment__c> newRecords) { 
		updateAccount(newRecords);
	}

	public static void updateAccount(List<RWfB_Attachment__c> newRecords) {
		Set<Id> accountIds = getAccountIds(newRecords);

		if(accountIds.isEmpty()) return;

		Map<Id, List<RWfB_Attachment__c>> accountIdToAttsMap = getRecordsWithAttachment(accountIds);

		List<Account> accountsToUpdate = new List<Account>();

		if(accountIdToAttsMap.isEmpty()) {

			for(Id accId : accountIds) {
				Account accToUpdate = new Account(Id = accId);

				accToUpdate.Documents_for_Credit_Application__c = 'None';

				accountsToUpdate.add(accToUpdate);
			}

			update accountsToUpdate;

			return;
		}

		for(Id accId : accountIdToAttsMap.keySet()) {

			List<RWfB_Attachment__c> atts = accountIdToAttsMap.get(accId);

			Account accToUpdate = new Account(Id = accId);

			if(atts == null || atts.isEmpty()) {
				accToUpdate.Documents_for_Credit_Application__c = 'None';
			} else {
				Set<String> types = new Set<String>();

				for(RWfB_Attachment__c att : atts) {
					types.add(att.Type__c);
				}

				List<String> typeList = new List<String>();
				typeList.addAll(types);

				typeList.sort();

				String docs = '';
				for(String t : typeList) {
					if(docs != '') docs += ',';

					docs += t;
				}

				accToUpdate.Documents_for_Credit_Application__c = docs;
			}

			accountsToUpdate.add(accToUpdate);
		}
		
		update accountsToUpdate;
	}

	private static Map<Id, List<RWfB_Attachment__c>> getRecordsWithAttachment(Set<Id> accountIds) {
		
        Map<Id, List<RWfB_Attachment__c>> returnMe = new Map<Id, List<RWfB_Attachment__c>>();

        List<RWfB_Attachment__c> rwfbList = [Select Id, Type__c, Public__c,
	            Document_for_Credit_Application__c, Account__c,
	            (Select Id from Attachments limit 1) 
            from RWfB_Attachment__c where Document_for_Credit_Application__c = true 
            and Account__c in :accountIds];

        
        for(RWfB_Attachment__c r : rwfbList){
        	List<RWfB_Attachment__c> atts = returnMe.get(r.Account__c);

        	if(atts == null) {
        		atts = new List<RWfB_Attachment__c>();
				returnMe.put(r.Account__c, atts);            		
        	}

            if(r.Attachments != null && !r.Attachments.isEmpty() ) atts.add(r);
        }

        return returnMe;
	}

	private static Set<Id> getAccountIds(List<RWfB_Attachment__c> attRecords) {
		Set<Id> accountIds = new Set<Id>();

		for(RWfB_Attachment__c att : attRecords) {
			if(!att.Document_for_Credit_Application__c) continue;

			accountIds.add(att.Account__c);
		}

		return accountIds;
	}

	/*
	private static List<Account> getAccounts(Set<Id> accountIds) {

		return [select Id, Documents_for_Credit_Application__c,
				(select Id, Type__c, Document_for_Credit_Application__c from 
					RWfB_Attachments__r where Type__c != null
					and Document_for_Credit_Application__c = true) 
				from Account where Id in :accountIds];

	}
	*/
}