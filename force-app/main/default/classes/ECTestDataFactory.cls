@isTest
Global class ECTestDataFactory{

	public static Account createAccount(String name, boolean saveItems) {
		Account newAccount = new Account();
		newAccount.Name = name;
		
		if(saveItems) {
			insert newAccount;
		}
		return newAccount;
	}
	
    Public Static Contact CreateContact(String FirstName, String LastName, String Email, boolean saveItems){
        Contact newContact = new Contact();
    
        newContact.FirstName = FirstName;
        newContact.LastName = LastName;
        newContact.Email = Email; 
    
        if(saveItems){
            insert newContact;
        }
        return newContact;    
    }

    Public Static CollaborationGroup CreateCollaborationGroup(String Name, String CollaborationType, boolean saveItems){
        CollaborationGroup cg = new CollaborationGroup();
        
        cg.Name = Name;
        cg.CollaborationType = CollaborationType;
        
        if(saveItems){
            insert cg;
        }
        
        return cg;
    }
    
    public static Case createCase(String primaryCaseType, String status, String caseOrigin, Id businessHours, Id recordTypeId, Id accountId, Id contactId, boolean saveItems) {
    	Case newCase = new Case();
    	newCase.RecordTypeId = recordTypeId;
    	newCase.ContactId = contactId;
    	
    	if(saveItems) {
    		insert newCase;
    	}
    	return newCase;
    }
    
    public static Task createTask(Id whoId, string status, string priority, string subject, date activitydate, boolean saveItems) {
    	Task newTask = new Task();
    	newTask.whoId = whoId;
    	newTask.Status = status;
    	newTask.Priority = priority;
    	newTask.Subject = subject;
    	newTask.ActivityDate = activitydate;
    	
    	if(saveItems) {
    		insert newTask;
    	}
    	return newTask;
    }
    
    public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User testUser = new User();
        testUser.FirstName = 'Test';
        testUser.LastName = 'Tester';
        testUser.Alias = 'tester';
        testUser.Email = 'test@tester.com';
        testUser.EmailEncodingKey='UTF-8';
        testUser.LanguageLocaleKey='en_US';
        testUser.LocaleSidKey='en_US';
        testUser.ProfileId = p.Id;
        testUser.TimeZoneSidKey='America/Los_Angeles';
        testUser.UserName = 'tester@redwingshoestest.com';
        return testUser;
    }
    
    public static Brand__c createBrand(Id accountId, Id userId, boolean saveItems) {
    	Brand__c newBrand = new Brand__c();
    	newBrand.Account__c = accountId;
    	newBrand.User__c = userId;
    	newBrand.CurrencyIsoCode = 'USD';
    	return newBrand;
    }
    
  // Create Custom Settings Marketing Assisted
    Global Static void CreateCustomSettingsChatterGroups(Id groupId, boolean saveItems) {    
    
    list<ChatterGroupsAutoAssigned__c> lstChatterGroups=new list<ChatterGroupsAutoAssigned__c>();

    ChatterGroupsAutoAssigned__c chatterGroupCS=new ChatterGroupsAutoAssigned__c();
    chatterGroupCS.name='ectest';
    chatterGroupCS.Group_Id__c=groupId;
    lstChatterGroups.add(chatterGroupCS);
      
    if(saveItems){
        insert lstChatterGroups;
    	}    
    }    
}