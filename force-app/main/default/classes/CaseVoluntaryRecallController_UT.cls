@isTest
private class CaseVoluntaryRecallController_UT {

/**
*   {Purpose}  �  Unit Test for CaseVoluntaryRecallController
*                 
*   {Function}  � None, Unit Test.
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20131105	Andy Boettcher DCS		Created
*   =============================================================================
*/

    static testMethod void testRecallController() {
       
        // Create Base Data
		Account acctTest = new Account(Name='Test Account');
		insert acctTest;
		
		Case cseTest = new Case();
		cseTest.AccountId = acctTest.Id;
		cseTest.Subject = 'Test Case';
		cseTest.Type = 'Voluntary Recall';
		cseTest.Status = 'New';
		cseTest.Origin = 'Phone';
		insert cseTest;
 		
		// Create Custom Setting Data
		List<Voluntary_Recall_Rules__c> lstRecallRules = new List<Voluntary_Recall_Rules__c>();
		lstRecallRules.add(new Voluntary_Recall_Rules__c(Name='test1',IsActive__c=true,StyleScope__c='B:15|C:13|D:13,14,15,16|E:13|E2:11,11.5,12,13,14,15|H:11,11.5,12,13'));
		lstRecallRules.add(new Voluntary_Recall_Rules__c(Name='test2',IsActive__c=true,StyleScope__c='D:13,14,15|E2:11,11.5,12,13,14|H:11,11.5,12,13'));
		lstRecallRules.add(new Voluntary_Recall_Rules__c(Name='test3',IsActive__c=true,StyleScope__c='B:15|D:13,14,15|E2:11,11.5,12,13,14,15|H:11,11.5,12,13'));
		lstRecallRules.add(new Voluntary_Recall_Rules__c(Name='test4',IsActive__c=true,StyleScope__c='D:13,14|E3:11,11.5,12,13'));
		lstRecallRules.add(new Voluntary_Recall_Rules__c(Name='test5',IsActive__c=true,StyleScope__c='D:13,14,15|E2:11,11.5,12,13|H:11,11.5,12,13'));
		insert lstRecallRules;
		
		test.startTest();
		
		// Instanciate Controller
		CaseVoluntaryRecallController clsRecall = new CaseVoluntaryRecallController(new ApexPages.standardController(cseTest));
		System.Assert(clsRecall.idRecord != null, 'Controller idRecord is NULL!');
		
		// Pull up preliminary List, no existing values
		List<CaseVoluntaryRecallController.hClsStyle> lstStylesInitial = clsRecall.lstStyles;
		System.Assert(lstStylesInitial.size() == 5, 'Initial Style List did not populate correctly!');
		
		String strResult = null;
		// Insert some new values - POSITIVE
		strResult = CaseVoluntaryRecallController.processData(string.valueOf(cseTest.Id), 'New', '', 'test1', 'B', '15', '42');
		System.Assert(strResult == 'success', 'Initial POSITIVE insert did not work!');
		
		// Insert some new values - NEGATIVE (bad data in Quantity)
		strResult = CaseVoluntaryRecallController.processData(string.valueOf(cseTest.Id), 'New', '', 'test1', 'B', '15', 'ABC');
		System.Assert(strResult != 'success', 'Initial NEGATIVE insert did work, shouldn\'t have!');
		
		// Requery Style List, should have existing values now
		List<CaseVoluntaryRecallController.hClsStyle> lstStylesExisting = clsRecall.lstStyles;
		System.Assert(lstStylesExisting.size() == 5, 'Existing Style List did not populate correctly!');
		
		// Delete Values - SUCCESS
		strResult = CaseVoluntaryRecallController.deleteData(string.valueOf(cseTest.Id), 'New', 'test1', 'B', '15');
		System.Assert(strResult == 'success', 'Initial POSITIVE delete did not work!');
		
		test.stopTest();
			
    }
}