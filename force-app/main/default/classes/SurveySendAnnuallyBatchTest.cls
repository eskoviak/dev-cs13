@isTest
private class SurveySendAnnuallyBatchTest {

    static Contact testContact;
    static Task testTask;

    static void initialize() {
        testContact = ECTestDataFactory.CreateContact('Fred', 'Flintstone', 'fflintstone@test.com', true);
        system.assertNotEquals(null, testContact.Id);

        testTask = ECTestDataFactory.createTask(testContact.Id, 'Completed', 'Normal', 'Email: Red Wing Shoes Survey', system.today().addDays(-366), false);
    }

    static testMethod void testSendSurveyWhenSurveyNeverSent() {
        initialize();

        insert testTask;

        SurveySendAnnuallyBatch batch = new SurveySendAnnuallyBatch();
        batch.query = batch.query +  ' Limit 200';

        test.startTest();
            Id batchprocessid = Database.executeBatch(batch, 200);
        test.stopTest();

        List<Task> result = [select Id from Task where whoId =: testContact.Id and isClosed = true];
        system.assertNotEquals(null, result[0].Id);
    }

    static testMethod void testSendSurveyWhenSurveyNotSentAnnually() {
        initialize();

        testContact.Active__c = true;
        testContact.Do_Not_Send_Surveys__c = false;
        testContact.HasOptedOutOfEmail = false;
        update testContact;

        testTask.CreatedDate = system.today().addDays(-366);
        insert testTask;

        SurveySendAnnuallyBatch batch = new SurveySendAnnuallyBatch();
        batch.query = batch.query +  ' Limit 200';

        test.startTest();
            Id batchprocessid = Database.executeBatch(batch, 200);
        test.stopTest();

        List<Task> results = [select Id from Task where whoId =: testContact.Id and isClosed = true];
        //system.assertEquals(2, results.size());
    }

    static testMethod void testSendSurveyWhenContactInactive() {
        initialize();

        testContact.Active__c = false;
        update testContact;

        SurveySendAnnuallyBatch batch = new SurveySendAnnuallyBatch();
        batch.query = batch.query +  ' Limit 200';

        test.startTest();
            Id batchprocessid = Database.executeBatch(batch, 200);
        test.stopTest();

        List<Task> results = [select Id from Task where whoId =: testContact.Id and isClosed = true];
        system.assertEquals(0, results.size());
    }

    static testMethod void testSendSurveyWhenContactDoNotSendSurvey() {
        initialize();

        testContact.Do_Not_Send_Surveys__c = true;
        update testContact;

        SurveySendAnnuallyBatch batch = new SurveySendAnnuallyBatch();
        batch.query = batch.query +  ' Limit 200';

        test.startTest();
            Id batchprocessid = Database.executeBatch(batch, 200);
        test.stopTest();

        List<Task> results = [select Id from Task where whoId =: testContact.Id and isClosed = true];
        system.assertEquals(0, results.size());
    }
}