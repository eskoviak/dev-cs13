/************************************************************************
* Custom Iterable Class - Implements 'Iterable' and 'Iterator' interfaces
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
global class RWS_CustomDeleteIterable implements Iterable<SObject>, Iterator<SObject>{ 
    
    //Class variables
    List<SObject> sobjs {get; set;} 
    Integer i {get; set;} 
    
    //Sets the Iterator method of the Iterable interface to this class
    public Iterator<SObject> iterator() { 
        return this; 
    }  
    
    //Constructor
    public RWS_CustomDeleteIterable(){ 
        sobjs = new List<SObject>();

	   //Query for PPBE records 
	   //WHERE filter_number__c is null AND active__c = ‘false'￼ AND Publish_Status__c = 'Deactivated'￼ AND Account_Number__c is not null AND Published_Date__c is not null AND LastModifiedDate < '7 days ago’    
       sobjs.addAll( [SELECT Id FROM Publish_PriceBook_Entry__c WHERE filter_number__c = null AND active__c = false AND Publish_Status__c = 'Deactivated'
                AND Account_Number__c != null AND Published_Date__c != null AND LastModifiedDate = LAST_N_DAYS:7 ]); 
       
       //Query for Servicing Store records 
	   //WHERE active__c = 'false' AND Expiration_Date__c is not null AND Published_Date__c is not null AND ProgramIsActive__c = 'true' AND Program_Service_level_Formula__c like 'Dealer%'
       sobjs.addAll([SELECT Id FROM Servicing_Store__c WHERE active__c = false AND Expiration_Date__c != null 
                			 AND Published_Date__c != null AND Program_Service_Level__c LIKE 'Dealer%' ]);        
       
       //Set i to 0
        i = 0; 
   }   
    
   //generic has next method 
   global boolean hasNext(){ 
       if(i >= sobjs.size()) 
           return false; 
       else 
           return true; 
   }    
   
    //generic next method
   global SObject next(){ 
       i++;        
       return sobjs[i-1]; 
   }
}