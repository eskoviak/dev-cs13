@isTest
public class ClaimsForm_Controller_Test 
{
	private static Account CreateStoreData()
    {
        Account a = new Account(
            Name = 'First Avenue', 
            Phone = '952-867-5309', 
            Store_Number__c = '137',
            M3_Location_City__c = 'Minneapolis',
            M3_Location_State_Province__c = 'Minnesota',
            M3_Location_ZIP_Postal_Code__c = '12345',
            M3_Location_Country__c = 'United States',
            AccountNumber = '7654321'
        );		
        insert a;
        return a;
    }
    
    private static User CreateUserAndContact(Account a, Id profileId, Id recordTypeId)
    {
        Contact c = new Contact( 
            AccountId = a.Id,
            Firstname = 'Andy',
            Lastname = 'Hall',
            Title = 'Store Manager',
            Email = 'andy.hall@fake.com',
            RWS_Id__c = 'andhall_' + a.AccountNumber,
            Phone = a.Phone,
            RecordTypeId = recordTypeId,
            Entity_ID__c = '1112223',
            EMS_Login__c = 'andhall',
            Active__c = true
        );
        insert c;
            
        User u = new User(
            LastName = 'Hall',
            FirstName='Andy',
            Alias = 'ahall',
            Email = 'andy.hall@fake.com',
            Username = 'andhall@137redwingshoes.com.dev',
            ProfileId = profileId,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            ContactId = c.Id,
            IsActive = true
        );
        insert u;
        return u;
    }
    
    private static AccountTeamMember CreateROM(Account a)
    {
        Contact c = new Contact( 
            AccountId = a.Id,
            Firstname = 'Rom',
            Lastname = 'Rommy',
            Title = 'Retail Operations Manager',
            Email = 'Rom.Rommy@fake.com',
            RWS_Id__c = 'romromm_' + a.AccountNumber,
            Phone = a.Phone,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'M3_Contact' LIMIT 1].Id,
            Entity_ID__c = '4445556',
            EMS_Login__c = 'romromm',
            Active__c = true
        );
        insert c;
            
