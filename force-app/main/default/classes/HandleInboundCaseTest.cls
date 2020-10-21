@IsTest
private class HandleInboundCaseTest {

    static testmethod void handleInboundCase(){
        
        Contact cnt = new Contact(Lastname='Test');
        insert cnt;
       
        Case c = new Case(Subject='Test',ExternalId__c='Red Wing_12345', ContactId = cnt.Id);
        upsert c ExternalId__c;
        
        InboundCase__e evt = new  InboundCase__e(
            CaseNumber__c = '12345',
            Subject__c = 'Test',
            SourceId__c = '12345',
            Source__c = 'RWS',
            Description__c = 'Test',
            ExternalId__c = 'Red Wing_12345'
        );
        
        Test.startTest();
        EventBus.publish(new List<InboundCase__e>{evt});
        Test.stopTest();
        
        List<Case> results = [Select Description From Case];
        System.assertEquals(1,results.size());
        //System.assertEquals('Test', results.get(0).Description);
    }
}