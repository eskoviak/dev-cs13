@isTest(seeAllData=false)
private class TaskTrigger_Test {
    
    private static Opportunity CreateTestData()
//CreateAccount
    {
        Account a = new Account(
            Name = 'First Avenue', 
            Phone = '952-867-5309', 
            Store_Number__c = '137',
            AccountNumber = '7654321'
        );		
        insert a;
//CreateOpportunity        
        Opportunity o = new Opportunity(
        	Solution_s_Developed__c = 'Open',
            Sales_Process_Control_Letter_Sent__c = 'Open',
            Key_Player_Letters_Sent__c = 'Open',
            Sphere_of_Influence_Created__c = 'Open',
            Benefits_Summary_Created__c = 'Open',
            Key_Players_Sequence_of_Events__c = 'Open',
            Cost_vs_Benefit_Created__c = 'Open',
            Success_Metrics_Created__c = 'Open',
            Negotiation_Worksheet_Created__c = 'Open',
            Bid_Tender_Contract_Documents_Attached__c = 'Open',
            Account = a,
            Name = 'Test',
            CloseDate = date.today(),
            StageName = 'Active'
        );
        insert o;
        return o;
    }
//SolutionDeveloped
	static testMethod void SolutionDevelopedTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD THE SOLUTION DEVELOPMENT PROMPTER',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        
        System.assertEquals('Open', o.Solution_s_Developed__c);
        System.assertEquals(null, o.Solution_s_Developed_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Solution_s_Developed__c, Solution_s_Developed_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Solution_s_Developed__c);
        System.assertEquals(date.today(), result.Solution_s_Developed_Date__c); 
        Test.stopTest();
    }
    
//ChampionLetter
    static testMethod void ChampionLetterTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD, ATTACH AND SEND YOUR CHAMPION LETTER',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
    
        System.assertEquals('Open', o.Sales_Process_Control_Letter_Sent__c);
        System.assertEquals(null, o.Sales_Process_Control_Letter_Sent_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Sales_Process_Control_Letter_Sent__c, Sales_Process_Control_Letter_Sent_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Sales_Process_Control_Letter_Sent__c);
        System.assertEquals(date.today(), result.Sales_Process_Control_Letter_Sent_Date__c); 
        Test.stopTest();
    }
//KeyPlayerLetters
    static testMethod void KeyPlayerLetterTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD, ATTACH AND SEND YOUR KEY PLAYER LETTER(S)',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        //system.debug('opportunity = ' + o);
        System.assertEquals('Open', o.Key_Player_Letters_Sent__c);
        System.assertEquals(null, o.Key_Player_Letters_Sent_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Key_Player_Letters_Sent__c, Key_Player_Letters_Sent_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Key_Player_Letters_Sent__c);
        System.assertEquals(date.today(), result.Key_Player_Letters_Sent_Date__c); 
        Test.stopTest();
    }
//SphereOfInfluence
    static testMethod void SphereOfInfluenceTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD THE SPHERE OF INFLUENCE DOCUMENT',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Sphere_of_Influence_Created__c);
        System.assertEquals(null, o.Sphere_of_Influence_Created_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Sphere_of_Influence_Created__c, Sphere_of_Influence_Created_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Sphere_of_Influence_Created__c);
        System.assertEquals(date.today(), result.Sphere_of_Influence_Created_Date__c); 
        Test.stopTest();
    }
//BenefitsSummary
    static testMethod void BenefitsSummaryTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD AND ATTACH BENEFITS SUMMARY',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Benefits_Summary_Created__c);
        System.assertEquals(null, o.Benefits_Summary_Created_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Benefits_Summary_Created__c, Benefits_Summary_Created_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Benefits_Summary_Created__c);
        System.assertEquals(date.today(), result.Benefits_Summary_Created_Date__c); 
        Test.stopTest();
    }
//SequenceOfEvents
    static testMethod void SequenceOfEventsTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD, ATTACH AND SEND A DRAFT OF THE SEQUENCE OF EVENTS',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Key_Players_Sequence_of_Events__c);
        System.assertEquals(null, o.Key_Players_Sequence_of_Events_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Key_Players_Sequence_of_Events__c, Key_Players_Sequence_of_Events_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Key_Players_Sequence_of_Events__c);
        System.assertEquals(date.today(), result.Key_Players_Sequence_of_Events_Date__c); 
        Test.stopTest();
    }
//CostVsBenefit
    static testMethod void CostVsBenefitTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD AND ATTACH THE COST VS. BENEFITS DOCUMENT',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Cost_vs_Benefit_Created__c);
        System.assertEquals(null, o.Cost_vs_Benefit_Created_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Cost_vs_Benefit_Created__c, Cost_vs_Benefit_Created_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Cost_vs_Benefit_Created__c);
        System.assertEquals(date.today(), result.Cost_vs_Benefit_Created_Date__c); 
        Test.stopTest();
    }
//SuccessMetrics
    static testMethod void SuccessMetricsTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD, ATTACH AND SEND THE SUCCESS METRICS DOCUMENT',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Success_Metrics_Created__c);
        System.assertEquals(null, o.Success_Metrics_Created_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Success_Metrics_Created__c, Success_Metrics_Created_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Success_Metrics_Created__c);
        System.assertEquals(date.today(), result.Success_Metrics_Created_Date__c); 
        Test.stopTest();
    }
//NegotiationWorksheet
    static testMethod void NegotiationWorksheetTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'BUILD AND ATTACH YOUR NEGOTIATION WORKSHEET',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Negotiation_Worksheet_Created__c);
        System.assertEquals(null, o.Negotiation_Worksheet_Created_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Negotiation_Worksheet_Created__c, Negotiation_Worksheet_Created_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Negotiation_Worksheet_Created__c);
        System.assertEquals(date.today(), result.Negotiation_Worksheet_Created_Date__c); 
        Test.stopTest();
    }
//BidTenderContract
    static testMethod void BidTenderContractTest()
    {
        Test.startTest();
        Opportunity o = CreateTestData();
                
        Task t = new Task(
        	Subject = 'Complete Bid/Tender/Contract Info Form',
            Status = 'Open',
            WhatId = o.Id
        );
        insert t;
        
        System.assertEquals('Open', o.Bid_Tender_Contract_Documents_Attached__c);
        System.assertEquals(null, o.Bid_Contract_Info_Sheet_Complete_Date__c);
        
        t.Status = 'Completed';
        Database.UpsertResult tUp = Database.upsert(t, false);
        
        Opportunity result = [SELECT Bid_Tender_Contract_Documents_Attached__c, Bid_Contract_Info_Sheet_Complete_Date__c FROM Opportunity WHERE Id = :o.Id][0];
        
        System.assertEquals('Complete', result.Bid_Tender_Contract_Documents_Attached__c);
        System.assertEquals(date.today(), result.Bid_Contract_Info_Sheet_Complete_Date__c); 
        Test.stopTest();
    }
}