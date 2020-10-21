@RestResource(urlMapping='/users/*')
global with sharing class RWS_Users {
    
    @TestVisible 
    private static String getEnv(String environment){
        //Verify environment is DEV, TST, or PRD
        if(environment.equals('DEV')){
            return '.dev';
        }
        else if(environment.equals('TST')){
            return '.test';
        }
        else if(environment.equals('PRD')){
            return '';
        }
        return 'ERROR';
    }
    
    @TestVisible 
    private static String createAlias(String firstName, String lastName){
        String alias = '';
        if(firstName.length() >= 1){
            alias += firstName.substring(0,1);
        }
        if(lastName.length() <= 4){
            alias += lastName;
        }
        else if(lastName.length() > 4){
            alias += lastName.substring(0,4);
        }
        return alias.toLowerCase();
    }
    
    @TestVisible 
    private static RestResponse finalizeResponse(String failJsonResponse, String successJsonResponse, Integer initLength) {
        RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
        if(failJsonResponse.length() > initLength) {
        	failJsonResponse = failJsonResponse.substring(0, failJsonResponse.length()-1) + ']';
            res.statusCode = 400;
        }
        else {
        	res.statusCode = 200;
            failJsonResponse += ']';
        }
        if(successJsonResponse.length() > initLength) {
            successJsonResponse = successJsonResponse.substring(0, successJsonResponse.length()-1) + ']';
        }
        else {
            successJsonResponse += ']';                              
        }
        res.responseBody = blob.valueOf('{' + successJsonResponse + ',' + failJsonResponse + '}');
        return res;
    }

    @TestVisible
    private static Map<String, String> createContacts(String body) {
        try { 
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Content-Length','1024');
            req.setBody(body);
            req.setTimeout(120000);
            String endpoint = 'https://' + URL.getSalesforceBaseUrl().getHost() + '/services/apexrest/contacts'; 
            req.setEndpoint(endpoint);   
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            HTTPResponse resp = http.send(req);
            Map<String, String> m = (Map<String, String>) JSON.deserialize(resp.getBody(), Map<String, String>.class);
            return m;
        }
        catch(CalloutException ex) {
            System.debug('Failed to Create Contact ' + ex.getMessage());
        }
        return null;    
    }
    
    @TestVisible @HttpPost 
    global static void create() {
        //Initialize response
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		String successJsonResponse = '"Success messages": [';
        String failJsonResponse =    '"Failure messages": [';
        Integer initLength = 21;
		try {
            //Parse fields from incoming payload
            Map<String, Object> emsObj = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            String id = (String)emsObj.get('id');
            List<Object> objCustomerNumbers = (List<Object>)emsObj.get('customerNumber');
            Set<String> customerNumber = new Set<String>();
            for(Object objCustomer : objCustomerNumbers) {
                if(String.valueOf(objCustomer) != '') {
                    customerNumber.add(String.valueOf(objCustomer));
                }
            }
            String firstName = (String)emsObj.get('firstName');
            String lastName = (String)emsObj.get('lastName'); 
            String applicationRoleName = (String)emsObj.get('applicationRoleName');
            String jobTitle = (String)emsObj.get('jobTitle'); 
            String emailAddress = '';
            //dealership stores may not have emails, in which case we need to construct one later
            //format: rwss{storeNumber}@redwingshoes.com
            if(!(emsObj.get('emailAddress') == null || (String)emsObj.get('emailAddress') == '')) {
                emailAddress = (String)emsObj.get('emailAddress');
            }
            String login = (String)emsObj.get('login'); 
            String environment = (String)emsObj.get('environment');
            String middleName = (String)emsObj.get('middleName');
            String active = (String)emsObj.get('active');
            String applicationRoleCode = (String)emsObj.get('applicationRoleCode');
            String applicationRoleId = (String)emsObj.get('applicationRoleId');
            String applicationName = (String)emsObj.get('applicationName');
            String applicationCode = (String)emsObj.get('applicationCode');
            String applicationId = (String)emsObj.get('applicationId');
            String entityTypeName = (String)emsObj.get('entityTypeName');
            String entityTypeCode = (String)emsObj.get('entityTypeCode');
            String entityTypeId = (String)emsObj.get('entityTypeId');
            
            //If there are no customerNumbers, we are removing the permissions for that id
            if(customerNumber.size() == 0) {
                res = removeAllPermissions(id);
                return;
            }
            
            //Verify environment is correct
            String env = getEnv(environment);
            if(env.equals('ERROR')){
                failJsonResponse += '{"reason": "Environment ' + environment + ' is not valid."},';
                res = finalizeResponse(failJsonResponse, successJsonResponse, initLength);
                return;                                
            } 
            
            //Verify login is less than 11 characters
            if(login.length() > 10 || String.isBlank(login)) {
                failJsonResponse += '{"reason": "Login field must exist and cannot exceed 10 characters."},';
                res = finalizeResponse(failJsonResponse, successJsonResponse, initLength);
                return; 
            }
                  
            //Check if required fields are empty
            if(String.isBlank(environment) || String.isBlank(firstName) || String.isBlank(id) || String.isBlank(lastName)){
                failJsonResponse += '{"reason": "Values for environment, firstName, id, lastName are required."},';
                res = finalizeResponse(failJsonResponse, successJsonResponse, initLength);
                return; 
            }
            
            res = processContacts(customerNumber, login, successJsonResponse,  failJsonResponse, 
                                          firstName, lastName, jobTitle, emailAddress, id, env, initLength, Boolean.valueOf(active)); 
            //res = finalizeResponse(failJsonResponse, successJsonResponse, initLength);
            return;
        }
        catch(ConnectApi.RateLimitException ex) {
            failJsonResponse += '{"reason": "REST API rate limit exceeded."},';                                 
        }
		catch(exception ex) {
            failJsonResponse += '{"reason": "Internal Server Error."},';
            System.debug('exception ' + ex.getMessage());
        }                        
        res = finalizeResponse(failJsonResponse, successJsonResponse, initLength);
    }
    
    @TestVisible 
    private static RestResponse processContacts(Set<String> customerNumber, String login, String successJsonResponse, String failJsonResponse, 
                                                String firstName, String lastName, String jobTitle, String emailAddress, String id, String env, 
                                                Integer initLength, Boolean active) {
        Map<Id, String> updateContacts = new Map<Id, String>();
        Map<Id, Boolean> updateUsers = new Map<Id, Boolean>();                                     
        List<User> newUsers = new List<User>();
        String newContacts = '{"contacts" : [';
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'RWS Business Partner Community' LIMIT 1];
        String profileId = (String)profile.Id;
        RecordType recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Partner_Community_Users' LIMIT 1];
        Integer remainder = Math.mod(customerNumber.size(), 200);
        String storeList = '';
        String accountList = '';
        String updatedStoreListContacts = '';
        String updatedStoreListUsers = '';                                      
                                                    
        for(List<Account> customerAccounts : [SELECT Id, Name, Phone, Store_Number__c, IA_Physical_Location_City__c, AccountNumber FROM Account WHERE AccountNumber IN :customerNumber]) {            
            for(List<User> users : [SELECT ContactId, Contact.Active__c, Contact.Entity_ID__c, Contact.Account_Number__c, Contact.Account_Store_Number__c, IsActive, Username, Contact.AccountId 
                                          FROM User WHERE Contact.Entity_ID__c = :id]) {
             if(customerAccounts.size() != 200 && customerAccounts.size() != remainder) {
                failJsonResponse += '{"' + id + '": "FAILED", "reason": "Unable to find all specified accounts."},';
                return finalizeResponse(failJsonResponse, successJsonResponse, initLength);
            }
                for(User u : users) {
                    Boolean found = false;
                    for(Integer i = customerAccounts.size() - 1; i >= 0; i--) {
                        Account a = customerAccounts.get(i);
                        
                        //We matched an account, activate the associated Contact and User (if they aren't already the active status)
                        if(u.Contact.Account_Number__c == a.AccountNumber) {
                            if(u.ContactId != null) {
                                if(u.Contact.Active__c != active) {
                                    updateContacts.put(u.ContactId, String.valueOf(active));
                                    updatedStoreListContacts += ' ' + a.Store_Number__c;
                                }
                                else {
                                    successJsonResponse += '{"' + u.Contact.Entity_ID__c + '": "Update not required for Contact with Store Number= ' + u.Contact.Account_Store_Number__c + '."},';
                                }
                            }
                            else {
                                failJsonResponse += '{"' + Id + '": "Unable to find corresponding Contact for Id= ' + u.ContactId + '."},';
                            }
                            
                            if(u.IsActive != active) {
                                updateUsers.put(u.Id, active);
                                updatedStoreListUsers += ' ' + a.Store_Number__c;
                            }
                            else {
                                successJsonResponse += '{"' + u.Contact.Entity_ID__c + '": "Update not required for User with Store Number= ' + u.Contact.Account_Store_Number__c + '."},';
                            }
                            customerAccounts.remove(i);
                            found = true;
                            break;
                        }
                    }
                    if(!found) {
                        //We didn't find the account in the list of customerNumbers, we need to deactivate the User+Contact
                        if(u.IsActive != false){
                            updateUsers.put(u.Id, false);
                            updatedStoreListUsers += ' ' + u.Contact.Account_Store_Number__c;
                        }
                        else {
                            successJsonResponse += '{"' + u.Contact.Entity_ID__c + '": "Update not required for User with Store Number= ' + u.Contact.Account_Store_Number__c + '."},';
                        }
                        if(u.ContactId != null) {
                            if(u.Contact.Active__c != false) {
                                updateContacts.put(u.ContactId, 'false');
                                updatedStoreListContacts += ' ' + u.Contact.Account_Store_Number__c;
                            }
                            else {
                                successJsonResponse += '{"' + u.Contact.Entity_ID__c + '": "Update not required for Contact with Store Number= ' + u.Contact.Account_Store_Number__c + '."},';
                            }
                        }
                        else {
                            failJsonResponse += '{"' + Id + '": "Unable to find corresponding Contact for Id= ' + u.Id + '."},';
                        }
                    }
                }
                                              
                //For any accounts still in the list, we need to create new Users+contacts for them
                //First, make all the contacts to avoid "uncommited transaction" errors
                for(Account a : customerAccounts) {
                    if(emailAddress == '') {
                        //create dealership email
                        emailAddress = 'rwss' + a.Store_Number__c + '@redwingshoes.com';
                    }
                    newContacts += '{"accountId":"' + a.Id + '", "firstName":"' + firstName + '", "lastName":"' + lastName + '", "jobTitle":"' + jobTitle + 
                                 '", "emailAddress":"' + emailAddress + '", "login":"' + login + '", "accountPhone":"' + a.Phone + 
                                 '", "recordId":"' + recordId.Id + '", "id":"' + id + '", "accountNumber":"' + a.AccountNumber + '", "active":"' + active + '"},';
                    
                    //Storing AccountId in the ContactId field so we can get the mapped value of ContactId later
                    newUsers.add(createUserToInsert(firstName, lastName, login, a.Store_Number__c, env, (String)a.Id, (String)profileId, emailAddress, active));
                    storeList += ' ' + a.Store_Number__c;
                    accountList += ' ' + a.Name;
                }
            }
        }
        
        //If we have new records to insert, call the helper method that will invoke an HttpRequest, allowing us to create the Contacts then Users
        if(newContacts.length() > 15) {
            newContacts = newContacts.substring(0, newContacts.length() - 1) + ']}';
            Map<String, String> contactIds = createContacts(newContacts);
            
            if(contactIds.size() > 0) {
                //Insert the new Users
                try{
                    Database.DMLOptions dmlo = new Database.DMLOptions();
                    dmlo.EmailHeader.triggerUserEmail = false;
                    for(User newUser : newUsers) {
                        //Utilize the AccountId we had saved to get the actual ContactId
                        newUser.ContactId = contactIds.get(newUser.ContactId);
                    }
                    
                    Database.insert(newUsers, dmlo);
                    successJsonResponse += '{"' + id + '": "Created Contact and User for ' + login + ' in store(s):' + storeList + '."},';
                }
                catch(exception ex) {
                    failJsonResponse += '{"' + id + '": "Failed", "reason": "Failed while Creating Users for Account(s):' + accountList + '."},';
                }
            }
            else {
                failJsonResponse += '{"' + id + '": "Failed", "reason": "Failed while Creating Contacts for Account(s):' + accountList + '."},';
            }
        }           
                                                    
        //Update contacts
        if(updateContacts.size() > 0){
        	updateUserIdAndStatusOnContact(updateContacts);
            if(updatedStoreListContacts.length() > 0) {
                successJsonResponse += '{"' + id + '": "Queued Contact(s) updates in store(s):' + updatedStoreListContacts + '."},';
            }
        }
                                                    
        //Update users
        if(updateUsers.size() > 0) {
            try {
                for(List<User> usersToUpdate : [Select Id, IsActive From User Where Id In :updateUsers.keySet()]) {
                    for(User u : usersToUpdate) {
                        u.IsActive = updateUsers.get(u.Id);
                    }
                    update(usersToUpdate);
                    successJsonResponse += '{"' + id + '": "Updated User(s) in store(s):' + updatedStoreListUsers + '."},';
                }
            }
            catch(exception ex) {
            	failJsonResponse += '{"reason": "Failed to Update User records."},'; 
        	}
        }
        return finalizeResponse(failJsonResponse, successJsonResponse, initLength);
    }
    
    @TestVisible 
    private static RestResponse removeAllPermissions(String id) {
		String successJsonResponse = '"Success messages": [';
        String failJsonResponse =    '"Failure messages": [';
        Integer initLength = 21;
        
        for(List<Contact> contacts : [SELECT Id, Entity_ID__c, Active__c, Account_Store_Number__c FROM Contact WHERE Entity_ID__c = :id]) {
            if(contacts.size() != 0) {
                RestResponse updateRes = disableContactsAndUsers(contacts);
                if(updateRes.statusCode == 200) {
                    successJsonResponse += updateRes.responseBody.toString() + ',';
                }
                else {
                    failJsonResponse += updateRes.responseBody.toString() + ',';
                }
            }
            else {
                successJsonResponse += '{"' + id + '": "No permissions to remove for entityId."},';
            }
        }
        
        return finalizeResponse(failJsonResponse, successJsonResponse, initLength);
    }
    
    @TestVisible 
    private static RestResponse disableContactsAndUsers(List<Contact> contacts) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String response = '';
        String contactsStores = '';
        String usersStores = '';
        try{
            List<Id> contactIds = new List<Id>();
            Map<Id, String> contactsToUpdate = new Map<Id, String>();
            for(Contact c : contacts) {
                contactIds.add(c.Id);
                if(c.Active__c != false) {
                    c.Active__c = false;
                	contactsToUpdate.put(c.Id, 'false');
                    contactsStores += c.Account_Store_Number__c + ' ';
                }
            }
            for(List<User> users : [SELECT IsActive, Username, Contact.Account_Store_Number__c FROM User WHERE ContactId In :contactIds And IsActive = true]) {
                if(users.size() > 0) {
                    for(User u : users) {
                        u.IsActive = false;
                        usersStores += u.Contact.Account_Store_Number__c + ' ';
                    }
                    update users;
                }
            }
            updateUserIdAndStatusOnContact(contactsToUpdate);
            res.statusCode = 200;
            if(contactsStores.length() > 0) {
                contactsStores = contactsStores.substring(0,contactsStores.length()-1);
                response += '{"Contact(s) Updated in Store(s)": "' + contactsStores + '"}';
            }
            if(usersStores.length() > 0) {
                if(response.length() > 0) {
                    response += ',';
                }
                usersStores = usersStores.substring(0,usersStores.length()-1);
                response += '{"User(s) Updated in Store(s)": "' + usersStores + '"}';
            }
            if(response.length() == 0) {
                response = '{"INFO": "No updates needed."}';
            }
            res.responseBody = blob.valueOf(response);
        }
        catch(ConnectApi.RateLimitException ex) {
            res.statusCode = 500;
            res.responseBody = blob.valueOf('{"ERROR": "REST API rate limit exceeded."}');                                 
        }
        catch(exception ex)
        {
            res.statusCode = 500;
            res.responseBody = blob.valueOf('{"ERROR": "Internal Server Error."}');
        }
        return res;
    }
    
    @TestVisible 
    private static User createUserToInsert(String firstName, String lastName, String login, String accountStore, 
                                                        String env, String contactId, String profileId, String emailAddress, Boolean active) {
        User u = new User(
              Firstname = firstName,
              Lastname = lastName,
              Username = login + accountStore + '@rwfb.com' + env,
              ContactId = contactId,
              ProfileId = profileId,
              Alias = createAlias(firstName, lastName),
              Email = emailAddress,
              EmailEncodingKey = 'UTF-8',
              CommunityNickname = firstName + '.' + lastName + '.' + accountStore,
              TimeZoneSidKey = 'America/Chicago',
              LocaleSidKey = 'en_US',
              LanguageLocaleKey = 'en_US',
              RWS_User_ID__c = emailAddress,
              Send_New_User_Welcome_Email__c = false,
              IsActive = active
          );
          return u;
    }
    
    @future @TestVisible
    private static void updateUserIdAndStatusOnContact(Map<Id, String> updateContacts) {
        for(List<Contact> contacts : [Select Id, Active__c, OwnerId From Contact Where Id In :updateContacts.keySet()]) {
            for(Contact contact : contacts) {
                String value = updateContacts.get(contact.Id);
                if(value == 'true' || value == 'false') {
                    contact.Active__c = Boolean.valueOf(value);
                }
                else {
                    contact.OwnerId = value;
                }
            }
            update(contacts);
        }
    }
}