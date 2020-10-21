@IsTest 
public class Test_accountDocumentExtension {

    public static testMethod void testAccountDocumentExtension() {
    
       PageReference pageRef = Page.AccountDocument; 
       Test.setCurrentPageReference(pageRef);
       
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;
       
        //Create Contact
        Contact newContact = new Contact (FirstName='Unit',LastName='Tester',AccountId=newAccount.id);
        insert newContact;
            
        //Create Document Version
        Date myDate = Date.newInstance(2007, 04, 08);
        Document_Version__c newDocVer = new Document_Version__c (Document_Text__c='Unit Test Document Version',Current_Active_Version__c=true,Version_Date__c=myDate);
        insert newDocVer;
        
        //Create Account Document
        Account_Document__c newAcctDoc = new Account_Document__c (Account__c=newAccount.id,Account_Contact__c=newContact.id,Document_Version__c=newDocVer.id);
        insert newAcctDoc;
        
        //Create standard controller
        ApexPages.standardController sc = new ApexPages.standardController(newAcctDoc);
        
        //Create an instance of the controller
        accountDocumentExtension acctDocExt = new accountDocumentExtension(sc);
        
        //Testing scenario
        String redirectPage = acctDocExt.save().getURL();      
        System.assertEquals(redirectPage,'http://www.redwingshoes.com');
    }

}