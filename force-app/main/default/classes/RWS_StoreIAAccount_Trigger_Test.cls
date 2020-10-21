@isTest
private class RWS_StoreIAAccount_Trigger_Test {
    static testMethod void testTrigger() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true); 

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);

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

        Account industrialAccount1 = new Account();
		industrialAccount1.Name = 'IA One';

		insert industrialAccount1;

		Store_IA_Account__c lookup = new Store_IA_Account__c();
		lookup.IA_Account__c = industrialAccount1.id;
		lookup.Store_Account__c = acc.id;

		insert lookup;

		List<AccountShare> shares = new List<AccountShare>();

		shares.add(
            new AccountShare(AccountId = industrialAccount1.Id,
                      UserorGroupId = u1.Id,
                      AccountAccessLevel ='Read',
                      OpportunityAccessLevel = 'Read')
                );

		shares.add(
            new AccountShare(AccountId = industrialAccount1.Id,
                      UserorGroupId = u2.Id,
                      AccountAccessLevel ='Read',
                      OpportunityAccessLevel = 'Read')
                );

		insert shares;

        Test.startTest();
        	delete lookup;
        Test.stopTest();

        System.assertEquals(0, [select Id from AccountShare 
        							where AccountId = :industrialAccount1.Id 
        						and UserorGroupId in (:u1.Id, :u2.Id)].size(),
        						'Account Share records not deleted'
        					);


    }
}