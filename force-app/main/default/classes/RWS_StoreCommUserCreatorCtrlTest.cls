/**
 * RWS_StoreCommUserCreatorCtrlTest
 * @description Test class for RWS_StoreCommUserCreatorCtrl
 * @date 7/31/2017
 * @author James Loghry (Demand Chain Systems)
 */
@isTest
private class RWS_StoreCommUserCreatorCtrlTest {
    static testmethod void testCreateCommunityUser(){
        Account acct = new Account(Name='ACME',Store_Number__c='999888777532');
        insert acct;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        RWS_StoreCommUserCreatorCtrl ctrl = new RWS_StoreCommUserCreatorCtrl(sc);

        PageReference pageRef = ctrl.createCommunityUser();
        //Should test exception path.
        PageReference pageRef2 = ctrl.createCommunityUser();
        Test.stopTest();	
        
        System.debug('JWL: ' + ApexPages.getMessages().get(0).getDetail());
        System.assertEquals(ApexPages.Severity.CONFIRM,ApexPages.getMessages().get(0).getSeverity());
    }
    
    static testmethod void testCreateCommunityUserDuplicateError(){
        Account acct = new Account(Name='ACME',Store_Number__c='999888777532');
        insert acct;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        RWS_StoreCommUserCreatorCtrl ctrl = new RWS_StoreCommUserCreatorCtrl(sc);
        ctrl.createCommunityUser();
        ctrl.createCommunityUser();
        Test.stopTest();	

        System.debug('JWL: ' + ApexPages.getMessages().get(0).getDetail());
        //System.assertEquals(2,ApexPages.getMessages().size());
        System.assertEquals(
            ApexPages.Severity.ERROR,
            ApexPages.getMessages().get(
                ApexPages.getMessages().size()-1
            ).getSeverity()
       	);
    }
}