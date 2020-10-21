/**
*   Test class for TriggerController_Account.
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20160902    James Loghry DCS        Created
*   =============================================================================
*/@isTest
private class Test_TriggerControllerZipcodeLatAndLong{
	static testmethod void testCreate(){
		Test.startTest();
		ZipCodeLatAndLong__c z = new ZipCodeLatAndLong__c(
			Name = '12345'
			,Zipcode__c = '12345'
			,Latitude__c = '11.123'
			,Longitude__c = '11.124'
			,City__c = 'City'
			,State__c = 'MN'
		);
		insert z;
		Test.stopTest();

		z = [Select Location__Latitude__s,Location__Longitude__s From ZipCodeLatAndLong__c Where Id = :z.Id];
		System.assertEquals(11.123,z.Location__Latitude__s);
		System.assertEquals(11.124,z.Location__Longitude__s);
	}

	static testmethod void testUpdate(){
		Test.startTest();
		ZipCodeLatAndLong__c z = new ZipCodeLatAndLong__c(
			Name = '12345'
			,Zipcode__c = '12345'
			//,Latitude__c = '123.123'
			//,Longitude__c = '124.124'
			,City__c = 'City'
			,State__c = 'MN'
		);
		insert z;

		z.Latitude__c = '11.123';
		z.Longitude__c = '11.124';
		update z;
		Test.stopTest();

		z = [Select Location__Latitude__s,Location__Longitude__s From ZipCodeLatAndLong__c Where Id = :z.Id];
		System.assertEquals(11.123,z.Location__Latitude__s);
		System.assertEquals(11.124,z.Location__Longitude__s);
	}
}