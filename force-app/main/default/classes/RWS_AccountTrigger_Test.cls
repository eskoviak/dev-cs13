@isTest
private class RWS_AccountTrigger_Test {

    static testMethod void testTaxExempt() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Tax_Exemption_Reason__c taxExemption = new Tax_Exemption_Reason__c();
        taxExemption.Name = 'TCN GOVT-PST EXMPT';
        taxExemption.Active__c = true;
        taxExemption.State_Exempt__c = 'TRUE'; 
        taxExemption.Applicable_to__c = 'All State/Provinces';
        taxExemption.Industrial_Account_Allowed__c = 'Y';
        taxExemption.National_Account_Allowed__c = 'Y';     
        taxExemption.City_Exempt__c = 'TRUE';
        taxExemption.State_Exempt__c = 'TRUE';
        taxExemption.County_Exempt__c = 'TRUE';
        taxExemption.Country_Exempt__c = 'TRUE';

        insert taxExemption;

        acc.Tax_Exempt__c = 'Yes';

        acc.IA_Tax_Exempt_Certificate_Nbr__c = '1122121';
        acc.Tax_Exempt_Expiration_Date__c = Date.today();
        acc.Tax_Exemption_Reason__c = taxExemption.Id;

        update acc;

        acc.Tax_Exempt__c = 'No';

