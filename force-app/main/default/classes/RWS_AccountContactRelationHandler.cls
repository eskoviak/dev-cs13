public class RWS_AccountContactRelationHandler {
    private static Id BusinessPartnerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
    private static Id GeneralContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General Contact').getRecordTypeId();


    private static Map<Id, Set<Id>> getContactIdToRelatedAccountIdsMap(List<AccountContactRelation> newRecords) {
        Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap = new Map<Id, Set<Id>>();

        for(AccountContactRelation acr : newRecords) {

            Set<Id> relatedAccountIds = contactIdToRelatedAccountIdsMap.get(acr.ContactId);
            if(relatedAccountIds == null) {
                relatedAccountIds = new Set<Id>();
                contactIdToRelatedAccountIdsMap.put(acr.ContactId, relatedAccountIds);
            }

            relatedAccountIds.add(acr.AccountId);
        }

        return contactIdToRelatedAccountIdsMap;
    }

    /******************************************************************************
    * onAfterInsert
    * @author: Kotapati Keerthi (Magnet 360)
    * @date: 11/22/2016
    * @description: Handles actions on After Insert
    * @param: List< AccountContactRelation> newRecords
    * @return: None.
    ******************************************************************************/ 
    public static void onAfterInsert(List<AccountContactRelation> newRecords) {
        Set<Id> accountid = new Set<Id>();
        Set<Id> contactid = new Set<Id>();

        
        Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap = getContactIdToRelatedAccountIdsMap(newRecords);

        for(AccountContactRelation acr : newRecords) {
           // if(acr.IsDirect == false) {
                accountid.add(acr.AccountId);
                contactid.add(acr.ContactId);
            //}
        }
        if(!accountid.isEmpty()) {
            shareIAAccounts(accountid, contactId);
            copyFieldsOnAccount(contactId, contactIdToRelatedAccountIdsMap, false);
            updateBPCOnAccount(newRecords, contactId, accountid);
        }
    }

    public static void onAfterDelete(List<AccountContactRelation> newRecords) {
        Set<Id> contactid = new Set<Id>();

        Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap = getContactIdToRelatedAccountIdsMap(newRecords);

        for(AccountContactRelation acr : newRecords) {
            contactid.add(acr.ContactId);
        }

        if(!contactid.isEmpty()) {
            copyFieldsOnAccount(contactId, contactIdToRelatedAccountIdsMap, true);
        }
    }

    private static void updateBPCOnAccount(List<AccountContactRelation> newRecords, 
                                            Set<Id> contactIds, 
                                            Set<Id> accountIds) {

        Map<Id, Contact> contactsMap = new Map<Id, Contact>([select 
                Id, Email, Contact_Identifier__c from Contact where Email != null 
                        and Contact_Identifier__c in ('Billing', 'Primary & Billing')
                        and Id in :contactIds 
            ]);


        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [select Id, HasBillingContact_BPC__c, RecordType.Name, Email_Application_To__c 
                from Account 
            where Id in :accountIds]
        );

        for(AccountContactRelation acr : newRecords) {

            Account acc = accountsMap.get(acr.AccountId);

            Contact c = contactsMap.get(acr.ContactId);

            if(c == null) continue;

            if(acc == null) continue;

            if(acc.RecordType.Name != 'Business Partner Community') continue;

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
        }

        update accountsMap.values();
    }

    private static void copyFieldsOnAccount(Set<Id> contactIds, 
                                                Map<Id, Set<Id>> contactIdToRelatedAccountIdsMap, 
                                                Boolean isDelete )  {
        List<Contact> contacts = [select FirstName, LastName,
                                    Phone,
                                    Email,
                                    Title,
                                    Role__c,
                                    MailingStreet,
                                    MailingCity,
                                    MailingCountry,
                                    MailingPostalCode,
                                    MailingState,
                                    AccountId,
                                    Contact_Identifier__c
                                from Contact where Id in :contactIds];

        System.debug('contacts: ' + contacts);
        if(!contacts.isEmpty()) RWS_ContactTrigger_Handler.copyFieldsOnAccount(contacts, 
                                                                contactIdToRelatedAccountIdsMap, isDelete);
    }

    /******************************************************************************
* shareIAAccounts
* @author: Kotapati Keerthi (Magnet 360)
* @date: 11/22/2016
* @description: Gives Share access to all the IA Accounts.
* @param: List< AccountContactRelation  > newRecords
* @return: None.
******************************************************************************/
    Public static void shareIAAccounts (Set<Id> accountId, Set<Id> contactId) {
        List<AccountShare> accshareInsert = new List<AccountShare>();
        List<Store_IA_Account__c> SIAList = [select id,IA_Account__c, Store_Account__C from Store_IA_Account__c 
                                             where Store_Account__c in :accountId and IA_Account__c != null
                                            ];
        Map<Id,Id> userContactMap = new Map<Id,Id>();
        userContactMap = getUserIds(contactId);
        for(Id cId : contactId) {
            if(userContactMap.containsKey(cId)) {
                for(Store_IA_Account__c SIA : SIAList) {                    
                    AccountShare share = new AccountShare();
                    share.AccountId =SIA.IA_Account__c;
                    share.UserorGroupId =userContactMap.get(cId);
                    share.AccountAccessLevel ='Edit';
                    share.OpportunityAccessLevel ='Read';
                    accshareInsert.add(share);
                }
            }
        }
        if(!accshareInsert.isEmpty()) {
            insert accshareInsert;
        }
    }
    /******************************************************************************
* GetUserIds
* @author: Kotapati Keerthi (Magnet 360)
* @date: 11/22/2016
* @description: Get userid of all the contacts.
* @param: Set<Id> contactId
* @return: Map<Id,Id> userContactMap
******************************************************************************/
    Public static Map<Id,Id> getUserIds (Set<Id> contactId) {
        List<User> userContactLst = [select id,contactid from user where contactid in :contactId 
                                     and (contact.RecordTypeId = :BusinessPartnerRecordTypeId or contact.RecordTypeId = :GeneralContactRecordTypeId) ];
        Map<Id,Id> userContactMap = new Map<Id,Id> ();
        for(user u : userContactLst) {
            userContactMap.put(u.contactid,u.id);
        }
        return userContactMap;
    }
}