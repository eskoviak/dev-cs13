@IsTest
public class Test_NewAccountDocumentExtension {

    public static testMethod void testAccountDocumentExtension() {

          //Create Account
          Account newAccount = new Account (name='Unit Test Account');
          insert newAccount;

          //Create Contact
          Contact newContact = new Contact (FirstName='Unit',LastName='Tester',AccountId=newAccount.id,email='test@test.com');
          insert newContact;

          //Get Record Type
          RecordType rt = [select id,Name from RecordType where SobjectType='Document_Version__c' and
                          DeveloperName='National_Accounts_Participation_Agreement' Limit 1];

          //Create Document Version
          Document_Version__c newDocVer = new Document_Version__c (Version_Date__c = system.Today(), recordTypeId=rt.id,Current_Active_Version__c=true);
          insert newDocVer;

          //Create Account Document
          Account_Document__c newAcctDoc = new Account_Document__c (Account__c=newAccount.id,Account_Contact__c=newContact.id,Document_Version__c=newDocVer.id);
          insert newAcctDoc;

          //Re-query the data
          Account_Document__c checkAccountDocument = new Account_Document__c();
          checkAccountDocument = [SELECT Id,Name FROM Account_Document__c WHERE Id= :newAcctDoc.id];

      	  //Create standard controller
          ApexPages.standardController sc = new ApexPages.standardController(checkAccountDocument);

          //Create an instance of the controller
          NewAccountDocumentExtension accDocExt = new NewAccountDocumentExtension(sc);

    }
}