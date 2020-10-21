/************************************************************************
*  Batch Class for Deletion of PPBE and Servicing Store records that fit criteria defined in RWS_CustomDeleteIterable class
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
global class RWS_ppbeAndServicingStoreDeleteBatch implements Database.batchable<SObject>{ 
   
   //Start method
   global Iterable<Sobject> start(Database.batchableContext info){        
       //Returning custom iterable class to allow querying of multiple objects in one job
       return new RWS_CustomDeleteIterable();
   }     
   
    //Execute method
   global void execute(Database.batchableContext info, List<SObject> scope){ 
   	   //Delete all records returned by start method
       delete scope;
       
   }
    
   //Finish method
   global void finish(Database.batchableContext info){       
       //Do nothing       
   } 
}