global class CaseSetCreateSurveyTaskFlag implements ITriggers.HandlerInterface {

	Case[] newCollection = trigger.new;
	Map<Id, Case> newMap = (Map<Id, Case>)trigger.newMap;
	Map<Id, Case> oldCollection = (Map<Id, Case>)trigger.oldMap;
	Set<Id> contactIds = new Set<Id>();
	
	global void handle() {
		updateContactCreateSurveyTaskFlag(getContactIds());
	}
	
	private Set<Id> getContactIds() {
		for(Case c : newCollection) {
			if(c.IsClosed) {
				if(c.ContactId != null) {
					if(c.Type != null && c.Case_Type_Detail__c != null) {
						if((c.Type.toLowerCase() == 'order' && c.Case_Type_Detail__c.toLowerCase() == 'order entry error') || (c.Type.toLowerCase() == 'order' && c.Case_Type_Detail__c.toLowerCase() == 'order revision') || (c.Type.toLowerCase() == 'sales support' && c.Case_Type_Detail__c.toLowerCase() == 'order revision')) {
							contactIds.add(c.ContactId);
						}
					}
				}
			}
		}
		return contactIds;
	}
	
	private void updateContactCreateSurveyTaskFlag(Set<Id> contactIds) {	
		if(!contactIds.isEmpty() && contactIds.size() > 0) {	
			List<Contact> contactsToUpdate = new List<Contact>();
		
			for(Contact c : [select Create_Survey_Task__c, Active__c, HasOptedOutOfEmail, Survey_Threshold_Reached__c, Do_Not_Send_Surveys__c from Contact where Id in: contactIds]) {
				if(c.Active__c && c.HasOptedOutOfEmail == false && c.Survey_Threshold_Reached__c == false && c.Do_Not_Send_Surveys__c == false) {
					c.Create_Survey_Task__c = true;
        			contactsToUpdate.add(c);
				}			
			}
		
			if(!contactsToUpdate.isEmpty() && contactsToUpdate.size() > 0) {
        		update contactsToUpdate;
			}
		}		
	}
}