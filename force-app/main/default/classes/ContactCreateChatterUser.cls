global class ContactCreateChatterUser implements ITriggers.HandlerInterface {
    
    Map<Id, Contact> newCollection = (Map<Id, Contact>)trigger.newMap;
    List<Contact> updateContacts = new List<Contact>();
    List<User> chatterUsers = new List<User>();
    List<Exception_Log__c> exceptionLst = new List<Exception_Log__c>();
    Final ID RecordTypeID = [Select ID from RecordType where DeveloperName = 'M3_Contact'].ID;
    Final ID ChatterProfileID = [Select ID From Profile p where p.UserLicenseId in 
                                 (Select ID From UserLicense where Name = 'Chatter Free') and Name = 'RWS Chatter Free User'].ID;
    
    global void handle() {
        System.debug('Trigger Data: ' + newCollection);
        CheckContact();
        System.debug('Record Type & Chatter Check Box Data: ' + updateContacts);
        if(updateContacts.size() > 0){
            CreateChatterUser();
            InsertUsers();
            addtoChatterGroups();           
        }
    }
    
    //Go through the list of matching Contacts and
    //check to see if they have the correct recordTypeID and
    //check if the Chatter Registration checkbox is checked
    private void CheckContact(){
        
        Set<String> userEmail = new Set<String>();        
        for(User u: [Select Email from User]){
            userEmail.add(u.Email);        
        }
        
        for(Contact c: newCollection.values()){
        //for(Contact c : [select FirstName, LastName, RecordTypeId, Chatter_Registration__c, Email, Send_Chatter_Welcome_Message__c from Contact where Id in: newCollection.keySet()]) {
            System.debug('Check Contact: ' + c.RecordTypeId + ' ' + RecordTypeId + ' Checkbox: ' + c.Chatter_Registration__c);
            if(c.Chatter_Registration__c == TRUE && !userEmail.contains(c.Email)){
                System.debug(c);
                //c.Send_Chatter_Welcome_Message__c = true;
                updateContacts.add(c);
            }
        }
    }
    
    //Go though the finshed list of Contacts and use the information
    //to create a ChatterFreeUser.  
    private void CreateChatterUser(){
        Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.EmailHeader.triggerUserEmail = true; 
		dmo.EmailHeader.triggerOtherEmail = false;
		dmo.EmailHeader.triggerAutoResponseEmail = false;       
		dmo.optAllOrNone = false;
        for(Contact c: updateContacts){
            User u = new User();
            
            System.debug('Contacts => Create Chatter User ' + c);
            u.ProfileId = ChatterProfileID;
            u.FirstName = c.FirstName;
            u.LastName = c.LastName;
            u.Email = c.Email;
            u.Username = c.Email;
            u.CommunityNickname = c.Name;
            u.Alias = c.LastName.substring(0,3);
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'America/Chicago';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.LanguageLocaleKey = 'en_US';
            u.setOptions(dmo);
            
            chatterUsers.add(u);
        }
    }
    
    //Insert the users
    private void InsertUsers(){
    
        Database.SaveResult[] insertResults = Database.insert(chatterUsers, false); 
        
        Exception_Log__c ex = new Exception_Log__c();
        ex.Name = 'auto assigned user';
        integer inx=0;
                
        // Iterate through each returned result
        for (Database.SaveResult sr : insertResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted user. User email: ' + updateContacts[inx].Email);
            }
            else {
                // Operation failed create exception objects 
                String errMessage=null;
                for(Database.Error err : sr.getErrors()) {
                    errMessage= errMessage + err.getMessage(); 
                }
                    ex.Contact__c = updateContacts[inx].Id;
                    ex.Error_Message__c = errMessage;
                    exceptionLst.add(ex);
            }
         inx=inx++;    
        }
         if(exceptionLst.size() > 0){
             insert exceptionLst;        
         }
         
         //if(!updateContacts.isEmpty() && updateContacts.size() > 0) {
         	//update updateContacts;
         //}
    }
    
    //Method to assign all the new users to each of the chatter groups
    private void addToChatterGroups(){
        
        list<CollaborationGroupMember> collaborationGroupMember = new list<CollaborationGroupMember>();
        
        list<ChatterGroupsAutoAssigned__c> customSettings = ChatterGroupsAutoAssigned__c.getall().values();
        list<Id> chatterGroups = new list<Id>();
        for(ChatterGroupsAutoAssigned__c cg : customSettings) {
            chatterGroups.add(cg.Group_Id__c);
        }    
        
       //Cycle through all the new Users and add them to 
       //all of the chatter groups
       for(User u: chatterUsers){
       //Looping though Chatter groups for each User
            for(Id cg : chatterGroups){
                System.debug('addToGhatterGroups => collaborationGroup' + cg);
                CollaborationGroupMember cgm = new CollaborationGroupMember();
                cgm.CollaborationGroupId = cg;
                cgm.MemberID = u.ID;
                CollaborationGroupMember.add(cgm);
            }
        }
        
        try{
            System.debug('addToChatterGroups => Collaboration Group Member' + CollaborationGroupMember);
            insert CollaborationGroupMember;
        }catch(DMLException e){
            System.debug(e);
        }
        
    }
}