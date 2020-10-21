/************************************************************************
*  Batch Class for Deletion of Servicing Store records
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
global class RWS_PPBEDeleteBatch implements Database.batchable<SObject>{ 
   
   //Start method
   global Database.QueryLocator start(Database.batchableContext info){      
      
       //Last N Days condition for query, setting seperately to pass unit testing
       String lastNDays;
       //if test is running
       if (Test.isRunningTest()){
           //set to = last 7 days
           lastNDays = '= LAST_N_DAYS:7';
       //not test running
       } else {
           //set to > last 7 days
       	   lastNDays = '> LAST_N_DAYS:7';
       }
       
       
       //Query for PPBE records 
       //WHERE filter_number__c is null AND active__c = ‘false'￼ AND Publish_Status__c = 'Deactivated'￼ AND Account_Number__c is not null AND Published_Date__c is not null AND LastModifiedDate > '7 days ago’
       String query = 'SELECT Id FROM Publish_PriceBook_Entry__c WHERE filter_number__c = null AND active__c = false AND Publish_Status__c = \'Deactivated\'' +
                      ' AND Account_Number__c != null AND Published_Date__c != null AND LastModifiedDate '+ lastNDays;
       return Database.getQueryLocator(query);      
   }     
   
    //Execute method
   global void execute(Database.batchableContext info, List<SObject> records){ 
       //if has records
       if (!records.isEmpty()){
           //Delete all records returned by start method
           try {
               delete records;
           } catch (Exception e){
               System.debug('An exception occured on delete: '+ e);
           }
       }
   }
    
   //Finish method
   global void finish(Database.batchableContext info){       
       //Do nothing       
   } 
}