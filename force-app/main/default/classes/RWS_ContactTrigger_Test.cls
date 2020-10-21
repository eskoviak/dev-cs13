@isTest
private class RWS_ContactTrigger_Test {

    static testMethod void testPhysicalLocation() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.IA_Physical_Location_City__c = 'MN';
        acc.IA_Physical_Location_Country__c = 'US';
        acc.IA_Physical_Location_State_Province__c = 'MN';
        acc.IA_Physical_Location_Address_Line_1__c = '24-A';
        acc.IA_Physical_Location_ZIP_Postal_Code__c = '55213';
        acc.RWfB_same_as_Physical_Address__c = true;
        
        Test.startTest();
        insert acc;
        Test.stopTest();

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Address_same_as_Accounts__c = 'Same as Physical';
        con1.Phone = '111-222-3333';
        insert con1;

        System.assert([select MailingCity from Contact where Id = :con1.Id].MailingCity == acc.IA_Physical_Location_City__c);

    }

    static testMethod void testBillingLocation() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.IA_Physical_Location_City__c = 'MN';
        acc.IA_Physical_Location_Country__c = 'US';
        acc.IA_Physical_Location_State_Province__c = 'MN';
        acc.IA_Physical_Location_Address_Line_1__c = '24-A';
        acc.IA_Physical_Location_ZIP_Postal_Code__c = '55213';
        acc.RWfB_same_as_Physical_Address__c = false;
        acc.RWfB_Billing_Address_City__c = 'ISB';

        Test.startTest();
        insert acc;
		Test.stopTest();
        
        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Address_same_as_Accounts__c = 'Same as Billing';
        con1.Phone = '111-222-3333';
        insert con1;

        System.assert([select MailingCity from Contact where Id = :con1.Id].MailingCity == acc.RWfB_Billing_Address_City__c);

    }

    static testMethod void testBPCUpdate() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Test.startTest();
        Account acc = RWS_TestUtil.createAccount(rtId, true);
        
        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Contact_Identifier__c = 'Billing';
        con1.FirstName = 'Bill';
        con1.LastName = 'Test';
        con1.Email = 'bill@test.com';
        con1.MailingCity = 'MN';
        con1.MailingCountry = 'US';
        con1.MailingState = 'MN';
        con1.MailingStreet = '24-A';
        con1.MailingPostalCode = '55213';
        con1.Phone = '111-222-3333';
        insert con1;
        Test.stopTest();

        System.assert([select HasBillingContact_BPC__c from Account where Id = :acc.Id].HasBillingContact_BPC__c);
        System.assertEquals([select BillingContactID__c from Account where Id = :acc.Id].BillingContactID__c, con1.Id);

        con1.Contact_Identifier__c = 'Primary';
        update con1;

        System.assert(![select HasBillingContact_BPC__c from Account where Id = :acc.Id].HasBillingContact_BPC__c);
    }

    static testMethod void testCopyData() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Test.startTest();
        Account acc = RWS_TestUtil.createAccount(rtId, true);
		Test.stopTest();
        
        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Contact_Identifier__c = 'Billing';
        con1.FirstName = 'Bill';
        con1.LastName = 'Test';
        con1.Email = 'bill@test.com';
        con1.MailingCity = 'MN';
        con1.MailingCountry = 'US';
        con1.MailingState = 'MN';
        con1.MailingStreet = '24-A';
        con1.MailingPostalCode = '55213';
        con1.Phone = '111-222-3333';
        insert con1;

        System.assert([select Billing_Contact_Last_Name__c from Account where Id = :acc.Id].Billing_Contact_Last_Name__c == con1.LastName);

        delete con1;
    }


    static testMethod void testPublishTrigger() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);
        con1.Phone = '111-222-3333';
        con2.Phone = '222-222-3333';

        List<Contact> contacts = new List<Contact>{con2, con1};

        insert contacts;

        Id roleId = [select Id from UserRole where Name = 'System Administrators' limit 1].Id;

        User u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, false);
        User u2 = RWS_TestUtil.createCommunityUser(con2.Id, profileId, false);

        System.runAs(new User(Id = UserInfo.getUserId())) {

            User user = new User(Id = UserInfo.getUserId(), UserRoleId = roleId);
            update user;

            List<User> users = new List<User>{u2, u1};  
            insert users;

            Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

            u1.UserRoleId = partnerRoleId;
            u2.UserRoleId = partnerRoleId;

            update users;
        }

        Test.startTest();

        System.runAs(u1) {
            Contact con3 = RWS_TestUtil.createContact(acc.Id, 2, false);
            Contact con4 = RWS_TestUtil.createContact(acc.Id, 3, false);

            List<Contact> otherContacts = new List<Contact>{con3, con4};

            insert otherContacts;
        }

        Test.stopTest();
    }

    static testMethod void testUserUpdate() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);
		con1.Phone = '111-222-3333';
        con2.Phone = '222-222-3333';
        
        List<Contact> contacts = new List<Contact>{con2, con1};


        insert contacts;

        User u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, true);
            User u2 = RWS_TestUtil.createCommunityUser(con2.Id, profileId, true);
        }

        Test.startTest();
        System.runAs(u1) {
            con1.Contact_Identifier__c = null;
            con1.FirstName = 'UserUpdate';

            update con1;
        }
        Test.stopTest();

    }
}