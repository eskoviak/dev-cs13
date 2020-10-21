@isTest
private class ZipAssignManagerController_UT {
	
	/*@isTest static void testManager() {
		User uTest = createTestData();

		test.startTest();

		ZipAssignManagerController clsZip = new ZipAssignManagerController();

		// False Search
		clsZip.validateCriteria();
		clsZip.getlstAssign();

		// True Search
		clsZip.clsSearch.zcSearch.City__c = 'City';
		clsZip.clsSearch.zcSearch.State__c = 'State';
		clsZip.clsSearch.zaSearch.OwnerId = uTest.Id;
		clsZip.clsSearch.zaSearch.Role__c = 'TSM';
		clsZip.clsSearch.zcSearch.County__c = 'County';
		clsZip.clsSearch.strZipCode = '12345';
		clsZip.validateCriteria();
		clsZip.getlstAssign();

		clsZip.getLstUnassigned();

		insert new Account(Name='test account', Freeze_Area_Assigment__c=true);
		insert new Lead(Lastname='test', email='me@you.com',PostalCode='12345',Freeze_Area_Assignment__c=true);
		clsZip.getLstFrozenRecords();

		// Page Buttons
		clsZip.newAssignment();

		test.stopTest();
	}
	
	@isTest static void testTriggerAction_Account() {
		User uTest = createTestData();
		test.startTest();
		Account acct = new Account(Name='Test Account', BillingPostalCode='12345');insert acct;
		Account acctCheck = [SELECT Id, OwnerId FROM Account WHERE Id = :acct.Id];
		//System.Assert(acctCheck.OwnerId == uTest.Id, 'Ownership did not change!');
		test.stopTest();
	}

	@isTest static void testTriggerAction_Lead() {
		User uTest = createTestData();
		test.startTest();
		Lead ld = new Lead(Lastname='Test Lead', Email='test@rws.com',PostalCode='12345');insert ld;
		Lead ldCheck = [SELECT Id, OwnerId FROM Lead WHERE Id = :ld.Id];
		//System.Assert(ldCheck.OwnerId == uTest.Id, 'Ownership did not change!');
		test.stopTest();
	}
	
	private static User createTestData() {

		List<Zip_Code_Assignment__c> lstCSAccountZips = new List<Zip_Code_Assignment__c>();
		List<Zip_Code_Assignment__c> lstCSLeadZips = new List<Zip_Code_Assignment__c>();
		for(RecordType rt : [SELECT Id, SObjectType FROM RecordType WHERE SObjectType IN ('Account', 'Lead')]) {
			if(rt.SObjectType == 'Account') {
				lstCSAccountZips.add(new Zip_Code_Assignment__c(Name=rt.Id, IsActive__c=true));
			}
			if(rt.SObjectType == 'Lead') {
				lstCSLeadZips.add(new Zip_Code_Assignment__c(Name=rt.Id, IsActive__c=true));
			}
		}
		insert lstCSAccountZips; insert lstCSLeadZips;

		APEX_Trigger_Settings__c csAPEXAccount = new APEX_Trigger_Settings__c(Name='ownerAssignmentAccount',IsActive__c=true);
		APEX_Trigger_Settings__c csAPEXLead = new APEX_Trigger_Settings__c(Name='ownerAssignmentLead',IsActive__c=true);
		insert csAPEXAccount;
		insert csAPEXLead;

		Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'RWSTEST1', email='standarduser@rwstestorg.com',
        	emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        	localesidkey='en_US', profileid = p.Id,
        	timezonesidkey='America/Los_Angeles', username='standarduserTEST@testorgRWS.com');
        insert u;

       	List<ZipCodeLatAndLong__c> lstZips = new List<ZipCodeLatAndLong__c>();
       	lstZips.add(new ZipCodeLatAndLong__c(Name='12345'));
       	lstZips.add(new ZipCodeLatAndLong__c(Name='12346'));
       	lstZips.add(new ZipCodeLatAndLong__c(Name='12347'));
       	lstZips.add(new ZipCodeLatAndLong__c(Name='12348'));
       	insert lstZips;

       	List<String> lstRoles = new List<String>();
       	lstRoles.add('TSM');
       	lstRoles.add('ISM');
       	lstRoles.add('NAM');
       	lstRoles.add('ROM');

       	List<Zip_Code_Area_Assignment__c> lstZipAssign = new List<Zip_Code_Area_Assignment__c>();
       	Integer i = 0;
       	for(ZipCodeLatAndLong__c zip : lstZips) {
       		Zip_Code_Area_Assignment__c zca = new Zip_Code_Area_Assignment__c();
       		zca.Zip_Code_Lookup__c = zip.Id;
       		zca.Role__c = lstRoles[i];
       		zca.IsIncluded__c = true;
       		zca.IsActive__c = true;
       		zca.Assignment_Effective_Date__c = System.Today().addDays(-7);
       		zca.OwnerId = u.Id;
       		zca.Account_Owner__c = u.Id;
       		lstZipAssign.add(zca);
       		i += 1;
       	}

       	i = i-1;
       	for(ZipCodeLatAndLong__c zip : lstZips) {
       		Zip_Code_Area_Assignment__c zca = new Zip_Code_Area_Assignment__c();
       		zca.Zip_Code_Lookup__c = zip.Id;
       		zca.Role__c = lstRoles[i];
       		zca.IsIncluded__c = true;
       		zca.IsActive__c = true;
       		zca.Assignment_Effective_Date__c = System.Today().addDays(-7);
       		zca.OwnerId = u.Id;
       		zca.Account_Owner__c = u.Id;
       		lstZipAssign.add(zca);
       		i = i-1;
       	}

       	insert lstZipAssign;

       	return u;

	}*/
}