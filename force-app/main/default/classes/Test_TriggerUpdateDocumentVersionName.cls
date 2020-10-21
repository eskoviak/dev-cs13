@IsTest
public class Test_TriggerUpdateDocumentVersionName {

      // Test creation of Document Version name
      static testMethod void createDocumentVersionName() {

          //Get Record Type
          RecordType rt = [select id,Name from RecordType where SobjectType='Document_Version__c' and
                          DeveloperName='National_Accounts_Participation_Agreement' Limit 1];

          //Create Document Version
          Document_Version__c docVersion = new Document_Version__c (Version_Date__c = system.Today(), recordTypeId=rt.id);
          insert docVersion;

          //Re-query the data
          Document_Version__c checkDocVersion = new Document_Version__c();
          checkDocVersion = [SELECT Id,Version_Date__c,Name FROM Document_Version__c WHERE Id= :docVersion.id];

        }
}