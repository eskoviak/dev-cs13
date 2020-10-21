/**
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 2013-07-22    Mike Eaton      Updated to increase code coverage
* 2013-08-01    Mike Eaton      Added additional code coverage
* 2013-08-02    Mike Eaton      Updated to avoid DML limit
* 2020-07-09    Chris Mollet    Commented out test class - DC Case 8433
* {Date}        {Changed By}    ({Ticket}) – {Change Description}
* =============================================================================
*/

@isTest(SeeAllData=false)
global class Test_AT_AccountTeamSolution {
    @IsTest
        private static void commentTest() {
            AT_AccountTeamSolution newTest = new AT_AccountTeamSolution();
        }
/*


    static testMethod void myUnitTest() {

        //  create support data
        createUserData();

        List<AT_AccountTeamSolution.AT_Customer> lCustomers = new List<AT_AccountTeamSolution.AT_Customer>();

        AT_AccountTeamSolution.AT_Customer Client1 = new AT_AccountTeamSolution.AT_Customer();

        //  Create Client1 Addresses  
        AT_AccountTeamSolution.AT_Address Address1 = new AT_AccountTeamSolution.AT_Address();
        Address1.Address1 = '103 SAND MOUNTAN DR NE';
        Address1.AddressNumber = '1000201';
        Address1.AddressType = 'Delivery';
        Address1.City = 'ALBERTVILLE';
        Address1.Country = 'US';
        Address1.CountryName = 'UNITED STATES';
        Address1.State = 'AL';
        Address1.Zipcode = '35950';

        Client1.Addresses.Add(Address1);

        AT_AccountTeamSolution.AT_Address Address2 = new AT_AccountTeamSolution.AT_Address();
        Address2.Address1 = '103 SAND MOUNTAIN DR NE';
        Address2.AddressNumber = '1000201I00001';
        Address2.AddressType = 'Invoice';
        Address2.City = 'ALBERTVILLE';
        Address2.Country = 'US';
        Address2.CountryName = 'UNITED STATES';
        Address2.State = 'AL';
        Address2.Zipcode = '35950';

        Client1.Addresses.Add(Address2);

        AT_AccountTeamSolution.AT_Address Address3 = new AT_AccountTeamSolution.AT_Address();
        Address3.Address1 = '103 SAND MOUNTAIN DR NE';
        Address3.AddressNumber = '1000201M00001';
        Address3.AddressType = 'Mailing';
        Address3.City = 'ALBERTVILLE';
        Address3.Country = 'US';
        Address3.CountryName = 'UNITED STATES';
        Address3.State = 'AL';
        Address3.Zipcode = '35950';

        Client1.Addresses.Add(Address3);

        AT_AccountTeamSolution.AT_Address Address4 = new AT_AccountTeamSolution.AT_Address();
        Address1.Address1 = '8021 BRIER CREEK PKWY';
        Address1.AddressNumber = '99999';
        Address1.AddressType = 'Location';
        Address1.City = 'RALEIGH';
        Address1.Country = 'US';
        Address1.CountryName = 'UNITED STATES';
        Address1.State = 'NC';
        Address1.Zipcode = '27617';

        Client1.Addresses.Add(Address4);


        //  Create Client1 Brands  
        AT_AccountTeamSolution.AT_Brand Brand1 = new AT_AccountTeamSolution.AT_Brand();
        Brand1.BrandName = 'Irish Setter Hunt';

        Client1.Brands.Add(Brand1);


        AT_AccountTeamSolution.AT_Brand Brand2 = new AT_AccountTeamSolution.AT_Brand();
        Brand2.BrandName = 'Red Wing Brand Other';
        Brand2.SalesRepName = 'Tom Drewel';
        Brand2.SalesRepNum = '0085';
        Brand2.SalesRepEmailAddress = 'tom.drewel@redwingshoe.com';
        Brand2.RegionDirector = 'True';
        Brand2.RegionDirectorName = 'Mike Tester';
        Brand2.RegionDirectorEmailAddress = 'mike.tester@redwingshoe.com';
        Brand2.RegionName = 'West';

        Client1.Brands.Add(Brand2);

        AT_AccountTeamSolution.AT_Brand Brand3 = new AT_AccountTeamSolution.AT_Brand();
        Brand3.BrandName = 'Red Wing Casual';

        Client1.Brands.Add(Brand3);

        AT_AccountTeamSolution.AT_Brand Brand4 = new AT_AccountTeamSolution.AT_Brand();
        Brand4.BrandName = 'Red Wing Heritage';
        Brand4.SalesRepName = 'Justin Lannan';
        Brand4.SalesRepNum = '0085';
        Brand4.SalesRepEmailAddress = 'jlannan@brandywinereps.com';

        Client1.Brands.Add(Brand4);

        AT_AccountTeamSolution.AT_Brand Brand5 = new AT_AccountTeamSolution.AT_Brand();
        Brand5.BrandName = 'WORX';
        Brand5.SalesRepName = 'Dan Mehrkens';
        Brand5.SalesRepNum = '0085';

        Client1.Brands.Add(Brand5);

        //  Create Client1 details  
        Client1.RegionDirector = 'WK05';
        Client1.RegionDirectorName = 'South-East';
        Client1.BuyingGroup = 'F';
        Client1.ChangeType = 'Changed';
        Client1.CompLegalName = 'ANDERSON SHOE SHOP';
        Client1.CreditAnalyst = 'CA5';
        Client1.CreditAnalystName = 'Ann Lunde';
        Client1.CreditLimit1 = 500.00;
        Client1.CreditLimit2 = 5000.00;
        Client1.CreditLimit3 = 6250.00;
        Client1.CreditLimit4 = 45;
        Client1.CustNum = '1000201';
        Client1.DistChannel = '01A';
        Client1.DistChannelName = 'Store Branded';
        //Client1.EmailForInvoices
        Client1.EmailForOrderConfirmations = 'paige.stajkowski@redwingshoe.com';
        Client1.FaxNum = '256-878-4392';
        Client1.ISMName = 'Dan McCauley';
        Client1.ISMNum = '207';
        Client1.ROMName = 'Not Applicable';
        Client1.ROMNum = '-';
        Client1.Responsible = 'MOVEX';
        Client1.RtlAcctSpecialist = '-';
        Client1.RtlAcctSpecialistName = 'NA';
        Client1.RtlAcctSpecialistEmailAddress = 'mike@eatontechnology.com';
        Client1.SearchKey = '35950';
        Client1.ShippingDesc = 'Best Way';
        Client1.ShippingMethodPref = 'BW';
        Client1.Status = '20';
        Client1.TelNum = '256-878-4392';
        Client1.TierLevel = '3';
        Client1.AgingNotDue = 'X';
        Client1.Aging1To30 = 'X';
        Client1.Aging31To60 = 'X';
        Client1.Aging61To90 = 'X';
        Client1.AgingOver90 = 'X';


        //  Create Client1 BillingContact  
        AT_AccountTeamSolution.AT_Contact BillingContact = new AT_AccountTeamSolution.AT_Contact();

        BillingContact.FirstName = 'Michael';
        BillingContact.LastName = 'K';
        BillingContact.Email = 'mk@email.com';
        BillingContact.Phone = '555-555-5555';

        Client1.BillingContact = BillingContact;

        //  Create Client1 StoreContact  
        AT_AccountTeamSolution.AT_Contact StoreContact = new AT_AccountTeamSolution.AT_Contact();

        StoreContact.FirstName = 'Michael';
        StoreContact.LastName = 'K';
        StoreContact.Email = 'mk@email.com';
        StoreContact.Phone = '555-555-5555';

        Client1.StoreContact = StoreContact;

        lCustomers.add(Client1);



        //   Create Client2 data with key missing items  
        AT_AccountTeamSolution.AT_Customer Client2 = new AT_AccountTeamSolution.AT_Customer();

        //  Create Client1 details
        Client2.RegionDirector = 'WK05';
        Client2.RegionDirectorName = 'South-East';
        Client2.BuyingGroup = 'F';
        Client2.ChangeType = 'Changed';
        Client2.CompLegalName = 'ACME UNIVERSAL';
        Client2.CreditAnalyst = 'CA5';
        Client2.CreditAnalystName = 'Ann Lunde';
        Client2.CreditLimit1 = 500.00;
        Client2.CreditLimit2 = 5000.00;
        Client2.CreditLimit3 = 6250.00;
        Client2.CreditLimit4 = 45;
        Client2.CustNum = '';
        Client2.DistChannel = '02A';
        Client2.DistChannelName = 'Store Branded';
        //Client1.EmailForInvoices
        Client2.EmailForOrderConfirmations = 'paige.stajkowski@redwingshoe.com';
        Client2.FaxNum = '256-878-4392';
        Client2.ISMName = 'Dan McCauley';
        Client2.ISMNum = '207';
        Client2.ROMName = 'Not Applicable';
        Client2.ROMNum = '-';
        Client2.Responsible = 'MOVEX';
        Client2.RtlAcctSpecialist = '-';
        Client2.RtlAcctSpecialistName = 'NA';
        Client2.RtlAcctSpecialistEmailAddress = 'mike@eatontechnology.com';
        Client2.SearchKey = '35950';
        Client2.ShippingDesc = 'Best Way';
        Client2.ShippingMethodPref = 'BW';
        Client2.Status = '20';
        Client2.TelNum = '256-878-4392';
        Client2.TierLevel = '3';

        lCustomers.add(Client2);

        //  Initial webservice sync call 
        Test.startTest();
        System.debug('JWL: Number of Queries 00: ' + Limits.getQueries());
        
        System.debug('JWL: sync lcustomers size: ' + lCustomers.size());
        AT_AccountTeamSolution.syncCustomer(lCustomers, true);

        //
        //
        //    Make some changes and call webservice with updates
        //
        //

        List<AT_AccountTeamSolution.AT_Customer> lCustomersA = new List<AT_AccountTeamSolution.AT_Customer>();
        AT_AccountTeamSolution.AT_Customer Client1a = new AT_AccountTeamSolution.AT_Customer();


        //  Create Client1a Brands 

        AT_AccountTeamSolution.AT_Brand Brand2a = new AT_AccountTeamSolution.AT_Brand();
        Brand2a.BrandName = 'Red Wing Brand Other';
        Brand2a.SalesRepName = 'Tom Drewel';
        Brand2a.SalesRepNum = '0085';
        Brand2a.SalesRepEmailAddress = 'tom.drewel@redwingshoe.com';
        Brand2a.RegionDirector = 'True';
        Brand2a.RegionDirectorName = 'John Tester';
        Brand2a.RegionDirectorEmailAddress = 'John.tester@redwingshoe.com';
        Brand2a.RegionName = 'West';

        Client1a.Brands.Add(Brand2a);

        AT_AccountTeamSolution.AT_Brand Brand4a = new AT_AccountTeamSolution.AT_Brand();
        Brand4a.BrandName = 'Red Wing Heritage';
        Brand4a.SalesRepName = 'Justin Lannan';
        Brand4a.SalesRepNum = '0085';
        Brand4a.SalesRepEmailAddress = 'jlannan@brandywinereps.com';

        Client1a.Brands.Add(Brand4a);

        AT_AccountTeamSolution.AT_Brand Brand5a = new AT_AccountTeamSolution.AT_Brand();
        Brand5a.BrandName = 'WORX';
        Brand5a.SalesRepName = 'Dan Mehrkens';
        Brand5a.SalesRepNum = '0095';

        Client1a.Brands.Add(Brand5a);

        //  Create Client1a details  
        Client1a.RegionDirector = 'WK05';
        Client1a.RegionDirectorName = 'South-East';
        Client1a.BuyingGroup = 'F';
        Client1a.ChangeType = 'Changed';
        Client1a.CompLegalName = 'ANDERSON SHOE SHOP';
        Client1a.CreditAnalyst = 'CA5';
        Client1a.CreditAnalystName = 'Ann Lunde';
        Client1a.CreditLimit1 = 500.00;
        Client1a.CreditLimit2 = 5000.00;
        Client1a.CreditLimit3 = 6250.00;
        Client1a.CreditLimit4 = 45;
        Client1a.CustNum = '1000201';
        Client1a.DistChannel = '01A';
        Client1a.DistChannelName = 'Store Branded';
        //Client1a.EmailForInvoices
        Client1a.EmailForOrderConfirmations = 'paige.stajkowski@redwingshoe.com';
        Client1a.FaxNum = '256-878-4392';
        Client1a.ISMName = 'Dan McCauley';
        Client1a.ISMNum = '207';
        Client1a.ROMName = 'Not Applicable';
        Client1a.ROMNum = '-';
        Client1a.Responsible = 'MOVEX';
        Client1a.RtlAcctSpecialist = '-';
        Client1a.RtlAcctSpecialistName = 'NA';
        Client1a.RtlAcctSpecialistEmailAddress = 'mike@eatontechnology.com';
        Client1a.SearchKey = '35950';
        Client1a.ShippingDesc = 'Best Way';
        Client1a.ShippingMethodPref = 'BW';
        Client1a.Status = '20';
        Client1a.TelNum = '256-878-4392';
        Client1a.TierLevel = '3';
        Client1a.AgingNotDue = 'X';
        Client1a.Aging1To30 = 'X';
        Client1a.Aging31To60 = 'X';
        Client1a.Aging61To90 = 'X';
        Client1a.AgingOver90 = 'X';


        //  Create Client1 BillingContact  
        AT_AccountTeamSolution.AT_Contact BillingContacta = new AT_AccountTeamSolution.AT_Contact();

        BillingContacta.FirstName = 'Michael';
        BillingContacta.LastName = 'K';
        BillingContacta.Email = 'mk@email.com';
        BillingContacta.Phone = '666-666-6666';

        Client1a.BillingContact = BillingContacta;

        //  Create Client1 StoreContact  
        AT_AccountTeamSolution.AT_Contact StoreContacta = new AT_AccountTeamSolution.AT_Contact();

        StoreContacta.FirstName = 'John';
        StoreContacta.LastName = 'M';
        StoreContacta.Email = 'jm@email.com';
        StoreContacta.Phone = '777-777-7777';

        Client1a.StoreContact = StoreContacta;

        lCustomersA.add(Client1a);

        //  Initial webservice sync call 
        System.debug('JWL: lcustomersA size: ' + lCustomersA.size());
        AT_AccountTeamSolution.syncCustomer(lCustomersA, true);
        Test.stopTest();
    }

    //  This method creates the sample test data needed to execute the other functionality tests 
    static testMethod void createUserData(){

        //  Additional Required Fields:
        //Username,
        //Alias,
        //CommunityNickname,
        //TimeZoneSidKey,
        //LocaleSidKey,
        //EmailEncodingKey,
        //ProfileId,
        //LanguageLocaleKey
        

        string sTimeZoneSidKey = 'America/Chicago';
        string sLocaleSidKey = 'en_US';
        string sEmailEncodingKey = 'ISO-8859-1';
        string sProfileId = '00eA0000000uXnWIAU';
        string sLanguageLocaleKey = 'en_US';


        List<User> listUsers = new List<User>();
        User oUser1 = new User();
        User oUser2 = new User();
        User oUser3 = new User();
        User oUser4 = new User();

        oUser1.Username = 'tom.drewel@redwingshoe.com.testSample';
        oUser1.Email = 'tom.drewel@redwingshoe.com';
        oUser1.Alias = 'tdrew';
        oUser1.FirstName = 'Tom';
        oUser1.LastName = 'Drewel';
        oUser1.Title = 'Technical Trainer';
        oUser1.ProfileId = sProfileId;
        oUser1.TimeZoneSidKey = sTimeZoneSidKey;
        oUser1.LocaleSidKey = sLocaleSidKey;
        oUser1.EmailEncodingKey = sEmailEncodingKey;
        oUser1.LanguageLocaleKey = sLanguageLocaleKey;
        listUsers.add(oUser1);

        oUser2.Username = 'mike.tester@redwingshoe.com.testSample';
        oUser2.Email = 'mike.tester@redwingshoe.com';
        oUser2.Alias = 'mtester';
        oUser2.FirstName = 'Mike';
        oUser2.LastName = 'Tester';
        oUser2.Title = 'QA Rep';
        oUser2.ProfileId = sProfileId;
        oUser2.TimeZoneSidKey = sTimeZoneSidKey;
        oUser2.LocaleSidKey = sLocaleSidKey;
        oUser2.EmailEncodingKey = sEmailEncodingKey;
        oUser2.LanguageLocaleKey = sLanguageLocaleKey;
        listUsers.add(oUser2);

        oUser3.Username = 'jlannan@brandywinereps.com.testSample';
        oUser3.Email = 'jlannan@brandywinereps.com';
        oUser3.Alias = 'jlann';
        oUser3.FirstName = 'Justin';
        oUser3.LastName = 'Lannan';
        oUser3.Title = 'Agency Rep';
        oUser3.ProfileId = sProfileId;
        oUser3.TimeZoneSidKey = sTimeZoneSidKey;
        oUser3.LocaleSidKey = sLocaleSidKey;
        oUser3.EmailEncodingKey = sEmailEncodingKey;
        oUser3.LanguageLocaleKey = sLanguageLocaleKey;
        listUsers.add(oUser3);

        oUser4.Username = 'john.tester@redwingshoe.com.testSample';
        oUser4.Email = 'john.tester@redwingshoe.com';
        oUser4.Alias = 'jtester';
        oUser4.FirstName = 'John';
        oUser4.LastName = 'Tester';
        oUser4.Title = 'QA Rep';
        oUser4.ProfileId = sProfileId;
        oUser4.TimeZoneSidKey = sTimeZoneSidKey;
        oUser4.LocaleSidKey = sLocaleSidKey;
        oUser4.EmailEncodingKey = sEmailEncodingKey;
        oUser4.LanguageLocaleKey = sLanguageLocaleKey;
        listUsers.add(oUser4);

        insert listUsers;

    }*/

}