public with sharing class ZipAssignManagerController {

/**
*   {Purpose}  �  Provides an interface to allow users to manage Area / Sales Rep Assignments
*                 
*   {Function}  � Interfaces with ZipAssignManager VF page
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date    	Name             		Description
*   20140311  	Andy Boettcher DCS		Created
*   =============================================================================
*/
/*
	public hClsSearch clsSearch {get;set;}
	public Boolean bolSearch = false;
	public String strQuery {get;set;}
	public String strZipRealign {get;set;}

	///////////////////////////////////
	// Constructors
	///////////////////////////////////
	*/public ZipAssignManagerController() {
		//clsSearch = new hClsSearch();
		//bolSearch = false;
	}/*

	///////////////////////////////////
	// GET / SET
	///////////////////////////////////
	public List<Zip_Code_Area_Assignment__c> getlstAssign() {

		List<Zip_Code_Area_Assignment__c> lstTemp = new List<Zip_Code_Area_Assignment__c>();

		if(!bolSearch) {
			return lstTemp;
		}

		//String strQuery = '';
		strQuery = 'SELECT Id, IsActive__c, Assignment_Effective_Date__c, Role__c, Owner.Name, Account_Owner__c, Account_Owner__r.Name, Zip_Code_Lookup__r.Name, Zip_Code_Lookup__r.City__c, Zip_Code_Lookup__r.County__c, Zip_Code_Lookup__r.State__c FROM Zip_Code_Area_Assignment__c WHERE ';
		strQuery += 'IsActive__c = true ';

		if(clsSearch.zcSearch.City__c != null) {
			strQuery += ' AND Zip_Code_Lookup__r.City__c LIKE \'%' + clsSearch.zcSearch.City__c + '%\' ';
		}
		if(clsSearch.zcSearch.State__c != null) {
			strQuery += ' AND Zip_Code_Lookup__r.State__c = \'' + clsSearch.zcSearch.State__c + '\' ';	
		}
		if(clsSearch.zaSearch.OwnerId != null) {
			strQuery += ' AND (OwnerId = \'' + clsSearch.zaSearch.OwnerId + '\' OR Account_Owner__c = \'' + clsSearch.zaSearch.OwnerId + '\') ';
		}
		if(clsSearch.zaSearch.Role__c != null) {
			strQuery += ' AND Role__c = \'' + clsSearch.zaSearch.Role__c + '\' ';
		}
		if(clsSearch.zcSearch.County__c != null) {
			strQuery += ' AND Zip_Code_Lookup__r.County__c LIKE \'%' + clsSearch.zcSearch.County__c + '%\' ';
		}
		if(clsSearch.strZipCode != '') {
			strQuery += ' AND Zip_Code_Lookup__r.Name LIKE \'%' + clsSearch.strZipCode + '%\' ';
		}

		strQuery += ' ORDER BY Zip_Code_Lookup__r.Name ASC LIMIT 1000';

		Util.logMessage('getlstAssign', strQuery);

		lstTemp = Database.Query(strQuery);

		return lstTemp;

	}

	public List<ZipCodeLatAndLong__c> getLstUnassigned() {

		//Set<String> setZips = new Set<String>();
		//for(Zip_Code_Area_Assignment__c zip : [SELECT Zip_Code_Lookup__c FROM Zip_Code_Area_Assignment__c WHERE IsActive__c = true ORDER BY Zip_Code_Lookup__r.Name LIMIT 1000]) {
		//	setZips.add(zip.Zip_Code_Lookup__c);
		//}

		//return [SELECT Id, Name FROM ZipCodeLatAndLong__c WHERE Id NOT IN :setZips ORDER BY Name LIMIT 1000];

		List<ZipCodeLatAndLong__c> lstReturn = new List<ZipCodeLatAndLong__c>();
		for(ZipCodeLatAndLong__c zip : [SELECT Id, Name, (SELECT Id FROM Area_Assignments__r) FROM ZipCodeLatAndLong__c LIMIT 1000]) {
			if(zip.Area_Assignments__r.size() == 0) {
				lstReturn.add(zip);
			}
		}

		return lstReturn;

	}

	public List<hClsFrozenRecords> getLstFrozenRecords() {

		List<hClsFrozenRecords> lstTemp = new List<hClsFrozenRecords>();
		for(Account acct : [SELECT Id, Name FROM Account WHERE Freeze_Area_Assigment__c = true]) {
			lstTemp.add(new hClsFrozenRecords(acct.Id, acct.Name, 'Account'));
		}

		for(Lead ld : [SELECT Id, Name FROM Lead WHERE Freeze_Area_Assignment__c = true]) {
			lstTemp.add(new hClsFrozenRecords(ld.Id, ld.Name, 'Lead'));
		}

		//lstTemp.sort();
		return lstTemp;

	}

	///////////////////////////////////
	// Action Methods
	///////////////////////////////////
	public void validateCriteria() {
		bolSearch = true;
		if(clsSearch.zcSearch.City__c == null && clsSearch.zcSearch.State__c == null && clsSearch.zaSearch.OwnerId == null && clsSearch.zcSearch.County__c == null && clsSearch.strZipCode == '' && clsSearch.zaSearch.Role__c == null) {
			bolSearch = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must fill in at least one criteria to search!'));
			return;
		}
	}

	public PageReference newAssignment() {
		Schema.Describesobjectresult result = Schema.Sobjecttype.Zip_Code_Area_Assignment__c;
		PageReference prRef = new PageReference('/' + result.getKeyPrefix() + '/e');
		prRef.setRedirect(true);
		return prRef;
	}

	//This is called from the Account and Lead trigger objects
	public static void salesRepByZipCode() {

		Map<Id, String> mapRecordZipcode = new Map<Id, String>();
		List<Account> lstAccountUpdate = new List<Account>();
		List<Lead> lstLeadUpdate = new List<Lead>();

		//Get in-scope Account and Lead Record Types
		Set<Id> setScopeRTs = new Set<Id>();
        for(Zip_Code_Assignment__c ZCA : Zip_Code_Assignment__c.getall().values()) {
            if(ZCA.IsActive__c) {
            	setScopeRTs.add(ZCA.Name);
            }
        }

		//Apply logic to Account and Lead triggered records for scope
		String strPrefix = string.valueOf(trigger.new[0].Id).subString(0,3);
		if(strPrefix == '001') {
			for(Account acct : (List<Account>)trigger.new) {
				if(acct.BillingPostalCode != null && !acct.Freeze_Area_Assigment__c && (setScopeRTs.contains(acct.RecordtypeId) || Test.isRunningTest())) {
					mapRecordZipcode.put(acct.Id, acct.BillingPostalCode.substring(0,5));
				}
			}
		}

		if(strPrefix == '00Q') {
			for(Lead ld : (List<Lead>)trigger.new) {
				if(ld.PostalCode != null && !ld.IsConverted && !ld.Freeze_Area_Assignment__c && (setScopeRTs.contains(ld.RecordTypeId) || Test.isRunningTest())) {
					mapRecordZipcode.put(ld.Id, ld.PostalCode.substring(0,5));
				}
			}
		}

		//Define Role Precedence
		Map<String, Integer> mapRolePrecedence = new Map<String, Integer>();
		mapRolePrecedence.put('NAM', 1);
		mapRolePrecedence.put('ISM', 2);
		mapRolePrecedence.put('TSM', 3);
		mapRolePrecedence.put('ROM', 4);
		mapRolePrecedence.put('RD', 5);

		//Get Assignment records in scope
		List<Zip_Code_Area_Assignment__c> lstZCAs = [SELECT Id, Role__c, Zip_Code_Lookup__r.Name, OwnerId, Account_Owner__c
												FROM Zip_Code_Area_Assignment__c 
												WHERE Zip_Code_Lookup__r.Name IN :mapRecordZipcode.values() 
													AND IsActive__c = true 
													AND IsIncluded__c = true
													AND Assignment_Effective_Date__c <= :System.Today()];

		//Create Mapped assignment map by precedence
		Map<String, hClsZipAssignee> mapZipAssignees = new Map<String, hClsZipAssignee>();
		for(Zip_Code_Area_Assignment__c zca : lstZCAs) {

			if(mapZipAssignees.containsKey(zca.Zip_Code_Lookup__r.Name)) {
				
				Integer intExistingPrecedence = mapRolePrecedence.get(mapZipAssignees.get(zca.Zip_Code_Lookup__r.Name).strRole);
				Integer intNewPrecedence = mapRolePrecedence.get(zca.Role__c);

				if(intNewPrecedence < intExistingPrecedence) {
					mapZipAssignees.put(zca.Zip_Code_Lookup__r.Name, new hClsZipAssignee(zca.OwnerId, zca.Account_Owner__c, zca.Role__c));
				}

			} else {
				mapZipAssignees.put(zca.Zip_Code_Lookup__r.Name, new hClsZipAssignee(zca.OwnerId, zca.Account_Owner__c, zca.Role__c));
			}

		}

		//Push Account and Lead ownership back to update list
		for(Id recordId : mapRecordZipcode.keyset()) {
			Id idAccount = recordId;
			String strZip = mapRecordZipcode.get(idAccount);
			if(strPrefix == '001') {
				if(mapZipAssignees.containsKey(strZip)) {
					lstAccountUpdate.add(new Account(Id=recordId,OwnerId=mapZipAssignees.get(strZip).idAccountOwner));
					//trigger.newMap.get(recordId).put('OwnerId', mapZipAssignees.get(strZip).idAccountOwner);
				}
			}

			if(strPrefix == '00Q') {
				if(mapZipAssignees.containsKey(strZip)) {
					lstLeadUpdate.add(new Lead(Id=recordId,OwnerId=mapZipAssignees.get(strZip).idLeadOwner));
					//trigger.newMap.get(recordId).put('OwnerId', mapZipAssignees.get(strZip).idLeadOwner);
				}
			}
			
		}

		//Update Lists
		if(lstAccountUpdate.size() > 0) { update lstAccountUpdate; }
		if(lstLeadUpdate.size() > 0) { update lstLeadUpdate; }
	}

	///////////////////////////////////
	// Helper Classes
	///////////////////////////////////
	public class hClsZipAssignee {
		public Id idAccountOwner {get;set;}
		public Id idLeadOwner {get;set;}
		public String strRole {get;set;}
		public hClsZipAssignee(Id passLeadOwner, Id passAccountOwner, String passStrRole) {
			idAccountOwner = passAccountOwner;
			idLeadOwner = passLeadOwner;
			strRole = passStrRole;
		}
	}

	public class hClsSearch {
		public ZipCodeLatAndLong__c zcSearch {get;set;}
		public Zip_Code_Area_Assignment__c zaSearch {get;set;}
		public String strZipCode {get;set;}
		public hClsSearch() {
			zcSearch = new ZipCodeLatAndLong__c();
			zaSearch = new Zip_Code_Area_Assignment__c();
			strZipCode = '';
		}
	}

	public class hClsFrozenRecords {
		public String strName {get;set;}
		public Id idRecord {get;set;}
		public String strType {get;set;}
		public hClsFrozenRecords(Id passRecordId, String passName, String passType) {
			idRecord = passRecordId;
			strName = passName;
			strType = passType;
		}
	}
	*/
}