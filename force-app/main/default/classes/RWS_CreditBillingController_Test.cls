@isTest
private class RWS_CreditBillingController_Test {

    static testMethod void testInsertRWFB(){
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        RWfB_Attachment__c att = RWS_CreditBillingController.insertRWFB(acc.Id, 'Company Voucher', false);


        System.assert(att.Id != null);
    }

    static testMethod void testYesCentralized(){

        //RWS_AccountTrigger_Handler.RUN

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Account childAcc = RWS_TestUtil.createAccount(rtId, false);
        childAcc.ParentId = acc.Id;
        childAcc.Requires_Invoicing__c = 'Yes';
        childAcc.Invoice_Parent_Account__c = 'Centralized';
        childAcc.Requested_Credit_Limi__c = '5000';
        childAcc.IA_Physical_Location_City__c = 'MN';
        childAcc.IA_Physical_Location_Country__c = 'US';
        childAcc.IA_Physical_Location_State_Province__c = 'MN';
        childAcc.IA_Physical_Location_Address_Line_1__c = '24-11';
        childAcc.IA_Physical_Location_ZIP_Postal_Code__c = '55211';
        childAcc.RWfB_same_as_Physical_Address__c = true;
        insert childAcc;

        Contact con = RWS_TestUtil.createContact(childAcc.Id, 1, false);
        con.Contact_Identifier__c = 'Primary';
        con.FirstName = 'Charles';
        con.LastName = 'Test';
        con.Email = 'charles@test.com';
        con.MailingCity = 'MN';
        con.MailingCountry = 'US';
        con.MailingState = 'MN';
        con.MailingStreet = '24-A';
        con.MailingPostalCode = '55213';

        Contact con0 = RWS_TestUtil.createContact(acc.Id, 2, false);
        con0.Contact_Identifier__c = 'Primary';
        con0.FirstName = 'Dave';
        con0.LastName = 'Test';
        con0.Email = 'dave@test.com';
        con0.MailingCity = 'MN';
        con0.MailingCountry = 'US';
        con0.MailingState = 'MN';
        con0.MailingStreet = '24-0';
        con0.MailingPostalCode = '55210';

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Contact_Identifier__c = 'Billing';
        con1.FirstName = 'Bill';
        con1.LastName = 'Test';
        con1.Email = 'bill@test.com';
        con1.MailingCity = 'MN';
        con1.MailingCountry = 'US';
        con1.MailingState = 'MN';
        con1.MailingStreet = '24-B';
        con1.MailingPostalCode = '55214';

        insert new List<Contact>{con, con0, con1};


        Test.startTest();

            PageReference pr = Page.RWS_Account_CreationV2;

            pr.getParameters().put('id', childAcc.Id);

            Test.setCurrentPage(pr);

            RWS_CreditBillingController cc = new RWS_CreditBillingController();
            cc.creditappFlag = true;
            cc.selectInvoiceAttributes = new List<String>();
            cc.selectedBillingRole = new List<String>();

            cc.updateCreditInfo();
            
            System.debug(cc.errors);
            System.debug(cc.haserrors);
            System.debug(cc.isCentralizedBilling);
            System.debug(cc.isDecentralizedBilling);
            System.debug(cc.hasParent);
            System.debug(cc.hasParent);
            System.debug(cc.isInvoiceParentAccount);
            System.debug(cc.outputBillingContact);
            System.debug(cc.hasParent);
            System.debug(cc.contactPrimaryEmail);
            System.debug(cc.decContactId);
            System.debug(cc.invoiceAttributes);

        Test.stopTest();

    } 

