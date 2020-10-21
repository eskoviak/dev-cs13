@isTest
private class CaseSetCreateSurveyTaskFlagTest {

    static Case testCase;
    static Contact testContact;
    static Account testAccount;
    static TriggerSettings__c settings;
    
    static void initialize() {    	
    	settings = TriggerSettings__c.getInstance();
    	
        testAccount = ECTestDataFactory.createAccount('Acme', true);
        system.assertNotEquals(null, testAccount.Id);
        
        testContact = ECTestDataFactory.CreateContact('Fred', 'Flintstone', 'fflintstone@test.com', false);
        testContact.Active__c = true;
        testContact.Do_Not_Send_Surveys__c = false;
        testContact.HasOptedOutOfEmail = false;
        testContact.Survey_Threshold_Reached__c = false;
        insert testContact;
        system.assertNotEquals(null, testContact.Id);
        
        BusinessHours bh = [select id from BusinessHours where IsDefault=true];
        Id recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Support').getRecordTypeId();
        testCase = ECTestDataFactory.createCase('Order', 'New', 'Phone', bh.Id ,recordTypeId , testAccount.Id, testContact.Id, false);
        insert testCase;
        system.assertNotEquals(null, testCase.Id);
        
    }
    
    static testMethod void testSendSurveyWhenCaseClosedTypeOrder() {
        initialize();
        
        testCase.Status = 'Closed';
        testCase.Type = 'Order';
        testCase.Case_Type_Detail__c = 'Order Entry Error';
        
        test.startTest();
            update testCase;
        test.stopTest();
    }
    
    static testMethod void testSendSurveyWhenCaseClosedTypeSalesSupport() {
        initialize();
        
        testCase.Status = 'Closed';
        testCase.Type = 'Sales Support';
        testCase.Case_Type_Detail__c = 'Order Revision';
        
        test.startTest();
            update testCase;
        test.stopTest();
    }
    
    static testMethod void testDoNotSendSurveyWhenCaseClosed() {
        initialize();
        
        testCase.Status = 'Closed';
        testCase.Type = 'Shipping';
        testCase.Case_Type_Detail__c = 'Wrong Label';
        
        test.startTest();
            update testCase;
        test.stopTest();
    }
}