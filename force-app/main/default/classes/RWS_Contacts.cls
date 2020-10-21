@RestResource(urlMapping='/contacts/*')
global with sharing class RWS_Contacts {
    
    @HttpPost @TestVisible 
    global static void createContacts() {  
        List<Contact> contacts = new List<Contact>();
        //Parse fields from incoming payload
        Map<String, Object> contactObjs = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        List<Object> objContacts = (List<Object>)contactObjs.get('contacts');
        for(Object objContact : objContacts) {
            Map<String, Object> mapped = (Map<String,Object>)objContact;
            Contact c = new Contact( 
                  AccountId = (String)mapped.get('accountId'),
                  Firstname = (String)mapped.get('firstName'),
                  Lastname = (String)mapped.get('lastName'),
                  Title = (String)mapped.get('jobTitle'),
                  Email = (String)mapped.get('emailAddress'),
                  RWS_Id__c = (String)mapped.get('login') + '_' + (String)mapped.get('accountNumber'),
                  RecordTypeId = (String)mapped.get('recordId'),
                  Entity_ID__c = (String)mapped.get('id'),
                  EMS_Login__c = (String)mapped.get('login'),
                  Active__c = Boolean.valueOf((String)mapped.get('active'))
            );
            if(!String.isBlank((String)mapped.get('accountPhone')) && ((String)mapped.get('accountPhone')) != 'null') {
                c.Phone = (String)mapped.get('accountPhone');
            }
            contacts.add(c);
        }
                               
        //Initialize response
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
        try {
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.EmailHeader.triggerUserEmail = false;
            List<Database.SaveResult> results = Database.insert(contacts, dmlo);
            res.statusCode = 201;
            String retVal = '';
            for(Integer i = 0; i < results.size(); i++) {
                retVal += '"' + contacts.get(i).AccountId + '":"' + results.get(i).getId() + '",';
            }
            if(retVal.length() > 0) {
                retVal = retVal.substring(0, retVal.length()-1);
            }
            res.responseBody = blob.valueOf('{' + retVal + '}');
        }
        catch(ConnectApi.RateLimitException ex) {
        	//Create failure response message
            res.statusCode = 500;
            res.responseBody = blob.valueOf(Json.serialize('{"response": {"status": "Failure", "message": "REST API rate limit exceeded."}}'));                                 
        }
		catch(exception ex) {
        	//Create failure response message
        	System.debug('Exception ' + ex.getMessage());
            res.statusCode = 500;
            res.responseBody = blob.valueOf(Json.serialize('{"response": {"status": "Failure", "message": "Internal Server Error."}}'));                                 
        } 
	}
}