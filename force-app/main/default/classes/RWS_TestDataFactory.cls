public class RWS_TestDataFactory {

    /*
    Salesforce records that are created in 
    test methods aren’t committed to the database. 
    They’re rolled back when the test finishes execution. 
    This rollback behavior is handy for testing because 
    you don’t have to clean up your test data after the test executes.
    */
    public User TestRunner {get; set;}
    public List<Tax_Exemption_Reason__c> TaxExemptionReasons {get; set;}
    public List<Contact> AccountContacts {get; set;}
    public List<Program__c> AccountPrograms {get; set;}
    public List<Pricebook2> ProgramPriceBooks {get; set;}

    public RWS_TestDataFactory(){
        //will set a user member level variable
        HandleTestUserSetup();
    }

    public void HandleTestUserSetup(){
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);

        User userWithRole = new User(
            alias = 'hasrole', 
            email='userwithrole@roletest1.com', 
            userroleid = r.id, 
            emailencodingkey='UTF-8', 
            lastname='Testing', 
            languagelocalekey='en_US',
            localesidkey='en_US', 
            profileid = UserInfo.getProfileId(),
            timezonesidkey='America/Los_Angeles', 
            username='userwithrole@testorg.com');
        Database.insert(userWithRole);
        //member variable use System.RunAs() with this user
        TestRunner = userWithRole;

    }

    public List<Store_IA_Account__c> createIndustrialAccounts() {
        return createIndustrialAccount(true);
    }

    public List<Store_IA_Account__c> createIndustrialAccounts(Boolean createPrograms) {
        return createIndustrialAccount(createPrograms);
    }

    private List<Store_IA_Account__c> createIndustrialAccount(Boolean createPrograms)
    {
        //assume the test runner user will be the user
        Id BPC = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
        Id BP = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
        String PrimaryContact = 'Primary Contact';
        String BillingContact = 'Billing Contact';

        //create two industrial accounts
        List<Account> industrialAccounts = new List<Account>();
        List<Account> storeAccounts = new List<Account>();
        List<Store_IA_Account__c> lookups = new List<Store_IA_Account__c>();
        List<Program__c> programs = new List<Program__c>();
        List<Contact> contacts = new List<Contact>();
        List<Tax_Exemption_Reason__c> taxExemptReasons = new List<Tax_Exemption_Reason__c>();
        List<Pricebook2> priceBooks = new List<Pricebook2>();


        Account industrialAccount1 = new Account();
        industrialAccount1.Name = 'IA One';

        Account industrialAccount2 = new Account();
        industrialAccount2.Name = 'IA Two';

        industrialAccounts.add(industrialAccount1);
        industrialAccounts.add(industrialAccount2);

        insert industrialAccounts;

        //create four store accounts
        Account acct = new Account();
        acct.Name = 'Store One';
        acct.RecordTypeId = BPC;
        acct.IA_Physical_Location_Address_Line_1__c = '123 East First Street';
        acct.IA_Physical_Location_City__c = 'Sartell';
        acct.IA_Physical_Location_State_Province__c = 'MN';
        acct.IA_Physical_Location_ZIP_Postal_Code__c = '56377';
        acct.IA_Physical_Location_Country__c = 'US';
        acct.Credit_Approval_Indicator__c = true;
        acct.Credit_Status__c = 'Approved/Active';
        acct.Active__c = true;
        acct.HasActiveProgram__c = true;
        acct.Requires_Invoicing__c = 'No';
        acct.Primary_Contact_Email__c = 'bob@test.com';
        acct.Primary_Contact_First_Name__c = 'Bob';
        acct.Primary_Contact_Last_Name__c = 'Test';

        Account acct2 = new Account();
        acct2.Name = 'Store Two';
        acct2.RecordTypeId = BPC;
        acct2.IA_Physical_Location_Address_Line_1__c = '1234 East First Street';
        acct2.IA_Physical_Location_City__c = 'Sartelll';
        acct2.IA_Physical_Location_State_Province__c = 'MN';
        acct2.IA_Physical_Location_ZIP_Postal_Code__c = '56378';
        acct2.IA_Physical_Location_Country__c = 'US';
        acct2.Credit_Approval_Indicator__c = true;
        acct2.Credit_Status__c = 'Approved/Active';
        acct2.Active__c = true;
        acct2.HasActiveProgram__c = true;
        acct2.Requires_Invoicing__c = 'No';
        acct2.Primary_Contact_Email__c = 'bob@test.com';
        acct2.Primary_Contact_First_Name__c = 'Bob';
        acct2.Primary_Contact_Last_Name__c = 'Test';

        Account acct3 = new Account();
        acct3.Name = 'Store Three';
        acct3.RecordTypeId = BPC;
        acct3.HasActiveProgram__c = true;
        acct3.Requires_Invoicing__c = 'No';

        Account acct4 = new Account();
        acct4.Name = 'Store Four';
        acct4.RecordTypeId = BPC;
        acct4.HasActiveProgram__c = true;
        acct4.Requires_Invoicing__c = 'No';

        storeAccounts.add(acct);
        storeAccounts.add(acct2);
        storeAccounts.add(acct3);
        storeAccounts.add(acct4);

        insert storeAccounts;

        system.debug('The store accounts are... ' + storeAccounts);

        //now join or relate the IA -> store
        Store_IA_Account__c lookup = new Store_IA_Account__c();
        lookup.IA_Account__c = industrialAccount1.id;
        lookup.Store_Account__c = acct.id;

        Store_IA_Account__c lookup2 = new Store_IA_Account__c();
        lookup2.IA_Account__c = industrialAccount1.id;
        lookup2.Store_Account__c = acct2.id;

        Store_IA_Account__c lookup3 = new Store_IA_Account__c();
        lookup3.IA_Account__c = industrialAccount2.id;
        lookup3.Store_Account__c = acct3.id;

        Store_IA_Account__c lookup4 = new Store_IA_Account__c();
        lookup4.IA_Account__c = industrialAccount2.id;
        lookup4.Store_Account__c = acct4.id;

        lookups.add(lookup);
        lookups.add(lookup2);
        lookups.add(lookup3);
        lookups.add(lookup4);

        insert lookups;

        if(createPrograms) {
            //now we are going to add programs to the mix
            Program__c program1 = new Program__c();
            program1.Name = 'Program One';
            program1.Account__c = lookups[0].Store_Account__c;
            program1.Template__c = false;
            program1.Active__c = true;
            program1.Type__c = 'CashandCarry';
            program1.Auto_Update_Price__c = true;
            program1.Activation_Date__c = Date.today().addDays(-1);
            program1.Expiration_Date__c = Date.today().addDays(5);
            program1.Eligibility_Option__c = 'False';
            program1.Subsidy_Tax__c = 'SubsidyTaxed';
            program1.HasPricebook__c = true;
            program1.Processing_Status__c = 'Completed';

            Program__c program2 = new Program__c();
            program2.Name = 'Program Two';
            program2.Account__c = lookups[1].Store_Account__c;
            program2.Template__c = false;
            program2.Active__c = true;
            program2.Type__c = 'CashandCarry';
            program2.Auto_Update_Price__c = true;
            program2.Activation_Date__c = Date.today().addDays(-1);
            program2.Expiration_Date__c = Date.today().addDays(5);
            program2.Eligibility_Option__c = 'False';
            program2.Subsidy_Tax__c = 'SubsidyTaxed';
            program2.HasPricebook__c = true;
            
            Program__c program3 = new Program__c();
            program3.Name = 'Program Three';
            program3.Type__c = 'CashandCarry';
            program3.Template__c = true;
            program3.Processing_Status__c = 'Completed';

            Program__c program4 = new Program__c();
            program4.Name = 'Program Four';
            program4.Type__c = 'CashandCarry';
            program4.Template__c = true;
            program4.Processing_Status__c = 'Completed';

            programs.add(program1);
            programs.add(program2);
            programs.add(program3);
            programs.add(program4);

            insert programs;

            system.debug('The account programs are... ' + programs);

            //set up a couple price books
            Pricebook2 priceBook = new Pricebook2();
            priceBook.Name = 'Price Book 1';
            priceBook.IsActive = true;
            priceBook.Program__c = program1.Id;

            priceBooks.add(priceBook);
            insert priceBooks;
        }

        AccountPrograms = programs;
        ProgramPriceBooks = priceBooks;

        //need contacts linked to accounts, use first account
        Contact contact1 = new Contact();
        contact1.RecordTypeId = BP;
        contact1.AccountId = acct.id;
        contact1.Contact_Identifier__c = 'Primary';
        contact1.FirstName = 'Bill';
        contact1.LastName = 'Test';
        contact1.Email = 'bill@test.com';

        Contact contact2 = new Contact();
        contact2.RecordTypeId = BP;
        contact2.AccountId = acct.id;
        contact2.Contact_Identifier__c = 'Primary';
        contact2.FirstName = 'Bob';
        contact2.LastName = 'Test';
        contact2.Email = 'bob@test.com';

        Contact contact3 = new Contact();
        contact3.RecordTypeId = BP;
        contact3.AccountId = acct.id;
        contact3.Contact_Identifier__c = 'Primary';
        contact3.FirstName = 'Brent';
        contact3.LastName = 'Test';
        contact3.Email = 'brent@test.com';

        contacts.add(contact1);
        contacts.add(contact2);
        contacts.add(contact3);

        insert contacts;

        AccountContacts = contacts;

        system.debug('The test contacts list is... ' + Contacts);

        Tax_Exemption_Reason__c taxExemption = new Tax_Exemption_Reason__c();
        taxExemption.Name = 'TCN GOVT-PST EXMPT';
        taxExemption.Active__c = true;
        taxExemption.State_Exempt__c = 'TRUE'; 
        taxExemption.Applicable_to__c = 'All State/Provinces';
        taxExemption.Industrial_Account_Allowed__c = 'Y';
        taxExemption.National_Account_Allowed__c = 'Y';     
        taxExemption.City_Exempt__c = 'TRUE';
        taxExemption.State_Exempt__c = 'TRUE';
        taxExemption.County_Exempt__c = 'TRUE';
        taxExemption.Country_Exempt__c = 'TRUE';

        Tax_Exemption_Reason__c taxExemption2 = new Tax_Exemption_Reason__c();
        taxExemption2.Name = 'IL-EQUIP EXEMPT';
        taxExemption2.Active__c = true;
        taxExemption2.State_Exempt__c = 'FALSE'; 
        taxExemption2.Applicable_to__c = 'All State/Provinces';
        taxExemption2.Industrial_Account_Allowed__c = 'N';
        taxExemption2.National_Account_Allowed__c = 'N';        
        taxExemption2.City_Exempt__c = 'FALSE';
        taxExemption2.State_Exempt__c = 'FALSE';
        taxExemption2.County_Exempt__c = 'FALSE';
        taxExemption2.Country_Exempt__c = 'FALSE';

        taxExemptReasons.add(taxExemption);
        taxExemptReasons.add(taxExemption2);

        insert taxExemptReasons;

        TaxExemptionReasons = taxExemptReasons;

        return lookups;

    }


}