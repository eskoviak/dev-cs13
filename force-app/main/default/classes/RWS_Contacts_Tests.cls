@isTest
public class RWS_Contacts_Tests {
    static testMethod void createContactTest() {
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
            String body = '{"contacts" : [{"accountId":"' + a.Id + '", "firstName":"Andy", "lastName":"Hall", "jobTitle":"Store Manager", "emailAddress":"andy.hall@fake.com", "login":"andhall", "accountPhone":"' + a.Phone + 
    					  '", "recordId":"' + r.Id + '", "id":"1112223", "accountNumber":"' + a.AccountNumber + '", "active":"true"}]}';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/users';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(body);
            RestContext.request = req;
            RestContext.response = res;
            
            RWS_Contacts.createContacts();
            System.assertEquals(201, res.statusCode);
            Contact c = [SELECT AccountId, Firstname, Lastname, Role__c, Title, RWS_Id__c, Phone, RecordTypeId, Entity_ID__c, EMS_Login__c, Active__c FROM Contact WHERE Email = 'andy.hall@fake.com'];
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals('Andy', c.FirstName);
            System.assertEquals('Hall', c.Lastname);
            System.assertEquals('Store Manager', c.Title);
            System.assertEquals('andhall_' + a.AccountNumber, c.RWS_Id__c);
            System.assertEquals(a.Phone, c.Phone);
            System.assertEquals(r.Id, c.RecordTypeId);
            System.assertEquals('1112223', c.Entity_ID__c);
            System.assertEquals('andhall', c.EMS_Login__c);
            System.assertEquals(true, c.Active__c);
        }
    }
    
    static testMethod void createContactTestMultiple() {
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
            Account a2 = new Account(
                Name = 'Second Avenue', 
                Phone = '952-867-5308', 
                Store_Number__c = '138', 
                M3_Location_City__c = 'St. Paul',
                AccountNumber = '7654320',
                IA_Physical_Location_City__c = 'St. Paul'
            );
            insert a2;
            
            RecordType r = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
            String body = '{"contacts" : [{"accountId":"' + a.Id + '", "firstName":"Andy", "lastName":"Hall", "jobTitle":"Store Manager", "emailAddress":"andy.hall@fake.com", "login":"andhall", "accountPhone":"' + a.Phone + 
    					  '", "recordId":"' + r.Id + '", "id":"1112223", "accountNumber":"' + a.AccountNumber + '", "active":"true"},' +
                		  '{"accountId":"' + a2.Id + '", "firstName":"Frank", "lastName":"Sinatra", "jobTitle":"Store Manager", "emailAddress":"frank.sinatra@fake.com", "login":"frasina", "accountPhone":"' + a2.Phone + 
    					  '", "recordId":"' + r.Id + '", "id":"1112224", "accountNumber":"' + a2.AccountNumber + '", "active":"true"}]}';
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        
            req.requestURI = '/services/apexrest/users';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(body);
            RestContext.request = req;
            RestContext.response = res;
            
            RWS_Contacts.createContacts();
            System.assertEquals(201, res.statusCode);
            Contact c = [SELECT AccountId, Firstname, Lastname, Role__c, Title, RWS_Id__c, Phone, RecordTypeId, Entity_ID__c, EMS_Login__c, Active__c FROM Contact WHERE Email = 'andy.hall@fake.com'];
            System.assertEquals(a.Id, c.AccountId);
            System.assertEquals('Andy', c.FirstName);
            System.assertEquals('Hall', c.Lastname);
            System.assertEquals('Store Manager', c.Title);
            System.assertEquals('andhall_' + a.AccountNumber, c.RWS_Id__c);
            System.assertEquals(a.Phone, c.Phone);
            System.assertEquals(r.Id, c.RecordTypeId);
            System.assertEquals('1112223', c.Entity_ID__c);
            System.assertEquals('andhall', c.EMS_Login__c);
            System.assertEquals(true, c.Active__c);
            
            Contact c2 = [SELECT AccountId, Firstname, Lastname, Role__c, Title, RWS_Id__c, Phone, RecordTypeId, Entity_ID__c, EMS_Login__c, Active__c FROM Contact WHERE Email = 'frank.sinatra@fake.com'];
            System.assertEquals(a2.Id, c2.AccountId);
            System.assertEquals('Frank', c2.FirstName);
            System.assertEquals('Sinatra', c2.Lastname);
            System.assertEquals('Store Manager', c2.Title);
            System.assertEquals('frasina_' + a2.AccountNumber, c2.RWS_Id__c);
            System.assertEquals(a2.Phone, c2.Phone);
            System.assertEquals(r.Id, c2.RecordTypeId);
            System.assertEquals('1112224', c2.Entity_ID__c);
            System.assertEquals('frasina', c2.EMS_Login__c);
            System.assertEquals(true, c2.Active__c);
        }
    }
}