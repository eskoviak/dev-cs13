global class schedule_ContractExpiration implements Schedulable {

/**
*   {Purpose}  �  Executes the Automated Truck and Account contract expiration email jobs
*                 
*   {Function}  �  EXECUTE - queries all ACTIVE records in the AutomatedEmailNotifications 
					Custom Setting and executes
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131008	Andy Boettcher DCS		Creation
*   =============================================================================
*/
	global void execute(SchedulableContext SC) {
		
		List<AutomatedEmailNotifications__c> lstAENs = AutomatedEmailNotifications__c.getAll().values();
		
		for(AutomatedEmailNotifications__c aen : lstAENs) {
			if(aen.IsActive__c) {
				TruckMobileExpirationNotify.processExpirations(aen.Name);
			}
		}

   }

}