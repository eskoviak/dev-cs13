@isTest
public class RWS_RwbaaARSummaryController_Tests {
	@isTest
	public static void RWS_RwbaaARSummaryControllerTests(){
				
		Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	acc.IsPartner = true;
    	update acc;
    	
    	Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
    	Contact con2 = RWS_TestUtil.createContact(acc.Id, 1, false);

    	List<Contact> contacts = new List<Contact>{con2, con1};

    	insert contacts;
    	
    	RWBAA_AR_Data__c rwbaa = RWS_TestUtil.createRwbaa(acc.Id,false);
    	insert rwbaa;
    	
    	RWBAA_Contacts__c rwbaaCont = RWS_TestUtil.createRwbaaContact(acc.Id,false);
    	insert rwbaaCont;
    	
    	Test.startTest();
    		PageReference pageRef = Page.RWS_AccountRwbaaSummary; 
	        pageRef.getParameters().put('Id', String.valueOf(acc.Id));
			Test.setCurrentPage(pageRef);
    		RWS_RwbaaARSummaryController controller = new RWS_RwbaaARSummaryController();
    		
    	Test.stopTest();
	} 
    
}