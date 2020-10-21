global class RWS_ProgramProducts_Batch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    global Boolean hasData = false;

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_ProgramProducts_Batch(), 1);
    }

    

    global Database.QueryLocator start(Database.BatchableContext bc) {

        hasData = ![SELECT Processed__c, Program__c, Program_Template_Name__c 
                                            FROM Program_Scheduler__c where Processed__c = false limit 1].isEmpty();

        return Database.getQueryLocator([SELECT Processed__c, Program__c, Program_Template_Name__c 
                                            FROM Program_Scheduler__c where Processed__c = false
                                            order by CreatedDate asc]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        Program_Scheduler__c scheduler = (Program_Scheduler__c) scope[0];

        Boolean createTemplate = !String.isBlank(scheduler.Program_Template_Name__c);

        

        RWS_ProgramProducts_BatchHandler h = new RWS_ProgramProducts_BatchHandler(scheduler.Program__c, 
                            createTemplate,
                            scheduler.Program_Template_Name__c);

        h.execute();

        scheduler.Processed__c = true;

        update scheduler;


    }

    global void finish(Database.BatchableContext BC) {
        Integer minutes = 5;
        if(hasData) minutes = 1;

       RWS_ProgramProducts_Batch sc = new RWS_ProgramProducts_Batch();
       Datetime dt = Datetime.now().addMinutes(minutes);
       String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
       Id schedId = System.Schedule('ProgramProducts' + timeForScheduler, timeForScheduler, sc);

    }
}