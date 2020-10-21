public without sharing class RWS_ContactTrigger_Handler {
    private static final Id recordtypeId = [Select Id from RecordType where Name = 'Business Partner'].Id;
    
    //private static final Id profileId = [select id from Profile where name = 'System Administrator' limit 1].Id;

    public static final String STR_PRIMARY = 'Primary';
    public static final String STR_PRIMARY_BILLING = 'Primary & Billing';
    public static final String STR_BILLING = 'Billing';

    public static Map<String, String> primaryConToAccountFieldMap = new Map<String, String>{ 
                'FirstName' => 'Primary_Contact_First_Name__c', 
                'LastName' => 'Primary_Contact_Last_Name__c',
                'Phone' => 'Primary_Contact_Phone__c',
                'Email'=> 'Primary_Contact_Email__c',
                'Title' => 'Primary_Contact_Title__c',
                'Role__c' => 'Primary_Contact_Role__c' ,
                'MailingStreet' => 'Primary_Contact_Mailing_Street__c',
                'MailingCity' => 'Primary_Contact_Mailing_City__c',
                'MailingState' => 'Primary_Contact_Mailing_State_Province__c',
                'MailingPostalCode' => 'Primary_Contact_Mailing_Zip_Postal_Code__c',
                'MailingCountry' => 'Primary_Contact_Mailing_Country__c'
            };

    public static Map<String, String> billingConToAccountFieldMap = new Map<String, String>{ 
                'FirstName' => 'Billing_Contact_First_Name__c', 
                'LastName' => 'Billing_Contact_Last_Name__c',
                'Phone' => 'Billing_Contact_Phone__c',
                'Email'=> 'Billing_Contact_Email__c',
                'Title' => 'Billing_Contact_Title__c',
                'Role__c' => 'Billing_Contact_Role__c' ,
                'MailingStreet' => 'Billing_Contact_Mailing_Street__c',
                'MailingCity' => 'Billing_Contact_Mailing_City__c',
                'MailingState' => 'Billing_Contact_Mailing_State_Province__c',
                'MailingPostalCode' => 'Billing_Contact_Mailing_Zip_Postal_Code__c',
                'MailingCountry' => 'Billing_Contact_Mailing_Country__c'
            };

    public static Map<String, String> conToUserFieldMap = new Map<String, String>{ 
                'FirstName' => 'FirstName', 
                'LastName' => 'LastName',
                'Phone' => 'Phone',
                'Email'=> 'Email',
                'Title' => 'Title',
                'MailingStreet' => 'Street',
                'MailingCity' => 'City',
                'MailingState' => 'State',
                'MailingPostalCode' => 'PostalCode',
                'MailingCountry' => 'Country'};

    /******************************************************************************
    * beforeInsert
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on Before Insert
    * @param: List<Contact> newRecords
    * @return: None.
    ******************************************************************************/ 
    public static void beforeInsert(List<Contact> newRecords) {
        setAddressOnContact(newRecords, null, false);
    }

    /******************************************************************************
    * afterInsert
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on After Insert
    * @param: List<Contact> newRecords
    * @return: None.
    ******************************************************************************/ 
    public static void afterInsert(List<Contact> newRecords) {
        publishContacts(newRecords, null, false);
        copyFieldsOnAccount(newRecords, false);
        updateBPCOnAccount(newRecords, null, false);
        //AfterInsertUpdateLogic(newRecords);
    }

    
    /******************************************************************************
    * beforeUpdate
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on Before Update, 
    * @param: List<Contact> newRecords, Map<Id, Contact> oldRecords
    * @return: None.
    ******************************************************************************/ 
    /*
    public static void beforeUpdate(List<Contact> newRecords, Map<Id, Contact> oldRecords) {
        updateBPCOnAccount(newRecords, oldRecords, true);
    }
    */

    
    /******************************************************************************
    * afterUpdate
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on After Update, 
    * @param: List<Contact> newRecords, Map<Id, Contact> oldRecords
    * @return: None.
    ******************************************************************************/ 
    public static void afterUpdate(List<Contact> newRecords, Map<Id, Contact> oldRecords) {
        publishContacts(newRecords, oldRecords, true);
        copyFieldsOnAccount(newRecords, false);
        copyContactDataOnUser(newRecords, oldRecords);
        updateBPCOnAccount(newRecords, oldRecords, true);
        //AfterInsertUpdateLogic(newRecords);
        
        //copied from old trigger
        new ITriggers().bind(ITriggers.Evt.afterUpdate, new ContactCreateChatterUser()).manage(); 
    }

    /******************************************************************************
    * afterDelete
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on After Delete
    * @param: List<Contact> oldRecords
    * @return: None.
    ******************************************************************************/ 
    public static void afterDelete(List<Contact> oldRecords) {
        copyFieldsOnAccount(oldRecords, true);
    }
    
    //Commented out per Cicily 07092020 - CAM Demand Chain
    /*private static void AfterInsertUpdateLogic(List<Contact> newRecords) {
        APEX_Trigger_Settings__c triggerSetting = APEX_Trigger_Settings__c.getValues('geoLocationContact');
        if(triggerSetting == null || triggerSetting.IsActive__c){
            List<Account> accounts = new List<Account>();
            Map<Id,Contact> contactsToDelete = new Map<Id,Contact>();
            for(Contact c : [Select MailingLongitude,MailingLatitude,Account.Id,Account.Data_com_Longitude__c,Account.Data_com_Latitude__c 
                             From Contact Where Id in :newRecords And RecordType.DeveloperName='M3_Contact']){
                if(c.MailingLongitude != null && c.MailingLatitude != null){
                    if(c.Account.Data_com_Longitude__c != c.MailingLongitude || c.Account.Data_com_Latitude__c != c.MailingLatitude){
                        c.Account.Data_com_Longitude__c = c.MailingLongitude;
                        c.Account.Data_com_Latitude__c = c.MailingLatitude;*/
                        /* code was already commented out in the old trigger, 3/8/2019 removed the unused fields from select
                        c.Account.M3_Location_City__c = c.MailingCity;  
                        c.Account.M3_Location_Country_Code__c = c.MailingCountry;
                        c.Account.M3_Mailing_State_Province__c  = c.MailingState;
                        c.Account.M3_Location_Street__c = c.MailingStreet;
                        c.Account.M3_Location_ZIP_Postal_Code__c = c.MailingPostalCode;
                        c.Account.Longitude__c = c.MailingLongitude;
                        c.Account.Latitude__c = c.MailingLatitude;
                        //c.Account.Geocode_Status__c = 'Success';*/
                        /*accounts.add(c.Account);
                    }
                    contactsToDelete.put(c.Id,c);
                }
            }
    
            if(!accounts.isEmpty()){
                update accounts;
            }
    
            if(!contactsToDelete.values().isEmpty()){
                try{
                    delete contactsToDelete.values();
                }catch(DMLException e){}
            }
        }
    }*/

    private static void setAddressOnContact(List<Contact> newRecords, Map<Id, Contact> oldRecords, Boolean isUpdate) {
        List<Contact> relevantContacts = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact c : newRecords) {
        }

        for(Contact c : newRecords) {
            if(c.AccountId == null) continue;

            if(c.Address_same_as_Accounts__c == 'Different' || 
                c.Address_same_as_Accounts__c == 'Same as Account') continue;

            relevantContacts.add(c);
            accountIds.add(c.AccountId);
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [select Id, RecordType.Name, 
                IA_Physical_Location_City__c,
                IA_Physical_Location_Address_Line_1__c,
                IA_Physical_Location_Address_Line_2__c,
                IA_Physical_Location_Address_Line_3__c,
                IA_Physical_Location_State_Province__c,
                IA_Physical_Location_ZIP_Postal_Code__c,
                IA_Physical_Location_Country__c, 
                RWfB_Billing_Address_City__c,
                RWfB_Billing_Address_Line_1__c,
                RWfB_Billing_Address_Line_2__c,
                RWfB_Billing_Address_Line_3__c,
                RWfB_Billing_Address_State_Province__c,
                RWfB_Billing_Address_ZIP_Postal_Code__c,
                RWfB_Billing_Address_Country__c

             from Account where Id in :accountIds]
        );

        // List<SelectOption> stateOptions = RWS_UtilityClass.getStates();
        // List<SelectOption> countryOptions = RWS_UtilityClass.getCountries();

        // Map<String, String> statesMap = new Map<String, String>(); 
        // for(SelectOption so : stateOptions) {
        //     statesMap.put(so.getValue(), so.getLabel());
        // }

        // Map<String, String> countriesMap = new Map<String, String>(); 
        // for(SelectOption so : countryOptions) {
        //    countriesMap.put(so.getValue(), so.getLabel());
        // }

        for(Contact c : relevantContacts) {
            Account acc = accountsMap.get(c.AccountId);

            if(acc == null) continue;

            if(acc.RecordType.Name != 'Business Partner Community') continue;

            if(c.Address_same_as_Accounts__c == 'Same as Physical') {
                if(!(  String.isBlank(acc.IA_Physical_Location_City__c) && 
                    String.isBlank(acc.IA_Physical_Location_Address_Line_1__c) && 
                    String.isBlank(acc.IA_Physical_Location_Address_Line_2__c) && 
                    String.isBlank(acc.IA_Physical_Location_Address_Line_3__c) && 
                    String.isBlank(acc.IA_Physical_Location_State_Province__c) && 
                    String.isBlank(acc.IA_Physical_Location_ZIP_Postal_Code__c) && 
                    String.isBlank(acc.IA_Physical_Location_Country__c) )) {

                    c.MailingCity = acc.IA_Physical_Location_City__c; 
                    c.MailingStreet = (String.isBlank(acc.IA_Physical_Location_Address_Line_1__c) ? '' : acc.IA_Physical_Location_Address_Line_1__c + '\n') + 
                                        (String.isBlank(acc.IA_Physical_Location_Address_Line_2__c) ? '' : acc.IA_Physical_Location_Address_Line_2__c + '\n') + 
                                        (String.isBlank(acc.IA_Physical_Location_Address_Line_3__c) ? '' : acc.IA_Physical_Location_Address_Line_3__c);

                    c.MailingState = acc.IA_Physical_Location_State_Province__c;
                    c.MailingPostalCode = acc.IA_Physical_Location_ZIP_Postal_Code__c;
                    c.MailingCountry = acc.IA_Physical_Location_Country__c;
                }
            } else if(c.Address_same_as_Accounts__c == 'Same as Billing') {

                if(!(  String.isBlank(acc.RWfB_Billing_Address_City__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_Line_1__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_Line_2__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_Line_3__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_State_Province__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_ZIP_Postal_Code__c) && 
                    String.isBlank(acc.RWfB_Billing_Address_Country__c) )) {

                    c.MailingCity = acc.RWfB_Billing_Address_City__c; 
                    c.MailingStreet = (String.isBlank(acc.RWfB_Billing_Address_Line_1__c) ? '' : acc.RWfB_Billing_Address_Line_1__c + '\n') + 
                                        (String.isBlank(acc.RWfB_Billing_Address_Line_2__c) ? '' : acc.RWfB_Billing_Address_Line_2__c + '\n') + 
                                        (String.isBlank(acc.RWfB_Billing_Address_Line_3__c) ? '' : acc.RWfB_Billing_Address_Line_3__c);

                    c.MailingState = acc.RWfB_Billing_Address_State_Province__c;
                    c.MailingPostalCode = acc.RWfB_Billing_Address_ZIP_Postal_Code__c;
                    c.MailingCountry = acc.RWfB_Billing_Address_Country__c;
                }
            }

        }
    }



    private static void updateBPCOnAccount(List<Contact> newRecords, Map<Id, Contact> oldRecords, Boolean isUpdate) {
        List<Contact> relevantContacts = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact c : newRecords) {
            if( c.AccountId != null && 
                (!(String.isBlank(c.MailingCity) || String.isBlank(c.MailingStreet)
                     || String.isBlank(c.MailingCountry)
                      || String.isBlank(c.MailingPostalCode)
                       || String.isBlank(c.MailingState)))
                && ( c.Contact_Identifier__c == 'Billing' || 
                     c.Contact_Identifier__c == 'Primary & Billing' || 
                     (isUpdate && c.Contact_Identifier__c != oldRecords.get(c.Id).Contact_Identifier__c))

                && !String.isBlank(c.Email)
            ) {
                relevantContacts.add(c);
                accountIds.add(c.AccountId);
            }
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [select Id, HasBillingContact_BPC__c, RecordType.Name, Email_Application_To__c from Account where Id in :accountIds]
        );

        for(Contact c : relevantContacts) {
            Account acc = accountsMap.get(c.AccountId);

            if(acc == null) continue;

            if(acc.RecordType.Name != 'Business Partner Community') continue;

            if(c.Contact_Identifier__c == 'Billing' || c.Contact_Identifier__c == 'Primary & Billing') {
                if(acc.HasBillingContact_BPC__c) {
                    if(String.isBlank(acc.Email_Application_To__c)) {
                        acc.Email_Application_To__c = c.Email;
                    }
                } else {
                    acc.HasBillingContact_BPC__c = true;
                    acc.BillingContactID__c = c.Id;

                    if(String.isBlank(acc.Email_Application_To__c)) {
                        acc.Email_Application_To__c = c.Email;
                    }
                }
            } else {
                acc.HasBillingContact_BPC__c = false;
                acc.BillingContactID__c = null;
            }
        }

        update accountsMap.values();
    }

    private static void copyContactDataOnUser(List<Contact> newRecords, Map<Id, Contact> oldRecords)  {
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();

        for(Contact c : newRecords) {

            Contact oc = oldRecords.get(c.Id);

            Boolean isChanged = false;
            for(String cf : conToUserFieldMap.keySet()) {
                Object v = c.get(cf);
                Object ov = oc.get(cf);

                if(v != ov) {
                    isChanged = true;
                    break;
                }
            }


            if(isChanged) {
                contactsMap.put(c.Id, c);
            }
        }

        if(contactsMap.isEmpty()) return;

        String fields = '';

        for(String uf : conToUserFieldMap.values()) {
            if(fields != '') fields += ', ';

            fields += uf;
        }

        Set<Id> contactIds = contactsMap.keySet();

        List<User> users = Database.query('select Id, ContactId, ' + fields + ' from User where ContactId in :contactIds');

        if(users.isEmpty()) return;

        for(User u : users) {
            if(u.ContactId == null) continue;

            Contact c = contactsMap.get(u.ContactId);

            if(c == null) continue;

            for(String cf : conToUserFieldMap.keySet()) {
                String uf = conToUserFieldMap.get(cf);

                String value = (String) c.get(cf);

                if(value == null) continue;

                u.put(uf, c.get(cf));
            }
        }

        String usersJSON = JSON.serialize(users);
        updateUsers(usersJSON);
    }

    @future
    public static void updateUsers(String usersJSON) {
        List<User> users = (List<User>) JSON.deserialize(usersJSON, List<User>.class);

        try {
            update users;    
        } catch(exception e) {}
        
    }

    private static Boolean RUN_ONCE = true;
    private static void publishContacts(List<Contact> newRecords, Map<Id, Contact> oldRecords, Boolean isUpdate) {
        System.Debug('Begin RWS_ContactTrigger_Handler.publishContacts ********' );

        //if(UserInfo.getProfileId() == ProfileId) return;

        Set<Id> conIdSet = new Set<Id>();
        for (Contact con : newRecords){
             if(con.RecordTypeId == recordtypeId){
                    conIdSet.add(con.Id);
             }
        }     
         
        if(conIdSet.isEmpty()) return;

        List<Contact> conList = [select id,Publish_Status__c,
                        Outbound_Message_Type__c,
                        Active__c, RecordTypeId, 
                        Account.Active__c,
                        Account.Publish_Status__c from Contact 
                    where Id in :conIdSet];

        if(conList.isEmpty()) return;

        for(Contact conObj : conList){
            
            if((conObj.Publish_Status__c == 'ReadyToPublish') || (conObj.Publish_Status__c == 'Waiting') ||
                (isUpdate && conObj.Publish_Status__c == 'Published' 
                    && conObj.Publish_Status__c != oldRecords.get(conObj.id).Publish_Status__c))
                continue;

            if(conObj.Account.Active__c == true && conObj.Account.Publish_Status__c == 'Published'){
                conObj.Outbound_Message_Type__c = 'Update Contact';
                conObj.Publish_Status__c = 'ReadyToPublish';  
            }

            else {
                conObj.Publish_Status__c = 'Waiting';   
            }
               
        }

        if(RUN_ONCE){
            RUN_ONCE = false;
            update conList;
        }
        System.Debug('End RWS_ContactTrigger_Handler.publishContacts ********' );
    }

    private static Boolean RUN_ONCE_CFOA = true ;
    private static void copyFieldsOnAccount(List<Contact> contacts, Boolean isDelete )  {
        Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap = new Map<Id, Set<Id>>();

        copyFieldsOnAccount(contacts, contactIdToRelatedAccountIdsMap, isDelete);
    }

    public static void copyFieldsOnAccount(List<Contact> contacts, 
                                            Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap, 
                                            Boolean isDelete)  { 
        
        if(!RUN_ONCE_CFOA) return;
        Set<Id> accountIds = new Set<Id>();
        List<Account> accounts = new List<Account>();

        // Iterate over contacts 
        for(Contact con : contacts ) {  

            Set<Id> relatedAccountIds = contactIdToRelatedAccountIdsMap.get(con.Id);

            if(relatedAccountIds == null) {
                relatedAccountIds = new Set<Id>();
                relatedAccountIds.add(con.AccountId);
            }

            for(Id accountId : relatedAccountIds) {
                Boolean accountChanged = false;
                Account ac = new Account(Id = accountId);

                // When contact is primary contact 
                if((con.Contact_Identifier__c == STR_PRIMARY_BILLING || con.Contact_Identifier__c == STR_PRIMARY) && !accountIds.contains(accountId) )  {
                    for( String key : primaryConToAccountFieldMap.keySet() ) {
                        // put value in account from Contact in case of Insert/Update other wise set null 
                        ac.put(primaryConToAccountFieldMap.get(key), ( isDelete ? null : con.get(key)) ) ;
                    }
                    accountChanged = true;
                }

                // When contact is primary&Billing OR Billing contact 
                if((con.Contact_Identifier__c == STR_PRIMARY_BILLING || con.Contact_Identifier__c == STR_BILLING) && !accountIds.contains(accountId) ) {
                    for( String key : billingConToAccountFieldMap.keySet() ) {
                        // put value in account from Contact in case of Insert/Update other wise set null 
                        ac.put(billingConToAccountFieldMap.get(key), ( isDelete ? null : con.get(key)) );
                    }

                    accountChanged = true;
                }

                if(accountChanged) {
                    accountIds.add(accountId);
                    accounts.add(ac);
                }
            }
        }
        
        // Update Accounts 
        if(accounts.size() > 0 ) {
            RUN_ONCE_CFOA = false ;
            update accounts ;
        }
    

    }

}