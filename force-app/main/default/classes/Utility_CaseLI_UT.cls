@isTest
private class Utility_CaseLI_UT {
	
	@isTest static void test() {
		
		// Prep Test Data
		APEX_Trigger_Settings__c apexSetting = new APEX_Trigger_Settings__c(Name='calcMktVendorShopLiteCLI', IsActive__c=true);
		insert apexSetting;

		Map<String, Id> mapCLIRT = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case_Line_Item__c']) {
			mapCLIRT.put(rt.DeveloperName, rt.Id);
		}

		Map<String, Id> mapCaseRT = new Map<String, Id>();
		for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case']) {
			mapCaseRT.put(rt.DeveloperName, rt.Id);
		}

		Id idScopeRT = mapCaseRT.get('Marketing_Vendor_Shop_Lite');
		System.Debug('************** ' + idScopeRT);
		Case cseRoot = new Case(Subject='Test Case',RecordTypeId=idScopeRT);
		insert cseRoot;

		// Start Test
		test.startTest();

		Case_Line_Item__c cliISHLozier = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Irish_Setter_Hunt')); 
		cliISHLozier.Merchandising_System__c = 'Lozier End Cap';
		cliISHLozier.Total_Backer_Panels__c = 1;
		insert cliISHLozier;

		Case_Line_Item__c cliISWLozier = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Irish_Setter_Work')); 
		cliISWLozier.Merchandising_System__c = 'Lozier End Cap';
		cliISWLozier.Total_Backer_Panels__c = 1;
		insert cliISWLozier;

		Case_Line_Item__c cliRWLozier = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Red_Wing_Brand')); 
		cliRWLozier.Merchandising_System__c = 'Lozier End Cap';
		cliRWLozier.Total_Backer_Panels__c = 1;
		insert cliRWLozier;


		Case_Line_Item__c cliISHSlatwall = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Irish_Setter_Hunt')); 
		cliISHSlatwall.Merchandising_System__c = 'Slatwall';
		cliISHSlatwall.Total_Backer_Panels__c = 1;
		insert cliISHSlatwall;

		Case_Line_Item__c cliISWSlatwall = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Irish_Setter_Work')); 
		cliISWSlatwall.Merchandising_System__c = 'Slatwall';
		cliISWSlatwall.Total_Backer_Panels__c = 1;
		insert cliISWSlatwall;

		Case_Line_Item__c cliRWSlatwall = new Case_Line_Item__c(Panels__c=cseRoot.Id,RecordTypeId=mapCLIRT.get('Vendor_Shop_Lite_Red_Wing_Brand')); 
		cliRWSlatwall.Merchandising_System__c = 'Slatwall';
		cliRWSlatwall.Total_Backer_Panels__c = 1;
		insert cliRWSlatwall;



		// End Test
		test.stopTest();

	}
	
}