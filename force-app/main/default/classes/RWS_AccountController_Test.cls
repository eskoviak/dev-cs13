@isTest
private class RWS_AccountController_Test {
    @isTest
    public static void InsertAccount_WithData_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

            
            RWS_AccountController controller = new RWS_AccountController();
            System.assert(controller != null);
            //try to save an account without setting member variables in the controller
            controller.accountName = 'My Test Account';
            controller.accountLine1 = '123 East First St';
            controller.accountCity = 'Sartell';
            controller.accountstate = 'MN';
            controller.accountZIPCODE = '56377';
            controller.accountCountry = 'US';
            controller.accountPhone = '3201111111';
            controller.SelectTaxExempt = 'NO';
            controller.SelectTaxName = dataFactory.TaxExemptionReasons[0].Name;
            controller.TaxCertificateNumber = 'ABC123';
            controller.TaxExpiryDate = date.newInstance(2017,12,31);
            Test.startTest();
            controller.insertAccount();
            Test.stopTest();
            //System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0, ApexPages.getMessages());
        }
    } 

    @isTest
    public static void InsertAccount_NoData_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

            RWS_AccountController controller = new RWS_AccountController();
            System.assert(controller != null);
            //try to save an account without setting member variables in the controller
            controller.accountName = null;
            controller.accountCountry = null;
            controller.SelectTaxExempt = 'Yes';
            controller.TaxCertificateNumber = null; 
            Test.startTest();
            controller.insertAccount();
            System.assert(ApexPages.getMessages() != null && ApexPages.getMessages().size() > 0);
 			Test.stopTest();
        } 
    }

    @isTest
    public static void InsertAccount_NoData_NoAccountId_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            RWS_AccountController controller = new RWS_AccountController();
            System.assert(controller != null);
            //try to save an account without setting member variables in the controller
            controller.accountName = null;
            controller.accountLine1 = null;
            controller.accountCity = null;
            controller.accountstate = null;
            controller.accountZipCode = null;
            controller.accountCountry = null;
            controller.accountPhone = null;
            controller.SelectTaxExempt = null;
            controller.SelectTaxName = dataFactory.TaxExemptionReasons[0].Name;
            controller.TaxCertificateNumber = null;
            controller.TaxExpiryDate = date.newInstance(2017,12,31);
            Test.startTest();
            controller.insertAccount();
            System.assert(ApexPages.getMessages() != null && ApexPages.getMessages().size() > 0);
            Test.stopTest();
        }
    } 


    @isTest
    public static void IsValidUser_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){
            RWS_AccountController controller = new RWS_AccountController();

            System.assert(controller.isValidUser(Userinfo.getProfileId()) == true);

        }
    }  

    @isTest
    public static void CreateAccountContact_EditModeFalse_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){
            
            RWS_AccountController controller = new RWS_AccountController();
            //here we create a couple accounts, one account has full address info
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set up account information same as what is in data factory
            controller.accountName = 'Store One';
            controller.accountLine1 = '123 East First Street';
            controller.accountCity = 'Sartell';
            controller.accountstate = 'MN';
            controller.accountZIPCODE = '56377';
            controller.accountCountry = 'US';
            controller.accountPhone = '3201111111';
            controller.EditMode = false;

            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
			Test.startTest();
            pagereference reference = controller.createAccountContact();
            //in this case controller action should return null
            System.assert(reference == null);
            Test.stopTest();
        }
    } 

    @isTest
    public static void CreateAccountContact_EditModeTrue_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){
            
            RWS_AccountController controller = new RWS_AccountController();
            //here we create a couple accounts, one account has full address info
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set up account information same as what is in data factory
            controller.accountName = 'Store One';
            controller.accountLine1 = '123 East First Street';
            controller.accountCity = 'Sartell';
            controller.accountstate = 'MN';
            controller.accountZIPCODE = '56377';
            controller.accountCountry = 'US';
            controller.accountPhone = '3201111111';
            controller.EditMode = true;

            Test.startTest();
            pagereference reference = controller.createAccountContact();
            Test.stopTest();
            //in this case controller action should return null
            System.assert(reference == null);

        }
    }   
     @isTest
    public static void AssignTaxExempt_ExemptYes_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){

            //here we create a couple accounts, one account has full address info
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
			RWS_AccountController controller = new RWS_AccountController();
            controller.selecttaxName = dataFactory.TaxExemptionReasons[0].Id;
			
            Test.startTest();
            controller.AssignTaxExempt();
            //in this case controller action should return null
            System.assert(controller.AccountStatusMessage == null);
            Test.stopTest();

        }   
    }
    @isTest
    public static void AssignTaxExempt_ExemptNo_Test(){

        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){

            //here we create a couple accounts, one account has full address info
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

            RWS_AccountController controller = new RWS_AccountController();
            controller.selecttaxName = dataFactory.TaxExemptionReasons[1].Id;
			
            Test.startTest();
            controller.AssignTaxExempt();
            //in this case controller action should return null
            System.assert(controller.AccountStatusMessage == null);
            Test.stopTest();

        }   
    } 

    @isTest
    public static void UploadAttachment_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();
        System.runAs(dataFactory.TestRunner){

            //here we create a couple accounts, one account has full address info
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();
            //set the id of the page
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);

            //after the constructor is ran, there should be a list of contacts
            Integer firstCount = [SELECT count()  FROM Attachment 
                                  WHERE parentid = :Industrial[0].Store_Account__c];

            Test.startTest();
            RWS_AccountController.doUploadAttachment(Industrial[0].Store_Account__c, 'This is a test body', 'FakeName', 'FakeAttachmentId', 'FakePageName');

            Integer secondCount = [SELECT count()  FROM Attachment 
                                  WHERE parentid = :Industrial[0].Store_Account__c];

            //in this case controller action should return null
            System.assert(firstCount < secondCount);
            Test.stopTest();

        }
    } 
}