/**
	* 
	* 09/14/2020	Sophia Murphy
    *				Added in logic for setting the ultimate parent on the account
    *               Tracking if parentIds have changed; and only updating accounts if that happened
    *               Not using the UpdateHierarchy methods; since those don't grab every child - and grab every account; not just those needing changes
 */    
public without sharing class RWS_AccountTrigger_Handler {

    private static final Id recordtypeId = [Select Id from RecordType where Name = 'Business Partner Community'].Id;
    private static final Id profileId = [select id from Profile where name = 'System Administrator' limit 1].Id;
    public static boolean QUERIED_ACCOUNT_TEAM = false;

    /******************************************************************************
    * beforeInsert
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on Before Insert
    * @param: List<Account> newRecords
    * @return: None.
    ******************************************************************************/ 
    public static void beforeInsert(List<Account> newRecords) {
        // set account number based on record type
        setAccountNumber(newRecords);

        // populates address fields on Account based on Contact type
        populateAddressFieldsOnAccount(newRecords, null, false);

        // copy data from Account to Contact
        copyFieldsOnChildAccount(newRecords);
        
        //03.11.2019 - Moved over from TriggerController_Account
        // update account hierarchy
        UpdateAccountHierarchyBeforeInsert(newRecords);
    }

    
    /******************************************************************************
    * afterInsert
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on After Insert
    * @param: List<Account> newRecords
    * @return: None.
	* 
	* 09/14/2020	Sophia Murphy
	*				Added in logic for setting the ultimate parent on the account
    ******************************************************************************/ 
    public static void afterInsert(List<Account> newRecords) {
        // create Store IA Account records
        createStoreIAAccounts(newRecords);

        // create Account Contact Relation records
        createAccountContactRelation(newRecords);

        // share account records
        shareAccounts(newRecords, null, false);
        
        //03.11.2019 - Moved over from TriggerController_Account
        // update account hierarchy
        UpdateAccountHierarchyAfterInsert(newRecords);
        
        // create contacts
        //CreateContactsOnAfterInsertAndUpdate(newRecords, null);

        ProcessUltimateParent(newRecords, null);
    }

    
    /******************************************************************************
    * beforeUpdate
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on Before Update, 
    * @param: List<Account> newRecords, Map<Id, Account> oldRecords
    * @return: None.
    ******************************************************************************/ 
    public static void beforeUpdate(List<Account> newRecords, Map<Id, Account> oldRecords, Map<Id, Account> newRecordMap) {

        // populates address fields on Account based on Contact type
        populateAddressFieldsOnAccount(newRecords, oldRecords, true);

        // clear tax exempt fields on account
        clearTaxExemptFields(newRecords, oldRecords);
        
        //03.11.2019 - Sophia Murphy (Demand Chain)
        //Run Account team update
        runAccountTeamUpdate(oldRecords, newRecordMap);
        
        // update account hierarchy
        UpdateAccountHierarchyBeforeUpdate(newRecords, oldRecords);
    }

    
    /******************************************************************************
    * afterUpdate
    * @author: Usman Aslam (Magnet 360)
    * @date: 01/12/2017
    * @description: Handles actions on After Update, 
    * @param: List<Account> newRecords, Map<Id, Account> oldRecords
    * @return: None.
	* 
	* 09/14/2020	Sophia Murphy
	*				Added in logic for setting the ultimate parent on the account
    ******************************************************************************/ 
    public static void afterUpdate(List<Account> newRecords, Map<Id, Account> oldRecords) {
        // deactivate programs
        deactivatePrograms(newRecords, oldRecords);

        // publish account recrds
        publishRecords(newRecords, oldRecords);

        // share account records
        shareAccounts(newRecords, oldRecords, true);

        // set Invoice Atributes Required on associated program
        setInvoiceAtributesRequiredOnProgram(newRecords, oldRecords);
        
        // create contacts
        //CreateContactsOnAfterInsertAndUpdate(newRecords, oldRecords);

        ProcessUltimateParent(newRecords, oldRecords);
    }
    
    /******************************************************************************
    * beforeDelete
    * @author: Erik Reitter (RWS)
    * @date: 02/28/2019
    * @description: Handles actions on Before Delete, 
    * @param: Map<Id, Account> oldRecords
    * @return: None.
    ******************************************************************************/ 
    public static void beforeDelete(Map<Id, Account> oldRecords) {
        // update account hierarchy
        UpdateAccountHierarchyBeforeDelete(oldRecords);

        ProcessUltimateParent(null, oldRecords);
    }
    
    /******************************************************************************
    * afterDelete
    * @author: Erik Reitter (RWS)
    * @date: 02/28/2019
    * @description: Handles actions on After Delete, 
    * @param: Map<Id, Account> oldRecords
    * @return: None.
	* 
	* 09/14/2020	Sophia Murphy
	*				Added in logic for setting the ultimate parent on the account
    ******************************************************************************/ 
    public static void afterDelete(Map<Id, Account> oldRecords) {
        // update account hierarchy
        UpdateAccountHierarchyAfterDelete(oldRecords);
    }

    private static void UpdateAccountHierarchyBeforeInsert(List<Account> newRecords)
    {
        for(Account a : newRecords)
        {
            if(a.RecordTypeId != null && a.RecordTypeId.equals(recordTypeId))
            {
                if(a.ParentId == null)
                {
                    a.Is_Child__c = false;
                    a.Is_Standalone__c = true;
                }
                else
                {
                    a.Is_Child__c = true;
                    a.Is_Standalone__c = false;
                }
                //new accounts cannot be parents (as they don't have an id yet)
                a.Is_Parent__c = false;
                a.Number_of_Children__c = 0;
            }
        }
    }
    
    //
    private static void UpdateAccountHierarchyBeforeUpdate(List<Account> newRecords, Map<Id, Account> oldRecords)
    {
        Map<Id, Integer> parentMap = new Map<Id, Integer>();
        for(List<Account> currentParents : [SELECT Id, ParentId, Is_Child__c, Is_Parent__c, Is_Standalone__c FROM Account 
                                            WHERE ParentId in :newRecords AND RecordTypeId = :recordTypeId])
        {
            for(Account a : currentParents)
            {
                if(parentMap.containsKey(a.ParentId))
                {
                    parentMap.put(a.ParentId, parentMap.get(a.ParentId)+1);
                }
                else
                {
                    parentMap.put(a.ParentId, 1); 
                }
            }
        }
        
        for(Account a : newRecords)
        {
            if(a.RecordTypeId != null && a.RecordTypeId.equals(recordTypeId))
            {
                a.Is_Child__c = a.ParentId != null;
                if(parentMap.containsKey(a.Id))
                {
                    a.Number_of_Children__c = parentMap.get(a.Id);
                    a.Is_Parent__c = true;
                    a.Is_Standalone__c = false;
                }
                else
                {
                    a.Number_of_Children__c = 0;
                    a.Is_Parent__c = false;
                }
                a.Is_Standalone__c = !a.Is_Child__c && !a.Is_Parent__c;
            }
        }
        
        //Create Map of # of children changed per ParentId
        Map<Id, Integer> childChangeMap = new Map<Id, Integer>();
        for(Account updatedAcc : newRecords)
        {
            Account oldAcc = oldRecords.get(updatedAcc.Id);
            if(updatedAcc.ParentId != oldAcc.ParentId)
            {
                if(updatedAcc.ParentId != null)
                {
                    if(childChangeMap.containsKey(updatedAcc.ParentId))
                    {
                        childChangeMap.put(updatedAcc.ParentId, childChangeMap.get(updatedAcc.ParentId)+1);
                    }
                    else
                    {
                        childChangeMap.put(updatedAcc.ParentId, 1); 
                    }
                }
                else
                {
                    //Needed for deletes
                    if(!childChangeMap.containsKey(updatedAcc.Id))
                    {
                        childChangeMap.put(updatedAcc.Id, 0);
                    }
                }
                if(oldAcc.ParentId != null)
                {
                    if(childChangeMap.containsKey(oldAcc.ParentId))
                    {
                        childChangeMap.put(oldAcc.ParentId, childChangeMap.get(oldAcc.ParentId)-1);
                    }
                    else
                    {
                        childChangeMap.put(oldAcc.ParentId, -1); 
                    }
                }
            }
        }
                
        //James Loghry (Demand Chain) - Removed query and using newAccounts since we should already have the data without SOQL.
        for(Account a : newRecords)
        {
            if(childChangeMap.containsKey(a.Id) && a.RecordTypeId == recordTypeId)
            {
                Decimal numChildren = a.Number_of_Children__c;
                boolean isParent = a.Is_Parent__c;
                boolean isStandAlone = a.Is_Standalone__c;
                Integer childChange = childChangeMap.get(a.Id);

                a.Number_of_Children__c = (a.Number_of_Children__c == null || a.Number_of_Children__c + childChange < 0) 
                                             ? 0 
                                             : a.Number_of_Children__c + childChange;
                a.Is_Parent__c = a.Number_of_Children__c > 0;
                a.Is_Child__c = a.ParentId != null;
                a.Is_Standalone__c = !a.Is_Child__c && !a.Is_Parent__c;
                
                //finally null out the record in the childMap so we know which updates we haven't done
                childChangeMap.put(a.Id, null);
            }
        }
        
        //At this point, the childChangeMap only contains updates to ParentIds, send those to be updated in @future
        List<Id> idsToUpdate = new List<Id>();
        for(Id fId : childChangeMap.KeySet())
        {
            Integer count = childChangeMap.get(fId);
            if(count != null && count != 0)
            {
                idsToUpdate.Add(fId);
            }
        }
        
        if(idsToUpdate.size() > 0)
        {
            FutureUpdates(idsToUpdate);
        }
    }
    
    @future
    private static void FutureUpdates(List<Id> updateList)
    {
        Map<Id, Integer> childrenCounts = new Map<Id, Integer>();
        List<Account> toUpdate = new List<Account>();
        List<Account> accounts = [SELECT Id, Is_Parent__c, Is_Child__c, Is_Standalone__c, Number_of_Children__c, ParentId FROM Account WHERE Id IN :updateList];
        AggregateResult[] groupedResults = [SELECT COUNT(Id), ParentId FROM Account where ParentId IN :updateList GROUP BY ParentId];
        for(AggregateResult ar : groupedResults) {
            Id accountId = (Id)ar.get('ParentId');
            Integer children = (Integer)ar.get('expr0');
            childrenCounts.put(accountId, children);
        }
        
        for(Account a : accounts)
        {
            Integer count = childrenCounts.get(a.Id);
            if(count != null && count != 0)
            {
                a.Number_of_Children__c = count;
            }
            if(a.Number_of_Children__c == null)
            {
                a.Number_of_Children__c = 0;
            }

            a.Is_Parent__c = a.Number_of_Children__c > 0;
            a.Is_Child__c = a.ParentId != null;
            a.Is_Standalone__c = !a.Is_Child__c && !a.Is_Parent__c;
            toUpdate.Add(a);
        }
        if(toUpdate.size() > 0)
        {
            update toUpdate;
        }
    }
    
    //Update the parental status per child account
    private static void UpdateAccountHierarchyBeforeDelete(Map<Id, Account> oldRecords)
    {
        List<Account> changes = new List<Account>();
        //Update the children of the deleted account
        for(List<Account> children : [SELECT ParentId, Invoice_Parent_Account__c, Is_Child__c, Is_Parent__c, Is_Standalone__c FROM Account 
                                      WHERE ParentId in :oldRecords.keySet() AND RecordTypeId = :recordTypeId])
        {
            for(Account a : children)
            {
                a.ParentId = null;
                a.Invoice_Parent_Account__c = null;
                a.Is_Child__c = false;
                if(!a.Is_Parent__c)
                {
                    a.Is_Standalone__c = true;
                }
                changes.add(a);
            }
        }
        
        update changes;
    }
    
    //Update the number of children removed per parent account and statuses of the parents
    private static void UpdateAccountHierarchyAfterDelete(Map<Id, Account> oldRecords)
    {
        //Create Map of # of children deleted per ParentId
        Map<Id, Integer> parentMap = new Map<Id, Integer>();
        for(Account a : oldRecords.values())
        {
            if(parentMap.containsKey(a.ParentId))
            {
                parentMap.put(a.ParentId, parentMap.get(a.ParentId)-1);
            }
            else
            {
                parentMap.put(a.ParentId, -1); 
            }
        }
        
        //Update the parents of the deleted account based on the Map
        List<Account> changes = new List<Account>();            
        for(List<Account> parents : [SELECT Id, Is_Child__c, Is_Parent__c, Is_Standalone__c, Number_Of_Children__c, ParentId FROM Account 
                                     WHERE Id in :parentMap.keySet() AND RecordTypeId = :recordTypeId])
        {
            for(Account a : parents)
            {
                Integer childChange = parentMap.get(a.Id);
                
                a.Number_of_Children__c = (a.Number_of_Children__c == null || a.Number_of_Children__c + childChange < 0) 
                                             ? 0 
                                             : a.Number_of_Children__c + childChange;
                a.Is_Parent__c = a.Number_of_Children__c > 0;
                a.Is_Child__c = a.ParentId != null;
                a.Is_Standalone__c = !a.Is_Child__c && !a.Is_Parent__c;
                
                changes.add(a);
            }
        }
     
        update changes;
    }
    
    //Update the number of children added per parent account and statuses of the parents
    private static void UpdateAccountHierarchyAfterInsert(List<Account> newRecords)
    {
        //Create Map of # of children added per ParentId
        Map<Id, Integer> parentMap = new Map<Id, Integer>();
        for(Account a : newRecords)
        {
            if(parentMap.containsKey(a.ParentId))
            {
                parentMap.put(a.ParentId, parentMap.get(a.ParentId)+1);
            }
            else
            {
                parentMap.put(a.ParentId, 1); 
            }
        }
        
        //Update the parents based on the Map
        List<Account> changes = new List<Account>();
        for(List<Account> parents : [SELECT Id, Is_Parent__c, Is_Standalone__c, Number_Of_Children__c FROM Account 
                                     WHERE Id in :parentMap.keySet() AND RecordTypeId = :recordtypeId])
        {
            for(Account parent : parents)
            {
                parent.Is_Parent__c = true;
                parent.Is_Standalone__c = false;
                if(parent.Number_of_Children__c == null)
                {
                    parent.Number_of_Children__c = parentMap.get(parent.Id);
                }
                else
                {
                    parent.Number_of_Children__c += parentMap.get(parent.Id);
                }
                changes.add(parent);
            }
        }
        update changes;
    }
    
    //This code was migrated from the old TriggerController_Account
    //commented out per Cicily request - 07092020 CAM Demand Chain
    /*private static void CreateContactsOnAfterInsertAndUpdate(List<Account> newRecords, Map<Id, Account> oldRecords) {
        APEX_Trigger_Settings__c triggerSetting = APEX_Trigger_Settings__c.getValues('geoLocationAccount');
        if(triggerSetting == null || triggerSetting.IsActive__c){
    
            List<Contact> contacts = new List<Contact>();
            for(Account a : newRecords){
    
                Account old = null;
                if(oldRecords != null){
                    old = oldRecords.get(a.Id);
                }
    
                if(
                   !String.isEmpty(a.M3_Location_Street__c)
                   && !String.isEmpty(a.M3_Location_City__c)
                   && !String.isEmpty(a.M3_Location_ZIP_Postal_Code__c)
                   && !String.isEmpty(a.M3_Location_Country_Code__c)
                   && (
                       old == null
                       || a.M3_Location_City__c != old.M3_Location_City__c
                       || a.M3_Location_Street__c != old.M3_Location_Street__c
                       || String.isEmpty(a.M3_Location_State_Province__c) != String.isEmpty(old.M3_Location_State_Province__c)
                       || (a.M3_Location_State_Province__c != null && a.M3_Location_State_Province__c != old.M3_Location_State_Province__c)
                       || String.isEmpty(a.M3_Location_Zip_Postal_Code__c) != String.isEmpty(old.M3_Location_Zip_Postal_Code__c)
                       || (a.M3_Location_Zip_Postal_Code__c != null && a.M3_Location_Zip_Postal_Code__c != old.M3_Location_Zip_Postal_Code__c)
                       || a.M3_Location_Country_Code__c != old.M3_Location_Country_Code__c
                   )){
    
                    contacts.add(
                        new Contact(
                            AccountId = a.Id
                            ,M3_Account_Ext_Id__c = a.Id
                            ,Firstname='M3'
                            ,Lastname='Address'
                            ,MailingStreet = a.M3_Location_Street__c
                            ,MailingCity = a.M3_Location_City__c
                            ,MailingState = a.M3_Location_State_Province__c
                            ,MailingCountry = a.M3_Location_Country_Code__c
                            ,MailingPostalCode = a.M3_Location_ZIP_Postal_Code__c
                        )
                    );
                }
            }
    
            if(!contacts.isEmpty()){
                upsert contacts M3_Account_Ext_Id__c;
            }
        }
    }*/

    private static void clearTaxExemptFields(List<Account> newRecords, 
                                                Map<Id, Account> oldRecords) {

        // iterate over account records
        for(Account acc : newRecords) {

            // if Tax Exempt is changed and its value is 'No'
            if(acc.Tax_Exempt__c != oldRecords.get(acc.Id).Tax_Exempt__c && acc.Tax_Exempt__c == 'No') {

                // clear field values
                acc.IA_Tax_Exempt_Certificate_Nbr__c = null;
                acc.Tax_Exempt_Expiration_Date__c = null;
                acc.Tax_Exemption_Reason__c = null;
            }
        }

    }

    private static void populateAddressFieldsOnAccount(List<Account> newRecords, 
                            Map<Id, Account> oldRecords, 
                            Boolean isUpdate) {

        // iterate over account records
        for(Account acc : newRecords) {
            //updated by Joey: RWCP-3181
            //update the Primary Contact Email (Primary_Contact_Email_c) with the Email Application To (Email_Application_To_c) field value. 
            if(

                // Send Application is checked and changed in update
                // OR
                // Send Credit Application is 'Send' and changed in update
                (acc.Send_Application__c == true && acc.Send_Application__c != oldRecords.get(acc.Id).Send_Application__c)
                ||
                (acc.Send_Credit_Application__c == 'Send' && acc.Send_Credit_Application__c != oldRecords.get(acc.Id).Send_Credit_Application__c)                
            ){
                // set Primary Contact Email from Email Application To
                acc.Primary_Contact_Email__c = acc.Email_Application_To__c;
            }
            //end ---- RWCP-3181

            if( (
                    // If Account is Inserted
                    // OR
                    // Account is Updte and any of IA Physical Location address fields
                    // all of the IA Physical Location address fields are NOT Blank
                    (!isUpdate) ||
                    (isUpdate && (
                        acc.IA_Physical_Location_City__c != oldRecords.get(acc.Id).IA_Physical_Location_City__c ||
                        acc.IA_Physical_Location_Address_Line_1__c != oldRecords.get(acc.Id).IA_Physical_Location_Address_Line_1__c ||
                        acc.IA_Physical_Location_Address_Line_2__c != oldRecords.get(acc.Id).IA_Physical_Location_Address_Line_2__c ||
                        acc.IA_Physical_Location_Address_Line_3__c != oldRecords.get(acc.Id).IA_Physical_Location_Address_Line_3__c ||
                        acc.IA_Physical_Location_State_Province__c != oldRecords.get(acc.Id).IA_Physical_Location_State_Province__c ||
                        acc.IA_Physical_Location_ZIP_Postal_Code__c != oldRecords.get(acc.Id).IA_Physical_Location_ZIP_Postal_Code__c ||
                        acc.IA_Physical_Location_Country__c != oldRecords.get(acc.Id).IA_Physical_Location_Country__c ||
                        acc.RWfB_same_as_Physical_Address__c != oldRecords.get(acc.Id).RWfB_same_as_Physical_Address__c
                    )) 
                    &&
                    !(  String.isBlank(acc.IA_Physical_Location_City__c) && 
                        String.isBlank(acc.IA_Physical_Location_Address_Line_1__c) && 
                        String.isBlank(acc.IA_Physical_Location_Address_Line_2__c) && 
                        String.isBlank(acc.IA_Physical_Location_Address_Line_3__c) && 
                        String.isBlank(acc.IA_Physical_Location_State_Province__c) && 
                        String.isBlank(acc.IA_Physical_Location_ZIP_Postal_Code__c) && 
                        String.isBlank(acc.IA_Physical_Location_Country__c) )
                )
            ) {

                // RWfB same as Physical Address is checked
                if(acc.RWfB_same_as_Physical_Address__c) {

                    // set RWfB Billing Address from IA Physical Location address fields
                    acc.RWfB_Billing_Address_City__c = acc.IA_Physical_Location_City__c; 
                    acc.RWfB_Billing_Address_Line_1__c = acc.IA_Physical_Location_Address_Line_1__c;
                    acc.RWfB_Billing_Address_Line_2__c = acc.IA_Physical_Location_Address_Line_2__c;
                    acc.RWfB_Billing_Address_Line_3__c = acc.IA_Physical_Location_Address_Line_3__c;
                    acc.RWfB_Billing_Address_State_Province__c = acc.IA_Physical_Location_State_Province__c;
                    acc.RWfB_Billing_Address_ZIP_Postal_Code__c = acc.IA_Physical_Location_ZIP_Postal_Code__c;
                    acc.RWfB_Billing_Address_Country__c = acc.IA_Physical_Location_Country__c;
                }


            }

            // If all the Billing Address fields are empty
            if( String.isBlank(acc.BillingCity) && 
                String.isBlank(acc.BillingStreet) && 
                String.isBlank(acc.BillingState) && 
                String.isBlank(acc.BillingPostalCode) && 
                String.isBlank(acc.BillingCountry)) {


                // Populate Billing Address from RWfB Billing Address
                acc.BillingCity = acc.RWfB_Billing_Address_City__c; 
                acc.BillingStreet = (String.isBlank(acc.RWfB_Billing_Address_Line_1__c) ? '' : acc.RWfB_Billing_Address_Line_1__c + '\n') + 
                                    (String.isBlank(acc.RWfB_Billing_Address_Line_2__c) ? '' : acc.RWfB_Billing_Address_Line_2__c + '\n') + 
                                    (String.isBlank(acc.RWfB_Billing_Address_Line_3__c) ? '' : acc.RWfB_Billing_Address_Line_3__c);

                acc.BillingState = acc.RWfB_Billing_Address_State_Province__c;
                acc.BillingPostalCode = acc.RWfB_Billing_Address_ZIP_Postal_Code__c;
                acc.BillingCountry = acc.RWfB_Billing_Address_Country__c;
            }
        }

    }

    // method to set Account Number on Account based on RecordType
    private static void setAccountNumber(List<Account> newRecords) {

        // get account record type details
        Map<Id, RecordType> rtMap = new Map<Id, RecordType>(
                [select Id, DeveloperName from RecordType where SObjectType = 'Account']
            );

        // initialize map
        Map<String, Integer> recordsCountByRecordType = new Map<String, Integer>();

        // iterate over all records
        for(Account a : newRecords) {

            // get record type
            RecordType rt = rtMap.get(a.RecordTypeId);

            // if record type is null, move to next records
            if(rt == null) continue;

            // get records count for the record type developer name from map
            Integer count = recordsCountByRecordType.get(rt.DeveloperName);

            // if not found, initialize with 0
            if(count == null) {
                count = 0;
            }

            // increment the value
            count ++;

            // put it back in the map
            recordsCountByRecordType.put(rt.DeveloperName, count);

        }

        // if there are no valid records, exit
        if(recordsCountByRecordType.isEmpty()) return;

        // grab the Custom Setting record and lock them for update
        List<Account_Number_Setting__c> 
            settings = [select Id, 
                            Starting_Number__c,
                            Record_Type_Developer_Name__c,
                            Format__c
                        from Account_Number_Setting__c
                        where Record_Type_Developer_Name__c in :recordsCountByRecordType.keySet()
                        for update];

        // iterate over custom setting records
        for(Account_Number_Setting__c s : settings) {

            // record count from map for the record type developer name
            Integer count = recordsCountByRecordType.get(s.Record_Type_Developer_Name__c);

            // if count is not found, move it to next record
            if(count == null) continue;

            // Starting number is null, initialize it with 10000000
            if(s.Starting_Number__c == null) s.Starting_Number__c = 10000000;

            // Format is null, initialize it with {0}
            if(s.Format__c == null) s.Format__c = '{0}';

            // Format does not contain {0}, append it in format
            if(!s.Format__c.containsIgnoreCase('{0}')) s.Format__c += '{0}';

            // Increment starting number with count
            s.Starting_Number__c += count;
        }

        // update custom settings
        update settings;


        // reset starting number value and put the setting in a map by record type develop name
        Map<String, Account_Number_Setting__c> recordsStartByRecordType = new Map<String, Account_Number_Setting__c>();
        for(Account_Number_Setting__c s : settings) {
            Integer count = recordsCountByRecordType.get(s.Record_Type_Developer_Name__c);

            if(count == null) continue;

            s.Starting_Number__c -= count;

            recordsStartByRecordType.put(s.Record_Type_Developer_Name__c, s);
        }


        // iterate over all account records
        for(Account a : newRecords) {
            // get record type
            RecordType rt = rtMap.get(a.RecordTypeId);

            // record not found, move to next record
            if(rt == null) continue;

            // get custom settings from map
            Account_Number_Setting__c s = recordsStartByRecordType.get(rt.DeveloperName);

            // custom setting not found, move to next record
            if(s == null) continue;

            // create a formatted account number
            String formatted = String.format(s.Format__c, new List<String>{String.valueOf(s.Starting_Number__c)});

            // set it on Account Number Text field
            a.Account_Number_Text__c = formatted;

            // increment Starting number on custom settings by 1
            s.Starting_Number__c ++;
        }

    }

    // method to set Invoice Atributes Required on Program
    private static void setInvoiceAtributesRequiredOnProgram(List<Account> newList, 
                                                                Map<Id, Account> oldRecords) {

        Set<Id> accountIds = new Set<Id>();

        // iterate over all records
        for(Account a : newList) {

            // if Invoice Atributes Required is changed on Account
            if(a.Invoice_Atributes_Required__c != oldRecords.get(a.Id).Invoice_Atributes_Required__c) {

                // add account id in a set
                accountIds.add(a.Id);
            }
        }

        // set is empty, exit
        if(accountIds.isEmpty()) return;

        // retrieve program where type is not CashandCarry
        List<Program__c> relatedPrograms = [select  Id, Account__c, 
                                                    Invoice_Attributes_Required__c,
                                                    Outbound_Message_Type__c,
                                                    Publish_Status__c
                                            from Program__c
                                            where Account__c in :accountIds
                                            and Type__c != null
                                            and Type__c != 'CashandCarry'];

        // if there are related records, call method to set Invoice Atributes Required on Program
        if(!relatedPrograms.isEmpty()) RWS_ProgramTrigger_Handler.setInvoiceAtributesRequiredOnProgram(relatedPrograms, true);
    }

    // method used to create Account Contact Relation records
    private static void createAccountContactRelation(List<Account> newRecords) {

        // initialize variables
        Set<Id> parentIds = new Set<Id>();
        List<Account> relevantAccounts = new List<Account>();

        // iterate over account records
        for(Account acc : newRecords) {

            // record type is not valid, move to next record
            if(acc.RecordTypeId != recordtypeId) continue;

            // parent id is null, move to next record
            if(acc.ParentId == null) continue;

            // Requires Invoicing is not 'Yes', move to next record
            if(acc.Requires_Invoicing__c != 'Yes') continue;

            // Invoice Parent Account is 'No', move to next record
            if(acc.Invoice_Parent_Account__c == 'No') continue;

            // add parentId to set
            parentIds.add(acc.ParentId);

            // add account to list
            relevantAccounts.add(acc);

        }

        // if set is empty, exit
        if(parentIds.isEmpty()) return;

        // retrieve parent accounts
        Map<Id, Account> parentAccountsMap = new Map<Id, Account>(
                [select Id, 
                        BillingContactID__c
                    from Account
                    where Id in :parentIds
                    and Billing_Contact_Last_Name__c != null]
            );

        // initialize list
        List<AccountContactRelation> relations = new List<AccountContactRelation>();

        // iterate of accounts that need to be processed
        for(Account acc : relevantAccounts) {

            // get parent acount
            Account pAcc = parentAccountsMap.get(acc.ParentId);

            // if parent account is not found, move to next record
            if(pAcc == null) continue;

            // Invoice Parent Account is 'Centralized'
            if(acc.Invoice_Parent_Account__c == 'Centralized') {

                // credit status is blank
                // AND
                // HasBillingContact BPC is not checked
                // AND
                // Billing Contact ID is not blank
                if( String.isBlank(acc.Credit_Status__c) &&
                (! acc.HasBillingContact_BPC__c ) &&
                (!String.isBlank(pAcc.BillingContactID__c))
                 ) {

                    // initialize new AccountContactRelation record
                    relations.add(new AccountContactRelation(AccountId = acc.Id, 
                                    ContactId = pAcc.BillingContactID__c)
                                );
                }
            }
        }

        // insert AccountContactRelation records
        if(!relations.isEmpty()) insert relations;
    }

    // method to copy data from Parent Account to child accounts
    private static void copyFieldsOnChildAccount(List<Account> newRecords) {

        // initialize variables
        Set<Id> parentIds = new Set<Id>();
        List<Account> relevantAccounts = new List<Account>();

        // iterate over account records
        for(Account acc : newRecords) {

            // record type is not valid, move to next record
            if(acc.RecordTypeId != recordtypeId) continue;

            // parent id is null, move to next record
            if(acc.ParentId == null) continue;

            // Requires Invoicing is not 'Yes', move to next record
            if(acc.Requires_Invoicing__c != 'Yes') continue;

            // Invoice Parent Account is 'No', move to next record
            if(acc.Invoice_Parent_Account__c == 'No') continue;

            // add parentId to set
            parentIds.add(acc.ParentId);

            // add account to list
            relevantAccounts.add(acc);

        }

        // if set is empty, exit
        if(parentIds.isEmpty()) return;

        // retrieve parent accounts
        // 67423
        Map<Id, Account> parentAccountsMap = new Map<Id, Account>(
                [select Id, Billing_Contact_First_Name__c,
                        Billing_Contact_Last_Name__c, 
                        Billing_Contact_Phone__c, 
                        Billing_Contact_Email__c,
                        Billing_Contact_Title__c,
                        Billing_Contact_Role__c,
                        Billing_Contact_Mailing_Street__c,
                        Billing_Contact_Mailing_City__c,
                        Billing_Contact_Mailing_State_Province__c,
                        Billing_Contact_Mailing_Country__c,
                        Billing_Contact_Mailing_Zip_Postal_Code__c,
                        BillingContactID__c,
                        BPC_Payment_Terms__c,
                        Billing_Frequency__c,
                        Requested_Credit_Limi__c,
                        IA_Federal_ID_Nbr__c,
                        Invoice_Atributes_Required__c,
                        Invoice_Delivery_Method__c
                    from Account
                    where Id in :parentIds
                    and Billing_Contact_Last_Name__c != null]
            );

        // iterate over accounts that need to be processed
        for(Account acc : relevantAccounts) {

            // get parent account
            Account pAcc = parentAccountsMap.get(acc.ParentId);

            // if parent account is null, move to next record
            if(pAcc == null) continue;

            // if Credit Status is blank
            if(String.isBlank(acc.Credit_Status__c)) {

                // populate fields on Account from its Parent Account
                acc.BPC_Payment_Terms__c = pAcc.BPC_Payment_Terms__c;
                acc.Billing_Frequency__c = pAcc.Billing_Frequency__c;
                acc.Requested_Credit_Limi__c = pAcc.Requested_Credit_Limi__c;
                acc.IA_Federal_ID_Nbr__c = pAcc.IA_Federal_ID_Nbr__c;
                acc.Invoice_Atributes_Required__c = pAcc.Invoice_Atributes_Required__c;
                acc.Invoice_Delivery_Method__c = pAcc.Invoice_Delivery_Method__c;

            }

            // Invoice Parent Account is 'Centralized'
            if(acc.Invoice_Parent_Account__c == 'Centralized') {

                // populate fields on Account from its Parent Account
                acc.Billing_Contact_First_Name__c = pAcc.Billing_Contact_First_Name__c;
                acc.Billing_Contact_Last_Name__c = pAcc.Billing_Contact_Last_Name__c; 
                acc.Billing_Contact_Phone__c = pAcc.Billing_Contact_Phone__c; 
                acc.Billing_Contact_Email__c = pAcc.Billing_Contact_Email__c;
                acc.Billing_Contact_Title__c = pAcc.Billing_Contact_Title__c;
                acc.Billing_Contact_Role__c = pAcc.Billing_Contact_Role__c;
            }

        }


    }

    // share account with truck manager
    private static void shareAccounts(List<Account> newRecords, Map<Id, Account> oldRecords, Boolean isUpdate) {

        List<Account> relevantAccounts = new List<Account>();

        // iterate over account records
        for(Account acc : newRecords) {

            // record type is not valid, move to next record
            if(acc.RecordTypeId != recordtypeId) continue;

            // if accounts are inserted
            // OR Owner of Account is changed
            if( (!isUpdate) || 
                    (isUpdate && acc.OwnerId != oldRecords.get(acc.Id).OwnerId)
            ) {

                // add account to a list
                relevantAccounts.add(acc);
            }
        }

        // if list is empty, exit
        if(relevantAccounts.isEmpty()) return;


        // get User Ids in Public Groups
        List<Set<Id>> ismAndNamUsers = RWS_UtilityClass.getIsmAndNamUser();

        Set<Id> ismUserIds = ismAndNamUsers[0];
        Set<Id> namUserIds = ismAndNamUsers[1];

        Set<Id> allInternalUserIds = new Set<Id>();

        allInternalUserIds.addAll(ismUserIds);
        allInternalUserIds.addAll(namUserIds);

        if(Test.isRunningTest()) allInternalUserIds.add(UserInfo.getUserId());

        // get Truck Managers Public Group
        Id truckManagerGroup = [select Id from Group 
                                    where DeveloperName = 'Truck_Managers'].Id;

        // initialize AccountShare list
        List<AccountShare> accountSharesToInsert = new List<AccountShare>();

        // iterate over accounts that need to be processed
        for(Account acc : relevantAccounts) {

            // if Account owner is set or currently logged in user is in the set
            if(allInternalUserIds.contains(acc.OwnerId) || allInternalUserIds.contains(UserInfo.getUserId())) {

                // intialize account share objects
                accountSharesToInsert.add(
                    new AccountShare(AccountId = acc.Id,
                              UserorGroupId = truckManagerGroup,
                              AccountAccessLevel ='Read',
                              OpportunityAccessLevel = 'Read')
                );
            }
        }


        // insert share records
        Database.insert(accountSharesToInsert, false); 
    }

    // flag to run logic once in an invocation
    private static Boolean RUN_DEACTIVATE_PROGRAM_ONCE = true;

    // method to deactivate related programs
    private static void deactivatePrograms(List<Account> newRecords, Map<Id, Account> oldRecords) {
    
      // if code already executed, exit
      if(!RUN_DEACTIVATE_PROGRAM_ONCE) return;

      // update flag value
      RUN_DEACTIVATE_PROGRAM_ONCE = Test.isRunningTest();
      
      // initialze set of IDs
      Set<Id> accountIds = new Set<Id>();

      // iterate over Accounts
      for(Account a : newRecords) {

        // if Active is NOT checked, and Active is changed, add account id in set
        if(a.Active__c == false && a.Active__c != oldRecords.get(a.Id).Active__c) accountIds.add(a.Id);
      }

      // if account Ids set is empty, exit
      if(accountIds.isEmpty()) return;

      // get related active programs
      List<Program__c> programs = [select Id, Active__c from Program__c 
                                  where Account__c in :accountIds
                                  and Active__c = true
                                    ];

        // if programs are not found, exit
      if(programs.isEmpty()) return;

      // iterate over related programs
      for(Program__c p : programs) {
        // set Active unchecked
        p.Active__c = false;
      }

      // update programs
      update programs;
    }

    //Trigger on account which will pick an Account Owner and then fetch the Role of that Owner. 
    //Pull all users under the role and share new Account with all Users under that Role
    //Share Industriall account to RWS Customer Service NA Mgr AND RWS -- Retail Accounting Profile Users
    private static void createStoreIAAccounts(List<Account> newRecords) {

        // initialize variables
        Set<ID> accountSet = new Set<ID>();
        Set<ID> accountOwnerSet = new Set<ID>();
        List<Account> accList = new List<Account>();  
        List<User> userList = new List<User>();
        Map<Id,Id> mapUserIdvsAccountId = new Map<Id,Id>();
        Set<ID> userRoleSet = new Set<ID>();  

        // iterate over account records
        for (Account a : newRecords) {
            // if record type is valid and profile of currently logged in user is valid too
            if(a.RecordTypeId == recordtypeId && UserInfo.getProfileId() != ProfileId ){

                // add account id to a set
                accountSet.add(a.Id);

                // add owner id to a set
                accountOwnerSet.add(a.ownerId);
            }
        }

        // if account ids set is NOT empty
        if(!accountSet.isEmpty()){
            // retrieve owner roles
            accList = [Select Id,owner.userrole.Id From Account where Id in:accountSet];
        }

        // if accounts List is not empty
        if(!accList.isEmpty()){

            // iterate over accounts list
            for(Account acc : accList) {

                // add owner role ids in set
                userRoleSet.add(acc.owner.userrole.Id);
            }
        } 

        //Second scenario create junction object between IA and Store Account after IA account insert
        if(!accountOwnerSet.isEmpty()){

            // retreive users
            List<User> uList = [select Id,ContactId,AccountId from User where Id IN:accountOwnerSet]; 

            if(!uList.isEmpty()) {
                // if users are found
                // iter over user records
                for(User storeUser : uList){
                    if(null != storeUser.AccountId) {
                        // details in a map
                        mapUserIdvsAccountId.put(storeUser.Id,storeUser.AccountId);
                    }
                } 

            }
        } 

        // if map and accounts list is not empty
        if(!mapUserIdvsAccountId.isEmpty() && !accList.isEmpty()){
            List<Store_IA_Account__c> storeAccList = new List<Store_IA_Account__c>();

            // iterate over accounts list
           for(Account acc:accList){
                // initialize IA Store Account object
               Store_IA_Account__c storeAccount = new Store_IA_Account__c();
               storeAccount.IA_Account__c = acc.Id;
               storeAccount.Store_Account__c =  mapUserIdvsAccountId.get(acc.OwnerId);
               storeAccount.Primary__c = true;
               storeAccList.add(storeAccount);
           }

           if(!storeAccList.isEmpty()){
               try{
                    // insert IA Store Account records
                   insert storeAccList;
               }
               catch(Exception e){ }
           }
           
        }
    }

    // flag to make sure that publish is run once in an invocation
    public static Boolean RUN_PUBLISH_RECORDS_ONCE = true;

    //Scenario A – Submitting Credit application: fires when user submits credit application
    //On Insert or Update of IA Account for below if condition
    //Scenario B – Active Accounts : fires when user activates an account and afterwards when they make change to an active account.
    //On Update of IA Account, trigger should fire for below if/else condition
    private static void publishRecords(List<Account> newRecords, Map<Id, Account> oldRecords) {
        System.debug('Begin: RWS_AccountTrigger_Handler.publishRecords() *****' );

        // add account ids in set RecordType Id is valid
        Set<Id> aId = new Set<Id>();
        //Sophia Murphy (Demand Chain) 03.12.2019
        //add the accounts to the list here, so we don't have to query for them again
        List<Account> accList = new List<Account>();

        for (Account a : newRecords){
            if(a.RecordTypeId == recordtypeId /*&& UserInfo.getProfileId() != ProfileId */){
                aId.add(a.Id);
                accList.add(a);
            }    
        }

        // if account ids set is empty, exit
        if(aId.isEmpty())  return;

        // get accounts with updated values by workflow
        /**
        Sophia Murphy (Demand Chain) 03.12.2019 - Don't need to query, we have this data already above
        List<Account> accList = [select id, Name, Credit_Status__c,
                                    Publish_Status__c, Outbound_Message_Type__c, 
                                    Active__c, Send_Application__c, RecordTypeId 
                                from Account where Id in :aId];
        */

        // no accounts returned, exit
        if(accList.isEmpty()) return;

        // get contacts associated with Account
        List<Contact> contactWaitList = [select id, Name, AccountId, Publish_Status__c, 
                            Outbound_Message_Type__c, Active__c 
                            from Contact Where AccountId in :accList 
                            and Publish_Status__c =: 'Waiting' 
                            and RecordType.Name = 'Business Partner'];  

        // get programs associated with Account
        List<Program__c> programWaitList = [select Id, Name, Publish_Status__c, 
                                            Outbound_Message_Type__c, Active__c, Account__c 
                                            from Program__c 
                                            Where Account__c = :accList 
                                            and Publish_Status__c =: 'Waiting'];    

        // initialize variables needed for logic
        List<Account> accupdateList = new List<Account>();
        Set<Id> processedAccountIds = new Set<Id>();
        Set<Id> processedContactIds = new Set<Id>();
        
        Map<Id, Contact> contactUpdateList = new Map<Id, Contact>();
        List<Program__c> programUpdateList = new List<Program__c>();

        Set<Id> programsProcessedIds = new Set<Id>();

        // iterate over retrieved accounts
        for(Account acc : accList) {
            
            //Make a new instance of our account - so we can make changes to it
            Account newAcc = new Account(Id = acc.Id);


            // if status is Ready to Publish 
            // or 
            // status is Published and changed from Ready to Publish 
            // then move to next iteration
            if((acc.Publish_Status__c == 'ReadyToPublish') 
                || (acc.Publish_Status__c == 'Published' 
                    && oldRecords.get(acc.id).Publish_Status__c == 'ReadyToPublish'))
                continue;
              
            //Credit application is submitted
            if(acc.Credit_Status__c == 'Submitted' && acc.Credit_Status__c != oldRecords.get(acc.id).Credit_Status__c){
                // set new values
                //acc.Publish_Status__c = 'ReadyToPublish';
                //acc.Outbound_Message_Type__c = 'Credit Application';

                newAcc.Publish_Status__c = 'ReadyToPublish';
                newAcc.Outbound_Message_Type__c = 'Credit Application';

                processedAccountIds.add(acc.Id);
                //accupdateList.add(acc);
                accupdateList.add(newAcc);
            }

            //Account is activated
            if(acc.Active__c == true && acc.Active__c != oldRecords.get(acc.id).Active__c) {
                // set new values
                //acc.Outbound_Message_Type__c = 'Active Account';
                //acc.Publish_Status__c = 'ReadyToPublish';   

                newAcc.Outbound_Message_Type__c = 'Active Account';
                newAcc.Publish_Status__c = 'ReadyToPublish';  

                if(!processedAccountIds.contains(acc.Id)) {
                    //accupdateList.add(acc);
                    accupdateList.add(newAcc);
                    processedAccountIds.add(acc.Id);
                }
                

                // set new values on related Contacts
                for(Contact con : contactWaitList) {
                    if(processedAccountIds.contains(con.AccountId) ) {
                        con.Publish_Status__c = 'ReadyToPublish';
                        con.Outbound_Message_Type__c = 'Update Contact';    
                        contactUpdateList.put(con.Id, con);
                    }
                }

                // set new values on related Programs
                for(Program__c prog : programWaitList) {
                    if(processedAccountIds.contains(prog.Account__c) ) {
                        prog.Publish_Status__c = 'ReadyToPublish';
                        prog.Outbound_Message_Type__c = 'Update Program';
                        programUpdateList.add(prog); 
                        programsProcessedIds.add(prog.Id);
                    }    
                }  
            }
            
            // Active account is updated
            else if(acc.Active__c == true && acc.Active__c == oldRecords.get(acc.id).Active__c && 
                !processedAccountIds.contains(acc.Id)){

                // set new values
                //acc.Publish_Status__c = 'ReadyToPublish';
                //acc.Outbound_Message_Type__c = 'Update Account';
                newAcc.Publish_Status__c = 'ReadyToPublish';
                newAcc.Outbound_Message_Type__c = 'Update Account';
                if(!processedAccountIds.contains(acc.Id)) 
                {
                    //accupdateList.add(acc);
                    accupdateList.add(newAcc);
                }
            }                           
            
            //Active account is deactivated
            else if(acc.Active__c == false && acc.Active__c != oldRecords.get(acc.id).Active__c && 
                !processedAccountIds.contains(acc.Id)){
                
                // set new values
                //acc.Publish_Status__c = 'Deactivated';
                //acc.Outbound_Message_Type__c = 'Update Account';

                newAcc.Publish_Status__c = 'Deactivated';
                newAcc.Outbound_Message_Type__c = 'Update Account';

                if(!processedAccountIds.contains(acc.Id))
                {
                   // accupdateList.add(acc);
                    accupdateList.add(newAcc);
                } 
            }        
        }

        if(RUN_PUBLISH_RECORDS_ONCE){

            if(!accupdateList.isEmpty()) {
                // turn off recursion flag
                RUN_PUBLISH_RECORDS_ONCE = false;
                try {

                    // update accounts
                    update accupdateList;
                } catch (System.DmlException dmlEx) {
                    for(Account a : newRecords) {
                        for(Integer i = 0; i < dmlEx.getNumDml(); i++) {
                            a.addError(dmlEx.getDmlMessage(i));    
                        }
                        
                    }
                }
            }

            if(!contactUpdateList.isEmpty()) {

                // update related contacts
                // try five time if an attempt is failed due to ROW locking
                Integer attempts = 5;
                while(attempts > 0){
                    try {
                        attempts --; 
                        update contactUpdateList.values();
                        attempts = 0;
                    } catch (System.DmlException dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                        if(attempts == 0) { throw dmlEx; }
                    } // end of catch
                } // end of while retry loop

            }

            if(!programUpdateList.isEmpty()) {

                // update related programs
                // try five time if an attempt is failed due to ROW locking
                Integer attempts = 5;
                while(attempts > 0){
                    try {
                        attempts --; 
                        update programUpdateList;
                        attempts = 0;
                    } catch (System.DmlException dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                        if(attempts == 0) { throw dmlEx; }
                    } // end of catch
                } // end of while retry loop
            }

            Set<Id> pricebookIds = new Set<Id>();
            List<Servicing_Store__c> servicingStoreUpdateList = new List<Servicing_Store__c>();

            
            // retrieve related servicing stores
            for(Servicing_Store__c ss : [select id, Publish_Status__c, 
                                        Outbound_Message_Type__c 
                                    from Servicing_Store__c 
                                    where Program__c in :programUpdateList 
                                    and Publish_Status__c = 'Waiting'])
            {
                // set new values
                ss.Publish_Status__c = 'ReadyToPublish';
                ss.Outbound_Message_Type__c = 'Update Servicing Store';
                servicingStoreUpdateList.add(ss); 
            }

            if(!servicingStoreUpdateList.isEmpty()){

                // update related servicing stores
                // try five time if an attempt is failed due to ROW locking
                Integer attempts = 5;
                while(attempts > 0){
                    try {
                        attempts --; 
                        update servicingStoreUpdateList;
                        attempts = 0;
                    } catch (System.DmlException dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                        if(attempts == 0) { throw dmlEx; }
                    } // end of catch
                } // end of while retry loop
            }

            // if this code is called for context of batch or future call, exit
            if(System.isBatch() || System.isFuture()) return;

            // iterate over programs the updated in this method
            // and publish associated publish price book and publish price book entry records
            for(Id programId : programsProcessedIds) {

                // utilize 90% future call limit
                if(System.Limits.getFutureCalls() >  System.Limits.getLimitFutureCalls() * 0.90) continue;

                RWS_ProgramPublish_Util.publishPriceBook(programId, 'ReadyToPublish');
            }
            
        }
        System.debug('End: RWS_AccountTrigger_Handler.publishRecords() *****' );
    }

    private static void runAccountTeamUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap){
        //only run this if one of these fields changed...
        
        Map<String,String> roleToFieldMap = new Map<String,String>{
            'Credit Analyst'=>'Account_Credit_Analyst__c'
            ,'Industrial Sales Manager'=>'Account_Team_ISM__c'
            ,'Sales Rep'=>'Account_TSM__c'
            ,'Region Director'=>'Account_Region_Director__c'
            ,'Retail Operations Manager'=>'Account_ROM__c'
            ,'Retail Accounting Specialist'=>'Account_Retail_Acctg_Specialist__c'
        };
        
        boolean requeryAccountTeam = false;
        for(Id aId : newMap.keySet()){
            Account oldAcct = oldMap.get(aId);
            Account newAcct = newMap.get(aId);

            requeryAccountTeam |= 
                oldAcct.Account_Credit_Analyst__c != newAcct.Account_Credit_Analyst__c || 
              oldAcct.Account_Team_ISM__c != newAcct.Account_Team_ISM__c ||
              oldAcct.Account_TSM__c != newAcct.Account_TSM__c ||
              oldAcct.Account_Region_Director__c != newAcct.Account_Region_Director__c ||
                oldAcct.Account_ROM__c != newAcct.Account_ROM__c ||
              oldAcct.Account_Retail_Acctg_Specialist__c != newAcct.Account_Retail_Acctg_Specialist__c;
        }
        
        System.debug('JWL: queried account team? ' + queried_account_team);
        System.debug('JWL: requery account team? ' + requeryaccountteam);
        if(!QUERIED_ACCOUNT_TEAM || requeryAccountTeam){
            System.debug('JWL: querying account team...');
          List<AccountTeamMember> atml =
                [Select 
                    Id,
                    AccountId,
                    UserId,
                    TeamMemberRole 
                 FROM 
                    AccountTeamMember 
                 Where 
                    AccountId in :newMap.keySet()
                  And TeamMemberRole in :roleToFieldMap.keySet()];
            QUERIED_ACCOUNT_TEAM = true;
            
            System.debug('JWL: atml: ' + atml);
            
             Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
            
            for(Id aId : newMap.keySet()){
                Account newAcct = newMap.get(aId);
                for(AccountTeamMember atm : atml){
                    if(atm.AccountId == aId){
                        System.debug('JWL: found matching account');
                        String roleField = roleToFieldMap.get(atm.TeamMemberRole);
                        Object val = newAcct.get(roleField);
                        if(val == null || ((Id)val) != atm.UserId){
                            System.debug('JWL: role lookups differ..');
                            if(!accountsToUpdate.containsKey(aId)){
                                accountsToUpdate.put(aId, newAcct);
                            }
                            newAcct.put(roleField,atm.UserId);
                            System.debug('JWL: rolefield: ' + roleField);
                        }
                    }
                }
            }
            System.debug('JWL: accountsToUpdate: ' + accountsToUpdate);
        }
        System.debug('JWL: newMap: ' + newMap);
    }

    private static void ProcessUltimateParent(List<Account> newList, Map<Id, Account> oldMap) {
        //If newList is there and oldMap is null - this is After Insert
        //If oldMap is there and newList is null - this is Before Delete
        //If both are there - this is After Update
        Boolean isInsert = false;
        Boolean isDelete = false;
        Boolean isUpdate = false;

        if(newList != null && oldMap == null) {
            isInsert = true;
        }
        if(newList == null && oldMap != null) {
            isDelete = true;
        }
        if(newList != null && oldMap != null) {
            isUpdate = true;
        }

        //We need a set of all the account ids that need to be reassessed to set their Ultimate Parent
        Set<Id> acctIds = new Set<Id>();
        if(isInsert) {
            System.debug('DC: isInsert');
            //These are NEW accounts; they all get looked at if they have a parent id
            //If this is a NEW account - it wouldn't be a parent itself - yet.
            for(Account a : newList) {
                if(a.ParentId != null) {
                    acctIds.add(a.Id);
                }
            }
        }

        if(isDelete) {
            System.debug('DC: isDelete');
            //This account is going away - we need to track it and reprocess it's parent and children/grandchildren
            for(Account a : oldMap.values()) {
                acctIds.add(a.Id);
            }
        }

        if(isUpdate) {
            System.debug('DC: isUpdate');
            //Only need to worry about this one if the ParentId of it changed
            for(Account newA : newList) {
                Account oldA = oldMap.get(newA.Id);
                if(newA.ParentId != oldA.ParentId) {
                    acctIds.add(newA.Id);
                }
            }
        }

        //Now we have a set of all the unique acctIds that need to be re-looked at
        //for each of these... I need all of the children - and will add those to the SET as well
        // then pass the set to a future method
        for(Account a : [SELECT Id FROM Account WHERE ParentId IN :acctIds 
                                                    OR Parent.ParentId IN :acctIds 
                                                    OR Parent.Parent.ParentId IN :acctIds 
                                                    OR Parent.Parent.Parent.ParentId IN :acctIds 
                                                    OR Parent.Parent.Parent.Parent.ParentId IN :acctIds]) {
            System.debug('DC: a.Id - ' + a.Id);
            acctIds.add(a.Id);
        }

        if(acctIds.size() > 0) {
            Future_ProcessUltimateParent(acctIds);
        }

    }

    @future
    private static void Future_ProcessUltimateParent(Set<Id> acctIds) {
        //These are all of the accounts that need their Ultimate Parent reset.
        List<Account> updList = new List<Account>();
        for(Account a : [SELECT Id, Name, AccountNumber, Ultimate_Parent__c
                            , ParentId, Parent.Name, Parent.AccountNumber
                            , Parent.ParentId, Parent.Parent.Name, Parent.Parent.AccountNumber
                            , Parent.Parent.ParentId, Parent.Parent.Parent.Name, Parent.Parent.Parent.AccountNumber
                            , Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.Name, Parent.Parent.Parent.Parent.AccountNumber
                            , Parent.Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.Parent.Name, Parent.Parent.Parent.Parent.Parent.AccountNumber 
                            FROM Account
                            WHERE Id IN :acctIds]) {
            System.debug('DC: a - ' + a);                    
            Id ultParent = null;
            String ultName = '';
            String ultNumber = '';
            if(a.Parent.Parent.Parent.Parent.ParentId != null) {
                ultParent = a.Parent.Parent.Parent.Parent.ParentId;
                ultName = a.Parent.Parent.Parent.Parent.Parent.Name;
                ultNumber = a.Parent.Parent.Parent.Parent.Parent.AccountNumber;
            }
            System.debug('DC: 1ultParent: ' + ultParent);
            if(ultParent == null && a.Parent.Parent.Parent.ParentId != null) {
                ultParent = a.Parent.Parent.Parent.ParentId;
                ultName = a.Parent.Parent.Parent.Parent.Name;
                ultNumber = a.Parent.Parent.Parent.Parent.AccountNumber;
            }
            System.debug('DC: 2ultParent: ' + ultParent);
            if(ultParent == null && a.Parent.Parent.ParentId != null) {
                ultParent = a.Parent.Parent.ParentId;
                ultName = a.Parent.Parent.Parent.Name;
                ultNumber = a.Parent.Parent.Parent.AccountNumber;
            }
            System.debug('DC: 3ultParent: ' + ultParent);
            if(ultParent == null && a.Parent.ParentId != null) {
                ultParent = a.Parent.ParentId;
                ultName = a.Parent.Parent.Name;
                ultNumber = a.Parent.Parent.AccountNumber;
            }
            System.debug('DC: 4ultParent: ' + ultParent);
            if(ultParent == null && a.ParentId != null) {
                ultParent = a.ParentId;
                ultName = a.Parent.Name;
                ultNumber = a.Parent.AccountNumber;
            }
            System.debug('DC: 5ultParent: ' + ultParent);
            if(ultParent == null) {
                ultName = a.Name;
                ultNumber = a.AccountNumber;
            }
            System.debug('DC: a.Id: ' + a.Id);
            System.debug('DC: a.Ultimate_Parent__c: ' + a.Ultimate_Parent__c);
    
            if(ultParent != a.Id && ultParent != a.Ultimate_Parent__c) {
                a.Ultimate_Parent__c = ultParent;
                a.Ult_Parent_Acct_Name__c = ultName;
                a.Ult_Parent_Acct_Number__c = ultNumber;
                updList.add(a);
            }
        }

        System.debug('DC: updList: ' + updList);
        if(updList.size() > 0) {
            //update updList;
            List<Database.SaveResult> updResults = Database.update(updList, false);
            Integer i=0;
            for (Database.SaveResult sr : updResults) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug('DC: ' + updList.get(i).Id + ': ' + err.getMessage());
                    }
                }
                i++;
            }  
        }
    }

}