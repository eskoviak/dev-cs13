/**
*   {Purpose}  �  Provides Unit Test Coverage for Mapquest Geolocation API Triggers and Classes
*					RWS Case 00030196
*
*	{Code Covered}	- Utility_Geolocation.class, TriggerController_Account.trigger,
*						Utility_GeolocationBatchProcessor.class, Util.class
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20140808  	Andy Boettcher DCS		Created
*   =============================================================================
*/
@isTest
public class Utility_Geolocation_UT {

	public static String strJSONRecordId;
	public static String strJSONRecordCode;

	@isTest static void testScheduler() {

		String strCronExp = '0 0 0-23 ? * *';

		Utility_GeolocationSchedule clsGeoSchedule = new Utility_GeolocationSchedule();
		String strJobId = System.schedule('MapQuest Geolocation - Account - Test', strCronExp, clsGeoSchedule);

		CronTrigger ctTest = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :strJobId];
		System.assertEquals(strCronExp, ctTest.CronExpression, 'Desired Time and Scheduled Time do not match!');

	}

	@isTest static void testManualFutureMethod() {
		
		Account acct = new Account(Name='Good Address',M3_Location_State_Province__c='IL',
									M3_Location_City__c='EVERGREEN PARK',
									M3_Location_ZIP_Postal_Code__c='11111',
									M3_Location_Street__c='3347 W 95TH ST',
									Geocode_Status__c='Pending');

		test.startTest();
		
		insert acct;
		Set<Id> setScopeIds = new Set<Id>();
		setScopeIds.add(acct.Id);

		Utility_Geolocation.hClsGeocodeTarget clsTarget = new Utility_Geolocation.hClsGeocodeTarget();
		clsTarget.strObject = 'Account';
		clsTarget.strResultStatusField = 'Geocode_Status__c';
		clsTarget.strResultMessageField = 'Geocode_Message__c';
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

		Utility_Geolocation.processBatchGeocodes(JSON.serialize(clsTarget), setScopeIds);

		test.stopTest();

	}
	
	@isTest static void testGeoJSONRecordPass() {
		
		dataSetup();
		Account acct = new Account(Name='Good Address',M3_Location_State_Province__c='IL',
									M3_Location_City__c='EVERGREEN PARK',
									M3_Location_ZIP_Postal_Code__c='11111',
									M3_Location_Street__c='3347 W 95TH ST',
									Geocode_Status__c='Pending');

		test.startTest();
		insert acct;
		test.stopTest();

	}

	@isTest static void testGeoJSONRecordFail() {

		dataSetup();
		Account acct = new Account(Name='Bad Address',M3_Location_State_Province__c='Alaska',
									M3_Location_City__c='Rennertown',
									M3_Location_ZIP_Postal_Code__c='22222',
									M3_Location_Street__c='498 Coleman Circle',
									Geocode_Status__c='Pending');
		test.startTest();
		insert acct;
		test.stopTest();

	}

	@isTest static void testGeoJSONResponseFail() {

		dataSetup();
		Account acct = new Account(Name='Bad Address',M3_Location_State_Province__c='Alaska',
									M3_Location_City__c='Rennertown',
									M3_Location_ZIP_Postal_Code__c='33333',
									M3_Location_Street__c='498 Coleman Circle',
									Geocode_Status__c='Pending');
		test.startTest();
		insert acct;
		test.stopTest();

	}

	@isTest static void testGeoRecordFail() {

		dataSetup();
		Account acct = new Account(Name='Bad Address',M3_Location_State_Province__c='Alaska',
									M3_Location_City__c='Rennertown',
									M3_Location_ZIP_Postal_Code__c='',
									M3_Location_Street__c='',
									Geocode_Status__c='Pending');
		test.startTest();
		insert acct;
		test.stopTest();

	}

	@isTest static void testGeoRecordPassPoorQuality() {

		dataSetup();
		Account acct = new Account(Name='Bad Address',M3_Location_State_Province__c='Alaska',
									M3_Location_City__c='Rennertown',
									M3_Location_ZIP_Postal_Code__c='44444',
									M3_Location_Street__c='498 Coleman Circle',
									Geocode_Status__c='Pending');
		test.startTest();
		insert acct;
		test.stopTest();

	}

	@isTest static void testResponseClasses() {

		test.startTest();
		
		Utility_Geolocation.hClsGeocodeResponse clsResponse = new Utility_Geolocation.hClsGeocodeResponse();
		clsResponse.info = null;
		clsResponse.options = null;
		clsResponse.results = null;

		Utility_Geolocation.hClsGeocodeLocationResponse clsLocation = new Utility_Geolocation.hClsGeocodeLocationResponse();
		clsLocation.street = null;
		clsLocation.adminArea6  = null;
		clsLocation.adminArea6Type = null;
		clsLocation.adminArea5 = null;
		clsLocation.adminArea5Type  = null;
		clsLocation.adminArea4  = null;
		clsLocation.adminArea4Type  = null;
		clsLocation.adminArea3  = null;
		clsLocation.adminArea3Type  = null;
		clsLocation.adminArea1  = null;
		clsLocation.adminArea1Type  = null;
		clsLocation.postalCode  = null;
		clsLocation.geocodeQualityCode   = null;
		clsLocation.geocodeQuality   = null;
		clsLocation.dragPoint   = null;
		clsLocation.sideOfStreet   = null;
		clsLocation.linkId   = null;
		clsLocation.unknownInput   = null;
		clsLocation.type  = null;


		test.stopTest();

	}

	private static void dataSetup() {
		APEX_Trigger_Settings__c apexSetting = new APEX_Trigger_Settings__c(Name='geoLocationAccount', IsActive__c=true);
		insert apexSetting;
	}

    public static String jsonGoodResponse {
    	get {
    		String strJSON = '';
			if(strJSONRecordCode == '11111') {
				strJSON = 'renderBatch({"info":{"statuscode":0,"copyright":{"text":"\u00A9 2014 MapQuest, Inc.","imageUrl":"http://api.mqcdn.com/res/mqlogo.gif","imageAltText":"\u00A9 2014 MapQuest, Inc."},"messages":[]},"options":{"maxResults":1,"thumbMaps":false,"ignoreLatLngInput":false},"results":[{"providedLocation":{"street":"3347W95thSt","city":"EvergreenPark","state":"IL","postalCode":"60805-2202","recordid":"' + strJSONRecordId + '"},"locations":[{"street":"3347 W 95th St","adminArea6":"","adminArea6Type":"Neighborhood","adminArea5":"Evergreen Park","adminArea5Type":"City","adminArea4":"Cook","adminArea4Type":"County","adminArea3":"IL","adminArea3Type":"State","adminArea1":"US","adminArea1Type":"Country","postalCode":"60805-2202","geocodeQualityCode":"P1AAA","geocodeQuality":"POINT","dragPoint":false,"sideOfStreet":"L","linkId":"178400010497655","unknownInput":"","type":"s","latLng":{"lat":41.720671,"lng":-87.706378},"displayLatLng":{"lat":41.720334,"lng":-87.706369}}]}]})';
			}
			if(strJSONRecordCode == '22222') {
				strJSON = 'renderBatch({"info":{"statuscode":200,"copyright":{"text":"\u00A9 2014 MapQuest, Inc.","imageUrl":"http://api.mqcdn.com/res/mqlogo.gif","imageAltText":"\u00A9 2014 MapQuest, Inc."},"messages":[]},"options":{"maxResults":1,"thumbMaps":false,"ignoreLatLngInput":false},"results":[{"providedLocation":{"street":"3347W95thSt","city":"EvergreenPark","state":"IL","postalCode":"60805-2202","recordid":"' + strJSONRecordId + '"},"locations":[{"street":"3347 W 95th St","adminArea6":"","adminArea6Type":"Neighborhood","adminArea5":"Evergreen Park","adminArea5Type":"City","adminArea4":"Cook","adminArea4Type":"County","adminArea3":"IL","adminArea3Type":"State","adminArea1":"US","adminArea1Type":"Country","postalCode":"60805-2202","geocodeQualityCode":"P1AAA","geocodeQuality":"POINT","dragPoint":false,"sideOfStreet":"L","linkId":"178400010497655","unknownInput":"","type":"s","latLng":{"lat":41.720671,"lng":-87.706378},"displayLatLng":{"lat":41.720334,"lng":-87.706369}}]}]})';
			}
			if(strJSONRecordCode == '33333') {
				strJSON = 'renderBatch(BAD BAD BAD BAD BAD JSON RESPONSE)';
			}
			if(strJSONRecordCode == '44444') {
				strJSON = 'renderBatch({"info":{"statuscode":0,"copyright":{"text":"\u00A9 2014 MapQuest, Inc.","imageUrl":"http://api.mqcdn.com/res/mqlogo.gif","imageAltText":"\u00A9 2014 MapQuest, Inc."},"messages":[]},"options":{"maxResults":1,"thumbMaps":false,"ignoreLatLngInput":false},"results":[{"providedLocation":{"street":"3347W95thSt","city":"EvergreenPark","state":"IL","postalCode":"60805-2202","recordid":"' + strJSONRecordId + '"},"locations":[{"street":"3347 W 95th St","adminArea6":"","adminArea6Type":"Neighborhood","adminArea5":"Evergreen Park","adminArea5Type":"City","adminArea4":"Cook","adminArea4Type":"County","adminArea3":"IL","adminArea3Type":"State","adminArea1":"US","adminArea1Type":"Country","postalCode":"60805-2202","geocodeQualityCode":"XXXXX","geocodeQuality":"POINT","dragPoint":false,"sideOfStreet":"L","linkId":"178400010497655","unknownInput":"","type":"s","latLng":{"lat":41.720671,"lng":-87.706378},"displayLatLng":{"lat":41.720334,"lng":-87.706369}}]}]})';
			}

    		return strJSON;
    	}
    }
	
}