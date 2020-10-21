public with sharing class RWS_UserAccess_Controller {

	private ApexPages.StandardController stdCon {get; set;}

    public RWS_UserAccess_Controller(ApexPages.StandardController sc) {
        stdCon = sc;
    }

    public PageReference updateSharing() {
    	Contact c = (Contact) stdCon.getRecord();

        Set<Id> userIds = new Map<Id, User>([
                select Id 
                from User 
                where Contact.AccountId = :c.AccountId
                and IsActive = true
            ]).keySet();


        Set<Id> programIds 
        	= new Map<Id, Program__c>([select Id from Program__c where OwnerId in :userIds]).keySet();


        if(!programIds.isEmpty()) RWS_ProgramTrigger_Handler.shareProgramAndAccount(programIds);

    	return new PageReference ('/' + c.Id);
    }
}