        User u = new User(
            LastName = 'Rommy',
            FirstName='Rom',
            Alias = 'rromm',
            Email = 'Rom.Rommy@fake.com',
            Username = 'romromm@137redwingshoes.com.dev',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            ContactId = c.Id,
            IsActive = true
        );
        insert u;
        
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = a.Id,
            TeamMemberRole = 'Retail Operations Manager',
            UserId = u.Id
        );
        
        insert atm;
        return atm;
    }
    
    private static AccountTeamMember CreateSalesRep(Account a)
    {
        Contact c = new Contact( 
            AccountId = a.Id,
            Firstname = 'Sales',
            Lastname = 'Represent',
            Title = 'Sales Rep',
            Email = 'Sales.Represent@fake.com',
            RWS_Id__c = 'salrepr_' + a.AccountNumber,
            Phone = a.Phone,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'M3_Contact' LIMIT 1].Id,
            Entity_ID__c = '7778889',
            EMS_Login__c = 'salrepr',
            Active__c = true
        );
        insert c;
            
        User u = new User(
            LastName = 'Represent',
            FirstName='Sales',
            Alias = 'srepr',
            Email = 'sales.represent@fake.com',
            Username = 'salrepr@137redwingshoes.com.dev',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            ContactId = c.Id,
            IsActive = true
        );
        insert u;
        
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = a.Id,
            TeamMemberRole = 'Sales Rep',
            UserId = u.Id
        );
        
        insert atm;
        return atm;
    }
    
    private static AccountTeamMember CreateRegionDirector(Account a)
    {
        Contact c = new Contact( 
            AccountId = a.Id,
            Firstname = 'Region',
            Lastname = 'Director',
            Title = 'Region Director',
            Email = 'region.director@fake.com',
            RWS_Id__c = 'regdire_' + a.AccountNumber,
            Phone = a.Phone,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'M3_Contact' LIMIT 1].Id,
            Entity_ID__c = '9998887',
            EMS_Login__c = 'regdire',
            Active__c = true
        );
        insert c;
            
        User u = new User(
            LastName = 'Director',
            FirstName='Region',
            Alias = 'rdire',
            Email = 'region.director@fake.com',
            Username = 'regdire@137redwingshoes.com.dev',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            ContactId = c.Id,
            IsActive = true
        );
        insert u;
        
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = a.Id,
            TeamMemberRole = 'Region Director',
            UserId = u.Id
        );
        
        insert atm;
        return atm;
    }
    
    private static Case MainAsserts(PageReference pr, Account a, ClaimsForm_Controller controller)
    {
        System.assertNotEquals(null, pr);
        Case cs = [Select Id, 
                   Account_Number__c, 
                   Account_Type__c, 
                   PO_and_Orginal_Invoice_Numbers__c, 
                   Order__c, 
                   Type, 
                   Subject, 
                   Claim_City__c,
                   Claim_State__c,
                   Claim_Postal_Code__c,
                   Claim_Country__c,
                   Reason,
                   Description,
                   CreatedDate,
                   Status,
                   Origin,
                   RecordTypeId,
                   OwnerId,
                   Sales_Rep__c
                   FROM Case
                   WHERE Account_Number__c = :a.AccountNumber];
        
        System.assertEquals(a.AccountNumber, cs.Account_Number__c);
        System.assertEquals(controller.AccountType, cs.Account_Type__c);
        System.assertEquals(controller.Orders.replaceAll(',', '\r\n'), cs.PO_and_Orginal_Invoice_Numbers__c);
        System.assertEquals(controller.OrderNumber, cs.Order__c);
        System.assertEquals('DTI Claim', cs.Type);
        System.assertEquals('Product Claim', cs.Subject);
        System.assertEquals(a.M3_Location_City__c, cs.Claim_City__c);
        System.assertEquals(a.M3_Location_State_Province__c, cs.Claim_State__c);
        System.assertEquals(a.M3_Location_ZIP_Postal_Code__c, cs.Claim_Postal_Code__c);
        System.assertEquals(a.M3_Location_Country__c, cs.Claim_Country__c);
        System.assertEquals('Return Authorization (RA)', cs.Reason);
        System.assertEquals(controller.IssueDescription, cs.Description);
        System.assertNotEquals(null, cs.CreatedDate);
        System.assertEquals('New', cs.Status);
        System.assertEquals('Claim Form', cs.Origin);
        System.assertEquals([SELECT Id FROM RecordType WHERE Name = 'DTI Claim' LIMIT 1].Id, cs.RecordTypeId);
        
        return cs;
    }
    
	static testMethod void InsertNewCaseTest_NoData()
    {
        ClaimsForm_Controller controller = new ClaimsForm_Controller();
        PageReference pr = controller.InsertNewCase();
        System.assertEquals(null, pr);
    }

    static testMethod void InsertNewCaseTest_NoTeam()
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        Account a;
        System.runAs(thisUser) {
            a = CreateStoreData();
            Id profileId = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1].Id;
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1].Id;
            u = CreateUserAndContact(a, profileId, recordTypeId);
        }
        System.runAs(u)
        {
            ClaimsForm_Controller controller = new ClaimsForm_Controller();
            controller.AccountType = 'US RWSS';
    		controller.Orders = '123';
    		controller.IssueDescription = 'Something';
    		controller.OrderNumber = 'Order#1';
        	PageReference pr = controller.InsertNewCase();
            
            Case cs = MainAsserts(pr, a, controller);

			System.assertEquals([SELECT Id FROM User WHERE FirstName = 'Chris' AND LastName = 'Doman' AND email = 'chris.doman@redwingshoes.com'].Id, cs.OwnerId);
            System.assertEquals(null, cs.Sales_Rep__c);
        }        
    }
    
    static testMethod void InsertNewCaseTest_OnlyROM()
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        Account a;
        AccountTeamMember rom;
        System.runAs(thisUser) {
            a = CreateStoreData();
            Id profileId = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1].Id;
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1].Id;
            u = CreateUserAndContact(a, profileId, recordTypeId);
            
            rom = CreateROM(a);
        }
        System.runAs(u)
        {
            ClaimsForm_Controller controller = new ClaimsForm_Controller();
            controller.AccountType = 'US RWSS';
    		controller.Orders = '123';
    		controller.IssueDescription = 'Something';
    		controller.OrderNumber = 'Order#1';
        	PageReference pr = controller.InsertNewCase();
            
            Case cs = MainAsserts(pr, a, controller);

			System.assertEquals(rom.UserId, cs.OwnerId);
            System.assertEquals(null, cs.Sales_Rep__c);
        }        
    }
    
    static testMethod void InsertNewCaseTest_OnlySalesRep()
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        Account a;
        AccountTeamMember rep;
        System.runAs(thisUser) {
            a = CreateStoreData();
            Id profileId = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1].Id;
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1].Id;
            u = CreateUserAndContact(a, profileId, recordTypeId);
            rep = CreateSalesRep(a);
        }
        System.runAs(u)
        {
            ClaimsForm_Controller controller = new ClaimsForm_Controller();
            controller.AccountType = 'US RWSS';
    		controller.Orders = '123';
    		controller.IssueDescription = 'Something';
    		controller.OrderNumber = 'Order#1';
        	PageReference pr = controller.InsertNewCase();
            
            Case cs = MainAsserts(pr, a, controller);

			System.assertEquals(rep.UserId, cs.OwnerId);
            System.assertEquals(rep.UserId, cs.Sales_Rep__c);
        }        
    }
    
    static testMethod void InsertNewCaseTest_OnlyRegionDirector()
    {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        Account a;
        AccountTeamMember rd;
        System.runAs(thisUser) {
            a = CreateStoreData();
            Id profileId = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1].Id;
            Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1].Id;
            u = CreateUserAndContact(a, profileId, recordTypeId);
            rd = CreateRegionDirector(a);
        }
        System.runAs(u)
        {
            ClaimsForm_Controller controller = new ClaimsForm_Controller();
            controller.AccountType = 'US RWSS';
    		controller.Orders = '123';
    		controller.IssueDescription = 'Something';
    		controller.OrderNumber = 'Order#1';
        	PageReference pr = controller.InsertNewCase();
            
            Case cs = MainAsserts(pr, a, controller);

			System.assertEquals(rd.UserId, cs.OwnerId);
            System.assertEquals(rd.UserId, cs.Sales_Rep__c);
        }        
    }
    
    static testMethod void InsertPictureToDocuments_Test()
    {
        ClaimsForm_Controller c = new ClaimsForm_Controller();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) 
        {
            Blob file = Blob.valueOf('This is my file');
            String fileName = 'testfile.jpg';
            String result = c.InsertPictureToDocuments(file, fileName);
            System.assert(result.length() > 0);
        }
    }
}