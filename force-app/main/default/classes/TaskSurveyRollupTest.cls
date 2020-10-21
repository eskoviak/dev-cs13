@isTest
private class TaskSurveyRollupTest {

	static Contact testContact;
	static Task testTask;
	
	static void initialize() {
		testContact = ECTestDataFactory.CreateContact('Fred', 'Flintstone', 'fflintstone@test.com', true);	
		system.assertNotEquals(null, testContact.Id);	
		
		testTask = ECTestDataFactory.createTask(testContact.Id, 'Completed', 'Normal', 'Email: Red Wing Shoes Survey', system.today(), false);
	}
	
	static testMethod void testTaskSurveyRollupOnInsert() {
		initialize();
		
		test.startTest();
			insert testTask;
		test.stopTest();
		
		Contact result = [select Survey_Count__c from Contact where Id =: testContact.Id];
		system.assertEquals(1, result.Survey_Count__c);
	}
	
	static testMethod void testTaskSurveyRollupOnDelete() {
		initialize();
		
		insert testTask;
		system.assertEquals(1, [select Survey_Count__c from Contact where Id =: testContact.Id].Survey_Count__c);
		
		test.startTest();
			delete testTask;
		test.stopTest();
		
		Contact result = [select Survey_Count__c from Contact where Id =: testContact.Id];
		system.assertEquals(0, result.Survey_Count__c);
	}
}