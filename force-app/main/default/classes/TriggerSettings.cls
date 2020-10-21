public with sharing class TriggerSettings {

	static {
  		if (Test.isRunningTest()) {
   			TriggerSettings__c ts = new TriggerSettings__c(); //if a test is running - create the settings so the test classes dont have to
   			ts.Case__c = true;
   			User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
   			System.runAs(thisUser) {
    			try{
        			insert ts;
    			}
    			catch(DMLException e){
     				//probably fine - just means it already exists
    			}
   			}
  		} 
 	}
 	
 	public TriggerSettings__c triggers { get; set; }
 	
 	public TriggerSettings() {
 		this.triggers = TriggerSettings__c.getInstance();
 	}
}