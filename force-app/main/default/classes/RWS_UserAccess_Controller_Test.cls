@isTest
private class RWS_UserAccess_Controller_Test {
	static testMethod void testController() {

		Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');
		
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.Invoice_Atributes_Required__c = 'Branch';
        insert acc;

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);
        pr.Active__c = false;
        insert pr;

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        insert con1;

        Id roleId = [select Id from UserRole where Name = 'System Administrators' limit 1].Id;

        User u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, false);

        System.runAs(new User(Id = UserInfo.getUserId())) {

            User user = new User(Id = UserInfo.getUserId(), UserRoleId = roleId);
            update user;

            insert u1;

            Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

            u1.UserRoleId = partnerRoleId;

            update u1;
        }

        PageReference pg = Page.RWS_UserAccess;

        Test.setCurrentPageReference(pg);

        ApexPages.StandardController sc = new ApexPages.StandardController(con1);

        RWS_UserAccess_Controller cont = new RWS_UserAccess_Controller(sc);

        System.assertNotEquals(null, cont.updateSharing());
	}
}