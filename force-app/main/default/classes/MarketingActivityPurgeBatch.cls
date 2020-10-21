global class MarketingActivityPurgeBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date sixMonthsAgo = date.today().addMonths(-6);
        return Database.getQueryLocator('SELECT Id, CreatedDate FROM ELQA_Marketing_Activity__c WHERE CreatedDate < :sixMonthsAgo');
    }

    global void execute(Database.BatchableContext bc, List<ELQA_Marketing_Activity__c> scope){
        delete scope;
        recordsProcessed = scope.size();
    }

    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records deleted.');
 
    }
}