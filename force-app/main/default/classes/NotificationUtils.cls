/**
* {Purpose} – The purpose of the class is to encapsulate the any logic necessary
*				to support the use of the NotificationSettings custom setting 
*				object.
* <p>
* {Function} – The NotificationSettings object allows system admins to easily
*				configure any email notification details that are generated
*				from Apex code such as ToEmail, ReplyToEmail, CcEmails and 
*				Priority
* <p>
* {Comments} – This class is dependent on the following components:
*				- NotificationSettings custom setting object
*
* @author	Mike Eaton
* @version	2013-07-13
*
	//	USAGE SAMPLE for Execute Anonymous:
	string sName = 'geocode';
	try{
		//NotificationUtils oNU = new NotificationUtils(sName);
		//system.debug(oNU.getNotificationSettings());
		NotificationUtils.SettingData myData = new  NotificationUtils.SettingData();
		myData = NotificationUtils.getNotificationSettings(sName);
		system.debug(myData.SettingName);
		if( myData.listCcEmail != NULL) {
			system.debug(myData.listCcEmail[0]);
			system.debug(myData.listCcEmail[1]);	
		}
	}
	catch (exception ex)
	{
		system.debug(ex.getMessage());
	}
*/

/**
* CHANGE HISTORY
* =============================================================================
* Date			Name			Description
* 2013-07-13	Mike Eaton		Created      
* {Date}    	{Changed By}	({Ticket}) – {Change Description}
* =============================================================================
*/

public with sharing class NotificationUtils{



	/* 	Contains the custom configuration setting data reformatted 
		for consumption by the Messaging.SingleEmailMessage class
	*/		 
    public class SettingData{
		public String settingName = '';
		public List<String> listToEmail = null;
		public List<String> listCcEmail = null;
		public String replyToEmail = '';
		public Boolean isActive = false;
		public String priority = '';
    }
    
    //	Class level exception
    public class ClassException extends Exception {}
    
    public static SettingData getNotificationSettings(string settingName){
		//	Member variables
		
    	string sNameAllCaps = null;
    	string sExMsg = '';
       
        //  validate argument
        if( string.isBlank(settingName) ){
        	sExMsg = 'Invalid value - settingName parameter cannot be blank!';
            throw new ClassException(sExMsg);
        }
       
        //  get custom setting data
        sNameAllCaps = settingName.toUpperCase();
    	NotificationSettings__c oNS = NotificationSettings__c.getValues(sNameAllCaps);
    	system.debug(oNS);
		if( oNS == null ){
			sExMsg = 'Invalid value - NotificationSetting.Name, "' + settingName + '" does not exist!';
			throw new ClassException(sExMsg);
			
		}
		
		//	set object data
		SettingData oData = new SettingData(); 
		oData.settingName = settingName;
		oData.listToEmail = new List<string>{oNS.ToEmail__c};
		oData.replyToEmail = oNS.ReplyToEmail__c;
		
		//  validate CcEmail__c contains data
		string sCcEmail = oNS.CcEmail__c;
		if( string.isNotBlank(sCcEmail) ){
			List<string> listCcEmail = sCcEmail.split(';');
			oData.listCcEmail = listCcEmail;
		}
		oData.priority = oNS.Priority__c;
		oData.isActive = oNS.IsActive__c;		

		//system.debug( moData );
		return oData;
	}
	
}