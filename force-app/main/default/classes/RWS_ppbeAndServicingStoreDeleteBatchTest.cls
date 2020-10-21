/************************************************************************
* Test class for the following Apex classes:
*
* RWS_ServicingStoreDeleteBatch
* RWS_PPBEDeleteBatch
* RWS_BatchDeleteSchedulable
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
@isTest 
public class RWS_ppbeAndServicingStoreDeleteBatchTest {
    
    //Test Data Creation
    @testSetup 
    static void setup() {  
        //Get record type for Account
        Id accRecTypeId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');
        //Create and insert Account for Program creation
        Account acc = RWS_TestUtil.createAccount(accRecTypeId, true);
        //Create and insert Program for Publish Pricebook and Servicing Store creation
        Program__c prog = RWS_TestUtil.createProgram(acc.Id, true);
        //Create and insert Publish Pricebook for Publish Pricebook Entry creation
        Publish_PriceBook__c ppb = RWS_TestUtil.createCustomPublishPricebook(prog.Id, true);
        
        //Create 50 Servicing Stores for testing
        List<Servicing_Store__c> ssList = new List<Servicing_Store__c>();        
        for(Integer i=0 ;i <50;i++){
            Servicing_Store__c ss = RWS_TestUtil.createServicingStore(acc.Id, prog.Id, false);
            ss.Active__c = false;
            ss.Expiration_Date__c = Date.today()-8;
            ss.Published_Date__c = Date.today()-8;
            ss.Program_Service_Level__c = 'Dealer';       
            ssList.add(ss);
        }
        
        //Set the first 10 to Active__c = true 
        for(Integer i=0 ;i <10;i++){
            ssList[i].Active__c = true;
        }
        
        //Insert Servicing Store records
        insert ssList; 
        
        //Create 50 Product records for PPBE creation        
        List<Product2> prodList = new List<Product2>();        
        for(Integer i=0 ;i <50;i++){
            prodList.add(RWS_TestUtil.createProduct('prod'+i, false));
        }
        //Insert products
        insert prodList;
        
        //Create 50 Publish Pricebook Entry records for testing
        List<Publish_PriceBook_Entry__c> ppbeList = new List<Publish_PriceBook_Entry__c>();        
        for(Integer i=0 ;i <50;i++){            
            Publish_PriceBook_Entry__c ppbe = RWS_TestUtil.createPublishPricebookEntry(ppb.Id, prodList[i].Id, false);
            ppbe.Filter_Number__c = null;
            ppbe.Active__c = false;
            ppbe.Published_Date__c = Date.today()-8;                          
            ppbeList.add(ppbe);
        }
        
        //Set the first 10 with Filter_Number__c values
        for(Integer i=0 ;i <10;i++){
            ppbeList[i].Filter_Number__c = i;
        }
        //Insert PPBE records
        insert ppbeList;
        
        //Make sure publish status is changed from 'waiting' to 'deactivated'
        for (Publish_PriceBook_Entry__c ppbe : ppbeList){
            ppbe.Publish_Status__c = 'Deactivated';
        }
        //Update PPBE records
        update ppbeList;
        
    }
    
    //This method tests the deletion of Servicing_Store__c records
    @isTest
    static void testServicingStoreDelete() {
        
        //Assert that 50 Servicing_Store__c records exist
        List<Servicing_Store__c> ssListAll = [SELECT Id FROM Servicing_Store__c];    
        System.assertEquals(50, ssListAll.size());
        
        Test.startTest();
            //Execute Servicing Store batch job
            RWS_ServicingStoreDeleteBatch obj = new RWS_ServicingStoreDeleteBatch();
            DataBase.executeBatch(obj);            
        Test.stopTest();
        
        //Assert that there are only 10 Servicing_Store__c records from the original 50 after batch runs
        List<Servicing_Store__c> ssList = [SELECT Id, Active__c FROM Servicing_Store__c];       
        System.assertEquals(10, ssList.size());
        
    }
    
    //This method tests the deletion of Publish_PriceBook_Entry__c records
    @isTest
    static void testPublishPricebookEntryDelete() {
        
        //Assert that 50 Publish_PriceBook_Entry__c records exist
        List<Publish_PriceBook_Entry__c> ppbeListAll = [SELECT Id FROM Publish_PriceBook_Entry__c]; 
        System.assertEquals(50, ppbeListAll.size());
        
        Test.startTest();
            //Execute PPBE batch job
            RWS_PPBEDeleteBatch obj = new RWS_PPBEDeleteBatch();
            DataBase.executeBatch(obj);            
        Test.stopTest();
        
        //Assert that there are only 10 Publish_PriceBook_Entry__c records from the original 50 after batch runs
        List<Publish_PriceBook_Entry__c> ppbeList = [SELECT Id, Publish_Status__c, Active__c, Filter_Number__c FROM Publish_PriceBook_Entry__c];       
        System.assertEquals(10, ppbeList.size());
        
    }
    
    //This method tests the scheduler class for code coverage
    @isTest
    static void testSchedulerClass() {
        String jobId  = RWS_BatchDeleteSchedulable.scheduleDeleteBatchJob();  
              
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(RWS_BatchDeleteSchedulable.CRON_EXPR, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
    }
    
}