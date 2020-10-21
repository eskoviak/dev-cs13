@isTest
public class RWS_ProgramHomeController_Test {
    @isTest
    public static void Constructor_Test(){

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

    	Test.startTest();

    	System.runAs(u1) {
            Program__c pr = RWS_TestUtil.createProgram(null, false);
            pr.Active__c = false;
            pr.Template__c = true;
            insert pr;	

    		//test that when we do not set the program id, there is no object returned from SOQL
			RWS_ProgramHomeController controller = new RWS_ProgramHomeController();
			System.assert(controller != null);
			System.assert(controller.ProListWrap != null);
    	}
	}

	@isTest
    public static void JsonProgramList_Test(){
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

    	Test.startTest();

    	System.runAs(u1) {
    		Program__c pr = RWS_TestUtil.createProgram(null, false);	
            pr.Template__c = true;
            pr.Active__c = false;
            insert pr;

    		//test that when we do not set the program id, there is no object returned from SOQL
			RWS_ProgramHomeController controller = new RWS_ProgramHomeController();
			String json = controller.jsonProgramList();

			System.assert(json != null);
    	}
	}
}