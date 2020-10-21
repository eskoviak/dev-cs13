@isTest
public class RWS_ProgramSetUpController_Test {
    

    @isTest
    public static void ActivateProgram_NoAccount_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();



            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[2].Id);

            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.ActivateProgram();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            //System.assert(controller.ProgramActivationStatus == '');
 
        } 
    }
    
    

    @isTest
    public static void ActivateProgram_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[0].Id);

            Test.startTest();
            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.ActivateProgram();
            Test.stopTest();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            System.assert(controller.ProgramActivationStatus == '');

 
        } 
    }
    
    @isTest
    public static void Constructor_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //test that when we do not set the program id, there is no object returned from SOQL
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            System.assert(controller != null);
            System.assert(controller.editProgram == null);

 
        } 
    }

    @isTest
    public static void Constructor_EditIds_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            Test.setCurrentPage(Page.RWS_NewProgramSetup);
            
            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[0].Id);

            //test that when we do not set the program id, there is no object returned from SOQL
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            System.assert(controller != null); 
            System.assert(controller.AccObj != null && controller.AccObj.Id == Industrial[0].Store_Account__c);
            System.assert(controller.editProgram != null);

 
        } 
    }

    @isTest
    public static void SaveProgramDetails_EditModeFalse_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[0].Id);

            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.EditMode = false;
            Test.startTest();
                controller.SaveProgramDetails();
            Test.stopTest();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            System.assert(controller.ProgramActivationStatus == null);

 
        } 


    }

    @isTest
    public static void SaveProgramDetails_EditModeTrue_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[0].Id);

            Test.startTest();
            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.EditMode = true;
            controller.SaveProgramDetails();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            System.assert(controller.ProgramActivationStatus == null);
            Test.stopTest();

 
        } 
    }

    @isTest
    public static void DeactivateProgram_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', dataFactory.AccountPrograms[0].Id);

            Test.startTest();
            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.DeactivateProgram();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            System.assert(controller.ProgramActivationStatus != null);
            Test.stopTest();

 
        } 
    }

    @isTest
    public static void DeactivateProgram_NoProgramId_Test(){
        RWS_TestDataFactory dataFactory = new RWS_TestDataFactory();

        System.runAs(dataFactory.TestRunner){
            //not sure if this is needs to be done per unit test method? I think so
            List<Store_IA_Account__c> Industrial = dataFactory.createIndustrialAccounts();

            //set account and program ids
            ApexPages.CurrentPage().getparameters().put('id', Industrial[0].Store_Account__c);
            ApexPages.CurrentPage().getparameters().put('proid', null);

            //set to edit mode and call save program details
            RWS_ProgramSetUpController controller = new RWS_ProgramSetUpController();
            controller.DeactivateProgram();

            System.assert(ApexPages.getMessages() == null || ApexPages.getMessages().size() == 0);
            System.assert(controller.ProgramActivationStatus != null);

 
        } 
    }
}