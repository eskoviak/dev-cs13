@isTest
private class BrandCopyToAccountTest {

    static testMethod void myContoller(){
       BrandCopyToAccount comment = new BrandCopyToAccount();
   }
    
/*    static User testUser;
    static Account testAccount;
    static Brand__c testBrand;
    
    static void initialize() {
        testUser = ECTestDataFactory.createTestUser();
        insert testUser;
        system.assertNotEquals(null, testUser.Id);
        
        testAccount = ECTestDataFactory.createAccount('Acme', true);    
        system.assertNotEquals(null, testAccount.Id);   
        
        testBrand = ECTestDataFactory.createBrand(testAccount.Id, testUser.Id, false);
    }   
    
    static testMethod void testCopyBrandToAccount() {
        initialize();
        
        testBrand.Brand__c = 'WROX';
        
        test.startTest();
            insert testBrand;
        test.stopTest();
    
        Account result = [select Brands__c from Account where Id =: testAccount.Id];
        system.assertEquals(testBrand.Brand__c, result.Brands__c);  
    }
    
    static testMethod void testCopyBrandToAccountOnDelete() {
        initialize();
        
        testBrand.Brand__c = 'WROX';
        insert testBrand;
        
        system.assertNotEquals(null, testBrand.Id);
        
        test.startTest();
            delete testBrand;
        test.stopTest();
    
        Account result = [select Brands__c from Account where Id =: testAccount.Id];
        system.assertEquals(null, result.Brands__c);    
    }*/
    
}