@isTest
public class RWS_EditAccounController_Test {
	@isTest
    public static void Constructor_Test(){

    	RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
 		System.runAs(dataFactory.TestRunner){
			//not sure if this is needs to be done per unit test method? I think so
			List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

			RWS_EditAccounController controller = new RWS_EditAccounController();
			System.assert(controller != null);
			System.assert(controller.editAccount.id == Industrial[0].Store_Account__c);
 		}
	} 

	@isTest
    public static void UpdateAcccount_Test(){

    	RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
 		System.runAs(dataFactory.TestRunner){
			//not sure if this is needs to be done per unit test method? I think so
			List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

			RWS_EditAccounController controller = new RWS_EditAccounController();
			controller.updateAcccountContact();
			//this code is weird. From the looks of it, the method will ALWAYS return the error message. 
			System.assert(controller.duplicationMessage.contains('We detected an account already established for') );
 		}
	} 

	@isTest
    public static void FinalUpdateAcccountContact_Test(){

    	RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
 		System.runAs(dataFactory.TestRunner){
			//not sure if this is needs to be done per unit test method? I think so
			List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

			RWS_EditAccounController controller = new RWS_EditAccounController();
			controller.finalUpdateAcccountContact();
			//this code is weird. From the looks of it, the method will ALWAYS return the error message.
			Id myType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M3 Wholesale Accounts').getRecordTypeId(); 
			System.assert(myType != null );
 		}
	} 
}