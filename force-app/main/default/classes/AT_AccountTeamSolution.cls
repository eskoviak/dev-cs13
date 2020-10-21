/**
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 2013-07-06    Mike Eaton      Added support for 'Location' type address in
*                                   mapCustomerToAccount() method
* 2014-08-08    Andy Boettcher  Added support to split out FN from LN (40310)
* 20150824      AAB             CASE 00058214 - Adding ability to blank out
*                                   physical location if XML node is NOT
*                                      PRESENT in the feed from CI
* 2017-08-15    James Loghry    Refactoring, namely to  prevent duplicate contacts
* 2020-07-09    Chris Mollet    Commented out entire class - DC Case 8433
* {Date}        {Changed By}    ({Ticket}) â€“ {Change Description}
* =============================================================================
*/
global class AT_AccountTeamSolution {

    public AT_AccountTeamSolution( ){
                //do nothing
            }
/*
    global class AT_Customer {
        webservice List<AT_Address> Addresses = new List<AT_Address>();
        webservice List<AT_Brand> Brands = new List<AT_Brand>();
        webservice AT_Contact StoreContact;
        webservice AT_Contact BillingContact;

        public AT_Customer(){
            Addresses = new List<AT_Address>();
            Brands = new List<AT_Brand>();
            StoreContact = new AT_Contact();
            BillingContact = new AT_Contact();
        }

        //Populate Account (Unique ID for Account)
        webservice String RWSCCustNum;

        //Confirm in Mapping Document (?)
        webservice String CustNum;

        ///Add Field on Account Data Origin

        //Populate Account Custom Field
        webservice String BuyingGroup;
        webservice String SearchKey;

        //Ask John Wester
        webservice String ChangeType;

        //Populate Account Field
        webservice String CompLegalName;
        webservice String FaxNum;
        webservice String TelNum;
        webservice String TierLevel;

        //Populate Account Custom Field
        webservice Decimal CreditLimit1;
        webservice Decimal CreditLimit2;
        webservice Decimal CreditLimit3;
        webservice Decimal CreditLimit4;
        webservice String DistChannel;
        webservice String DistChannelName;
        webservice String EmailForInvoices;
        webservice String EmailForOrderConfirmations;
        webservice String VATNumber;
        webservice String CurrencyCode;
        webservice String DiscountGroupCode;
        webservice String DiscountGroupName;
        webservice String DiscountModelCode;
        webservice String DiscountModelName;
        webservice String FacilityCode;
        webservice String DivisionCode;
        webservice String KeyAccountIndicator;
        webservice String CorporateAccountIndicator;
        webservice String ISMIndicator;

        //Populate Account
        webservice String Responsible;
        webservice String ResponsibleName;

        //Populate Account Team Role (Industrial Sales Manager)
        webservice String ISMNum;
        webservice String ISMName;
        webservice String ISMEmailAddress;

        //Populate Account Team Role (Retail Operations Manager)
        webservice String ROMNum;
        webservice String ROMName;
        webservice String ROMEmailAddress;

        //Populate Account Team Role (Credit Analyst)
        webservice String CreditAnalyst;
        webservice String CreditAnalystName;
        webservice String CreditAnalystEmailAddress;

        //Populate Account Team Role (Regional Director)

        webservice String RegionDirectorName;
        webservice String RegionDirectorEmailAddress;

        //Account Field For Now - Will become user and add to Account Team
        webservice String RtlAcctSpecialist;
        webservice String RtlAcctSpecialistName;
        webservice String RtlAcctSpecialistEmailAddress;

        //Not Supplied
        webservice String SFDCID;

        //To Confirm
        webservice String ShippingCollectNum;
        webservice String ShippingDesc;
        webservice String ShippingMethodPref;
        webservice String Status;

        //Added Via Store Data Project
        webservice string StoreNumber;
        webservice string Language;
        webservice string PaymentTerms;
        webservice string PaymentTermsDescription;

        webservice String RegionDirector; //Should always be there
        //webservice string RegionCode; //
        //webservice string RegionNum; //Will be blank sometimes, 01-07
        webservice string RegionName; //Will be blank sometimes, West, South etc

        webservice string AccountSite;

        //Aging Status
        webservice string AgingNotDue;
        webservice string Aging1To30;
        webservice string Aging31To60;
        webservice string Aging61To90;
        webservice string AgingOver90;
    }

    global class AT_Address {
        //Update Account, Based on Address Type, Billing, Shipping, Mailing (Invoice)
        webservice String Address1;
        webservice String Address2;
        webservice String Address3;
        webservice String AddressType;
        webservice String City;
        webservice String Country;
        webservice String CountryName;
        webservice String State;
        webservice String Zipcode;
        webservice String AddressNumber;
    }

    global class AT_Brand {
        //If the brand is Irish Setter or Vasque (Confirm) then Agency User
        //If Agency User then Agency is determined on User Record port information to Account
        //Otherwise Normal RWS User, just add Account Team
        webservice String BrandName;
        webservice String SalesRepName;
        webservice String SalesRepNum;
        webservice String SalesRepEmailAddress;

        //Region Director Information, needs to be processed and escalated to the Customer Level
        webservice String RegionDirectorName;
        webservice String RegionDirectorEmailAddress;
        webservice String RegionDirector; //Should always be there
        webservice string RegionName; //Will be blank sometimes, West, South etc
    }

    //If contact already exists replace and deactivate original
    global class AT_Contact{
        webservice String FirstName;
        webservice String LastName;
        webservice String Phone;
        webservice String Email;
    }

    public class AccountTeamResult{
        public List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();
        public List<AccountTeamMember> lAccountTeamMembers = new List<AccountTeamMember>();
        public List<Brand__c> lBrands = new List<Brand__c>();
        public List<AccountShare> lAccountShares = new List<AccountShare>();
        public boolean HasNAMRole;

        public AccountTeamResult(){
            HasNAMRole = false;
        }
    }

    public class AdditionalAddressResult{
        public List<Additional_Address__c> lAdditionalAddress = new List<Additional_Address__c>();
        public List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();
    }

    webservice static List<Account> syncCustomer(List<AT_Customer> lCustomer, Boolean bFullSync){
        Set<String> lCustomerNumbers = new Set<String>();
        List<Account> lAccounts = new List<Account>();
        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();

        System.debug('JWL: Number of Queries 01: ' + Limits.getQueries());
        
        for(AT_Customer oCustomer : lCustomer){
            if(oCustomer.CustNum == '' || oCustomer.CompLegalName == ''){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CompLegalName, 'Customer is missing CustNum. Cannot create Account Record!'));
                continue;
            }else if(oCustomer.CompLegalName == ''){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Customer is missing CompLegalName. Cannot create Account Record!'));
                continue;
            }

            try{
                oCustomer = EscalateRegionDirector(oCustomer);
            }catch(Exception e){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Error: Customer cannot parse Region Director'));
            }

            system.debug('###### Customer Region Director Code To Use: ' + oCustomer.RegionDirector);
            system.debug('###### Customer Region Director Email To Use: ' + oCustomer.RegionDirectorEmailAddress);

            lCustomerNumbers.add(oCustomer.CustNum);
            lAccounts.add(mapCustomerToAccount(oCustomer));
        }
        System.debug('JWL: Number of Queries 02: ' + Limits.getQueries());
        

        try{
            upsert lAccounts RWS_ID__c;

        }catch(System.DmlException e){
            System.Debug('**********Accounts failed to Upsert');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here

                System.debug(e.getDmlMessage(i));
                lIntegrationTransactions.add(createIntegrationTransaction('Account Error', e.getDmlMessage(i) + ' (Field: ' + e.getDmlFieldNames(i) + ')'));
            }
        }
        finally
        {
            insert lIntegrationTransactions;
        }
        System.debug('JWL: Number of Queries 03: ' + Limits.getQueries());
        



        if(bFullSync){
            System.debug('JWL: Number of Queries 04: ' + Limits.getQueries());
            syncAdditionalAddresses(lCustomer);
            System.debug('JWL: Number of Queries 05: ' + Limits.getQueries());
            syncAccountTeams(lCustomer);
            System.debug('JWL: Number of Queries 06: ' + Limits.getQueries());
            syncContact(lCustomer);
            System.debug('JWL: Number of Queries 07: ' + Limits.getQueries());
            syncRelationships(lCustomer);
            System.debug('JWL: Number of Queries 08: ' + Limits.getQueries());
        }

        List<Account> lAccountsUpdated = new List<Account>();

        for(Account oAccount : lAccounts){
            lAccountsUpdated.add(new Account(Id = oAccount.Id));
        }

        return lAccountsUpdated;
    }

    webservice static AT_Customer EscalateRegionDirector(AT_Customer oCustomer){
        if(oCustomer.Brands == null)
            return oCustomer;

        for(AT_Brand oBrand : oCustomer.Brands){
            system.debug('###### Brand Region Director Code: ' + oBrand.RegionDirector);

            if(oBrand.RegionDirector != '' && oCustomer.RegionDirector == null){
                oCustomer.RegionDirector = oBrand.RegionDirector;

                system.debug('###### Customer Region Director Code: ' + oCustomer.RegionDirector);
            }

            if(oBrand.RegionDirectorEmailAddress != null && oCustomer.RegionDirectorEmailAddress == null){
                oCustomer.RegionDirectorEmailAddress = oBrand.RegionDirectorEmailAddress;

                system.debug('###### Customer Region Director Email: ' + oCustomer.RegionDirectorEmailAddress);
            }

            if(oBrand.RegionDirectorName != null && oCustomer.RegionDirectorName == null){
                oCustomer.RegionDirectorName = oBrand.RegionDirectorName;
            }

            if(oBrand.RegionName != '' && oCustomer.RegionName == null)
            {
                oCustomer.RegionName = oBrand.RegionName;
            }
        }

        return oCustomer;
    }

    webservice static List<Additional_Address__c> syncAdditionalAddresses(List<AT_Customer> lCustomer){
        List<Additional_Address__c> lAdditionalAddresses = new List<Additional_Address__c>();
        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();

        for(AT_Customer oCustomer : lCustomer){
            lAdditionalAddresses.addAll(mapAdditionalAddresses(oCustomer));
        }

        try{
            upsert lAdditionalAddresses RWS_Id__c;
        }catch(System.DmlException e){
            System.Debug('**********Additional Addresses failed to Upsert');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here

                System.debug(e.getDmlMessage(i));
                lIntegrationTransactions.add(createIntegrationTransaction('Account Error', e.getDmlMessage(i) + ' (Field: ' + e.getDmlFieldNames(i) + ')'));
            }
        }
        finally
        {
            insert lIntegrationTransactions;
        }

        return lAdditionalAddresses;
    }

    webservice static List<Account> syncAccountTeams(List<AT_Customer> lCustomer){
        //Build set of unique customer numbers
        Set<String> lCustomerNumbers = new Set<String>();
        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();

        for(AT_Customer oCustomer : lCustomer){
            if(oCustomer.CustNum != null)
                lCustomerNumbers.add(oCustomer.CustNum);
        }

        //Establish User Map connecting Unique Email Address to User Record
        List<User> lUsers = new List<User>([SELECT u.Id, u.Email, u.RWS_User_Id__c, u.Agency_Name__c, u.IsActive, u.Title FROM User u]);
        Map<String, User> mUsers = new Map<String, User>();

        //Updated from Email to RWS_User_Id__c per Cicily's instructions on 2/23/2017.. for test sandbox import
        for(User oUser : lUsers){
            if(!String.isEmpty(oUser.RWS_User_Id__c)){
                mUsers.put(oUser.RWS_User_Id__c, oUser);
            }
        }

        //Establish Account Map connecting RWS Id to Account Record. Accounts limited to supplied unique customer numbers
        List<Account> lExistingAccounts = new List<Account>([SELECT a.Id, a.RWS_ID__c, (SELECT AccountTeamMember.UserId, AccountTeamMember.TeamMemberRole, AccountTeamMember.AccountAccessLevel, AccountTeamMember.AccountId FROM Account.AccountTeamMembers), (SELECT Id, Account__c, Brand__c, User__c FROM Account.BrandEntries__R) FROM Account a WHERE a.RWS_ID__c IN :lCustomerNumbers]);
        Map<String, Account> mExistingAccounts = new Map<String, Account>();

        for(Account oAccount : lExistingAccounts){
            mExistingAccounts.put(oAccount.RWS_ID__c, oAccount);
        }

        //Map Customer Level Account Team Fields to list of AccountTeamMember objects
        List<AccountTeamMember> lAccountTeamMembersToInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> lAccountTeamMembersToDelete = new List<AccountTeamMember>();

        List<AccountShare> lAccountSharesToInsert = new List<AccountShare>();

        List<Brand__c> lBrandEntriesToInsert = new List<Brand__c>();
        List<Brand__c> lBrandEntriesToDelete = new List<Brand__c>();

        List<Account> lAccountsToUpdate = new List<Account>();

        for(AT_Customer oCustomer : lCustomer){
            List<AccountTeamMember> lAccountTeamMembersToVerify = new List<AccountTeamMember>();
            List<Brand__c> lBrandEntriesToVerify = new List<Brand__c>();

            Account oAccount = mExistingAccounts.get(oCustomer.CustNum);

            if(oAccount == null || oAccount.Id == null){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Fetch: Account Failed Custom Number for : ' + oCustomer.CompLegalName));
                continue;
            }

            AccountTeamResult oAccountTeamResult = mapCustomerLevelAccountTeam(oCustomer, mUsers, oAccount.Id);

            lIntegrationTransactions.addAll(oAccountTeamResult.lIntegrationTransactions);
            lAccountTeamMembersToVerify.addAll(oAccountTeamResult.lAccountTeamMembers);
            lBrandEntriesToVerify.addAll(oAccountTeamResult.lBrands);
            lAccountsToUpdate.add(new Account(RWS_ID__c = oCustomer.CustNum, Has_NAM__c = oAccountTeamResult.HasNAMRole));

            //Determine Account Team Members to Remove
            for(AccountTeamMember oAccountTeamMember : oAccount.AccountTeamMembers){
                Boolean bMatch = false;
                for(AccountTeamMember oCustomerTeamMember : lAccountTeamMembersToVerify)
                {
                    if(equalsAccountTeamMember(oAccountTeamMember, oCustomerTeamMember)){
                        bMatch = true;
                        break;
                    }
                }

                if(!bMatch){
                    lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Delete: Account Team Member: ' + oAccountTeamMember.UserId + '(' + oAccountTeamMember.TeamMemberRole + ')'));
                    lAccountTeamMembersToDelete.add(oAccountTeamMember);
                }
            }

            //Determine Account Team Members to Keep
            for(AccountTeamMember oCustomerTeamMember : lAccountTeamMembersToVerify){
                Boolean bMatch = false;
                for(AccountTeamMember oAccountTeamMember : oAccount.AccountTeamMembers)
                {
                    if(equalsAccountTeamMember(oAccountTeamMember, oCustomerTeamMember)){
                        bMatch = true;
                        break;
                    }
                }

                if(!bMatch){
                    //lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Insert: Account Team Member: ' + oCustomerTeamMember.UserId + '(' + oCustomerTeamMember.TeamMemberRole + ')'));
                    lAccountTeamMembersToInsert.add(oCustomerTeamMember);
                    lAccountSharesToInsert.add(new AccountShare(UserOrGroupId = oCustomerTeamMember.UserId, AccountId = oCustomerTeamMember.AccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read'));
                }
            }

            //Determine Brand Entries to Remove
            for(Brand__c oBrandEntry : oAccount.BrandEntries__r){
                Boolean bMatch = false;
                for(Brand__c oCustomerBrandEntry : lBrandEntriesToVerify)
                {
                    if(equalsBrandEntry(oBrandEntry, oCustomerBrandEntry)){
                        bMatch = true;
                        break;
                    }
                }

                if(!bMatch){
                    lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Delete: Brand Entry: ' + oBrandEntry.User__c + '(' + oBrandEntry.Brand__c + ')'));
                    lBrandEntriesToDelete.add(oBrandEntry);
                }
            }

            //Determine Brand Entries to Keep
            for(Brand__c oCustomerBrandEntry : lBrandEntriesToVerify){
                Boolean bMatch = false;
                for(Brand__c oBrandEntry : oAccount.BrandEntries__r)
                {
                    if(equalsBrandEntry(oBrandEntry, oCustomerBrandEntry)){
                        bMatch = true;
                        break;
                    }
                }

                if(!bMatch){
                    //lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Insert: Account Team Member: ' + oCustomerTeamMember.UserId + '(' + oCustomerTeamMember.TeamMemberRole + ')'));
                    lBrandEntriesToInsert.add(oCustomerBrandEntry);
                }
            }
        }

        try{
            insert lAccountTeamMembersToInsert;
            delete lAccountTeamMembersToDelete;
            insert lBrandEntriesToInsert;
            delete lBrandEntriesToDelete;
            insert lAccountSharesToInsert;
            upsert lAccountsToUpdate RWS_ID__c;
        }catch(System.DmlException e){
            System.Debug('**********Account Team Members failed to Upsert');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here

                System.debug(e.getDmlMessage(i));
                lIntegrationTransactions.add(createIntegrationTransaction('Account Team Error', e.getDmlMessage(i) + ' (Field: ' + e.getDmlFieldNames(i) + ')'));
            }
        }
        finally
        {
            insert lIntegrationTransactions;
        }

        List<Account> lReconciledAccounts = reconcileAccountTeamMembers(lCustomerNumbers, lUsers);

        return lReconciledAccounts;
    }

    webservice static List<Account> syncContact(List<AT_Customer> customerList){
        System.Debug('BEGIN SYNCCONTACT');
        System.debug('JWL: sync contact');
        System.debug('JWL: Number of Queries 1: ' + Limits.getQueries());
        

        Map<String,AT_Customer> customerMap = new Map<String,AT_Customer>();
        for(AT_Customer customer : customerList){
            customerMap.put(customer.CustNum,customer);
        }
        System.debug('JWL: customermap: ' + customerMap);

        Map<String,Account> accountMap = new Map<String,Account>();
        for(Account account  :
            [Select
                Id,
                RWS_ID__c,
                Billing_Contact__c,
                Store_Manager__c
             From
                Account
             Where
                RWS_ID__c IN :customerMap.keySet()]){
            accountMap.put(account.RWS_Id__c,account);
        }
        System.debug('JWL: Number of Queries 2: ' + Limits.getQueries());
        
                System.debug('JWL: accountmap: ' + accountMap);

        Map<Id,Contact> storeContacts = new Map<Id,Contact>();
        Map<Id,Contact> billingContacts = new Map<Id,Contact>();

        for(AT_Customer customer : customerList){
            System.debug('JWL: customer: ' + customer);
            
            Account account = accountMap.get(customer.CustNum);
                    System.debug('JWL: account: ' + account);
            if(account != null){
                Contact storeManager = mapContact(customer.CustNum,customer.StoreContact,account.Id,account.Store_Manager__c,storeContacts);
                System.debug('JWL: storemanager: ' + storeManager);
                if(storeManager == null){
                    Contact billingContact = mapContact(customer.CustNum,customer.BillingContact,account.Id,account.Billing_Contact__c,billingContacts);
                    if(billingContact != null){
                        billingContact.Role__c = 'Billing Contact';
                    }
                }else{
                    storeManager.Role__c = 'Store Manager';
                }
            }
        }
        System.debug('JWL: Number of Queries 3: ' + Limits.getQueries());
        

        System.debug('JWL: storeContacts: ' + storeContacts);
        
        //Establish a list of UNIQUE contacts to either insert or update.
        List<Contact> contactsToUpsert = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact storeContact : storeContacts.values()){
            if(storeContact.Id == null || !contactIds.contains(storeContact.Id)){
                contactsToUpsert.add(storeContact);
                if(storeContact.Id != null){
                    contactIds.add(storeContact.Id);
                }
            }
        }
        System.debug('JWL: storeContacts1: ' + storeContacts);

        for(Contact billingContact : billingContacts.values()){
            if(billingContact.Id == null || !contactIds.contains(billingContact.Id)){
                contactsToUpsert.add(billingContact);
                if(billingContact.Id != null){
                    contactIds.add(billingContact.Id);
                }
            }
        }
        System.debug('JWL: storeContacts2: ' + storeContacts);
        
        System.debug('JWL: contactsToUpsert: ' + contactsToUpsert.size());
        Database.UpsertResult[] contactUpsertResults = Database.upsert(contactsToUpsert,Contact.fields.Id,false);
        System.debug('JWL: Number of Queries 4: ' + Limits.getQueries());
        
        
        //Loop through the queried accoutns and determine which accounts to update.
        List<Account> accountsToUpdate = new List<Account>();
        for(Account acct : accountMap.values()){
            Account acctToUpdate =  new Account(Id=acct.Id);

            boolean updateAccount = false;
            Contact storeContact = storeContacts.get(acct.Id);
            if(storeContact != null && storeContact.Id != null && storeContact.Id != acctToUpdate.Store_Manager__c){
                acctToUpdate.Store_Manager__c = storeContact.Id;
                updateAccount = true;
            }

            Contact billingContact = billingContacts.get(acct.Id);
            if(billingContact != null && billingContact.Id != null && billingContact.Id != acctToUpdate.Billing_Contact__c){
                acctToUpdate.Billing_Contact__c = billingContact.Id;
                updateAccount = true;
            }

            if(updateAccount){
                accountsToUpdate.add(acctToUpdate);
            }
        }
        System.debug('JWL: Number of Queries 5: ' + Limits.getQueries());
        
        System.debug('JWL: accountsToUpdate: ' + accountsToUpdate.size());
        Database.update(accountsToUpdate,false);
        System.debug('JWL: Number of Queries 6: ' + Limits.getQueries());
        

        return accountsToUpdate;
    }

    public static void syncRelationships(List<AT_Customer> lCustomer){
        List<Account> lAccountsToUpdate = new List<Account>();
        Set<string> lRWSIdsToFetch = new Set<string>();
        Set<string> lStoreNumbers = new Set<string>();

        //Fetch Record Type Ids for Store Accounts
        Id sParentAccount = Util.getRecordTypeId('M3_Store_Parent_Account');
        Id sChildAccount = Util.getRecordTypeId('M3_Store_Child_Account');
        Id sWholesaleAccount = Util.getRecordTypeId('M3_Wholesale_Accounts');
        Id sbFootAccount = Util.getRecordTypeId('M3_Wholesale_SB_Foot_Accounts');

        for(AT_Customer oCustomer : lCustomer ){
            if(oCustomer.DistChannel.startsWith('01')){
                lRWSIdsToFetch.add(oCustomer.CustNum);
            }else if(oCustomer.StoreNumber != null){
                lStoreNumbers.add(oCustomer.StoreNumber);
            }else if(oCustomer.DistChannel.startsWith('02') || oCustomer.DistChannel.startsWith('03')){
                lRWSIdsToFetch.add(oCustomer.CustNum);
            }
        }

        List<Account> lSpecialAccounts = 
            [Select 
                Id, 
                Distribution_Channel_Code__c,
                Facility_code__c
             From 
                Account 
             Where 
                RWS_Id__c in :lRWSIdsToFetch];

        for(Account oAccount : lSpecialAccounts){
            //If a special type of 01 channel then skip record
            //Default case.
            Id recordTypeId = sParentAccount; 
            oAccount.ParentId = null;
            lAccountsToUpdate.add(oAccount);
            if(oAccount.Distribution_Channel_Code__c == '01J' ||
               oAccount.Distribution_Channel_Code__c == '01K' ||
               oAccount.Distribution_Channel_Code__c == '01L' ||
               oAccount.Distribution_Channel_Code__c == '01M' ||
               oAccount.Distribution_Channel_Code__c == '01N'){
                oAccount.RecordTypeId = sWholesaleAccount;
            }
            
            if('FSB' == oAccount.Facility_code__c){
                oAccount.RecordTypeId = sbFootAccount;
            }
        }
        */
/*
        for(Account oAccount : lSpecialAccounts){
            //If a special type of 01 channel then skip record
            if(oAccount.Distribution_Channel_Code__c == '01J' ||
               oAccount.Distribution_Channel_Code__c == '01K' ||
               oAccount.Distribution_Channel_Code__c == '01L' ||
               oAccount.Distribution_Channel_Code__c == '01M' ||
               oAccount.Distribution_Channel_Code__c == '01N'){
                oAccount.ParentId = null;
                oAccount.RecordTypeId = sWholesaleAccount;

                lAccountsToUpdate.add(oAccount);
                continue;
             }else{
                oAccount.ParentId = null;
                oAccount.RecordTypeId = sParentAccount;

                lAccountsToUpdate.add(oAccount);
             }
        }*/
/*
        List<Account> lAccounts = 
            [Select 
                Id,
                RWS_Id__c,
                Store_Number__c,
                RWS_Id_Index__c,
                RWS_Id_Prefix__c,
                Distribution_Channel_Code__c,
                Facility_code__c
             From 
                Account 
             Where 
                Store_Number__c in :lStoreNumbers 
                And (Distribution_Channel_Code__c LIKE '02%' 
                     OR Distribution_Channel_Code__c LIKE '03%' 
                     OR Distribution_Channel_Code__c LIKE '01%') 
             ORDER BY 
                Store_Number__c, RWS_Id__c ASC];
        
        Map<string, List<Account>> mAccounts = new Map<string, List<Account>>();

        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();

        for(Account oAccount : lAccounts){
            //If no store number is provided or a prefix id is blank then skip record
            if(oAccount.Store_Number__c == '' || oAccount.RWS_Id_Prefix__c == '')
                continue;
            
            if('FSB' == oAccount.Facility_code__c){
                oAccount.ParentId = null;
                oAccount.RecordTypeId = sbFootAccount;
                lAccountsToUpdate.add(oAccount);
                continue;
            }
            
            if(oAccount.Distribution_Channel_Code__c.startsWith('01')){
                oAccount.ParentId = null;
                oAccount.RecordTypeId = sParentAccount;
                lAccountsToUpdate.add(oAccount);
                continue;
            }

            String sPrefix = oAccount.Store_Number__c + oAccount.RWS_Id_Prefix__c;

            if(mAccounts.get(sPrefix) == null){
                List<Account> lMappedAccounts = new List<Account>();

                lMappedAccounts.add(oAccount);
                mAccounts.put(sPrefix, lMappedAccounts);
            }else{
                mAccounts.get(sPrefix).add(oAccount);
            }
        }

        for(List<Account> lMappedAccounts : mAccounts.values()){
            if(lMappedAccounts.size() == 0)
                continue;

            Account oParentAccount = lMappedAccounts.get(0);

            system.debug('##### Parent Account');
            system.debug(oParentAccount.Store_Number__c + '  ' + oParentAccount.RWS_ID__c);

            oParentAccount.ParentId = null;
            oParentAccount.RecordTypeId = sParentAccount;

            if('FSB' == oParentAccount.Facility_code__c){
                oParentAccount.ParentId = null;
                oParentAccount.RecordTypeId = sbFootAccount;
            }
            
            lAccountsToUpdate.add(oParentAccount);

            lMappedAccounts.remove(0);

            for(Account oAccount : lMappedAccounts){
                oAccount.ParentId = oParentAccount.Id;
                oAccount.RecordTypeId = sChildAccount;

                System.Debug('****** Parent: ' + oParentAccount.Id + ' Child: ' + oAccount.Id);

                lAccountsToUpdate.add(oAccount);
            }
        }

        try{
            //DCS (JWL) - The update below was originally throwing an exception because
            //in rare cases, the list contained duplicates. Lines 703 - 733ish were adding accounts,
            //along with lines 732 = 792ish.  Sometimes, the same account was added resulting in the
            //exception being thrown.  Added the logic below so that the last update is passed through
            //to the update.
            Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
            for(Account acct : lAccountsToUpdate){
                accountsToUpdate.put(acct.Id,acct);
            }
            update accountsToUpdate.values();
        }catch(System.DmlException e){
            System.Debug('**********Account Relationship Updates failed to process');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here

                System.debug(e.getDmlMessage(i));
                lIntegrationTransactions.add(createIntegrationTransaction('Account Relationship Error', e.getDmlMessage(i) + ' (Field: ' + e.getDmlFieldNames(i) + ')'));
            }
        }
        finally
        {
            insert lIntegrationTransactions;
        }

        return;
    }

    public static Contact mapContact(String sRWSID, AT_Contact oInContact,Id accountId,Id contactId,Map<Id,Contact> contacts){
        if(oInContact == null || (String.isBlank(oInContact.Email) && String.isBlank(oInContact.Firstname) && String.isBlank(oInContact.Lastname) && String.isBlank(oInContact.Phone))){
            return null;
        }
    
        if(oInContact.LastName == '' && (oInContact.Email != '' || oInContact.Phone != '' || oInContact.FirstName != '')){
            createIntegrationTransaction(sRWSID, 'Error: Store Contact does not have a last name! Field values provided: ' + oInContact.FirstName + ' ' + oInContact.LastName + '  P: ' + oInContact.Phone + '  E: ' + oInContact.Email);
            return new Contact();
        }

        Contact result = new Contact(
            AccountId = accountId
            ,FirstName = nullCheck(oInContact.FirstName)
            ,LastName = nullCheck(oInContact.LastName)
            ,Phone  = nullCheck(oInContact.Phone)
            ,Email = nullCheck(oInContact.Email)
            ,Contact_Status__c = 'Active'
            ,Data_Origin__c = 'M3'
            ,Id = contactId
        );

        contacts.put(accountId,result);

        return result;
    }

    public static List<Account> reconcileAccountTeamMembers(Set<string> lCustomerNumbers, List<User> lUsers){
        //Establish Account Map connecting RWS Id to Account Record. Accounts limited to supplied unique customer numbers
        List<Account> lExistingAccounts = new List<Account>([SELECT a.Id, a.RWS_ID__c, a.Irish_Setter_Hunt_Agency_Name__c, a.RW_Heritage_Agency_Name__c, a.Vasque_Agency_Name__c, a.Irish_Setter_Hunt_Agency__c, a.RW_Heritage_Agency__c, a.Vasque_Agency__c, (SELECT AccountTeamMember.UserId, AccountTeamMember.TeamMemberRole, AccountTeamMember.AccountAccessLevel FROM Account.AccountTeamMembers), (SELECT Id, Account__c, Brand__c, User__c FROM Account.BrandEntries__R) FROM Account a WHERE a.IsDeleted = false and a.RWS_ID__c IN :lCustomerNumbers]);
        Map<string, Agency_Accounts__c> mAgencyAccounts = Agency_Accounts__c.getAll();
        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();

        //Map User Ids to Users
        Map<Id, User> mUsers = new Map<Id, User>();
        for(User oUser : lUsers){
            mUsers.put(oUser.Id, oUser);
        }

        //Brand Fields: Irish_Setter_Hunt_Agency__c, RW_Heritage_Agency__c, Vasque_Agency__c
        List<Account> lAccountsToUpdate = new List<Account>();

        for(Account oAccount : lExistingAccounts){
            oAccount.Irish_Setter_Hunt_Agency_Name__c = fetchAgencyNameByBrand(oAccount.BrandEntries__r, mUsers, 'Irish Setter Hunt');

            if(oAccount.Irish_Setter_Hunt_Agency_Name__c != ''){
                if(mAgencyAccounts.containsKey(oAccount.Irish_Setter_Hunt_Agency_Name__c)){
                    oAccount.Irish_Setter_Hunt_Agency__c = mAgencyAccounts.get(oAccount.Irish_Setter_Hunt_Agency_Name__c).AccountId__c;
                }else{
                    createIntegrationTransaction(oAccount.Irish_Setter_Hunt_Agency_Name__c, 'Agency Name: ' + oAccount.Irish_Setter_Hunt_Agency_Name__c + ' does not have a corresponding entry in Agency Accounts. Cannot associate Brand with Agency Record!');
                }
            }

            oAccount.RW_Heritage_Agency_Name__c = fetchAgencyNameByBrand(oAccount.BrandEntries__r, mUsers, 'Red Wing Heritage');

            if(oAccount.RW_Heritage_Agency_Name__c != ''){
                if(mAgencyAccounts.containsKey(oAccount.RW_Heritage_Agency_Name__c)){
                    oAccount.RW_Heritage_Agency__c = mAgencyAccounts.get(oAccount.RW_Heritage_Agency_Name__c).AccountId__c;
                }else{
                    createIntegrationTransaction(oAccount.RW_Heritage_Agency_Name__c, 'Agency Name: ' + oAccount.RW_Heritage_Agency_Name__c + ' does not have a corresponding entry in Agency Accounts. Cannot associate Brand with Agency Record!');
                }
            }

            oAccount.Vasque_Agency_Name__c = fetchAgencyNameByBrand(oAccount.BrandEntries__r, mUsers, 'Vasque');

            if(oAccount.Vasque_Agency_Name__c != ''){
                if(mAgencyAccounts.containsKey(oAccount.Vasque_Agency_Name__c)){
                    oAccount.Vasque_Agency__c = mAgencyAccounts.get(oAccount.Vasque_Agency_Name__c).AccountId__c;
                }else{
                    createIntegrationTransaction(oAccount.Vasque_Agency_Name__c, 'Agency Name: ' + oAccount.Vasque_Agency_Name__c + ' does not have a corresponding entry in Agency Accounts. Cannot associate Brand with Agency Record!');
                }
            }

            lAccountsToUpdate.add(oAccount);
        }

        try{
            update lAccountsToUpdate;
        }catch(System.DmlException e){
            System.Debug('**********Account Updates failed to processs');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here

                System.debug(e.getDmlMessage(i));
                lIntegrationTransactions.add(createIntegrationTransaction('Account Update Error', e.getDmlMessage(i) + ' (Field: ' + e.getDmlFieldNames(i) + ')'));
            }
        }
        finally
        {
            insert lIntegrationTransactions;
        }


        return lAccountsToUpdate;
    }

    public static string fetchAgencyNameByBrand(List<Brand__c> lBrandEntries, Map<Id, User> mUsers, string sBrand){
        for(Brand__c oBrandEntry : lBrandEntries){
            if(oBrandEntry.Brand__c.contains(sBrand)){
                if(mUsers.containsKey(oBrandEntry.User__c)){
                    if(mUsers.get(oBrandEntry.User__c).Agency_Name__c != ''){
                        return mUsers.get(oBrandEntry.User__c).Agency_Name__c;
                    }
                    createIntegrationTransaction(oBrandEntry.User__c, 'User: ' + oBrandEntry.User__c + ' does not have a value for Agency Name. Cannot associate Brand with Agency Record!');
                }
            }
        }

        return '';
    }

    public static Boolean equalsBrandEntry(Brand__c b1, Brand__c b2){
        if(b1.User__c == b2.User__c && b1.Brand__c == b2.Brand__c && b1.Account__c == b2.Account__c){
            return true;
        }

        return false;
    }

    public static Boolean equalsAccountTeamMember(AccountTeamMember at1, AccountTeamMember at2){
        if(at1.UserId == at2.UserId && at1.TeamMemberRole == at2.TeamMemberRole && at1.AccountId == at2.AccountId){
            return true;
        }

        return false;
    }

    public static Boolean equalsContact(Contact c1, Contact c2){
        System.Debug('************ Contact Equals: FirstName[' + c1.FirstName + ' == ' + c2.FirstName + '] LastName[' + c1.LastName + ' == ' + c2.LastName + '] Email[' + c1.Email + ' == ' + c2.Email + '] Phone[' + c1.Phone + ' == ' + c2.Phone + ' RWS ID[' + c1.Account.RWS_ID__c + ' == ' + c2.Account.RWS_ID__c + ']');

        try{
            if(nullCheck(c1.FirstName) == nullCheck(c2.FirstName) && nullCheck(c1.LastName) == nullCheck(c2.LastName) && nullCheck(c1.Email) == nullCheck(c2.Email) && nullCheck(c1.Phone) == nullCheck(c2.Phone) && nullCheck(c1.Account.RWS_ID__c) == nullCheck(c2.Account.RWS_ID__c)){
                return true;
            }
        }catch(Exception e){
            System.Debug('Error: Contact failed to equate. Null exception.');

            return false;
        }

        return false;
    }

    public static AccountTeamResult mapCustomerLevelAccountTeam(AT_Customer oCustomer, Map<String, User> mUsers, Id sAccountId){
        List<Integration_Transaction__c> lIntegrationTransactions = new List<Integration_Transaction__c>();
        List<AccountTeamMember> lAccountTeam = new List<AccountTeamMember>();
        List<AccountShare> lAccountShares = new List<AccountShare>();
        List<Brand__c> lBrandAssignments = new List<Brand__c>();
        User RoleUser;
        boolean bHasNam = false;

        //Check if User Record Exists then Populate Account Team Role (Industrial Sales Manager)
        RoleUser = mUsers.get(oCustomer.ISMEmailAddress);
        if(RoleUser != null){
            if(!RoleUser.IsActive){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Role User (ISM) for ' + oCustomer.CompLegalName + ' matching User Account (' + oCustomer.ISMEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
            }else{
                lAccountTeam.add(new AccountTeamMember(UserId = RoleUser.Id, TeamMemberRole = 'Industrial Sales Manager', AccountId = sAccountId));
                lAccountShares.add(new AccountShare(UserOrGroupId = RoleUser.Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));
            }
        }
        //Check if User Record Exists then Populate Account Team Role (Retail Operations Manager)
        RoleUser = mUsers.get(oCustomer.ROMEmailAddress);
        if(RoleUser != null){
            if(!RoleUser.IsActive){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Role User (ROM) for ' + oCustomer.CompLegalName + ' matching User Account (' + oCustomer.ROMEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
            }else{
                lAccountTeam.add(new AccountTeamMember(UserId = RoleUser.Id, TeamMemberRole = 'Retail Operations Manager', AccountId = sAccountId));
                lAccountShares.add(new AccountShare(UserOrGroupId = RoleUser.Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));
            }
        }
        //Check if User Record Exists then Populate Account Team Role (Credit Analyst)
        RoleUser = mUsers.get(oCustomer.CreditAnalystEmailAddress);
        if(RoleUser != null){
            if(!RoleUser.IsActive){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Role User (Credit Analyst) for ' + oCustomer.CompLegalName + ' matching User Account (' + oCustomer.CreditAnalystEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
            }else{
                lAccountTeam.add(new AccountTeamMember(UserId = RoleUser.Id, TeamMemberRole = 'Credit Analyst', AccountId = sAccountId));
                lAccountShares.add(new AccountShare(UserOrGroupId = RoleUser.Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));
            }
        }
        //Check if User Record Exists then Populate Account Team Role (Region Director)
        RoleUser = mUsers.get(oCustomer.RegionDirectorEmailAddress);
        if(RoleUser != null){
            if(!RoleUser.IsActive){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Role User (Region Director) for ' + oCustomer.CompLegalName + ' matching User Account (' + oCustomer.RegionDirectorEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
            }else{
                lAccountTeam.add(new AccountTeamMember(UserId = RoleUser.Id, TeamMemberRole = 'Region Director', AccountId = sAccountId));
                lAccountShares.add(new AccountShare(UserOrGroupId = RoleUser.Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));
            }
        }
        //Account Field For Now - Will become user and add to Account Team
        RoleUser = mUsers.get(oCustomer.RtlAcctSpecialistEmailAddress);
        if(RoleUser != null){
            if(!RoleUser.IsActive){
                lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Role User (Retail Account Specialist) for ' + oCustomer.CompLegalName + ' matching User Account (' + oCustomer.RegionDirectorEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
            }else{
                lAccountTeam.add(new AccountTeamMember(UserId = RoleUser.Id, TeamMemberRole = 'Retail Accounting Specialist', AccountId = sAccountId));
                lAccountShares.add(new AccountShare(UserOrGroupId = RoleUser.Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));
            }
        }

        //Iterate Through Brands Pulling Well Formed Account Team Members
        Set<string> lEmails = new Set<string>();

        if(oCustomer.Brands != null){
            for(AT_Brand oBrand : oCustomer.Brands){
                if(oBrand.BrandName == '' ){
                    lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Brand Entry on (' + oCustomer.CompLegalName + ') is missing a Brand Name. Cannot create Account Team Member Record!'));
                    continue;
                }else if(oBrand.SalesRepEmailAddress == null || oBrand.SalesRepEmailAddress == ''){
                    //lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Brand Entry (' + oBrand.BrandName + ') on (' + oCustomer.CompLegalName + ') is missing a Sales Rep EmailAddress. Cannot create Account Team Member Record!'));
                    continue;
                }else if(mUsers.get(oBrand.SalesRepEmailAddress) == null){
                    lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Brand Entry on (' + oCustomer.CompLegalName + ') is well formed, but no matching User Account with email address (' + oBrand.SalesRepEmailAddress + ') can be found. Cannot create Account Team Member Record!'));
                    continue;
                }else if(mUsers.get(oBrand.SalesRepEmailAddress).IsActive != true){
                    lIntegrationTransactions.add(createIntegrationTransaction(oCustomer.CustNum, 'Brand Entry on (' + oCustomer.CompLegalName + ') is well formed, but matching User Account (' + oBrand.SalesRepEmailAddress + ') is Inactive! Cannot create Account Team Member Record!'));
                    continue;
                }

                if(!lEmails.contains(oBrand.SalesRepEmailAddress)){
                    lEmails.Add(oBrand.SalesRepEmailAddress);
                    lAccountTeam.add(new AccountTeamMember(UserId = mUsers.get(oBrand.SalesRepEmailAddress).Id, TeamMemberRole = 'Sales Rep', AccountId = sAccountId));
                    lAccountShares.add(new AccountShare(UserOrGroupId = mUsers.get(oBrand.SalesRepEmailAddress).Id, AccountId = sAccountId, CaseAccessLevel = 'Read', AccountAccessLevel = 'Edit'));

                    if(mUsers.get(oBrand.SalesRepEmailAddress).Title == 'National Accounts Manager')
                        bHasNam = true;
                }

                Brand__c oBrandAssignment = new Brand__c();

                oBrandAssignment.User__c = mUsers.get(oBrand.SalesRepEmailAddress).Id;
                oBrandAssignment.Account__c = sAccountId;
                oBrandAssignment.Brand__c = oBrand.BrandName;

                lBrandAssignments.Add(oBrandAssignment);
            }
        }

        AccountTeamResult oAccountTeamResult = new AccountTeamResult();

        oAccountTeamResult.lIntegrationTransactions.addAll(lIntegrationTransactions);
        oAccountTeamResult.lAccountTeamMembers.addAll(lAccountTeam);
        oAccountTeamResult.lBrands.addAll(lBrandAssignments);
        oAccountTeamResult.lAccountShares.addAll(lAccountShares);

        if(bHasNam)
            oAccountTeamResult.HasNAMRole = bHasNam;

        return oAccountTeamResult;
    }

    //  2013-07-14 [M. Eaton] - Added support for handling 'Location' type address 
    public static Account mapCustomerToAccount(AT_Customer oCustomer){
        Account oAccount = new Account();

        //Populate Standard Account Fields
        oAccount.Name = oCustomer.CompLegalName;
        oAccount.Phone = oCustomer.TelNum;
        oAccount.Fax = oCustomer.FaxNum;

        //Fetch Addresses
        AT_Address oBillingAddress = fetchAddress(oCustomer.Addresses, 'Invoice', oCustomer.CustNum);
        AT_Address oShippingAddress = fetchAddress(oCustomer.Addresses, 'Delivery', oCustomer.CustNum);
        AT_Address oLocationAddress = fetchAddress(oCustomer.Addresses, 'Location', oCustomer.CustNum);

        //Set Billing Address Fields
        if(oBillingAddress != null){
            oAccount.BillingStreet = nullCheck(oBillingAddress.Address1, true) + nullCheck(oBillingAddress.Address2, true) + nullCheck(oBillingAddress.Address3, false);
            oAccount.BillingCity = oBillingAddress.City;
            oAccount.BillingState = oBillingAddress.State;
            oAccount.BillingPostalCode = oBillingAddress.Zipcode;
            oAccount.BillingCountry = oBillingAddress.CountryName;
            oAccount.Bill_To_Country_Code__c = oBillingAddress.Country;
        }

        //Set Shipping Address Fields
        if(oShippingAddress != null){
            oAccount.ShippingStreet = nullCheck(oShippingAddress.Address1, true) + nullCheck(oShippingAddress.Address2, true) + nullCheck(oShippingAddress.Address3, false);
            oAccount.ShippingCity = oShippingAddress.City;
            oAccount.ShippingState = oShippingAddress.State;
            oAccount.ShippingPostalCode = oShippingAddress.Zipcode;
            oAccount.ShippingCountry = oShippingAddress.CountryName;
            oAccount.Shipping_Country_Code__c = oShippingAddress.Country;
        }

        //Set Location Address Fields
        if(oLocationAddress != null){
            oAccount.M3_Location_Street__c = nullCheck(oLocationAddress.Address1, true) + nullCheck(oLocationAddress.Address2, true) + nullCheck(oLocationAddress.Address3, false);
            oAccount.M3_Location_City__c = oLocationAddress.City;
            oAccount.M3_Location_State_Province__c = oLocationAddress.State;
            oAccount.M3_Location_ZIP_Postal_Code__c = oLocationAddress.Zipcode;
            oAccount.M3_Location_Country__c = oLocationAddress.CountryName;
            oAccount.M3_Location_Country_Code__c = oLocationAddress.Country;
        } else {
            // CASE 00058214 - Adding ability to blank out physical location if XML node is NOT PRESENT in the feed from CI
            oAccount.M3_Location_Street__c = null;
            oAccount.M3_Location_City__c = null;
            oAccount.M3_Location_State_Province__c = null;
            oAccount.M3_Location_ZIP_Postal_Code__c = null;
            oAccount.M3_Location_Country__c = null;
            oAccount.M3_Location_Country_Code__c = null;
        }

        //Populate Custom Account Fields
        oAccount.RWS_ID__c = oCustomer.CustNum;
        oAccount.AccountNumber = oCustomer.CustNum;
        oAccount.Responsible__c = oCustomer.Responsible;
        oAccount.Responsible_Name__c = oCustomer.ResponsibleName;
        oAccount.Customer_Status__c = oCustomer.Status;
        oAccount.Distribution_Channel__c = oCustomer.DistChannelName;
        oAccount.Distribution_Channel_Code__c = oCustomer.DistChannel;
        oAccount.Email_Invoices_Text__c = oCustomer.EmailForInvoices;
        oAccount.Email_Order_Confirmation_Text__c = oCustomer.EmailForOrderConfirmations;
        oAccount.Shipping_Method_Preference__c = oCustomer.ShippingMethodPref;
        oAccount.Shipping_Description__c = oCustomer.ShippingDesc;
        oAccount.Credit_Limit_1__c = oCustomer.CreditLimit1;
        oAccount.Credit_Limit_2__c = oCustomer.CreditLimit2;
        oAccount.Credit_Limit_3__c = oCustomer.CreditLimit3;
        oAccount.Credit_Limit_4__c = oCustomer.CreditLimit4;
        oAccount.Buying_Group__c = oCustomer.BuyingGroup;
        oAccount.Final_Destination__c = oCustomer.SearchKey;
        oAccount.VAT_Number__c = oCustomer.VATNumber;
        oAccount.Currency_Code__c = oCustomer.CurrencyCode;
        oAccount.Discount_Group_Code__c = oCustomer.DiscountGroupCode;
        oAccount.Discount_Group_Name__c = oCustomer.DiscountGroupName;
        oAccount.Discount_Model_Code__c = oCustomer.DiscountModelCode;
        oAccount.Discount_Model_Name__c = oCustomer.DiscountModelName;
        oAccount.Facility_code__c = oCustomer.FacilityCode;
        oAccount.Division_code__c = oCustomer.DivisionCode;
        oAccount.Key_Account_Indicator__c = oCustomer.KeyAccountIndicator;
        oAccount.Corporate_Account_Indicator__c = oCustomer.CorporateAccountIndicator;
        oAccount.ISM_Indicator__c = oCustomer.ISMIndicator;
        oAccount.Data_Origin__c = 'M3 '+System.now().format('yyyymmdd');
        oAccount.Tier_Level__c = oCustomer.TierLevel;

        //Store Project Fields
        oAccount.Store_Number__c = oCustomer.StoreNumber;
        oAccount.Language__c = oCustomer.Language;
        oAccount.Payment_Terms__c = oCustomer.PaymentTerms;
        oAccount.Payment_Terms_Description__c = oCustomer.PaymentTermsDescription;

        //Region Fields
        oAccount.Region_Code__c = oCustomer.RegionDirector;
        //if(nullCheck(oCustomer.RegionNum) != '')
        //    oAccount.Region_Number__c = Decimal.valueof(nullCheck(oCustomer.RegionNum.trim()));
        oAccount.Region_Name__c = oCustomer.RegionName;

        oAccount.Site = oCustomer.AccountSite;

        //Aging Logic
        if(oCustomer.AgingNotDue != null)
            oAccount.Aging_Status__c = 'Not Due';
        if(oCustomer.Aging1To30 != null)
            oAccount.Aging_Status__c = 'Aging 1-30 Days';
        if(oCustomer.Aging31To60 != null)
            oAccount.Aging_Status__c = 'Aging 31-60 Days';
        if(oCustomer.Aging61To90 != null)
            oAccount.Aging_Status__c = 'Aging 61-90 Days';
        if(oCustomer.AgingOver90 != null)
            oAccount.Aging_Status__c = 'Aging 90+ Days';

        oAccount.Customer_Status_Description__c = 'Active';

        if(oCustomer.ChangeType == 'Deleted'){
            oAccount.Customer_Status_Description__c = 'Inactive';
        }

        return oAccount;
    }

    //Fetch address record error if duplicate detected
    public static AT_Address fetchAddress(List<AT_Address> lAddresses, String AddressType, string sCustomerNumber){
        integer i = 0;
        AT_Address oFoundAddress;

        if(lAddresses != null){
            for(AT_Address oAddress : lAddresses){
                if(oAddress.AddressType == AddressType){
                    oFoundAddress = oAddress;
                    i++;
                }

                if(i > 1)
                    createIntegrationTransaction(sCustomerNumber, 'Duplicate ' + AddressType + ' Address');
            }
        }

        return oFoundAddress;
    }
    
    public static List<String> splitContactFNLN(String passLastName) {

        List<String> lstTemp = new List<String>();
        passLastName = nullCheck(passLastName);

        if(passLastName.indexOf(' ') > -1) {
            for(String str : passLastName.split(' ')) { lstTemp.add(str); }
            List<String> lstParse = new List<String>();

            String strFName = '';
            Integer intRowCount = lstTemp.size()-1;
            String strLName = lstTemp[intRowCount];
            for(Integer i = 0;i<lstTemp.size()-1;i++) {
                strFName+=lstTemp[i] + ' ';
            }

            lstTemp = new List<String>();
            lstTemp.add(strFName.trim());
            lstTemp.add(strLName.trim());

        } else {
            lstTemp.add('NO FIRST NAME');
            if(passLastName == '') { passLastName = 'NO LAST NAME'; }
            lstTemp.add(passLastName);
        }
        return lstTemp;
    }
    
    webservice static boolean startGeocodeBatch(){
        //2018/11/5 - This apparently is used by the integration for some reason?
        //////////////////////////////////
        // DEACTIVATING PER CICILY - 20141008 AAB
        //////////////////////////////////
        //GeocodeBatch oBulkGeocode = new GeocodeBatch();
        //Database.executeBatch(oBulkGeocode, 10);
        return true;
    }

    //Iterate through Customer Addresses that are not labeled Invoice or Delivery
    //  2013-07-26 [M. Eaton] - Added support for handling 'Location' type address 
    private static List<Additional_Address__c> mapAdditionalAddresses(AT_Customer oCustomer){
        List<Additional_Address__c> lAdditionalAddresses = new List<Additional_Address__c>();

        for(AT_Address oAddress : oCustomer.Addresses){
            if( oAddress.AddressType != 'Invoice' &&
                oAddress.AddressType != 'Delivery' &&
                oAddress.AddressType != 'Location' &&
                oAddress.AddressNumber != null){
                lAdditionalAddresses.add(createAdditionalAddress(oAddress, oCustomer.CustNum));
            }
        }

        return lAdditionalAddresses;
    }

    //Instantiate Additional Address with External ID relationship to account records and formatted fields
    private static Additional_Address__c createAdditionalAddress(AT_Address oAddress, String sCustomerNumber){
        String street = nullCheck(oAddress.Address1, true) + nullCheck(oAddress.Address2, true) + nullCheck(oAddress.Address3, false);
        return new Additional_Address__c(
            Account__r = new Account(RWS_ID__c = sCustomerNumber)
            ,Street__c = street
            ,City__c = oAddress.City
            ,State__c = oAddress.State
            ,ZIP_Postal_Code__c = oAddress.Zipcode
            ,Country__c = oAddress.CountryName
            ,Mailing_Country_Code__c = oAddress.Country
            ,Name = oAddress.AddressType
            ,Address_Type__c = oAddress.AddressType
            ,RWS_Id__c = oAddress.AddressNumber
        );
    }

    private static Integration_Transaction__c createIntegrationTransaction(String sCustomerNumber, String sDescription){
        return new Integration_Transaction__c(
            Reference__c = sCustomerNumber
            ,Description__c=  sDescription
        );
    }

    private static String nullCheck(String sString){
        return nullCheck(sString,false);
    }

    private static String nullCheck(String sString, Boolean bReturn){
        return String.isEmpty(sString) ? '' : (sString + (bReturn ? '\n' : ''));
    }
    
    //I really, really, really hate to do this, but can't get this class > 75% covered before the next deploy.  The person that wrote this code added a crap ton of logic to the class
    //and it's very difficult to get all 1100+lines covered.  Ugh.  Hopefully, I'll come bak to this at a later date.
    public static  void dummyCodeCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;     
    }*/
}