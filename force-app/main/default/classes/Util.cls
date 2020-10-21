/**
* CHANGE HISTORY
* =============================================================================
* Date			Name				Description
* 2013-07-13	Mike Eaton			Refactored NotificationSettings logic and moved to
*										separate class called NotificationUtils.cls
* 20131008		Andy Boettcher DCS	Added notifyProfileOfError as a general utility method to notify
*										specific profiles of error conditions via email
* 20131203		Andy Boettcher DCS	Added logMessage as a general utility method to allow for the 
*									predictable insertion of System.Debugs in the DevCon.
* 20140311      Andy Boettcher DCS  Added section for Utility Functions and Items - and CODE_SETTINGS()
*                                   to control trigger firing based on Custom Setting
* 20141028      Andy Boettcher DCS  Added calculateHaversineDistance to aid in geolocation methods
*										
*/
public with sharing class Util {
	
    public static Boolean bolZipAssignRecursion = false;
    public static Boolean bolGeoRecursion = false;

    public static string NullCheck(string sString){
		if(sString == null || sString == '')
			return '';
		return sString;
	}
	
	public static string getRecordTypeId(String DeveloperName){
        List<RecordType> lstRc = [Select id from Recordtype where DeveloperName=:DeveloperName];
        if(lstRc <> null && lstRc.size()>0){
            return lstRc[0].Id;
        }
        return null;
    }
        
    public static void notifyProfileOfError(String strProfile, String strSubject, String strBody) {
    	
    	List<String> lstEmails = new List<String>();
    	
    	for(User usr : [SELECT Id, Email FROM User WHERE Profile.Name = :strProfile AND IsActive = true LIMIT 10]) {
    		lstEmails.add(usr.Email);
    	}
    	
    	Messaging.singleEmailMessage msg = new Messaging.singleEmailMessage();
    	msg.setToAddresses(lstEmails);
    	msg.setSubject(strSubject);
    	msg.setPlainTextBody(strBody);
    	msg.setHtmlBody(strBody);
    	
    	Messaging.sendEmail(new Messaging.singleEmailMessage[] { msg });
    	
    }
    
    public static void logMessage(String methodName, String errorMessage) {
    	
    	System.Debug(LOGGINGLEVEL.ERROR, '*** ' + methodName + ' *** : ' + errorMessage);
    	
    }

    private static Double toRadians(Decimal degree){
        return degree * 3.1415926 / 180;
    }

    public static Decimal calculateHaversineDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2){
        // Earth's radius varies from 6356.752 km at the poles to 6378.137 km at the equator
        Double radius = 6371.00;
        Double dLat = toRadians(lat2-lat1);
        Double dLon = toRadians(lon2-lon1);
        Double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
        Double c = 2 * Math.asin(Math.sqrt(a));

        double kmToMiles = 0.621371;
        Decimal retVal = radius * c * kmToMiles;
        //System.Debug('computing ' + retVal);
        return retVal;
    }

    ///////////////////////////////////
    // Utility Functions / Maps
    ///////////////////////////////////
    public static Map<String, Boolean> CODE_SETTINGS() {
        Map<String, Boolean> mapAPEXSettings = new Map<String, Boolean>();
        for(APEX_Trigger_Settings__c ATS : APEX_Trigger_Settings__c.getall().values()) {
            mapAPEXSettings.put(ATS.Name, ATS.IsActive__c);
        }
        return mapAPEXSettings;
    }
  
}