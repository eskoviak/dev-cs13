@isTest
private class RWS_ProgramTrigger_Test {

    static testMethod void testSetInvoiceAttributes() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
		
        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.Invoice_Atributes_Required__c = 'Branch';
        insert acc;

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);
        pr.Active__c = false;
        insert pr;

       System.assertEquals(null, 
                        [select Invoice_Attributes_Required__c from Program__c where Id = :pr.Id].Invoice_Attributes_Required__c);

        pr.Type__c = 'PayrollDeduction';
        pr.Mandatory__c = 'No';
        pr.Accessories_Allowed_on_Payroll_Deduction__c = 'No';
        pr.Servicing_Level__c = 'RWSS';
        pr.Require_Upload_of_Company_Voucher__c = 'No';
        //test changing ecomm/digital values too.
        pr.Ecomm_Enabled__c = 'Yes';
        pr.Eligibility_Option__c = 'True';
        pr.Allow_Expedited_Shipping__c  = 'No';
        pr.Annual_Reset_or_Rollover__c = 'Single-use';
        //If Active__c is true; and "Processing_Status__c" is not completed
        //we need "hasBeenActive__c" to be true
        pr.HasBeenActive__c = false;

        update pr;

        System.assertEquals(acc.Invoice_Atributes_Required__c, 
                        [select Invoice_Attributes_Required__c from Program__c where Id = :pr.Id].Invoice_Attributes_Required__c);

    }

    static testMethod void testPublish() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

        Product2 prod = RWS_TestUtil.createProduct(true);

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

        Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

        Publish_PriceBook_Entry__c	 customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);

        RWS_PriceBookEntry_Util.createPublicPriceBookEntries(new List<Publish_PriceBook_Entry__c>{customPrice});

        Servicing_Store__c ss = RWS_TestUtil.createServicingStore(acc.Id, pr.Id, true);

        pr.Publish_Status__c = '';

        pr.Servicing_Level__c = 'RWSS';
        Test.startTest();
        update pr;
        Test.stopTest();

    }
    static testMethod void testSetExpiration() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);   

        pr.Active__c = false;

        update pr;


        Program__c prog = [select Id, Expiration_Date__c from Program__c where Id = :pr.Id];
        System.assert(prog.Expiration_Date__c == date.today());
    }
    
    static testMethod void testTriggerDealer() {

        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
		
        Account csAcc = RWS_TestUtil.createAccount(rtId, false);
        csAcc.Invoice_Atributes_Required__c = 'Branch';
        insert csAcc;
        
        insert new Region_Exception__c(Name = '01', Accounts_CSV__c = String.valueOf(csAcc.Id));        
        
        Dealer__c d = RWS_TestUtil.createDealer(true);
        
        Account acc = RWS_TestUtil.createAccount(rtId, false);
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
        User userTest = [SELECT Id, Contact.Account.Region_Code__c FROM User WHERE Id =: u1.Id];
        System.debug(userTest);

        System.runAs(u1) {
            Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);  
            pr.Servicing_Level__c = 'DealerOnly';
            insert pr;
        }


        System.runAs(u2) {
            Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);  
            pr.Servicing_Level__c = 'DealerMarketAreaProgram';
            insert pr;
        }

        Test.stopTest();

    }

    static testMethod void testTriggerCorporate() {

        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Dealer__c d = RWS_TestUtil.createDealer(true);
        
        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.Store_Ownership_Type__c = 'Corporate';
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
            Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);  
            pr.Servicing_Level__c = 'RWSS';
            insert pr;
        }

        Test.stopTest();

    }
}