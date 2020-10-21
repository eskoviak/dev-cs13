@isTest
public class RWS_Users_Tests {
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(201);
            Account a = [SELECT Id, M3_Location_City__c, AccountNumber, Phone FROM Account WHERE Name = 'First Avenue'];
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
            Contact c = new Contact( 
                  AccountId = a.Id,
                  Firstname = 'Frank',
                  Lastname = 'Sinatra',
                  Role__c = 'RED WING STORE - ' + a.M3_Location_City__c + ' Partner User',
                  Title = 'Store Manager',
                  Email = 'frank.sinatra@fake.com',
                  RWS_Id__c = 'frasina_' + a.AccountNumber,
                  Phone = a.Phone,
                  RecordTypeId = r.Id,
                  Entity_ID__c = '1234567',
                  EMS_Login__c = 'frasina'
                  
            );
            insert c;
            res.setBody('{"' + c.AccountId + '":"' + c.Id + '"}');
            return res;
        }
    }
    
    static testMethod void getEnvTests(){
        String result = '';
        
        //Case dev
        result = RWS_Users.getEnv('DEV');
        System.assertEquals('.dev', result);
        
        //Case test
        result = RWS_Users.getEnv('TST');
        System.assertEquals('.test', result);
        
        //Case prd
        result = RWS_Users.getEnv('PRD');
        System.assertEquals('', result);
        
        //Case error
        result = RWS_Users.getEnv('Bad env');
        System.assertEquals('ERROR', result);
    }
    
    static testMethod void createAliasTests(){
        String result = '';
        
        //Last name length greater than 4
        result = RWS_Users.createAlias('Albert', 'Bernstein');
        System.assertEquals('abern', result);
        
        //Last name length less than 4
        result = RWS_Users.createAlias('Albert', 'Ber');
        System.assertEquals('aber', result);
    }

    static testMethod void finalizeResponseTests() {
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        String failJson = '[Failed,';
        String successJson = '[P';
        Integer initLength = 5;
        res = RWS_Users.finalizeResponse(failJson, successJson, initLength);
        System.assertEquals(400, res.statusCode);
        System.assertEquals(blob.valueOf('{[P],[Failed]}'), res.responseBody);
        
        failJson = '[F';
        successJson = '[Passed,';
        initLength = 5;
        res = RWS_Users.finalizeResponse(failJson, successJson, initLength);
        System.assertEquals(200, res.statusCode);
        System.assertEquals(blob.valueOf('{[Passed],[F]}'), res.responseBody);
    }
    
    static testMethod void createContactsTest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
                Account a = new Account(
                    Name = 'First Avenue', 
                    Phone = '952-867-5309', 
                    Store_Number__c = '137', 
                    M3_Location_City__c = 'Minneapolis',
                    AccountNumber = '7654321',
                    IA_Physical_Location_City__c = 'Minneapolis'
                );
                insert a;
                
                RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
                String body = 'use Mock';
            Test.setMock(HttpCalloutMock.class, new Mock());
            Test.startTest();
            Map<String, String> result = RWS_Users.createContacts(body);
            Contact c = [Select Id, AccountId From Contact Where Email = 'frank.sinatra@fake.com'];
            System.assert(result.containsKey(c.AccountId));
            System.assertEquals(c.Id, result.get(c.AccountId));
            Test.stopTest();
        }
        
    }
    
    static testMethod void createRemovePermissions() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : [""], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "false", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entitycode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        Test.startTest();
    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        RWS_Users.create();
        System.assertEquals(blob.valueOf('{"Success messages": [{"1112223": "No permissions to remove for entityId."}],"Failure messages": []}'), res.responseBody); 
        Test.stopTest();
    }
    
    static testMethod void createInvalidEnv() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["1231231", "3213213"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "false", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "RAWR", "sfdcEnv" : "cs67"}';
        Test.startTest();
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        RWS_Users.create();
        
        System.assertEquals(blob.valueOf('{"Success messages": [],"Failure messages": [{"reason": "Environment RAWR is not valid."}]}'), res.responseBody);
        Test.stopTest();
    }
    
    static testMethod void createInvalidLogin() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhallllllll", "customerNumber" : ["1231231", "3213213"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "false", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        Test.startTest();
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        RWS_Users.create();
        System.assertEquals(blob.valueOf('{"Success messages": [],"Failure messages": [{"reason": "Login field must exist and cannot exceed 10 characters."}]}'), res.responseBody);
        Test.stopTest();
    }
    
    static testMethod void createEmptyFields() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["1231231", "3213213"], "id" : "", "jobTitle" : "Store Manager", "active" : "false", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        Test.startTest();
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        RWS_Users.create();
        
        System.assertEquals(blob.valueOf('{"Success messages": [],"Failure messages": [{"reason": "Values for environment, firstName, id, lastName are required."}]}'), res.responseBody); 
        Test.stopTest();
    }
    
    static testMethod void createInvalidAccountNumber() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["1231231"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "false", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        Test.startTest();
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        RWS_Users.create();
        
        System.assertEquals(blob.valueOf('{"Success messages": [],"Failure messages": [{"1112223": "FAILED", "reason": "Unable to find all specified accounts."}]}'), res.responseBody); 
    	Test.stopTest();
    }
    
    static testMethod void createInsertOnePair() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["7654321"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "true", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(
                Name = 'First Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '137', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654321'
            );
            insert a;
            Profile p = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1];
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
            String[] customerNumber = new String[]{''};
            
            Test.setMock(HttpCalloutMock.class, new Mock());
            Test.startTest();
            RWS_Users.create();
            System.assertEquals(blob.valueOf('{"Success messages": [{"1112223": "Created Contact and User for andhall in store(s): 137."}],"Failure messages": []}'), res.responseBody);
            System.assertEquals(200, res.statusCode);
            Test.stopTest();
        }
    }
    
    static testMethod void createTwoPair() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["7654321", "7654320"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "true", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(
                Name = 'First Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '137', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654321'
            );
            insert a;
            Account a2 = new Account(
                Name = 'Second Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '138', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654320'
            );
            insert a2;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1];
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
            
            Contact c = new Contact( 
                  AccountId = a.Id,
                  Firstname = 'Andy',
                  Lastname = 'Hall',
                  Role__c = 'RED WING STORE - ' + a.M3_Location_City__c + ' Partner User',
                  Title = 'Store Manager',
                  Email = 'andy.hall@fake.com',
                  RWS_Id__c = 'andhall_' + a.AccountNumber,
                  Phone = a.Phone,
                  RecordTypeId = r.Id,
                  Entity_ID__c = '1112223',
                  EMS_Login__c = 'andhall',
                  Active__c = false
            );
            insert c;
            
            User u = new User(LastName = 'Hall',
                              FirstName='Andy',
                              Alias = 'ahall',
                              Email = 'andy.hall@fake.com',
                              Username = 'andhall@137redwingshoes.com.dev',
                              ProfileId = p.Id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              ContactId = c.Id,
                              IsActive = false
                              );
            insert u;
            
            c.OwnerId = u.Id;
            update c;
            
            Test.setMock(HttpCalloutMock.class, new Mock());
            Test.startTest();
            //Insert 2nd
            RWS_Users.create();
            System.assertEquals(blob.valueOf('{"Success messages": [{"1112223": "Created Contact and User for andhall in store(s): 138."},{"1112223": "Queued Contact(s) updates in store(s): 137."},{"1112223": "Updated User(s) in store(s): 137."}],"Failure messages": []}'), res.responseBody);
            System.assertEquals(200, res.statusCode);
            Test.stopTest();
        }
    }
    
    static testMethod void deactivateTest() {
        String jsonMsg='{"emailAddress":"andy.hall@fake.com", "firstName" : "Andy", "lastName" : "Hall", "middleName" : "F", "login" : "andhall", "customerNumber" : ["7654321"], "id" : "1112223", "jobTitle" : "Store Manager", "active" : "true", "applicationRoleName" : "appRoleName", "applicationRoleCode" : "appRoleCode", "applicationRoleId" : "appRoleId", "applicationName" : "appName", "applicationCode" : "appCode", "applicationId" : "appId", "entityTypeName" : "entityName", "entityTypeCode" : "entityCode", "entityTypeId" : "entityId", "environment" : "DEV", "sfdcEnv" : "cs67"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/users';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(
                Name = 'First Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '137', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654321'
            );
            insert a;
            Account a2 = new Account(
                Name = 'Second Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '138', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654320'
            );
            insert a2;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1];
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
            
            Contact c = new Contact( 
                  AccountId = a.Id,
                  Firstname = 'Andy',
                  Lastname = 'Hall',
                  Role__c = 'RED WING STORE - ' + a.M3_Location_City__c + ' Partner User',
                  Title = 'Store Manager',
                  Email = 'andy.hall@fake.com',
                  RWS_Id__c = 'andhall_' + a.AccountNumber,
                  Phone = a.Phone,
                  RecordTypeId = r.Id,
                  Entity_ID__c = '1112223',
                  EMS_Login__c = 'andhall',
                  Active__c = true
            );
            insert c;
            Contact c2 = new Contact( 
                  AccountId = a2.Id,
                  Firstname = 'Andy',
                  Lastname = 'Hall',
                  Role__c = 'RED WING STORE - ' + a2.M3_Location_City__c + ' Partner User',
                  Title = 'Store Manager',
                  Email = 'andy.hall@fake.com',
                  RWS_Id__c = 'andhall_' + a2.AccountNumber,
                  Phone = a2.Phone,
                  RecordTypeId = r.Id,
                  Entity_ID__c = '1112223',
                  EMS_Login__c = 'andhall',
                  Active__c = true
            );
            insert c2;
            
            User u = new User(LastName = 'Hall',
                              FirstName='Andy',
                              Alias = 'ahall',
                              Email = 'andy.hall@fake.com',
                              Username = 'andhall@137redwingshoes.com.dev',
                              ProfileId = p.Id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              ContactId = c.Id,
                              IsActive = true
                              );
            insert u;
            User u2 = new User(LastName = 'Hall',
                              FirstName='Andy',
                              Alias = 'ahall',
                              Email = 'andy.hall@fake.com',
                              Username = 'andhall@138redwingshoes.com.dev',
                              ProfileId = p.Id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              ContactId = c2.Id,
                              IsActive = true
                              );
            insert u2;
            
            c.OwnerId = u.Id;
            update c;
            c2.OwnerId = u2.Id;
            update c2;
            
            Test.setMock(HttpCalloutMock.class, new Mock());
            Test.startTest();
            //Deactivate user2
            RWS_Users.create();
            System.assertEquals(blob.valueOf('{"Success messages": [{"1112223": "Update not required for Contact with Store Number= 137."},{"1112223": "Update not required for User with Store Number= 137."},{"1112223": "Queued Contact(s) updates in store(s): 138."},{"1112223": "Updated User(s) in store(s): 138."}],"Failure messages": []}'), res.responseBody);
            System.assertEquals(200, res.statusCode);
            System.assertEquals(false, [Select IsActive From User Where Username = 'andhall@138redwingshoes.com.dev'][0].IsActive);
            Test.stopTest();
        }
    }
    
    static testMethod void removeAllPermissionsTestHappyPath() {
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Account a = new Account(
                Name = 'First Avenue', 
                Phone = '952-867-5309', 
                Store_Number__c = '137', 
                M3_Location_City__c = 'Minneapolis',
                AccountNumber = '7654321'
            );
        	insert a;
            
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
        	Contact c = new Contact( 
                  AccountId = a.Id,
                  Firstname = 'Frank',
                  Lastname = 'Sinatra',
                  Role__c = 'RED WING STORE - ' + a.M3_Location_City__c + ' Partner User',
                  Title = 'Store Manager',
                  Email = 'frank.sinatra@fake.com',
                  RWS_Id__c = 'frasina_' + a.AccountNumber,
                  Phone = a.Phone,
                  RecordTypeId = r.Id,
                  Entity_ID__c = '1234567',
                  EMS_Login__c = 'frasina',
                  Active__c = true
            );
            insert c;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='RWS Business Partner Community' LIMIT 1];
            User u = new User(LastName = 'Sinatra',
                              FirstName='Frank',
                              Alias = 'fsina',
                              Email = 'frank.sinatra@fake.com',
                              Username = 'frasina@137redwingshoes.com.dev',
                              ProfileId = p.Id,
                              TimeZoneSidKey = 'GMT',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'UTF-8',
                              LocaleSidKey = 'en_US',
                              ContactId = c.Id,
                              IsActive = true
                              );
            insert u;
            
            c.OwnerId = u.Id;
            update c;
            
            System.assertEquals(true, c.Active__c);
            System.assertEquals(true, u.IsActive);
            res = RWS_Users.removeAllPermissions(c.Entity_ID__c);
            System.assertEquals(false, [Select IsActive From User Where Username = 'frasina@137redwingshoes.com.dev'][0].IsActive);
        }
    }
    
    static testMethod void removeAllPermissionsTestInvalidContact() {
        RestResponse res = new RestResponse();
        RestContext.response = res;
    	String expected = '{"Success messages": [{"invalidId": "No permissions to remove for entityId."}],"Failure messages": []}';
        
        res = RWS_Users.removeAllPermissions('invalidId');
        System.assertEquals(200, res.statusCode);
        System.assertEquals(blob.valueOf(expected), res.responseBody);
    }
    
}