    static testMethod void testYesDecentralizedDifferentSameAcc(){

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Account childAcc = RWS_TestUtil.createAccount(rtId, false);
        childAcc.ParentId = acc.Id;
        childAcc.Requires_Invoicing__c = 'Yes';
        childAcc.Invoice_Parent_Account__c = 'Decentralized';
        childAcc.Requested_Credit_Limi__c = '5000';
        insert childAcc;

        Contact con = RWS_TestUtil.createContact(childAcc.Id, 1, false);
        con.Contact_Identifier__c = 'Primary';
        con.FirstName = 'Dave';
        con.LastName = 'Test';
        con.Email = 'dave@test.com';
        con.MailingCity = 'MN';
        con.MailingCountry = 'US';
        con.MailingState = 'MN';
        con.MailingStreet = '24-A';
        con.MailingPostalCode = '55213';
        
        Contact con2 = RWS_TestUtil.createContact(childAcc.Id, 3, false);
        
        con2.Contact_Identifier__c = 'Billing';
        con2.FirstName = 'Bill';
        con2.LastName = 'Test';
        con2.Email = 'bill@test.com';
        con2.MailingCity = 'MN';
        con2.MailingCountry = 'US';
        con2.MailingState = 'MN';
        con2.MailingStreet = '24-C';
        con2.MailingPostalCode = '55218';

        insert new List<Contact>{con, con2};

        PageReference pr = Page.RWS_Account_CreationV2;

        pr.getParameters().put('id', childAcc.Id);

        Test.setCurrentPage(pr);

        Test.startTest();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            RWS_CreditBillingController cc = new RWS_CreditBillingController();

            cc.creditappFlag = true;

            cc.selectbillingcontactOptions = 'Different';

            cc.decLast = 'Last';
            cc.decFirst = 'First';

            cc.decPhone = '310-745-0000';
            cc.decEmail = 'test@cbc.com';
            
            cc.decRoles = 'DEV';
            
            cc.decSelectedBillingRole = new List<String>();
            
            cc.decTitle = 'TEST';

            cc.selectContactAddrBillOptions = 'Same as Account';
            cc.selectInvoiceAttributes = new List<String>();
            cc.selectedBillingRole = new List<String>();

            cc.selectInvoiceParent = 'Yes';
            cc.selectBillingParent = 'Decentralized';
            cc.selectbillingcontactOptions = 'Yes';
            //cc.updateCreditInfo();

            cc.selectContactAddrBillOptions = 'Different';
            cc.selectbillingcontactOptions = 'Different';
            //cc.updateCreditInfo();
            ////Commented  out on 3/30/2020 because of too many soql queries - James Loghry

            cc.selectInvoiceParent = 'No';
            //Commented  out on 3/30/2020 because of too many soql queries - James Loghry
            //cc.updateCreditInfo();

            cc.accountId = null;
            cc.updateCreditInfo();

        }
        Test.stopTest();
        
    } 

    static testMethod void testYesDecentralizedDifferentDifferentAcc(){

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        Account childAcc = RWS_TestUtil.createAccount(rtId, false);
        childAcc.ParentId = acc.Id;
        childAcc.Requires_Invoicing__c = 'Yes';
        childAcc.Invoice_Parent_Account__c = 'Decentralized';
        childAcc.Requested_Credit_Limi__c = '5000';
        insert childAcc;

        Contact con = RWS_TestUtil.createContact(childAcc.Id, 1, false);
        con.Contact_Identifier__c = 'Primary';
        con.FirstName = 'Bill';
        con.LastName = 'Test';
        con.Email = 'bill@test.com';
        con.MailingCity = 'MN';
        con.MailingCountry = 'US';
        con.MailingState = 'MN';
        con.MailingStreet = '24-A';
        con.MailingPostalCode = '55213';

        Contact con0 = RWS_TestUtil.createContact(acc.Id, 2, false);
        con0.Contact_Identifier__c = 'Primary';
        con0.FirstName = 'Charles';
        con0.LastName = 'Test';
        con0.Email = 'charles@test.com';
        con0.MailingCity = 'MN';
        con0.MailingCountry = 'US';
        con0.MailingState = 'MN';
        con0.MailingStreet = '24-0';
        con0.MailingPostalCode = '55210';

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);
        con1.Contact_Identifier__c = 'Billing';
        con1.FirstName = 'Bill';
        con1.LastName = 'Test';
        con1.Email = 'bill@test.com';
        con1.MailingCity = 'MN';
        con1.MailingCountry = 'US';
        con1.MailingState = 'MN';
        con1.MailingStreet = '24-B';
        con1.MailingPostalCode = '55214';
        
        Contact con2 = RWS_TestUtil.createContact(childAcc.Id, 3, false);
        
        con2.Contact_Identifier__c = 'Billing';
        con2.FirstName = 'Bill';
        con2.LastName = 'Test';
        con2.Email = 'bill@test.com';
        con2.MailingCity = 'MN';
        con2.MailingCountry = 'US';
        con2.MailingState = 'MN';
        con2.MailingStreet = '24-C';
        con2.MailingPostalCode = '55218';

        insert new List<Contact>{con, con0, con1, con2};

        Test.startTest();

            PageReference pr = Page.RWS_Account_CreationV2;

            pr.getParameters().put('id', childAcc.Id);

            Test.setCurrentPage(pr);

            RWS_CreditBillingController cc = new RWS_CreditBillingController();
            cc.creditappFlag = true;
            cc.selectbillingcontactOptions = 'Different';

            cc.decLast = 'Last';
            cc.decFirst = 'First';

            cc.decPhone = '310-745-0000';
            cc.decEmail = 'test@cbc.com';

            cc.selectContactAddrBillOptions = 'Different';

            cc.decCity = 'MN';
            cc.decCountry = 'US';
            cc.decEmail = 'test@cc.com';
            cc.decState = 'MN';
            cc.decZipCode = '55250';
            cc.selectInvoiceAttributes = new List<String>();
            cc.selectedBillingRole = new List<String>();

            cc.updateCreditInfo();

        Test.stopTest();
    }
}