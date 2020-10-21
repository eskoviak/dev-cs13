/**
* {Purpose} – This is the corresponding testClass for the NotificationUtils.cls
* <p>
* {Function} – (optional) A brief paragraph describing any functional details
* <p>
* {Comments} – (optional) Any additional comments that may be useful.
*
* @author	Mike Eaton
* @version	2013-07-15
*/

/**
* CHANGE HISTORY
* =============================================================================
* Date			Name			Description
* 2013-07-15	Mike Eaton		Created      
* {Date}    	{Changed By}	({Ticket}) – {Change Description}
* =============================================================================
*/
@isTest(SeeAllData=true)
private class NotificationUtilsTest {
	
	static testMethod void unitTest() {
		
		string sBlankName = ' ';
		string sInvalidName = 'InvalidSetting';
		string sValidName = 'geocode';
		NotificationUtils.SettingData myData = new NotificationUtils.SettingData() ;
		  
		//  test 1 - Blank setting name
		string sTest1Msg = 'Invalid value - settingName parameter cannot be blank!';
		try{
			myData = NotificationUtils.getNotificationSettings(sBlankName);
		}
		catch (Exception ex){
			system.assertEquals(ex.getMessage(), sTest1Msg );	
		}	
		
		//	test 2 - Invalid setting name
		string sTest2Msg = 'Invalid value - NotificationSetting.Name, "' + sInvalidName + '" does not exist!';
		try{
			myData = NULL;
			myData = NotificationUtils.getNotificationSettings(sInvalidName);
		}	
		catch (Exception ex){
			system.assertEquals(ex.getMessage(), sTest2Msg);	
		}
		
		//	test 3 - Valid setting name
		try{
			myData = NULL;
			myData = NotificationUtils.getNotificationSettings(sValidName);
			
			system.assertEquals(myData.settingName, sValidName);
			system.assertNotEquals(myData.listToEmail, NULL);
			system.assertNotEquals(myData.replyToEmail, NULL);
			system.assertNotEquals(myData.priority, NULL);
			system.assertNotEquals(myData.isActive, NULL);
		}	
		catch (Exception ex){
			throw ex;
		}
		
	}
}