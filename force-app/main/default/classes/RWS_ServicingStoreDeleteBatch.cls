/************************************************************************
*  Batch Class for Deletion of Servicing Store records
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
global class RWS_ServicingStoreDeleteBatch implements Database.batchable<SObject>{ 
   
   //Start method
   global Database.QueryLocator start(Database.batchableContext info){        
       
       //Query for Servicing Store records 
	   //WHERE active__c = 'false' AND Expiration_Date__c is not null AND Published_Date__c is not null AND ProgramIsActive__c = 'true' AND Program_Service_level_Formula__c like 'Dealer%'
       String query = 'SELECT Id FROM Servicing_Store__c WHERE active__c = false AND Expiration_Date__c != null AND Published_Date__c != null AND Program_Service_Level__c LIKE \'Dealer%\'';
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