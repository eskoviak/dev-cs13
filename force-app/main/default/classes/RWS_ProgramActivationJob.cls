/********************************************************************************
*   PURPOSE :   Activate/Deactivate Program on Activation/Expiration date.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/09/2016  Usman Aslam/M360        Initial version
********************************************************************************/
global class RWS_ProgramActivationJob implements Database.Batchable<sObject>, Schedulable {

    // initialize batch job
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_ProgramActivationJob());
    }

    global Database.QueryLocator start(Database.BatchableContext bc) { 
        // get programs that needs to be updated
        return Database.getQueryLocator('SELECT Id, Active__c, Expiration_Date__c, Activation_Date__c ' +
                                'FROM Program__c ' +
                                'WHERE Template__c = false ' +
                                'AND Active__c = true ' + (Test.isRunningTest() ? '' : 'AND Expiration_Date__c < TODAY ')
                            ); 
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Program__c> programs = (List<Program__c>) scope;

        for(Program__c p : programs) {
            p.Active__c = false;
        }

        // update programs
        update programs;
    }

    global void finish(Database.BatchableContext BC) {}
}