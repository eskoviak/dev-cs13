public with sharing class Utility_TTRRequestForm {

/**
*   {Purpose}  �  This class holds general utilities for the TTR_Request_Form__c object
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131203  	Andy Boettcher DCS		Created
*   =============================================================================
*/

	///////////////////////////////////
	// Constructors
	///////////////////////////////////
	
	///////////////////////////////////
	// GET / SET
	///////////////////////////////////
	
	///////////////////////////////////
	// Action Methods
	///////////////////////////////////
	public static void manageTTRActiveFlag(List<TTR_Request_Form__c> lstTrigger) {
		
		Util.logMessage('manageTTRActiveFlag', string.valueOf(lstTrigger));
		
		// Set all new TTRs to TRUE and retrieve all accounts in scope
		for(TTR_Request_Form__c ttr : lstTrigger) {
			Util.logMessage('manageTTRActiveFlag', 'Setting TTR ' + ttr.Name + ' to TRUE');
			ttr.Active_Form__c = true;
		}
		
		// Store all Accounts in scope
		Set<Id> setScopeAccounts = new Set<Id>();
		for(TTR_Request_Form__c ttr : lstTrigger) {
			setScopeAccounts.add(ttr.Account__c);
		}
		
		// Retrieve all TTRs for Accounts in scope
		List<TTR_Request_Form__c> lstTTRs = [SELECT Id, Name, Active_Form__c FROM TTR_Request_Form__c WHERE Account__c IN :setScopeAccounts];
		
		// Set all previous TTRs to FALSE
		for(TTR_Request_Form__c ttr : lstTTRs) {
			Util.logMessage('manageTTRActiveFlag', 'Setting TTR ' + ttr.Name + ' to FALSE');
			ttr.Active_Form__c = false;
		}
		
		// Update previous TTRs
		if(lstTTRs.size() > 0) { update lstTTRs; }
		
		
	}
	
	///////////////////////////////////
	// Helper Classes
	///////////////////////////////////

}