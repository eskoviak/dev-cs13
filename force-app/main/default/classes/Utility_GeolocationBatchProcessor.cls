global class Utility_GeolocationBatchProcessor implements Database.Batchable<sObject>,
	Database.AllowsCallouts {

/**
*   {Purpose}  �  Handles batch processing for Geolocation MapQuest services
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20140808    Andy Boettcher DCS      Created
*   =============================================================================
*/
	
	private String strQuery;
	public String strObject;
	public Set<Id> setScopeIds;
	public Utility_Geolocation.hClsGeocodeTarget clsTarget;
	
	global Utility_GeolocationBatchProcessor() { }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		strQuery = 'SELECT Id FROM ' + strObject + ' WHERE Id IN :setScopeIds';
		return Database.getQueryLocator(strQuery);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		// Get Ids from List
   		Set<Id> setBatchScopeIds = new Set<Id>();
   		for(sObject so : scope) { setBatchScopeIds.add((Id)so.get('Id')); }

   		System.Debug('Pushing ' + setBatchScopeIds.size() + ' records to Batch!');

   		Map<String, Boolean> mapCodeSettings = Util.CODE_SETTINGS();
   		String strAccountGeolocation = 'geoLocationAccount';
        if(mapCodeSettings.containsKey(strAccountGeolocation)) {
            if(mapCodeSettings.get(strAccountGeolocation)) {
            	Utility_Geolocation.processBatchGeocodes(clsTarget, setBatchScopeIds);
            }
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		// Intentionally Empty
	}
	
}