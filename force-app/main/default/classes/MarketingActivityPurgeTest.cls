@isTest 
public class MarketingActivityPurgeTest {
    static testMethod void testMethod1() {
        List<ELQA_Marketing_Activity__c> lstActivities = new List<ELQA_Marketing_Activity__c>();
        for(Integer i=0 ;i < 200 ;i++){
            ELQA_Marketing_Activity__c a = new ELQA_Marketing_Activity__c();
            a.Name ='Test Activity' + i;
            lstActivities.add(a);
        }
        insert lstActivities;
        
        for(ELQA_Marketing_Activity__c e : [SELECT Id FROM ELQA_Marketing_Activity__c LIMIT 100]){
        	Test.setCreatedDate(e.Id, datetime.now().addMonths(-7));
        }
        
        Test.startTest();   
        system.debug([SELECT Id FROM ELQA_Marketing_activity__c].size());
        
        MarketingActivityPurgeBatch b = new MarketingActivityPurgeBatch();
        Database.executeBatch(b);
        
        MarketingActivityPurgeSchedule m = new MarketingActivityPurgeSchedule();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Purge', sch, m);
        
        Test.stopTest();
        
        List<ELQA_Marketing_Activity__c> existingActivities = [SELECT Id FROM ELQA_Marketing_Activity__c];
        System.assertEquals(100, existingActivities.size());
    }
}