global with sharing class Utility_Geolocation {
/**
*   {Purpose}  �  Utilizes the MapQuest Bulk API to process geolocation information for records.
*					This method can be used with any object as long as fields are present.
*					(Case 00030196)
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
	
	///////////////////////////
	// Action Methods
	///////////////////////////
	@future(callout=true)
	public static void processBatchGeocodes(String strDefJSON, Set<Id> setTargetIds) {

		// Deserialize clsDef (Future)
		hClsGeocodeTarget clsDef = (hClsGeocodeTarget)JSON.deserialize(strDefJSON, hClsGeocodeTarget.class);
		processBatchGeocodes(clsDef, setTargetIds);
	}

	public static void processBatchGeocodes(hClsGeocodeTarget clsDef, Set<Id> setTargetIds) {

		// Variables
		String strBaseURL = 'http://www.mapquestapi.com/geocoding/v1/batch?key=';
		//String strMapquestKey = 'Fmjtd%7Cluur200r2h%2Caw%3Do5-9a1n94'; // Original Key
		String strMapquestKey = 'Gmjtd%7Cluur2002n9%2Cb5%3Do5-lrag0';
		//String strURLSuffix = '&callback=renderBatch&json=';
		String strURLSuffix = '&callback=renderBatch&inFormat=json';
		Set<String> setGeoGranularity = new Set<String>();
		setGeoGranularity.add('P1');
		setGeoGranularity.add('L1');

		// Step 1:  Pull targetIds in to MAP
		Set<String> setFieldNames = new Set<String>();
		setFieldNames.add(clsDef.strResultMessageField);
		setFieldNames.add(clsDef.strLatField);
		setFieldNames.add(clsDef.strLngField);
		setFieldNames.add(clsDef.strStreetSourceField);
		setFieldNames.add(clsDef.strCitySourceField);
		setFieldNames.add(clsDef.strStateSourceField);
		setFieldNames.add(clsDef.strPostalCodeSourceField);
		setFieldNames.add(clsDef.strCountrySourceField);
		setFieldNames.add(clsDef.strStreetTargetField);
		setFieldNames.add(clsDef.strCityTargetField);
		setFieldNames.add(clsDef.strStateTargetField);
		setFieldNames.add(clsDef.strPostalCodeTargetField);
		setFieldNames.add(clsDef.strCountryTargetField);

		String strQuery = 'SELECT ';
		for(String strField : setFieldNames) { strQuery+= strField + ', '; }
		strQuery+='Id ';
		strQuery+= ' FROM ' + clsDef.strObject;
		strQuery+= ' WHERE Id IN :setTargetIds';
		System.Debug('Query = ' + strQuery);
		Map<Id, sObject> mapTargets = new Map<Id, sObject>((List<sObject>)Database.query(strQuery));

		// Step 2:  Pull results in to JSON location list
		List<hClsGeocodeLocation> lstLocations = new List<hClsGeocodeLocation>();
		for(sObject so : mapTargets.values()) {
			if(Util.NullCheck((String)so.get('Id')) != '' &&
				Util.NullCheck((String)so.get(clsDef.strStreetSourceField)) != '' &&
				Util.NullCheck((String)so.get(clsDef.strPostalCodeSourceField)) != '') {

				// For Testing
				Utility_Geolocation_UT.strJSONRecordId = (String)so.get('Id');
				Utility_Geolocation_UT.strJSONRecordCode = (String)so.get(clsDef.strPostalCodeSourceField);

				hClsGeocodeLocation clsLocation = new hClsGeocodeLocation();
				clsLocation.recordid = Util.NullCheck((String)so.get('Id'));
				clsLocation.street = Util.NullCheck((String)so.get(clsDef.strStreetSourceField));
				clsLocation.city = Util.NullCheck((String)so.get(clsDef.strCitySourceField));
				clsLocation.state = Util.NullCheck((String)so.get(clsDef.strStateSourceField));
				clsLocation.postalCode = Util.NullCheck((String)so.get(clsDef.strPostalCodeSourceField));
				clsLocation.country = Util.NullCheck((String)so.get(clsDef.strCountrySourceField));
				lstLocations.add(clsLocation);
			} else {
				System.Debug((String)so.get('Id') + ' is being set to IGNORE');
				so.put(clsDef.strResultStatusField, 'Ignore');
				so.put(clsDef.strResultMessageField, 'Required Geolocation Address Not Provided');
			}
		}

		if(lstLocations.size() == 0) {
			System.Debug('No locations were specified for processing via MapQuestAPI, exiting method');
			if(mapTargets.values().size() > 0) { update mapTargets.values(); }
			return;
		}

		// Step 3:  Assemble HTTP Request
		String strEndpointURL = strBaseURL + strMapquestKey + strURLSuffix;
		hClsGeocodeRequest clsRequest = new hClsGeocodeRequest();
		clsRequest.options = new hClsGeocodeOptions(false, 1);
		clsRequest.locations = lstLocations;

		System.Debug(JSON.serialize(clsRequest));

		HttpRequest req = new HttpRequest();
		//req.setEndpoint(strEndpointURL + EncodingUtil.urlEncode(JSON.serialize(clsRequest), 'UTF-8'));
		req.setEndpoint(strEndpointURL);
		req.setMethod('POST');
		req.setHeader('referer', 'https://redwingshoes.my.salesforce.com'); // Needed for MapQuest AppKey security
		req.setBody(JSON.serialize(clsRequest));
		Http httpTransport = new Http();
		HttpResponse res = new HttpResponse();
		if(Test.isRunningTest()) {
			res.setStatus('200');
			res.setBody(Utility_Geolocation_UT.jsonGoodResponse);
		} else {
			res = httpTransport.send(req);
		}

		String strResponseBody = res.getBody();
		System.Debug(strResponseBody);

		strResponseBody = strResponseBody.replace('renderBatch(', '');
		strResponseBody = strResponseBody.substring(0, strResponseBody.length()-1);

		hClsGeocodeResponse apiResponse;
		try {
			apiResponse = (hClsGeocodeResponse)JSON.deserialize(strResponseBody, hClsGeocodeResponse.class);
		} catch(Exception ex) {
			System.Debug(ex);
			return;
		}

		System.Debug('API STATUS CODE = ' + apiResponse.info.statuscode);

		// Step 4:  Check statuscode
		if(apiResponse.info.statuscode != 0) {
			System.Debug('There was a problem returning information from MapQuestAPI - statuscode = ' + apiResponse.info.statuscode);
			System.Debug(apiResponse.info.messages);
			for(sObject so : mapTargets.values()) {
				//so.put(clsDef.strResultStatusField, 'Batch Failure');
				so.put(clsDef.strResultMessageField, String.valueOf(apiResponse.info.statuscode));
			}
		} else {
			for(hClsGeocodeResults result : apiResponse.results) {
				for(hClsGeocodeLocationResponse clsLoc : result.locations) {
					System.Debug('Processing result for ' + result.providedLocation.recordid + ' of quality/confidence ' + clsLoc.geocodeQualityCode + '/' + clsLoc.geocodeQuality);
					sObject so = mapTargets.get(result.providedLocation.recordid);
					
					if(Util.NullCheck(clsLoc.street) != '') { so.put(clsDef.strStreetTargetField, clsLoc.street); }
					if(Util.NullCheck(clsLoc.adminArea5) != '') { so.put(clsDef.strCityTargetField, clsLoc.adminArea5); }
					if(Util.NullCheck(clsLoc.adminArea3) != '') { so.put(clsDef.strStateTargetField, clsLoc.adminArea3); }
					if(Util.NullCheck(clsLoc.postalCode) != '') { so.put(clsDef.strPostalCodeTargetField, clsLoc.postalCode); }
					if(Util.NullCheck(clsLoc.adminArea1) != '') { so.put(clsDef.strCountryTargetField, clsLoc.adminArea1); }
					so.put(clsDef.strLatField, clsLoc.latLng.lat);
					so.put(clsDef.strLngField, clsLoc.latLng.lng);
					so.put(clsDef.strResultStatusField, 'Success');

					// Good Match
					if(setGeoGranularity.contains(clsLoc.geocodeQualityCode.substring(0,2))) {
						so.put(clsDef.strResultMessageField, 'High Quality Match, Code ' + clsLoc.geocodeQualityCode + ' (' + clsLoc.geocodeQuality + ')');
					} else {  // Bad Match
						so.put(clsDef.strResultMessageField, 'Poor Quality Match, Code ' + clsLoc.geocodeQualityCode + ' (' + clsLoc.geocodeQuality + ')');
					}
					mapTargets.put(result.providedLocation.recordid, so);
				}
			}
		}

		// Step 5:  Update List
		if(mapTargets.values().size() > 0) { update mapTargets.values(); }
	}
	
	
	///////////////////////////
	// Inner / Helper Classes
	///////////////////////////
	public class hClsGeocodeTarget {
		public String strObject {get;set;}
		public String strResultStatusField {get;set;}
		public String strResultMessageField {get;set;}
		public String strLatField {get;set;}
		public String strLngField {get;set;}
		public String strStreetSourceField {get;set;}
		public String strCitySourceField {get;set;}
		public String strStateSourceField {get;set;}
		public String strPostalCodeSourceField {get;set;}
		public String strCountrySourceField {get;set;}
		public String strStreetTargetField {get;set;}
		public String strCityTargetField {get;set;}
		public String strStateTargetField {get;set;}
		public String strPostalCodeTargetField {get;set;}
		public String strCountryTargetField {get;set;}
		public hClsGeocodeTarget() { }
	}

	public class hClsGeocodeRequest {
		public List<hClsGeocodeLocation> locations {get;set;}
		public hClsGeocodeOptions options {get;set;}
		public hClsGeocodeRequest() { }
	}

	public class hClsGeocodeOptions {
		public Boolean thumbMaps {get;set;}
		public Integer maxResults {get;set;}
		public hClsGeocodeOptions(Boolean passThumbMaps, Integer passMaxResults) {
			thumbMaps = passThumbMaps;
			maxResults = passMaxResults;
		}
	}

	public class hClsGeocodeLocation {
		public String recordid {get;set;}
		public String street {get;set;}
		public String city {get;set;}
		public String state {get;set;}
		public String postalCode {get;set;}
		public String country {get;set;}
		public hClsGeocodeLocation() { }
	}

	public class hClsGeocodeResponse {
		public hClsGeocodeResponseInfo info {get;set;}
		public hClsGeocodeOptions options {get;set;}
		public List<hClsGeocodeResults> results {get;set;}
	}

	public class hClsGeocodeResponseInfo {
		public Integer statuscode {get;set;}
		public List<String> messages {get;set;}

	}

	public class hClsGeocodeResults {
		public hClsGeocodeLocation providedLocation {get;set;}
		public List<hClsGeocodeLocationResponse> locations {get;set;}
	}

	public class hClsGeocodeLocationResponse {
		public String street {get;set;}
		public String adminArea6 {get;set;}
		public String adminArea6Type {get;set;}
		public String adminArea5 {get;set;}
		public String adminArea5Type {get;set;}
		public String adminArea4 {get;set;}
		public String adminArea4Type {get;set;}
		public String adminArea3 {get;set;}
		public String adminArea3Type {get;set;}
		public String adminArea1 {get;set;}
		public String adminArea1Type {get;set;}
		public String postalCode {get;set;}
		public String geocodeQualityCode {get;set;}
		public String geocodeQuality {get;set;}
		public Boolean dragPoint {get;set;}
		public String sideOfStreet {get;set;}
		public String linkId {get;set;}
		public String unknownInput {get;set;}
		public String type {get;set;}
		public hClsGeocodeLocationResponseCoords latLng {get;set;}
	}

	public class hClsGeocodeLocationResponseCoords {
		public Decimal lat {get;set;}
		public Decimal lng {get;set;}
	}
}