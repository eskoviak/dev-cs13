@isTest
private class RWS_ppbButtonTest {
  
    //test
    @isTest
    static void testppbButton() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
        Account acc = RWS_TestUtil.createAccount(recordTypeId, true);
        Program__c prgm = RWS_TestUtil.createProgram(acc.Id, false);
        prgm.Publish_Status__c = 'Published';
        insert prgm;
        
        Publish_Pricebook__c ppb = RWS_TestUtil.createCustomPublishPricebook(prgm.Id, true);
        
        Product2 p1 = RWS_TestUtil.createProduct('1', true);
        Product2 p2 = RWS_TestUtil.createProduct('2', true);
        Product2 p3 = RWS_TestUtil.createProduct('3', true);
        Product2 p4 = RWS_TestUtil.createProduct('4', true);
        
        Publish_Pricebook_Entry__c ppbe1 = RWS_TestUtil.createPublishPricebookEntry(ppb.Id, p1.Id, true);
        Publish_Pricebook_Entry__c ppbe2 = RWS_TestUtil.createPublishPricebookEntry(ppb.Id, p2.Id, true);
        Publish_Pricebook_Entry__c ppbe3 = RWS_TestUtil.createPublishPricebookEntry(ppb.Id, p3.Id, true);
        Publish_Pricebook_Entry__c ppbe4 = RWS_TestUtil.createPublishPricebookEntry(ppb.Id, p4.Id, true);
        
        ppbe1.Active__c = true;
        ppbe1.Publish_Status__c = 'Waiting';
        update ppbe1;
        ppbe2.Active__c = true;
        ppbe2.Publish_Status__c = 'Deactivated';
        update ppbe2;
        ppbe3.Active__c = false;
        ppbe3.Publish_Status__c = 'Deactivated';
        update ppbe3;
        ppbe4.Active__c = true;
        ppbe4.Publish_Status__c = 'Published';
        update ppbe4;
        
        System.debug('ppbe1: '+ppbe1.Publish_Status__c);
        System.debug('ppbe2: '+ppbe2.Publish_Status__c);
        System.debug('ppbe3: '+ppbe3.Publish_Status__c);
        System.debug('ppbe4: '+ppbe4.Publish_Status__c);
                        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ppb);
        RWS_ppbButtonController testPpbButton = new RWS_ppbButtonController(sc);
        
        PageReference pageRef = Page.RWS_ppbButtonPage; 
        
        pageRef.getParameters().put('id', String.valueOf(ppb.Id));
        
        Test.setCurrentPage(pageRef);
        
        testPpbButton.autoRun();
       
        Test.stopTest();
        
        Publish_Pricebook_Entry__c updatedPPBE1 = [SELECT Publish_Status__c FROM Publish_Pricebook_Entry__c WHERE Id =: ppbe1.Id];
        Publish_Pricebook_Entry__c updatedPPBE2 = [SELECT Publish_Status__c FROM Publish_Pricebook_Entry__c WHERE Id =: ppbe2.Id];
        Publish_Pricebook_Entry__c updatedPPBE3 = [SELECT Publish_Status__c FROM Publish_Pricebook_Entry__c WHERE Id =: ppbe3.Id];
        Publish_Pricebook_Entry__c updatedPPBE4 = [SELECT Publish_Status__c FROM Publish_Pricebook_Entry__c WHERE Id =: ppbe4.Id];
        
        System.debug('updatedPPBE1: '+updatedPPBE1.Publish_Status__c);
        System.debug('updatedPPBE2: '+updatedPPBE2.Publish_Status__c);
        System.debug('updatedPPBE3: '+updatedPPBE3.Publish_Status__c);
        System.debug('updatedPPBE4: '+updatedPPBE4.Publish_Status__c);
        
        System.assertEquals('Published', updatedPPBE1.Publish_Status__c);
        System.assertEquals('Published', updatedPPBE2.Publish_Status__c); 
        System.assertEquals('Deactivated', updatedPPBE3.Publish_Status__c);
        System.assertEquals('Published', updatedPPBE4.Publish_Status__c);        

    }
  
    
    
    
}