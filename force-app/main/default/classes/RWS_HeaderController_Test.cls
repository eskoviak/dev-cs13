@isTest
public class RWS_HeaderController_Test {
	@isTest
    public static void Constructor_Test(){
    	RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

 		System.runAs(dataFactory.TestRunner){
			//not sure if this is needs to be done per unit test method? I think so
			List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

			//test that when we do not set the program id, there is no object returned from SOQL
			RWS_HeaderController controller = new RWS_HeaderController();
			String name = controller.LoggedInUserName;

			System.assert(name != null);
		} 
	}
    
    static testMethod void testController() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        
        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.Store_Ownership_Type__c = 'Dealer';
            
        insert acc;

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

        Test.startTest();

        System.runAs(u1) {
            RWS_HeaderController pr = new RWS_HeaderController();  
            System.assertEquals(0, pr.recourseNumber);
        }

        Test.stopTest();
    }
}