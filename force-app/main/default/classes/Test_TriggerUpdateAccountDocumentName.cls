@IsTest
public class Test_TriggerUpdateAccountDocumentName {

    // Test creation of Account Document name
    static testMethod void createAccountDocumentName() {

        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;

        //Create Contact
        Contact newContact = new Contact (FirstName='Unit',LastName='Tester',AccountId=newAccount.id,email='test@test.com');
        insert newContact;

        //Get Record Type
        RecordType docRt =
            [Select
                Id
                ,Name
             From
                RecordType
             where
                SobjectType='Document_Version__c' and
                DeveloperName='National_Accounts_Participation_Agreement'
             Limit 1];

        RecordType acctDocRt =
            [Select
                Name
             From
                RecordType
             Where
                SobjectType='Account_Document__c'
                And Name != null
             Limit 1];

        //Create Document Version
        Document_Version__c newDocVer = new Document_Version__c (
            Version_Date__c = system.Today()
            ,RecordTypeId=docRt.Id
            ,Current_Active_Version__c=true
        );
        insert newDocVer;

        Test.startTest();
        //Create Account Document
        Account_Document__c newAcctDoc = new Account_Document__c (
            Account__c=newAccount.Id
            ,Account_Contact__c=newContact.Id
            ,Document_Version__c=newDocVer.Id
            ,Record_Type__c = acctDocRt.Name
        );
        insert newAcctDoc;
        Test.stopTest();

        newDocVer = [Select Name From Document_Version__c Where Id = :newDocVer.Id];
        newAcctDoc = [Select Id,Account_Name__c,Name,RecordTypeId From Account_Document__c Where Id = :newAcctDoc.Id];
        System.assertEquals(newAcctDoc.Account_Name__c + ' - ' + newDocVer.Name,newAcctDoc.Name);
        System.assertEquals(acctDocRt.Id,newAcctDoc.RecordTypeId);
      }
  }