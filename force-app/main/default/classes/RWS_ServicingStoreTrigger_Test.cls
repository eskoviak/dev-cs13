@isTest
private class RWS_ServicingStoreTrigger_Test {
    static testMethod void testTrigger() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, false); 
    	pr.Publish_Status__c  = 'Published';
    	insert pr;

    	Servicing_Store__c ss = RWS_TestUtil.createServicingStore(acc.Id, pr.Id, false);

    	ss.Publish_Status__c = 'Waiting';

    	insert ss;

    	ss.Publish_Status__c = '';
    	ss.Servicing_Status__c = 'Active';

    	update ss;

    	pr.Active__c = false;

    	update ss;
    }
}