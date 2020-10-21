@isTest
private class Test_TriggerControllerAccount {
/*
  static testmethod void testAutoGeocodingWithInsert() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };
    insert settings;


    Test.startTest();
    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US');
    insert a;
    Test.stopTest();

    //Data.com isn't working with unit tests. Instead, the contact test below will mock the lat and long geocoding up to the account.
    //Account result = [Select Longitude__c,Latitude__c From Account];
    //System.assertNotEquals(null,result.Longitude__c);
    //System.assertNotEquals(null,result.Latitude__c);
  }

  static testmethod void testAutoGeocodingWithUpdate() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };
    insert settings;

    Account a = new Account(
      Name='Test'
    );
    insert a;

    Test.startTest();
    a.M3_Location_City__c = 'Red Wing';
    a.M3_Location_Street__c = '314 MAIN ST';
    a.M3_Location_State_Province__c = 'MN';
    a.M3_Location_Zip_Postal_Code__c = '55066';
    a.M3_Location_Country__c = 'US';
    update a;
    Test.stopTest();

    //Data.com isn't working with unit tests. Instead, the contact test below will mock the lat and long geocoding up to the account.
    //Account result = [Select Longitude__c,Latitude__c From Account];
    //System.assertNotEquals(null,result.Longitude__c);
    //System.assertNotEquals(null,result.Latitude__c);
  }

  static testmethod void testAutoGeocodingContactWithUpdate() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };
    insert settings;

    RecordType rt = [Select Id From RecordType Where DeveloperName = 'M3_Contact'];

    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US'
    );
    insert a;

    Contact c = new Contact(
      AccountId = a.Id
            ,M3_Account_Ext_Id__c = a.Id
            ,Firstname='M3'
            ,Lastname='Address'
            ,MailingStreet = a.M3_Location_Street__c
            ,MailingCity = a.M3_Location_City__c
            ,MailingState = a.M3_Location_State_Province__c
            ,MailingCountry = a.M3_Location_Country__c
            ,MailingPostalCode = a.M3_Location_ZIP_Postal_Code__c
            ,RecordTypeId = rt.Id
        );
        insert c;

    Test.startTest();
    c.MailingLatitude = 44.566353;
        c.MailingLongitude = -92.534672;
        update c;
    Test.stopTest();

    Account result = [Select Data_com_Longitude__c,Data_com_Latitude__c From Account];
    System.assertEquals(-92.534672,result.Data_com_Longitude__c);
    System.assertEquals(44.566353,result.Data_com_Latitude__c);
  }

  static testmethod void testAutoGeocodingContactInsert() {
    List<APEX_Trigger_Settings__c> settings = new List<Apex_Trigger_Settings__c>{
      new Apex_Trigger_Settings__c(Name='geoLocationAccount',IsActive__c=true)
      ,new Apex_Trigger_Settings__c(Name='geoLocationContact',IsActive__c=true)
    };
    insert settings;

    RecordType rt = [Select Id From RecordType Where DeveloperName = 'M3_Contact'];

    Account a = new Account(
      Name='Test'
      ,M3_Location_City__c = 'Red Wing'
      ,M3_Location_Street__c = '314 MAIN ST'
      ,M3_Location_State_Province__c = 'MN'
      ,M3_Location_Zip_Postal_Code__c = '55066'
      ,M3_Location_Country__c = 'US'
    );
    insert a;

    Test.startTest();
    Contact c = new Contact(
      AccountId = a.Id
            ,M3_Account_Ext_Id__c = a.Id
            ,Firstname='M3'
            ,Lastname='Address'
            ,MailingStreet = a.M3_Location_Street__c
            ,MailingCity = a.M3_Location_City__c
            ,MailingState = a.M3_Location_State_Province__c
            ,MailingCountry = a.M3_Location_Country__c
            ,MailingPostalCode = a.M3_Location_ZIP_Postal_Code__c
            ,RecordTypeId = rt.Id
            ,MailingLatitude = 44.566353
          ,MailingLongitude = -92.534672
        );
        insert c;
    Test.stopTest();

    Account result = [Select Data_com_Longitude__c,Data_com_Latitude__c From Account];
    System.assertEquals(-92.534672,result.Data_com_Longitude__c);
    System.assertEquals(44.566353,result.Data_com_Latitude__c);
    System.assertEquals(0,[Select Id From Contact].size());
  }

*/}