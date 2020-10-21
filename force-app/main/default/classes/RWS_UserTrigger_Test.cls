@isTest
private class RWS_UserTrigger_Test {
    static testMethod void tesTrigger() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id customerServiceProfileId = RWS_TestUtil.getProfileIdByName('RWS Customer Service NA Mgr');
        Id indSalesProfileId = RWS_TestUtil.getProfileIdByName('RWS Industrial Sales Manager');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, false);
    	acc.Store_Ownership_Type__c = 'Dealer';
    	insert acc;
    	
    	acc.IsPartner = true;
    	update acc;

    	Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
    	Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);

    	List<Contact> contacts = new List<Contact>{con2, con1};

    	insert contacts;

    	Id roleId = [select Id from UserRole where Name = 'System Administrators' limit 1].Id;

    	User u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, false);
    	User u2 = RWS_TestUtil.createCommunityUser(con2.Id, profileId, false);


    	Test.startTest();

    	
    	System.runAs(new User(Id = UserInfo.getUserId())) {

    		User user = new User(Id = UserInfo.getUserId(), UserRoleId = roleId);
    		update user;


    		User u3 = RWS_TestUtil.createUser('1test1', customerServiceProfileId, false);
    		User u4 = RWS_TestUtil.createUser('2test2', indSalesProfileId, false);

    		List<User> users = new List<User>{u2, u1, u3, u4};	
    		insert users;

    		Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

    		u1.UserRoleId = partnerRoleId;
    		u2.UserRoleId = partnerRoleId;

    		update users;


    	} 

    	System.assert([select Id from GroupMember where UserOrGroupId = :u1.Id].size() == 2);
    	System.assert([select Id from GroupMember where UserOrGroupId = :u2.Id].size() == 2);

    	Test.stopTest();
    }
}