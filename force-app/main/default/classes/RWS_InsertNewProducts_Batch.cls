/**
* Batch class to get all the programs where Auto_Add_Products__c = true
* @DateCreated: 12/06/2016
* @Author: Kotapati Keerthi (Magnet360)
*/
global class RWS_InsertNewProducts_Batch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc) {
        // execute the batch job with one record at a time
        Database.executeBatch(new RWS_InsertNewProducts_Batch(), 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        // find if any product updated yesterday
        Integer count = [select Id from Product2 where LastModifiedDate >= YESTERDAY 
                        and IsActive = true and Product_Style__c != null limit 1].size();

        // find if any product feature updated yesterday
        Integer featureCount = [select Id from Product_Style_Features__c where LastModifiedDate >= YESTERDAY limit 1].size();

        // do not process program if no product or product feature was changed yesterday
        return Database.getQueryLocator('Select Id From Program__c where Auto_Add_Products__c = true '
                                        + (featureCount == 0 && count == 0 && !Test.isRunningTest() ?  
                                            ' and Id = null ' 
                                            : '') );
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        for (sObject p : scope) {
            //convert scope to actual Program
            Program__c program = (Program__c) p;

            // pass program to the logic handler for further processing
            RWS_InsertNewProducts_BatchHandler.createProducts(program.Id);
        }
        
    }     
    
    global void finish(Database.BatchableContext BC) {} 
}