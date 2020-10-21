public with sharing class Utility_CaseLI {

/**
*   {Purpose}  �  This class holds general utilities for the Case Line Item object
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20140207  	Andy Boettcher DCS		Created
*   =============================================================================
*/

	///////////////////////////////////
	// Constructors
	///////////////////////////////////
	
	///////////////////////////////////
	// GET / SET
	///////////////////////////////////
	
	///////////////////////////////////
	// Action Methods
	///////////////////////////////////
	public static void calcMktVendorShopLiteCLI(List<Case_Line_Item__c> lstLineItems) {

		System.debug('**** START ****');

		List<Case> lstCases = new List<Case>();
		List<Case> lstCasesToUpdate = new List<Case>();
		Map<String, Map<Integer, String>> mapQuantityPicklist = new Map<String, Map<Integer, String>>();
		Map<Integer, String> mapTempISWS = new Map<Integer, String>();
		Map<Integer, String> mapTempISHS = new Map<Integer, String>();
		Map<Integer, String> mapTempRWS = new Map<Integer, String>();
		Map<Integer, String> mapTempISWL = new Map<Integer, String>();
		Map<Integer, String> mapTempISHL = new Map<Integer, String>();
		Map<Integer, String> mapTempRWL = new Map<Integer, String>();

		// Create Map of Quantity Picklist Options
		mapTempISWS.put(0,'');mapTempISHS.put(0,'');mapTempRWS.put(0,'');
		for(Integer i=1; i<9; i++) { mapTempISWS.put(i,'1-8 units'); }
		for(Integer i=9; i<18; i++) { mapTempISWS.put(i,'9-17 units'); }
		for(Integer i=18; i<27; i++) { mapTempISWS.put(i,'18-26 units'); }
		for(Integer i=1; i<9; i++) { mapTempISHS.put(i,'1-8 units'); }
		for(Integer i=9; i<18; i++) { mapTempISHS.put(i,'9-17 units'); }
		for(Integer i=18; i<27; i++) { mapTempISHS.put(i,'18-26 units'); }
		for(Integer i=1; i<9; i++) { mapTempRWS.put(i,'1-8 units'); }
		for(Integer i=9; i<18; i++) { mapTempRWS.put(i,'9-17 units'); }
		for(Integer i=18; i<27; i++) { mapTempRWS.put(i,'18-26 units'); }
		mapQuantityPicklist.put('ISWSlatwall',mapTempISWS);
		mapQuantityPicklist.put('ISHSlatwall',mapTempISHS);
		mapQuantityPicklist.put('RWSlatwall',mapTempRWS);
		System.Debug('mapTemp = ' + mapQuantityPicklist);

		System.debug('**** 1 ****');

		mapTempISWL.put(0,'');mapTempISHL.put(0,'');mapTempRWL.put(0,'');
		for(Integer i=1; i<5; i++) { mapTempISWL.put(i,'1-4 units'); }
		for(Integer i=5; i<10; i++) { mapTempISWL.put(i,'5-9 units'); }
		for(Integer i=10; i<15; i++) { mapTempISWL.put(i,'10-14 units'); }
		for(Integer i=1; i<5; i++) { mapTempISHL.put(i,'1-4 units'); }
		for(Integer i=5; i<10; i++) { mapTempISHL.put(i,'5-9 units'); }
		for(Integer i=10; i<15; i++) { mapTempISHL.put(i,'10-14 units'); }
		for(Integer i=1; i<5; i++) { mapTempRWL.put(i,'1-4 units'); }
		for(Integer i=5; i<10; i++) { mapTempRWL.put(i,'5-9 units'); }
		for(Integer i=10; i<15; i++) { mapTempRWL.put(i,'10-14 units'); }
		mapQuantityPicklist.put('ISWLozier',mapTempISWL);
		mapQuantityPicklist.put('ISHLozier',mapTempISHL);
		mapQuantityPicklist.put('RWLozier',mapTempRWL);

		System.debug('**** 2 ****');	

		// Determine CLIs in Scope based on parent Case RT
		Id idScopeRT = Util.getRecordTypeId('Marketing Vendor Shop Lite');
		Set<Id> setIds = new Set<Id>();

		for(Case_Line_Item__c cli : lstLineItems) {
			if(cli.Panels__r.RecordTypeId == idScopeRT) {
				setIds.add(cli.Panels__c);
			}
		}

		System.debug('**** 3 ****');

		// Query Cases with CLI relationships
		lstCases = [SELECT Id, ISH_Total_Lozier_Backer_Panels_Total__c, ISH_Total_Slatwall_Backer_Panels__c, ISW_Total_Lozier_Backer_Panels__c, ISW_Total_Slatwall_Backer_Panels__c,
						RW_Total_Lozier_Backer_Panels__c, RW_Total_Slatwall_Backer_Panels__c,  
						(SELECT Backer_Panel_Graphic__c, Backer_Panel_Size__c, Merchandising_System__c, Total_Backer_Panels__c, RecordType.DeveloperName FROM Case_Line_Items__r) 
					FROM Case
					WHERE Id IN :setIds
						AND RecordType.DeveloperName = 'Marketing_Vendor_Shop_Lite'];

		System.debug('**** - lstCases Size = ' + lstCases.size());

		// Loop through and do math / update fields
		for(Case cse : lstCases) {
			
			// Reset Counts
			Integer intCountISHLozier = 0;
			Integer intCountISHSlatwall = 0;
			Integer intCountISWLozier = 0;
			Integer intCountISWSlatwall = 0;
			Integer intCountRWLozier = 0;
			Integer intCountRWSlatwall = 0;

			// Spin through Related Case Line Items
			for(Case_Line_Item__c cli : cse.Case_Line_Items__r) {

				if(cli.Merchandising_System__c == 'Lozier End Cap') {
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Irish_Setter_Hunt') {
						intCountISHLozier += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Irish_Setter_Work') {
						intCountISWLozier += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Red_Wing_Brand') {
						intCountRWLozier += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
				}

				if(cli.Merchandising_System__c == 'Slatwall') {
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Irish_Setter_Hunt') {
						intCountISHSlatwall += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Irish_Setter_Work') {
						intCountISWSlatwall += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
					if(cli.RecordType.DeveloperName == 'Vendor_Shop_Lite_Red_Wing_Brand') {
						intCountRWSlatwall += Integer.valueOf(cli.Total_Backer_Panels__c);
					}
				}
			}

			// Set Number Fields on parent Case
			cse.ISH_Total_Lozier_Backer_Panels_Total__c = intCountISHLozier;
			cse.ISH_Total_Slatwall_Backer_Panels__c = intCountISHSlatwall;
			cse.ISW_Total_Lozier_Backer_Panels__c = intCountISWLozier;
			cse.ISW_Total_Slatwall_Backer_Panels__c = intCountISWSlatwall;
			cse.RW_Total_Lozier_Backer_Panels__c = intCountRWLozier;
			cse.RW_Total_Slatwall_Backer_Panels__c = intCountRWSlatwall;

			System.Debug(intCountISHSlatwall);
			System.Debug(mapQuantityPicklist.get('ISHSlatwall'));
			System.Debug(mapQuantityPicklist.get('ISHSlatwall').get(intCountISHSlatwall));

			cse.ISH_Lozier_End_Cap_Panel_Total__c = mapQuantityPicklist.get('ISHLozier').get(intCountISHLozier);
			cse.ISW_Lozier_End_Cap_Panel_Total__c = mapQuantityPicklist.get('ISWLozier').get(intCountISWLozier);
			cse.RW_Lozier_End_Cap_Panel_Total__c = mapQuantityPicklist.get('RWLozier').get(intCountRWLozier);
			cse.ISH_Slatwall_Backer_Panel_Total__c = mapQuantityPicklist.get('ISHSlatwall').get(intCountISHSlatwall);
			cse.ISW_Slatwall_Backer_Panel_Total__c	 = mapQuantityPicklist.get('ISWSlatwall').get(intCountISWSlatwall);
			cse.RW_Slatwall_Panel_Total__c = mapQuantityPicklist.get('RWSlatwall').get(intCountRWSlatwall);

			// Add Case to Update List
			lstCasesToUpdate.add(cse);

		}

		// Update List
		if(lstCasesToUpdate.size() > 0) {
			update lstCasesToUpdate;
		}

	}

	///////////////////////////////////
	// Helper Classes
	///////////////////////////////////

}