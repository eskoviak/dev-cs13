@isTest
private class RWS_ContactController_Test {
    static testMethod void testController() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        PageReference pr = Page.RWS_Account_CreationV2;

        pr.getParameters().put('id', acc.Id);

        Test.setCurrentPage(pr);

        RWS_ContactController cc = new RWS_ContactController();

        cc.resetContactFields();

        cc.contactCity = 'MN';
        cc.contactCountry = 'US';
        cc.contactEmail = 'test@cc.com';
        cc.contactState = 'MN';
        cc.contactFirstName = 'First';
        cc.contactLastName = 'Last';

        cc.contactPhoneNo = '310-745-0000';
        //James Loghry (Demand Chain) I have no clue why the contact controller needs two phone numbers, but it does...
        cc.contactPhoneNoEdit = '310-745-0000';
        cc.contactTitle = 'DEV';

        cc.SelectContactAddressOptions = 'Different';

        cc.createContact();

        System.assert(!String.isBlank(cc.contactId) );

        cc.deletedContactId = cc.contactId;

        cc.viewContact();

        cc.deleteContact();
    }


    static testMethod void testControllerPrimaryContact() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Contact con = RWS_TestUtil.createContact(acc.Id, 1, false);
        con.Contact_Identifier__c = 'Primary';
        con.FirstName = 'Bill';
        con.LastName = 'Test';
        con.Email = 'bill@test.com';
        
        insert con;

        PageReference pr = Page.RWS_Account_CreationV2;

        pr.getParameters().put('id', acc.Id);

        Test.setCurrentPage(pr);

        RWS_ContactController cc = new RWS_ContactController();
    }
}