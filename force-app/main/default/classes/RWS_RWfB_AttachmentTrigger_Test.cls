@isTest
private class RWS_RWfB_AttachmentTrigger_Test {
    static testMethod void testTrigger() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        
        Account acc = RWS_TestUtil.createAccount(rtId, true);

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);

        List<Contact> contacts = new List<Contact>{con1};

        insert contacts;

        Id roleId = [select Id from UserRole where Name = 'System Administrators' limit 1].Id;

        User u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, false);

        System.runAs(new User(Id = UserInfo.getUserId())) {

            User user = new User(Id = UserInfo.getUserId(), UserRoleId = roleId);
            update user;

            List<User> users = new List<User>{u1};  
            insert users;

            Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

            u1.UserRoleId = partnerRoleId;

            update users;
        }

        Test.startTest();

        RWfB_Attachment__c rwfb = new RWfB_Attachment__c();
        rwfb.Type__c = 'Customer Master Service Agreement';
        rwfb.Public__c = true;
        rwfb.Account__c = acc.Id;
        rwfb.Document_for_Credit_Application__c = true;
        insert rwfb;

        System.assert([select Id, Documents_for_Credit_Application__c from Account where Id = :acc.Id].Documents_for_Credit_Application__c == 'None');

        Attachment attach = new Attachment();
        attach.ParentId = rwfb.Id;
        attach.Name = 'Test Attachment';
        attach.Body = Blob.valueOf('Test Attachment');

        insert attach;

        System.assert([select Id, Documents_for_Credit_Application__c from Account where Id = :acc.Id].Documents_for_Credit_Application__c == 'Customer Master Service Agreement');

        rwfb.Type__c = 'Customer Purchase Order';

        update rwfb;

        System.assert([select Id, Documents_for_Credit_Application__c from Account where Id = :acc.Id].Documents_for_Credit_Application__c == 'Customer Purchase Order');

        delete rwfb;

        System.assert([select Id, Documents_for_Credit_Application__c from Account where Id = :acc.Id].Documents_for_Credit_Application__c == 'None');

        undelete rwfb;

        System.assert([select Id, Documents_for_Credit_Application__c from Account where Id = :acc.Id].Documents_for_Credit_Application__c == 'Customer Purchase Order');

        System.runAs(u1) {
            rwfb.Type__c = 'Customer Purchase Order';

            try {
                update rwfb;    
            } catch(Exception e) {}

            try {
                delete rwfb;
            } catch(Exception e) {}
            
        }

        Test.stopTest();
    }   
}