@isTest
private class RWS_AccountProgramAccess_Batch_Test {
    static testMethod void testBatch() {

    	Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        
        Id m3RtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('M3_Store_Parent_Account', 'Account');
        
        Dealer__c d = RWS_TestUtil.createDealer(true);
        
        Account acc = RWS_TestUtil.createAccount(m3RtId, false);
        acc.Credit_Status__c = null;
        acc.Publish_Status__c = null;
        acc.Requires_Invoicing__c = null;
        acc.Active__c = false;
        acc.Store_Ownership_Type__c = 'Dealer';
        acc.Dealer__c = d.Id;
        acc.Region_Code__c = '01';
        
        Account acc2 = RWS_TestUtil.createAccount(rtId, false);
        acc2.Store_Ownership_Type__c = 'Corporate';
        acc2.Dealer__c = d.Id;
        acc2.Region_Code__c = '01';
        
        Account acc3 = RWS_TestUtil.createAccount(rtId, false);
        acc3.Store_Ownership_Type__c = 'Corporate';
        acc3.Dealer__c = d.Id;
        acc3.Region_Code__c = '01';
        
        Account acc5 = RWS_TestUtil.createAccount(rtId, false);
        acc5.Store_Ownership_Type__c = 'Dealer';
        acc5.Region_Code__c = '01';
        
        List<Account> accList = new List<Account>{acc, acc2, acc3, acc5};
            
        insert accList;

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);

        List<Contact> contacts = new List<Contact>{con2, con1};

        insert contacts;

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
            Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);  
            pr.Servicing_Level__c = 'DealerOnly';
            
            
            Program__c pr2 = RWS_TestUtil.createProgram(acc.Id, false);  
            pr2.Servicing_Level__c = 'DealerMarketAreaProgram';
            
            insert new List<Program__c>{pr, pr2};
        }
        
        User u2 = RWS_TestUtil.createCommunityUser(con2.Id, profileId, false);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            
            insert u2;

            Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

            u2.UserRoleId = partnerRoleId;

            update u2;
        }
        
        RWS_AccountProgramAccess_Batch b = new RWS_AccountProgramAccess_Batch();
        
        b.execute(null);
        
        acc.Region_Code__c = '02';
        update acc;
        
        b.execute(null);

        Test.stopTest();
    }
}