        update acc;

    }
    
    static testMethod void testPhysicalLocation() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.IA_Physical_Location_City__c = 'MN';
        acc.IA_Physical_Location_Country__c = 'US';
        acc.IA_Physical_Location_State_Province__c = 'MN';
        acc.IA_Physical_Location_Address_Line_1__c = '24-A';
        acc.IA_Physical_Location_ZIP_Postal_Code__c = '55213';
        acc.RWfB_same_as_Physical_Address__c = true;
        insert acc;

        System.assert([select RWfB_Billing_Address_City__c from Account where Id = :acc.Id].RWfB_Billing_Address_City__c == acc.IA_Physical_Location_City__c);
        System.assert([select BillingCity from Account where Id = :acc.Id].BillingCity == acc.IA_Physical_Location_City__c);

    }


    static testMethod void testSetInvoiceAttributes() {


        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account_Number_Setting__c setting = 
            new Account_Number_Setting__c(Record_Type_Developer_Name__c = 'Business_Partner_Community',
                                            Name = 'BPC_TEST');

        insert setting;

        Account acc = RWS_TestUtil.createAccount(rtId, false);
        acc.Invoice_Atributes_Required__c = 'Branch';
        insert acc;

        System.assertNotEquals(null, 
                        [select Account_Number_Text__c from Account where Id = :acc.Id].Account_Number_Text__c);



        Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);
        pr.Type__c = 'PayrollDeduction';
        pr.Mandatory__c = 'No';
        pr.Accessories_Allowed_on_Payroll_Deduction__c = 'No';
        pr.Servicing_Level__c = 'RWSS';
        pr.Require_Upload_of_Company_Voucher__c = 'No';
        insert pr;

        System.assertEquals(acc.Invoice_Atributes_Required__c, 
                        [select Invoice_Attributes_Required__c from Program__c where Id = :pr.Id].Invoice_Attributes_Required__c);

        acc.Invoice_Atributes_Required__c = 'Branch;CostCenter';
        update acc;


        System.assertEquals(acc.Invoice_Atributes_Required__c, 
                        [select Invoice_Attributes_Required__c from Program__c where Id = :pr.Id].Invoice_Attributes_Required__c);


    }

    
    static testMethod void testChildAccountSharing() {

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

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
        insert con1;

        Account childAcc = RWS_TestUtil.createAccount(rtId, false);
        childAcc.ParentId = acc.Id;
        childAcc.Requires_Invoicing__c = 'Yes';
        childAcc.Invoice_Parent_Account__c = 'Centralized';
        childAcc.Requested_Credit_Limi__c = '5000';
        Test.startTest();
            insert childAcc;
        Test.stopTest();

        System.assert([select Billing_Contact_Last_Name__c from Account where Id = :childAcc.Id].Billing_Contact_Last_Name__c == con1.LastName);

    }

    static testMethod void testSetExpiration() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);   

        acc.Active__c = false;



        update acc;


        Program__c prog = [select Id, Expiration_Date__c from Program__c where Id = :pr.Id];
        System.assert(prog.Expiration_Date__c == date.today());

    }
    
    static testMethod void testAccountPublishing() {
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
            Account acc2 = RWS_TestUtil.createAccount(rtId, false);
            acc2.Active__c = false;
            insert acc2;

            Contact con3 = RWS_TestUtil.createContact(acc2.Id, 2, true);

            acc2.Active__c = true;
            acc2.Credit_Status__c = 'Submitted';
            update acc2;
        }

        Test.stopTest();
    }
    
    // Test when there are no Account Team Members
    static testMethod void TestNoAccountTeamMembers() {
        
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;
        
        //Get Profile Information
        Profile p = [select id from profile where name='System Administrator'];
        
        //Create Users
        User newUser01 = new User (FirstName='Test01',LastName='User01',Alias='tuser01',Email='test01@test.com',
                                   Username='edatest01@redwingshoes.com',CommunityNickname='test01',profileid=p.Id,EmailEncodingKey='UTF-8',
                                   TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                                   LanguageLocaleKey='en_US');
        insert newUser01;
        
        User newUser02 = new User (FirstName='Test02',LastName='User02',Alias='tuser02',Email='test02@test.com',
                                   Username='edatest02@redwingshoes.com',CommunityNickname='test02',profileid=p.Id,EmailEncodingKey='UTF-8',
                                   TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                                   LanguageLocaleKey='en_US');
        insert newUser02;
        
        //Test that Account Credit Analyst should be null
        System.assertEquals(null,newAccount.Account_Credit_Analyst__c);  
    }
    
    // Test when there is a Credit Analyst Account Team Member
    static testMethod void TestCreditAnalystAccountTeamMember() {
        
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;
        
        //Get Profile Information
        Profile p = [select id from profile where name='System Administrator'];
        
        //Create Users
        User newUser01 = new User (FirstName='Test01',LastName='User01',Alias='tuser01',Email='test01@test.com',
                                   Username='edatest01@redwingshoes.com',CommunityNickname='test01',profileid=p.Id,EmailEncodingKey='UTF-8',
                                   TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                                   LanguageLocaleKey='en_US');
        insert newUser01;
        
        //Create Account Team
        Test.startTest();
        RWS_AccountTrigger_Handler.QUERIED_ACCOUNT_TEAM = false;
        AccountTeamMember atm01 = new AccountTeamMember (UserId=newUser01.id,AccountId=newAccount.id,TeamMemberRole='Credit Analyst');
        insert atm01;    
        
        //Update Account
        newAccount.Gift_Card_Participant__c = true;
        update newAccount;
        Test.stopTest();
        //Re-query the data
        Account checkAccount = [SELECT Id,Account_Credit_Analyst__c FROM Account WHERE Id= :newAccount.id];
        
        //Run Check
        System.assertEquals(newUser01.id,checkAccount.Account_Credit_Analyst__c);
    }       
    
    // Test when there is a non Credit Analyst Account Team Member
    static testMethod void TestNonCreditAnalystAccountTeamMember() {
        
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;
        
        //Get Profile Information
        Profile p = [select id from profile where name='System Administrator'];
        
        //Create Users
        User newUser02 = new User (FirstName='Test02',LastName='User02',Alias='tuser02',Email='test02@test.com',
                                   Username='edatest02@redwingshoes.com',CommunityNickname='test02',profileid=p.Id,EmailEncodingKey='UTF-8',
                                   TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                                   LanguageLocaleKey='en_US');
        insert newUser02;
        
        RWS_AccountTrigger_Handler.QUERIED_ACCOUNT_TEAM = false;
        
        Test.startTest();
        
        AccountTeamMember atm02 = new AccountTeamMember (UserId=newUser02.id,AccountId=newAccount.id,TeamMemberRole='Industrial Sales Manager');
        insert atm02;     
        
        //Update Account
        newAccount.Gift_Card_Participant__c = true;
        update newAccount;
        Test.stopTest();
        
        //Re-query the data
        Account checkAccount = [SELECT Id,Account_Credit_Analyst__c,Account_Team_ISM__c FROM Account WHERE Id= :newAccount.id];
        
        //Run Check
        System.assertEquals(null,checkAccount.Account_Credit_Analyst__c);
        System.assertEquals(newUser02.id,checkAccount.Account_Team_ISM__c);
    } 
    
    static testmethod void testAutoGeocodingWithInsert() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };

    insert settings;


    Test.startTest();
    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US');
    insert a;
    Test.stopTest();

    //Data.com isn't working with unit tests. Instead, the contact test below will mock the lat and long geocoding up to the account.
    //Account result = [Select Longitude__c,Latitude__c From Account];
    //System.assertNotEquals(null,result.Longitude__c);
    //System.assertNotEquals(null,result.Latitude__c);
  }


  static testmethod void testAutoGeocodingWithUpdate() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };

    insert settings;

    Account a = new Account(
      Name='Test'
    );

    insert a;

    Test.startTest();
    a.M3_Location_City__c = 'Red Wing';
    a.M3_Location_Street__c = '314 MAIN ST';
    a.M3_Location_State_Province__c = 'MN';
    a.M3_Location_Zip_Postal_Code__c = '55066';
    a.M3_Location_Country__c = 'US';
    update a;
    Test.stopTest();

    //Data.com isn't working with unit tests. Instead, the contact test below will mock the lat and long geocoding up to the account.
    //Account result = [Select Longitude__c,Latitude__c From Account];
    //System.assertNotEquals(null,result.Longitude__c);
    //System.assertNotEquals(null,result.Latitude__c);
  }


  static testmethod void testAutoGeocodingContactWithUpdate() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };

    insert settings;

    RecordType rt = [Select Id From RecordType Where DeveloperName = 'M3_Contact'];

    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US'
    );

    insert a;

    Contact c = new Contact(
      AccountId = a.Id
            ,M3_Account_Ext_Id__c = a.Id
            ,Firstname='M3'
            ,Lastname='Address'
            ,MailingStreet = a.M3_Location_Street__c
            ,MailingCity = a.M3_Location_City__c
            ,MailingState = a.M3_Location_State_Province__c
            ,MailingCountry = a.M3_Location_Country__c
            ,MailingPostalCode = a.M3_Location_ZIP_Postal_Code__c
            ,RecordTypeId = rt.Id
        );
        insert c;

    Test.startTest();

    c.MailingLatitude = 44.566353;
        c.MailingLongitude = -92.534672;
        update c;
    Test.stopTest();

    Account result = [Select Data_com_Longitude__c,Data_com_Latitude__c From Account];
    System.assertEquals(-92.534672,result.Data_com_Longitude__c);
    System.assertEquals(44.566353,result.Data_com_Latitude__c);
  }


  static testmethod void testAutoGeocodingContactInsert() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };

    insert settings;

    RecordType rt = [Select Id From RecordType Where DeveloperName = 'M3_Contact'];

    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US'
    );

    insert a;

    Test.startTest();
    Contact c = new Contact(
      AccountId = a.Id
            ,M3_Account_Ext_Id__c = a.Id
            ,Firstname='M3'
            ,Lastname='Address'
            ,MailingStreet = a.M3_Location_Street__c
            ,MailingCity = a.M3_Location_City__c
            ,MailingState = a.M3_Location_State_Province__c
            ,MailingCountry = a.M3_Location_Country__c
            ,MailingPostalCode = a.M3_Location_ZIP_Postal_Code__c
            ,RecordTypeId = rt.Id
            ,MailingLatitude = 44.566353
          ,MailingLongitude = -92.534672
        );
        insert c;
    Test.stopTest();

    Account result = [Select Data_com_Longitude__c,Data_com_Latitude__c From Account];
    System.assertEquals(-92.534672,result.Data_com_Longitude__c);
    System.assertEquals(44.566353,result.Data_com_Latitude__c);
    System.assertEquals(0,[Select Id From Contact].size());
  }
  
  static TestMethod void InsertNewAccountWithIncorrectBoxes()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;

		Account a = new Account(
			Name='Test'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = true
            ,Is_Standalone__c = false
            ,Is_Parent__c = true
		);
		insert a;
        
        Test.startTest();
        //Confirm the boxes were updated correctly
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        Test.stopTest();
    }
    
    static TestMethod void InsertNewAccountWithParent()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        //Confirm the single parent's boxes are correct
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        Account a2 = new Account(
			Name='Child'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		insert a2;
        
        Test.startTest();
        //Confirm the child's boxes were updated
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);

        //Confirm the parent's boxes were updated
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        Test.stopTest();
    }
    
    static TestMethod void RemoveChildFromAccountWithMultipleChildrenViaUpdate()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        List<Account> children = new List<Account>();
        Account a1 = new Account(
			Name='Child1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a1);
        
        Account a2 = new Account(
			Name='Child2'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a2);
        insert children;
        
        Test.startTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(2, result.Number_of_Children__c);
        
        //Remove the 2nd child's parent
        a2.ParentId = null;
        a2.Invoice_Parent_Account__c = null;
        update a2;
        
        Test.stopTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
    }
    
    static TestMethod void RemoveChildFromAccountWithMultipleChildrenViaDelete()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        List<Account> children = new List<Account>();
        Account a1 = new Account(
			Name='Child1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a1);
        
        Account a2 = new Account(
			Name='Child2'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a2);
        insert children;
        
        Test.startTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(2, result.Number_of_Children__c);
        
        //Remove the 2nd child
        delete a2;
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        Test.stopTest();
    }
    
    static TestMethod void AddParentToAccountWithChild()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        List<Account> children = new List<Account>();
        Account a1 = new Account(
			Name='Child1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a1);
        
        Account a2 = new Account(
			Name='SuperParent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		children.add(a2);
        insert children;
        
        Test.startTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        
        //Make a2 the parent of the original account
        a.ParentId = a2.Id;
        a.Invoice_Parent_Account__c = a2.Id;
        update a;
                
        Test.StopTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
    }
    
    static TestMethod void ChangeParentAccount()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        List<Account> accounts = new List<Account>();
        Account a1 = new Account(
			Name='Child'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		accounts.add(a1);
        
        Account a2 = new Account(
			Name='NewParent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		accounts.add(a2);
        insert accounts;
        
        Test.startTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        
        //Make a2 the parent of the child account
        a1.ParentId = a2.Id;
        a1.Invoice_Parent_Account__c = a2.Id;
        update a1;        
        
        Test.StopTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(1, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
    }
    
    static TestMethod void DeleteParentWithMultipleChildren()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        Account result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        List<Account> children = new List<Account>();
        Account a1 = new Account(
			Name='Child1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a1);
        
        Account a2 = new Account(
			Name='SuperParent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a2);
        insert children;
        
        Test.startTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(true, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(true, result.Is_Parent__c);
        System.assertEquals(false, result.Is_Standalone__c);
        System.assertEquals(2, result.Number_of_Children__c);
        
        //Delete the parent account and make final checks
        delete a;
        
        Test.StopTest();
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
    }

    static TestMethod void DeleteMiddleAccount()
    {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Business Partner Community' LIMIT 1].Id;
		
		Account a = new Account(
			Name='Parent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		insert a;
        
        List<Account> children = new List<Account>();
        Account a1 = new Account(
			Name='Child1'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = false
            ,Is_Parent__c = false
            ,ParentId = a.Id
            ,Invoice_Parent_Account__c = a.Id
		);
		children.add(a1);
        
        Account a2 = new Account(
			Name='SuperParent'
			,M3_Location_City__c = 'Red Wing'
			,M3_Location_Street__c = '314 MAIN ST'
			,M3_Location_State_Province__c = 'MN'
			,M3_Location_Zip_Postal_Code__c = '55066'
			,M3_Location_Country__c = 'US'
            ,RecordTypeId = recordTypeId
            ,Is_Child__c = false
            ,Is_Standalone__c = true
            ,Is_Parent__c = false
		);
		children.add(a2);
        insert children;
        
        Test.startTest();
        a.ParentId = a2.Id;
        a.Invoice_Parent_Account__c = a2.Id;
        update a;
                
        //Delete the middle account and make final checks
        delete a;
        
        Test.stopTest();
        Account result = [SELECT ParentId, Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a2.Id];
        System.assertEquals(null, result.ParentId);
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
        
        result = [SELECT ParentId, Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_of_Children__c FROM Account WHERE Id = :a1.Id];
        System.assertEquals(null, result.ParentId);
        System.assertEquals(false, result.Is_Child__c);
        System.assertEquals(false, result.Is_Parent__c);
        System.assertEquals(true, result.Is_Standalone__c);
        System.assertEquals(0, result.Number_of_Children__c);
    }

  static TestMethod void testUltimateParent() {
        Integer NUM_OF_KIDS = 5;

        /**
         * Final Hierarchy
         * AccountGeorge = gr. gr. grpa
         * AccountJames = gr. grpa
         * AccountCharles = grpa
         * AccountBob = dad
         * AccountKids = list of x "kids"  
         */

        //For this test - I don't want the publish records to run
        RWS_AccountTrigger_Handler.RUN_PUBLISH_RECORDS_ONCE = false;

        //Create x accounts - these will be the children; grand children - etc.
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        List<Account> accountKids = new List<Account>();
        for(Integer i = 0; i < NUM_OF_KIDS; i++) {
            Account acc = RWS_TestUtil.createAccount(rtId, false);
            acc.Name = acc.Name + i;
            accountKids.add(acc);
        }
        insert accountKids;

        //Create a "parent" account; assign the x 
        Account acctBob = RWS_TestUtil.createAccount(rtId, true);
        List<Account> updAccts = new List<Account>();
        for(Account a : accountKids) {
            a.ParentId = acctBob.Id;
            a.Invoice_Parent_Account__c = 'No';
            updAccts.add(a);
        }
        update updAccts;

        //asserts won't work; because the update is done via a future method - 
        //and the update isn't complete by the time we query for the info again.
        /**for(Account a: [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN :accountKids]) {
            System.assertEquals(a.Ultimate_Parent__c, acctBob.Id);
        }*/

        Account acctCharles = RWS_TestUtil.createAccount(rtId, true);
        acctBob.ParentId = acctCharles.Id;
        acctBob.Invoice_Parent_Account__c = 'No';
        update acctBob;

        /**for(Account a: [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN :accountKids]) {
            System.assertEquals(a.Ultimate_Parent__c, acctCharles.Id);
        }*/

        Account acctJames = RWS_TestUtil.createAccount(rtId, true);
        acctCharles.ParentId = acctJames.Id;
        acctCharles.Invoice_Parent_Account__c = 'No';
        update acctCharles;

        /**for(Account a: [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN :accountKids]) {
            System.assertEquals(a.Ultimate_Parent__c, acctJames.Id);
        }*/

        Account acctGeorge = RWS_TestUtil.createAccount(rtId, true);
        acctJames.ParentId = acctGeorge.Id;
        acctJames.Invoice_Parent_Account__c = 'No';
        update acctJames;

        /**for(Account a: [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN :accountKids]) {
            System.assertEquals(a.Ultimate_Parent__c, acctGeorge.Id);
        }*/
  }

}