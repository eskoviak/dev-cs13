@isTest
private class ContactCreateChatterUserTest {

    static testMethod void singleTrueContactInsert() {
 
        Final ID RecordTypeID = [Select ID from RecordType where DeveloperName = 'M3_Contact'].ID;
        Final ID ChatterProfileID = [Select ID From UserLicense where Name = 'Chatter Free'].ID;

        Contact chatterContact = ECTestDataFactory.CreateContact('conF', 'conL', 'ectrue@test.com', FALSE);
        CollaborationGroup cg = ECTestDataFactory.CreateCollaborationGroup('ECTest', 'Public', TRUE);
        EcTestDataFactory.CreateCustomSettingsChatterGroups(cg.Id, TRUE);           
        Insert chatterContact;
        chatterContact.Chatter_Registration__c = TRUE;
        chatterContact.RecordTypeId = RecordTypeID; 
        Update chatterContact;

        User u = [Select FirstName, LastName, Email from User where email =: chatterContact.Email];
    
        System.debug(u);
        
        System.assertEquals([Select CollaborationGroupId from CollaborationGroupMember where MemberID =: u.ID].size(), 
                            [Select ID from collaborationGroup].size());        
        
        System.assertEquals(u.FirstName, chatterContact.FirstName);
        System.assertEquals(u.LastName, chatterContact.LastName); 
        System.assertEquals(u.Email, chatterContact.Email);  
        
        
    }

    static testMethod void singleFalseContactInsert() {

        Final ID RecordTypeID = [Select ID from RecordType where DeveloperName = 'M3_Contact'].ID;
        Final ID ChatterProfileID = [Select ID From UserLicense where Name = 'Chatter Free'].ID;
        

        Contact chatterContact = ECTestDataFactory.CreateContact('conF', 'conL', 'ecfalse@test.com', FALSE);       
        Insert chatterContact;
        chatterContact.Chatter_Registration__c = FALSE;
        Update chatterContact;
        
        List<User> u = [Select FirstName, LastName, Email from User where email =: chatterContact.Email];
        
        System.assert(u.size() == 0);
    }
    
}