public with sharing class RWS_AttachmentTrigger_Handler {

	private static Id SYS_ADMIN_PROFILE_ID = [select Id from Profile where Name = 'System Administrator'].Id;

	public static void beforeUpdate(List<Attachment> newRecords) {
		//validateChange(newRecords, true);
	}

	public static void beforeDelete(List<Attachment> oldRecords) {
		validateChange(oldRecords, false);
	}

	public static void afterInsert(List<Attachment> newRecords) {
		updateAccount(newRecords);
	}

	public static void afterDelete(List<Attachment> oldRecords) {
		updateAccount(oldRecords);	
	}

	private static void validateChange(List<Attachment> records, Boolean isUpdate) {
		if(UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID )  return;

		Set<Id> attIds = getAttachmentIds(records);

		List<RWfB_Attachment__c> rwfbList  = getAttachments(attIds);

		if(rwfbList.isEmpty()) return;

		for(Attachment att : records) {
			att.addError('System Administrators can ' + (isUpdate ? 'edit' : 'delete') + ' RWfB Attachments that are flagged as Document for Credit Application');
		}
	}

	private static void updateAccount(List<Attachment> records) {
		List<RWfB_Attachment__c> rwfbList = getAttachments(records);

        if(rwfbList.isEmpty()) return;

        RWS_RWfB_AttachmentTrigger_Handler.updateAccount(rwfbList);
	}

	private static Set<Id> getAttachmentIds(List<Attachment> records) {
		String attKeyPrefix = RWfB_Attachment__c.SObjectType.getDescribe().getKeyPrefix();

		Set<Id> attIds = new Set<Id>();

		for(Attachment att : records) {
			if(String.valueOf(att.ParentId).startsWith(attKeyPrefix)) {
	            attIds.add(att.ParentId);
	        }	
		}

		return attIds;
	}

	private static List<RWfB_Attachment__c> getAttachments(List<Attachment> records) {
		List<RWfB_Attachment__c> rwfbList = new List<RWfB_Attachment__c>();

		Set<Id> attIds = getAttachmentIds(records);

		if(attIds.isEmpty()) return rwfbList;

		rwfbList = getAttachments(attIds);

         return rwfbList;

	}

	private static List<RWfB_Attachment__c> getAttachments(Set<Id> attIds) {
		return [Select Id, Type__c, Public__c,
	            Document_for_Credit_Application__c, Account__c 
            from RWfB_Attachment__c where Document_for_Credit_Application__c = true 
            and Id in :attIds];
	}
}