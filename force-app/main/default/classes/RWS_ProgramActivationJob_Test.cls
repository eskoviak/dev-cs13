@isTest
private class RWS_ProgramActivationJob_Test {
    static testMethod void testJob() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, true);

    	System.assert([select Active__c from Program__c where Id = :pr.Id].Active__c);

    	Test.startTest();
    		RWS_ProgramActivationJob job = new RWS_ProgramActivationJob();
			job.execute(null);
		Test.stopTest();

		System.assert(![select Active__c from Program__c where Id = :pr.Id].Active__c);
    }
}