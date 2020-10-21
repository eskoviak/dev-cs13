/**
* {Purpose} – The purpose of this class is to test and validate that the GeocodeBatch.cls
*               logic is functioning properly and has the appropriate code coverage 
* <p>
* {Function} – (optional) A brief paragraph describing any functional details
* <p>
* {Comments} – (optional) Any additional comments that may be useful.
*
* @author   
* @version  2013-07-14
*/

/**
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 2013-07-14    Mike Eaton      Updated to support the new M3 Location fields  
* 2013-07-15    Mike Eaton      Added annotation (SeeAllData=true) to allow access
                                    to NotificationSetting__c custom setting data    
* 2013-07-29    Mike Eaton      Added addition code coverage support
* 2013-08-01    Mike Eaton      Updated code to work with new workflow rules that
*                                   inadvertently broke the Geocode_Status setting                                  
* {Date}        {Changed By}    ({Ticket}) – {Change Description}
* =============================================================================
*/

@isTest(SeeAllData=true)
private class GeocodeBatchTest {
    
    static testMethod void commentTest(){
        GeocodeBatch myController = new GeocodeBatch();
    }
/*
    static testMethod void test_BatchWithSampleData() {
*/        
        /*
        List<Account> lAccounts = new List<Account>();
        
        for(integer i = 0; i<10; i++){
            Account oAccount = new Account(Name = 'Test Account' + i, 
                Geocode_Status__c = 'Pending', 
                M3_Location_Street__c = '1600 Amphitheatre Parkway', 
                M3_Location_City__c = 'Mountain View', 
                M3_Location_State_Province__c = 'CA',
                M3_Location_Zip_Postal_Code__c = '12345');
            
            lAccounts.add(oAccount);
        }
        
        //  add additional variation of missing address components
        Account oAcctMSZ = new Account();
        oAcctMSZ.Name = 'Test Account - Missing Street/Zip';
        oAcctMSZ.Geocode_Status__c = 'Pending';
        oAcctMSZ.M3_Location_Street__c = NULL;
        oAcctMSZ.M3_Location_City__c = 'San Francisco';
        oAcctMSZ.M3_Location_State_Province__c = 'CA';
        oAcctMSZ.M3_Location_ZIP_Postal_Code__c = NULL;
        lAccounts.add(oAcctMSZ);
        
        Account oAcctMCS = new Account();
        oAcctMCS.Name = 'Test Account - Missing City/State';
        oAcctMCS.Geocode_Status__c = 'Pending';
        oAcctMCS.M3_Location_Street__c = 'The Landmark @ One Market';
        oAcctMCS.M3_Location_City__c = NULL;
        oAcctMCS.M3_Location_State_Province__c = NULL;
        oAcctMCS.M3_Location_ZIP_Postal_Code__c = '94105';
        lAccounts.add(oAcctMCS);
        
        
        insert lAccounts;
        */
/*        
        createTestData();
        
        Test.startTest();
        
        GeocodeBatch oBulkGeocode = new GeocodeBatch();
        oBulkGeocode.Query = 'SELECT id, M3_Location_Street__c, M3_Location_City__c, M3_Location_State_Province__c, M3_Location_ZIP_Postal_Code__c ' +
                                'FROM Account WHERE Name LIKE \'Test Account %\' LIMIT 25';
        
        Database.executeBatch(oBulkGeocode, 25);

        Test.stopTest();
    }*/
/*   
    static testMethod void test_BatchWithoutData(){
        
        Test.startTest();
        
        GeocodeBatch oBulkGeocode = new GeocodeBatch();
        
        Database.executeBatch(oBulkGeocode, 25);

        Test.stopTest();
    }
*/
 /*   
    // This method creates the sample test data needed to execute the other functionality tests
    static testMethod void createTestData(){
        
        List<Account> lAccounts = new List<Account>();
        
        for(integer i = 0; i<10; i++){
            Account oAccount = new Account(Name = 'Test Account' + i, 
                Geocode_Status__c = 'Pending', 
                M3_Location_Street__c = '1600 Amphitheatre Parkway', 
                M3_Location_City__c = 'Mountain View', 
                M3_Location_State_Province__c = 'CA');
            
            lAccounts.add(oAccount);
        }
        
        //  add additional variation of missing address components
        Account oAcctMSZ = new Account();
        oAcctMSZ.Name = 'Test Account - Missing Street/Zip';
        oAcctMSZ.Geocode_Status__c = 'Pending';
        oAcctMSZ.M3_Location_Street__c = NULL;
        oAcctMSZ.M3_Location_City__c = 'San Francisco';
        oAcctMSZ.M3_Location_State_Province__c = 'CA';
        oAcctMSZ.M3_Location_ZIP_Postal_Code__c = NULL;
        lAccounts.add(oAcctMSZ);
        
        Account oAcctMCS = new Account();
        oAcctMCS.Name = 'Test Account - Missing City/State';
        oAcctMCS.Geocode_Status__c = 'Pending';
        oAcctMCS.M3_Location_Street__c = 'The Landmark @ One Market';
        oAcctMCS.M3_Location_City__c = NULL;
        oAcctMCS.M3_Location_State_Province__c = NULL;
        oAcctMCS.M3_Location_ZIP_Postal_Code__c = '94105';
        lAccounts.add(oAcctMCS);
        
        Account oAcctMCSZ = new Account();
        oAcctMCSZ.Name = 'Test Account - Missing City/State/Zip';
        oAcctMCSZ.Geocode_Status__c = 'Pending';
        oAcctMCSZ.M3_Location_Street__c = NULL;
        oAcctMCSZ.M3_Location_City__c = NULL;
        oAcctMCSZ.M3_Location_State_Province__c = NULL;
        oAcctMCSZ.M3_Location_ZIP_Postal_Code__c = NULL;
        lAccounts.add(oAcctMCSZ);
        
        
        insert lAccounts;
    }*/
}