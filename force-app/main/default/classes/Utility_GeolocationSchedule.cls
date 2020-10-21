global class Utility_GeolocationSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {
		
		// Find all records in 'Pending' status
		Map<Id, Account> mapPendingGeo = new Map<Id, Account>([
			SELECT Id FROM Account WHERE Geocode_Status__c = 'Pending'
		]);

		Utility_Geolocation.hClsGeocodeTarget clsTarget = new Utility_Geolocation.hClsGeocodeTarget();
        clsTarget.strObject = 'Account';
        clsTarget.strResultStatusField = 'Geocode_Status__c';
        clsTarget.strResultMessageField = 'MapQuest_Response__c';
        clsTarget.strStreetSourceField = 'M3_Location_Street__c';
        clsTarget.strCitySourceField = 'M3_Location_City__c';
        clsTarget.strStateSourceField = 'M3_Location_State_Province__c';
        clsTarget.strPostalCodeSourceField = 'M3_Location_ZIP_Postal_Code__c';
        clsTarget.strCountrySourceField = 'M3_Location_Country__c';
        clsTarget.strStreetTargetField = 'MapQuest_Street__c';
        clsTarget.strCityTargetField = 'MapQuest_City__c';
        clsTarget.strStateTargetField = 'MapQuest_State_Province__c';
        clsTarget.strPostalCodeTargetField = 'MapQuest_Postal_Code__c';
        clsTarget.strCountryTargetField = 'MapQuest_Country_Code__c';
        clsTarget.strLatField = 'Latitude__c';
        clsTarget.strLngField = 'Longitude__c';
        
        Utility_GeolocationBatchProcessor clsBatch = 
            new Utility_GeolocationBatchProcessor();
        clsBatch.clsTarget = clsTarget;
        clsBatch.setScopeIds = mapPendingGeo.keySet();
        clsBatch.strObject = 'Account';

        Id idBatchprocess = Database.executeBatch(clsBatch,150);

	}

}