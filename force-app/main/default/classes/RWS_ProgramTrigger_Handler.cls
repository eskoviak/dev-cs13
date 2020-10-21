/********************************************************************************
*   PURPOSE :   Share program with all user related to the Account.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    	Description
*   12/09/2016  Usman Aslam/M360        	Initial version
*	06/22/2020	Sophia Murphy/Demand Chain	Update to mark IsEcommCustomer and HasDigitalVoucher on Acct
********************************************************************************/
public without sharing class RWS_ProgramTrigger_Handler {

    // method to handle before insert event of the trigger
    public static void beforeInsert(List<Program__c> newList) {
        // create share records
        setInvoiceAtributesRequiredOnProgram(newList, null, false); 
    }

    // method to handle after insert event of the trigger
    public static void afterInsert(List<Program__c> newList) {
        // create share records
        shareProgramAndAccount(newList); 

        // publish programs
        publishPrograms(newList, null, false);
    }

    // method to handle after update event of the trigger
    public static void afterUpdate(List<Program__c> newList, Map<Id, Program__c> oldRecords) {
        // publish programs
        publishPrograms(newList, oldRecords, true);

        // unpublish programs
        unpublishPrograms(newList, oldRecords);

        // share programs and related accounts based on program type
        shareProgramAndAccount(newList, oldRecords);

        // set active programs count on acount
        setActiveProgramsOnAccount(newList, oldRecords);
    }

    // method to handle before update event of the trigger
    public static void beforeUpdate(List<Program__c> newList, Map<Id, Program__c> oldRecords) {
        // set expiration date on program
        setExpirationDateOnProgram(newList, oldRecords);

        // set invoice attributes required on program
        setInvoiceAtributesRequiredOnProgram(newList, oldRecords, true);
    }

    // set active programs count on account
    private static void setActiveProgramsOnAccount(List<Program__c> newList, Map<Id, Program__c> oldRecords) {
        Set<Id> accountIds = new Set<Id>();

        // iterate over programs list
        for(Program__c p : newList) {
            
            Program__c pOld = oldRecords.get(p.Id);

            // account is null, move to next record
            if(p.Account__c == null) continue;

            //If Active__c, ecomm or digital fields change - we need to put this account id in the list.
            Boolean doAdd = false;
            
            if(p.Ecomm_Enabled__c != pOld.Ecomm_Enabled__c) {
                doAdd = true;
            }
            if(p.Eligibility_Option__c != pOld.Eligibility_Option__c) {
                doAdd = true;
            }
            if(p.Active__c != pOld.Active__c) {
                doAdd = true;
            }
            /**
            // active is not changed, move to next record
            if(p.Active__c == oldRecords.get(p.Id).Active__c) continue;
			*/
            // add account id in a set
            if(doAdd) {
            	accountIds.add(p.Account__c);
            }
        }

        // if set is empty, exit
        if(accountIds.isEmpty()) return;

        // code is being execute form the context of batch job or future call, exit
        if(System.isFuture() || System.isBatch())  return;

        // call future method to set count
        setActiveProgramsOnAccount(accountIds);
    }

     // future to set active programs count on account and avoid recursion
    @future
    public static void setActiveProgramsOnAccount(Set<Id> accountIds) {
        system.debug('DC: setActiveProgramsOnAccount');

        // retrieve accounts
        List<Account> accounts = [select Id, HasActiveProgram__c, Active__c, 
                                  IsEcommCustomer__c, HasDigitalVoucher__c, 
                (SELECT Id, Ecomm_Enabled__c, Eligibility_Option__c FROM Programs__r where Active__c = true)
            FROM Account where Id in :accountIds];

        system.debug('DC: accounts: ' + accounts);
        
        // initialize list
        List<Account> accountsToUpdate = new List<Account>();

        // iterate over accounts
        for(Account a : accounts) {
            system.debug('DC: a: ' + a);
            Boolean isEcomm = false;
            Boolean isDigital = false;

            // initialze variable to true if a have associated active programs
            Boolean hasPrograms = a.Programs__r != null && !a.Programs__r.isEmpty();
            if(hasPrograms) {
                //If they have an active program; then loop through the programs to see if they have ecomm/digital turned on
                for(Program__c p : a.Programs__r) {
            		system.debug('DC: p: ' + p);
                    if(p.Eligibility_Option__c == 'Yes' || p.Eligibility_Option__c == 'True') {
            		system.debug('DC: isDigital is true');
                        isDigital = true;
                    }
                    if(p.Ecomm_Enabled__c == 'Yes' || p.Ecomm_Enabled__c == 'True') {
                        isEcomm = true;
                    }
                }
            }
            
            system.debug('DC: hasPrograms: ' + hasPrograms);
            system.debug('DC: a.HasActiveProgram__c: ' + a.HasActiveProgram__c);
            system.debug('DC: isDigital: ' + isDigital);
            system.debug('DC: a.HasDigitalVoucher__c: ' + a.HasDigitalVoucher__c);
            system.debug('DC: isEcomm: ' + isEcomm);
            system.debug('DC: a.IsEcommCustomer__c: ' + a.IsEcommCustomer__c);
            
            //See if the account values have changed; if they haven't - there's no point in updating the account again
            if(hasPrograms != a.HasActiveProgram__c ||
              	isDigital != a.HasDigitalVoucher__c ||
               isEcomm != a.IsEcommCustomer__c) {
                   accountsToUpdate.add(new Account(Id = a.Id, 
                                    		HasActiveProgram__c = hasPrograms, 
                                            HasDigitalVoucher__c = isDigital,
                                            IsEcommCustomer__c = isEcomm,
                                    		Active__c = (!hasPrograms ? false : a.Active__c ) ) );
               }

            /**
            // flag on account is already have the same value, moved to next record
            if(a.HasActiveProgram__c == hasPrograms)  continue;

            // initialize variable for update and add it to a list
            accountsToUpdate.add(new Account(Id = a.Id, 
                                    HasActiveProgram__c = hasPrograms, 
                                    Active__c = (!hasPrograms ? false : a.Active__c ) ) );
			*/
        }

        // exit if list is empty
        if(accountsToUpdate.isEmpty() ) return;

        // update accounts
        update accountsToUpdate;
        
    }

    // set expiration date on Program when active is set to false
    private static void setExpirationDateOnProgram(List<Program__c> newList, Map<Id, Program__c> oldRecords) {
        // iterate over programs list
        for(Program__c p : newList) {
            // active field is changed and its value is fals
            if(p.Active__c != oldRecords.get(p.Id).Active__c && !p.Active__c) {
                //set expiration date as current
                p.Expiration_Date__c = date.today();
            }
        }
    }

    // set invoice attribute required on program
    private static void setInvoiceAtributesRequiredOnProgram(List<Program__c> newList, 
                                                                Map<Id, Program__c> oldRecords, 
                                                                Boolean isUpdate) {

        List<Program__c> relatedPrograms = new List<Program__c>();

        // iterate over programs list
        for(Program__c p : newList) {
			
            
            if(isUpdate)
            // if program is being inserted
            // OR
            // program is being updated AND
            // type is changed AND
            // Account is not null
            if(((!isUpdate) || (isUpdate && p.Type__c != null && p.Invoice_Attributes_Required__c == null)) && p.Account__c != null ) {
                
                // if program type is neither null nor cash and carry
                if(p.Type__c != null && p.Type__c != 'CashandCarry') {

                    // add it to a list
                    relatedPrograms.add(p);     
                } else {

                    // set value to None
                    p.Invoice_Attributes_Required__c = 'None';
                }
            }
        }
		
        // if list is not empty, send data to method for further processing
        if(!relatedPrograms.isEmpty()) setInvoiceAtributesRequiredOnProgram(relatedPrograms, false);
    }

    // set invoice attribute required on program
    public static void setInvoiceAtributesRequiredOnProgram(List<Program__c> newList, Boolean updateRecords) {
        Set<Id> accountIds = new Set<Id>();

        // iterate over programs list
        for(Program__c p : newList) {

            // add account id in a set
            accountIds.add(p.Account__c);
        }
        // get accounts populated date in a Map
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [select Id, Invoice_Atributes_Required__c 
                from Account 
                where Id = :accountIds /*
                and Invoice_Atributes_Required__c != null */ ]
        );

        // iterate over programs list
        for(Program__c p : newList) {

            // get account
            Account acc = accountsMap.get(p.Account__c);
            // account is null, move to next record
            if(acc == null) continue;

            // set value on Invoice_Attributes_Required from account.Invoice_Attributes_Required
            p.Invoice_Attributes_Required__c = String.isBlank(acc.Invoice_Atributes_Required__c) ? 'None' : acc.Invoice_Atributes_Required__c;

            // if publish status is published
            if(p.Publish_Status__c == 'Published') {

                // set new values
                p.Outbound_Message_Type__c = 'Update Program';
                p.Publish_Status__c = 'ReadyToPublish';  
            }
        }

        // update record when this method is called from Account trigger
        System.debug('********* update Records: '+updateRecords);
        System.debug('********* newList: '+newList);
        if(updateRecords) {
            update newList;
        }
    }

    // flag to make sure unpublish code is executed once
    private static Boolean RUN_ONCE_UNPUBLISH = true;

    // method for unpublishing programs
    private static void unpublishPrograms(List<Program__c> newList, Map<Id, Program__c> oldRecords) {
        System.debug('*** RWS_ProgramTrigger_Hander.unpublishPrograms() - Begin');
        Set<Id> programsProcessedIds = new Set<Id>();

        // iterate over all programs
        for(Program__c p : newList) {
            // Active is changed
            // AND
            // Expiration data = today
            // AND
            // Active is FALSE
            if(p.Active__c != oldRecords.get(p.Id).Active__c && p.Expiration_Date__c == date.today() && !p.Active__c) {

                // add program id to a set
                programsProcessedIds.add(p.Id);
            }
        }


        List<Program__c> progupdateList = new List<Program__c>();
        List<Servicing_Store__c> servicingStoreUpdateList = new List<Servicing_Store__c>();

        // no programs valid for further processing, exit
        if(programsProcessedIds.isEmpty()) {
            System.debug('No programs need to be unpublished. Exiting...');
            return;
        }

        // query programs for latest values
        List<Program__c> progList = [select id, Program_ID__c, Publish_Status__c,
                    Active__c,Outbound_Message_Type__c
                    from Program__c where Id in :programsProcessedIds];


        // iterate over programs list
        for(Program__c proObj : progList){

            //Set programs to Deactivated
            proObj.Outbound_Message_Type__c = 'Update Program';
            proObj.Publish_Status__c = 'Deactivated'; 
            progupdateList.add(proObj);
        }

        // get servicing stores
        for(Servicing_Store__c ss : [select id, Publish_Status__c, 
                                    Outbound_Message_Type__c 
                                from Servicing_Store__c 
                                where Program__c in :programsProcessedIds
                               // and Publish_Status__c = 'Published'
								])
        {
            // set new values
            ss.Publish_Status__c = 'Deactivated';
            ss.Outbound_Message_Type__c = 'Update Servicing Store';
            servicingStoreUpdateList.add(ss); 
        }

        
        if(RUN_ONCE_UNPUBLISH){

            // turn processing flag off
            RUN_ONCE_UNPUBLISH = false;

            // update programs
            // try five times, if a try fails for ROW LOCKING issue
            if(!progupdateList.isEmpty()){
                Integer attempts = 5;
                while(attempts > 0){
                    try {
                        attempts --; 
                        update progupdateList;
                        attempts = 0;
                    } catch (System.DmlException dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                        if(attempts == 0) { throw dmlEx; }
                    } // end of catch
                } // end of while retry loop
            }

            // update servicing stores
            // try five times, if a try fails for ROW LOCKING issue
            if(!servicingStoreUpdateList.isEmpty()){
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

            // exit if current code is being executed from the context of batch or future call
            if(System.isBatch() || System.isFuture()) return;

            // iterate over porgram ids
            for(Id programId : programsProcessedIds) {

                // utilize upto 90% of future calls
                if(System.Limits.getFutureCalls() >  System.Limits.getLimitFutureCalls() * 0.90) continue;

                // unpublish price books
                RWS_ProgramPublish_Util.unpublishPriceBook(programId);
            }

        }
        System.debug('*** RWS_ProgramTrigger_Hander.unpublishPrograms() - End');
    }

    // flag to make sure unpublish code is executed once
    private static Boolean RUN_ONCE = true;

    // method to publish programs
    private static void publishPrograms(List<Program__c> newList, Map<Id, Program__c> oldRecords, Boolean isUpdate) {
        
        // initialize variables required for logic
        Set<Id> proIdSet = new Set<Id>();
        List<Program__c> progList = new List<Program__c>();
        Map<Id, Program__c> progupdateList = new Map<Id, Program__c>();
        
        List<Servicing_Store__c> servicingStoreUpdateList = new List<Servicing_Store__c>();

        // get program ids
        for(Program__c pro : newList){
            proIdSet.add(pro.Id);
        }       

        // get programs with values updated by workflow
        progList = [select id, Program_ID__c, Publish_Status__c,
                                Outbound_Message_Type__c,Active__c,
                                Account__r.Active__c,Account__r.Publish_Status__c 
                    from Program__c where Id in :proIdSet];

                    
        Set<String> programsProcessedIds = new Set<String>();

        // iterate over programs list
        for(Program__c proObj : progList){
            
            // if status is ReadyToPublish or  Waiting or just changed to published, do nothing
            if((proObj.Publish_Status__c == 'ReadyToPublish') || (proObj.Publish_Status__c == 'Waiting') ||
                (isUpdate && proObj.Publish_Status__c == 'Published' && 
                    proObj.Publish_Status__c != oldRecords.get(proObj.id).Publish_Status__c))
                continue;

            // account is active
            // and
            // program status is published 
            // and
            // programs is active
            if (proObj.Account__r.Active__c == true && proObj.Account__r.Publish_Status__c == 'Published' && proObj.Active__c == true){

                //set new values
                proObj.Outbound_Message_Type__c = 'Update Program';
                proObj.Publish_Status__c = 'ReadyToPublish';  
                progupdateList.put(proObj.Id, proObj);
                programsProcessedIds.add(proObj.Id);
            }

            // account is not active
            // or
            // program status is published 
            // and
            // programs is active 
            else if ((proObj.Account__r.Active__c == false || proObj.Account__r.Publish_Status__c == 'Published') && proObj.Active__c == true 
                && proObj.Publish_Status__c != 'Waiting' ){

                //set new values
                proObj.Publish_Status__c = 'Waiting';  
                progupdateList.put(proObj.Id, proObj);
                programsProcessedIds.add(proObj.Id);
            }    
        }

        // new values are being set on program
        if(!programsProcessedIds.isEmpty()) {
            
            // get servicing stores
            for(Servicing_Store__c ss : [select id, Publish_Status__c, 
                                        Outbound_Message_Type__c,
                                        Program__c 
                                    from Servicing_Store__c 
                                    where Program__c in :progupdateList.keySet() 
                                    and Publish_Status__c = 'Waiting'])
            {

                Program__c p = progupdateList.get(ss.Program__c);

                // set new values
                ss.Publish_Status__c = p.Publish_Status__c;
                ss.Outbound_Message_Type__c = 'Update Servicing Store';
                servicingStoreUpdateList.add(ss); 
            }
        }

        if(RUN_ONCE){

            // turn processing flag of 
            RUN_ONCE = false;

            
            // update programs
            // try five times, if a try fails for ROW LOCKING issue
            if(!progupdateList.isEmpty()){
                Integer attempts = 5;
                while(attempts > 0){
                    try {
                        attempts --; 
                        update progupdateList.values();
                        attempts = 0;
                    } catch (System.DmlException dmlEx) {
                        if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                        if(attempts == 0) { throw dmlEx; }
                    } // end of catch
                } // end of while retry loop
            }

            // update servicing stores
            // try five times, if a try fails for ROW LOCKING issue
            if(!servicingStoreUpdateList.isEmpty()){
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

            // exit if current code is being executed from the context of batch or future call
            if(System.isBatch() || System.isFuture()) return;

            // iterate over program ids that are processed in this method
            for(Id programId : programsProcessedIds) {
                Program__c p = progupdateList.get(programId);

                if(p == null) continue;

                // use upto 90% of future calls limit
                if(System.Limits.getFutureCalls() >  System.Limits.getLimitFutureCalls() * 0.90) continue;

                // publis price book
                RWS_ProgramPublish_Util.publishPriceBook(programId, p.Publish_Status__c);
            }

        }

    }

    
    // method to set expiration date on servicing stores
    public static void setExpirationDateOnServicingStores(List<Program__c> relatedPrograms) {
        
        // retrieve servicing stores related to programs
        List<Servicing_Store__c> servicingStores = [select Id, Program__c, 
                                                            Servicing_Status__c, 
                                                            Publish_Status__c, 
                                                            Active__c
                                                        from Servicing_Store__c
                                                        where Program__c in :relatedPrograms
                                                   		and Active__c = true];

        // exit if servicing store are not found
        if(servicingStores.isEmpty()) return;

        // itervate over records
        for(Servicing_Store__c ss : servicingStores) {

            // set new values
            ss.Servicing_Status__c = 'Inactive';
            ss.Publish_Status__c = 'Deactivated';
            ss.Active__c = false;
            ss.Expiration_Date__c = DateTime.now();
        }

        // update servicing store records
        update servicingStores;
    }

    // flag to make sure sharing code is executed once
    private static Boolean RUN_SHARE_ONCE = true;

    // method to share Program and Account records based on servicing level in case of update
    private static void shareProgramAndAccount(List<Program__c> newList, Map<Id, Program__c> oldRecords) {

        List<Program__c> relatedPrograms = new List<Program__c>();
        List<Program__c> relatedOldPrograms = new List<Program__c>();

        // get programs for further processing
        // if servicing level 
        // or
        // owner Id
        // or
        // account is changed
        for(Program__c p : newList) {
            if(p.Servicing_Level__c == oldRecords.get(p.Id).Servicing_Level__c && 
               p.OwnerId == oldRecords.get(p.Id).OwnerId &&
               p.Account__c == oldRecords.get(p.Id).Account__c ) continue;

            if(!String.valueOf(p.OwnerId).startsWith('005')) continue;

            relatedPrograms.add(p);
            relatedOldPrograms.add(oldRecords.get(p.Id));
        }

        // if no program is valid for further processing, exit
        if(relatedPrograms.isEmpty()) return;

        if(!RUN_SHARE_ONCE) return;

        // turn off sharing code processing flag
        RUN_SHARE_ONCE = Test.isRunningTest();

        // set expiration date on programs
        setExpirationDateOnServicingStores(relatedPrograms);

        // remove old access records based on old owner id, account and service level
        removeProgramAndAccountAccess(relatedOldPrograms);

        // create new access records
        shareProgramAndAccount(new Map<Id, Program__c>(relatedPrograms).keySet());
    }    

    // future method to handle sharing in case of update
    @future
    public static void shareProgramAndAccount(Set<Id> programIds) {
        // get programs
        List<Program__c> newList = [select Id, OwnerId, Servicing_Level__c, Account__c 
                                        from Program__c
                                    where Id in :programIds];

        // forward records for further processing
        shareProgramAndAccount(newList);                       
    }

    // method to share Program and Account records based on servicing level in case of insert
    public static void shareProgramAndAccount(List<Program__c> newList) {

        // initialize variables
        List<Program__c> relatedPrograms = new List<Program__c>();

        Set<Id> ownerIds = new Set<Id>();

        // iterate over program record
        for(Program__c p : newList) {

            // if program owner is not a user, move to next record
            if(!String.valueOf(p.OwnerId).startsWith('005')) continue;

            // add program to a list
            relatedPrograms.add(p);

            // add onwer to a set
            ownerIds.add(p.OwnerId);
        }

        // if list is empty, exit
        if(relatedPrograms.isEmpty()) return;

        // get users from ISM and NAM public groups
        List<Set<Id>> ismAndNamUsers = RWS_UtilityClass.getIsmAndNamUser();

        Set<Id> ismUserIds = ismAndNamUsers[0];
        Set<Id> namUserIds = ismAndNamUsers[1];

        Set<Id> allInternalUserIds = new Set<Id>();

        allInternalUserIds.addAll(ismUserIds);
        allInternalUserIds.addAll(namUserIds);

        // get user details
        Map<Id, User> currentUsersMap 
            = new Map<Id, User>(
                [select Id, Contact.Account.Store_Ownership_Type__c, Contact.Account.Dealer__c, 
                                    Contact.Account.Region_Code__c, Contact.AccountId, AccountId
                            from User
                            where Id in :ownerIds
                            and IsActive = true]
                );

        //updated by Joey, to fit Branded_user scenario.
        //query all 3 groups and assign Dealer and Corperate to grouplist as before
        //assign Branded User separately to brandedGroupId.
        // get group details
        list<Group> groupList = [select Id, DeveloperName from Group where DeveloperName in ('Branded_Users', 'Dealer_Users', 'Corporate_Users')];

        // initialize variables with group details
        Set<Id> validGroups = new Set<Id>();
        Id brandedGroupId;
        for(Group g: groupList){
            if(g.DeveloperName == 'Dealer_Users' ||g.DeveloperName == 'Corporate_Users'){
                validGroups.add(g.Id);
            }if(g.DeveloperName == 'Branded_Users'){
                brandedGroupId = g.Id;
            }
        }

        // get truck managers group id
        Id truckManagerGroup = [select Id from Group 
                                    where DeveloperName = 'Truck_Managers'].Id;



        Set<ID> accountIdsSet = new Set<ID>();

        // get account ids
        for (Program__c p : relatedPrograms) {

            if(p.Account__c != null)  accountIdsSet.add(p.Account__c);
        }

        // if no account is found, exit
        if(accountIdsSet.isEmpty()) return;

        // get account details
        Map<Id, Account> accountsMap = new Map<Id, Account>([select Id, Dealer__c, Region_Code__c, 
            OwnerId from Account where Id in :accountIdsSet]);
        
        Set<Id> allAccountIds = new Set<Id>();

        allAccountIds.addAll(accountIdsSet);

        // add dealer ids and region code in their respective sets
        Set<Id> dealerIds = new Set<Id>();
        Set<String> regionCodes = new Set<String>();
        for(User currentUser : currentUsersMap.values()) {
            allAccountIds.add(currentUser.Contact.AccountId);
            dealerIds.add(currentUser.Contact.Account.Dealer__c);
            regionCodes.add(currentUser.Contact.Account.Region_Code__c);
        }
        
        Map<Id, Set<Id>> dealerIdToDealerGroup = new Map<Id, Set<Id>>();
        
        // if dealers ids set is not empty
        if(!dealerIds.isEmpty()) {
            // get accounts based on dealer ids
            for(Account a : [select Id, Dealer__c from Account 
                             where Dealer__c != null and Dealer__c in :dealerIds]) {


                // populate map, dealer id > all accounts in dealer group
                Set<Id> dealerGroup = dealerIdToDealerGroup.get(a.Dealer__c);
    
                if(dealerGroup == null) {
                    dealerGroup = new Set<Id>();
                    dealerIdToDealerGroup.put(a.Dealer__c, dealerGroup);                
                }
    
                dealerGroup.add(a.Id);
                allAccountIds.add(a.Id);
            }
        }

        Map<String, Set<Id>> regionCodeToDealerGroup = new Map<String, Set<Id>>();
        Map<String, Set<Id>> regionCodeToCorporateGroup = new Map<String, Set<Id>>();

        // if region codes set is not empty
        if(!regionCodes.isEmpty()) {
            // get account based on account set
            for(Account a : [select Id, Region_Code__c, Store_Ownership_Type__c from Account 
                                where Region_Code__c != null 
                                    and Region_Code__c in :regionCodes 
                                    and Store_Ownership_Type__c != null]) {
    
                // if onwership type is Dealer
                if(a.Store_Ownership_Type__c == 'Dealer') {

                    // populate map, dealer region code > all accounts in dealer region code
                    Set<Id> dealerGroup = regionCodeToDealerGroup.get(a.Region_Code__c);
    
                    if(dealerGroup == null) {
                        dealerGroup = new Set<Id>();
                        regionCodeToDealerGroup.put(a.Region_Code__c, dealerGroup);                
                    }
    
                    dealerGroup.add(a.Id);
                }
    
                // if onwership type is Corporate
                if(a.Store_Ownership_Type__c == 'Corporate') {

                    // populate map, corporate region code > all accounts in corporate region code
                    Set<Id> dealerGroup = regionCodeToCorporateGroup.get(a.Region_Code__c);
    
                    if(dealerGroup == null) {
                        dealerGroup = new Set<Id>();
                        regionCodeToCorporateGroup.put(a.Region_Code__c, dealerGroup);                
                    }
    
                    dealerGroup.add(a.Id);
                }
    
                allAccountIds.add(a.Id);
            }
        }

        // Gets a map of all account exceptions mapped by region - Added by BW 4/18/2018
        Map<String, Region_Exception__c> csMap = Region_Exception__c.getAll();
        Set<Id> dealerExceptionSet = new Set<Id>();
        
        for(Region_Exception__c cs : csMap.values()) {

            // split the CSV field into a List<String> of Account Ids
            List<String> dealerExceptions = cs.Accounts_CSV__c.split(',');
            
            // for every String in list add the Id value of the string to dealer Id set
            for (String IdString : dealerExceptions){
                dealerExceptionSet.add(Id.valueOf(IdString));                    
            }
        }
        
        allAccountIds.addAll(dealerExceptionSet);



        Map<Id, Set<Id>> accountIdToUserIds = new Map<Id, Set<Id>>();

        // get users under all related accounts
        for(User u : [select Id, AccountId from User where AccountId in :allAccountIds]) {

            // populate map, account id > all users under that account
            Set<Id> userIds = accountIdToUserIds.get(u.AccountId);

            if(userIds == null) {
                userIds = new Set<Id>();
                accountIdToUserIds.put(u.AccountId, userIds);
            }

            userIds.add(u.Id);
        }

        // init list to insert servicing stores
        List<Servicing_Store__c> ssToInsert = new List<Servicing_Store__c>();

        Set<String> existingServicingStores = new Set<String>();

        // get existing servicing stores under the same programs
        for(Servicing_Store__c ss : [select Account__c, Program__c 
                                        from 
                                    Servicing_Store__c
                                    where Servicing_Status__c != 'Inactive'
                                    and Program__c in :relatedPrograms]) {

            existingServicingStores.add((ss.Account__c == null ? 'NULL' : String.valueOf(ss.Account__c)) + 
                                        String.valueOf(ss.Program__c) );

        }

        // Lists used to insert new sharing records
        List<AccountShare> accountSharesToInsert = new List<AccountShare>();
        List<Program__Share> programSharesToInsert = new List<Program__Share>();
        
        // iterate over the programs that needs to be processed
        for(Program__c p : relatedPrograms) {

            // move to next record if account is null
            if(p.Account__c == null) continue;

            // get onwer of the program and treat it as logged in user
            User currentUser = currentUsersMap.get(p.OwnerId);
 
            // logged in user info is not found, move to next record
            if(currentUser == null) continue;

            // get account ownership type
            String accountType = currentUser.Contact.Account.Store_Ownership_Type__c;

            // get account details
            Account acc = accountsMap.get(p.Account__c);

            // get account dealer group based on delaer id
            Set<Id> dealerGroup = dealerIdToDealerGroup.get(currentUser.Contact.Account.Dealer__c);

            if(dealerGroup == null) dealerGroup = new Set<Id>();

            // get dealers based on region code
            Set<Id> dealers =  regionCodeToDealerGroup.get(currentUser.Contact.Account.Region_Code__c);

            if(dealers == null) dealers = new Set<Id>();
            
            // if custom setting map has a key that matches current user's region code
            if (csMap.containsKey(currentUser.Contact.Account.Region_Code__c)){
              
                dealerExceptionSet = new Set<Id>();
                
                // Get custom setting data set for user region
		        Region_Exception__c cs = csMap.get(currentUser.Contact.Account.Region_Code__c); 
                
                // split the CSV field into a List<String> of Account Ids
                List<String> dealerExceptions = cs.Accounts_CSV__c.split(',');
                
                // for every String in list add the Id value of the string to dealer Id set
                for (String IdString : dealerExceptions){
                	dealerExceptionSet.add(Id.valueOf(IdString));                    
                }
                
                // add dealer exception Id Set to dealer Id Set
                dealers.addAll(dealerExceptionSet);
            }

            // get companies based on region code
            Set<Id> companies =  regionCodeToCorporateGroup.get(currentUser.Contact.Account.Region_Code__c);

            if(companies == null) companies = new Set<Id>();

            Set<Id> allRelatedAccountIds = new Set<Id>();
            
            // if account onwership type is Dealer
            // AND
            // program servicing level is either DealerOnly OR DealerMarketAreaProgram
            if(accountType == 'Dealer' && (p.Servicing_Level__c == 'DealerOnly' || p.Servicing_Level__c == 'DealerMarketAreaProgram')) {

                // add current user account
                allRelatedAccountIds.add(currentUser.Contact.AccountId);
                
                // add dealer group
                allRelatedAccountIds.addAll(dealerGroup);
            }
            
            // if account onwership type is Dealer
            // AND 
            // program servicing level is DealerMarketAreaProgram
            if(accountType == 'Dealer' && p.Servicing_Level__c == 'DealerMarketAreaProgram') {

                // add dealer by region code
                allRelatedAccountIds.addAll(dealers);

                // add companies by region code
                allRelatedAccountIds.addAll(companies);
            }
            
            // Program Owner is an internal user and account onwership type is Corporate OR program servicing level is RWSS
            // OR
            // Program Owner is an internal user and program servicing level is RWSSPlus
            if( (
                (accountType == 'Corporate' || allInternalUserIds.contains(p.OwnerId)) 
                && p.Servicing_Level__c == 'RWSS')
                || 
                (allInternalUserIds.contains(p.OwnerId) && p.Servicing_Level__c == 'RWSSPlus') ) {

                // add account in dealer group group
                allRelatedAccountIds.addAll(dealerGroup);

                // create servicing store, if already doesn't exist        
                if(!existingServicingStores.contains('NULL' + String.valueOf(p.Id)) ) {
                    ssToInsert.add(new Servicing_Store__c(Account__c = null, Program__c = p.Id, 
                                                        Servicing_Status__c = 'Active',
                                                        Program_Service_Level__c = p.Servicing_Level__c));
                }

                // create account and program share records for the public groups
                for(Id gId : validGroups) {
                    programSharesToInsert.add(new Program__Share(
                            ParentId = p.Id,
                            AccessLevel = 'Read',
                            UserorGroupId = gId
                        )
                    );

                    // intialize account share objects
                    accountSharesToInsert.add(
                        new AccountShare(AccountId = p.Account__c,
                                  UserorGroupId = gId,
                                  AccountAccessLevel ='Read',
                                  OpportunityAccessLevel = 'Read')
                    );
                }
            }
            
            // account owner id is an internal user, create program share records from truck managers
            if(allInternalUserIds.contains(acc.OwnerId)) {
                programSharesToInsert.add(new Program__Share(
                            ParentId = p.Id,
                            AccessLevel = ismUserIds.contains(acc.OwnerId) ? 'Edit' : 'Read',
                            UserorGroupId = truckManagerGroup
                        )
                    );
            }
            
            // this portion is related to dealer and corporate users 
            // if account type is deal and servicing level is either DealerOnly or DealerMarketAreaProgram
            // OR 
            // account type corporate and servicing level is RWSS
            if ((accountType == 'Dealer' 
                        && (p.Servicing_Level__c == 'DealerOnly' || 
                            p.Servicing_Level__c == 'DealerMarketAreaProgram')) ||

                (accountType == 'Corporate' && p.Servicing_Level__c == 'RWSS') ) {
            
                Set<Id> currentUserCoworkers = accountIdToUserIds.get(currentUser.AccountId);


                // this portion is related to dealer users only
                // ideally we are going provide Edit access in IF
                // IF the Program Owner is of Type Dealer but some internal User selects RWSS
                if(currentUserCoworkers != null) {
    
                    for(Id uId : currentUserCoworkers) {
                        programSharesToInsert.add(new Program__Share(
                                ParentId = p.Id,
                                AccessLevel = 'Edit',
                                UserorGroupId = uId
                            )
                        );
    
                        // intialize account share objects
                        accountSharesToInsert.add(
                            new AccountShare(AccountId = p.Account__c,
                                      UserorGroupId = uId,
                                      AccountAccessLevel = 'Edit',
                                      OpportunityAccessLevel = 'Read')
                        );    
                    }
                }
            }

            // this portion is related to dealer users only
            // if account type is deal and servicing level is either DealerOnly or DealerMarketAreaProgram
            if(accountType == 'Dealer' 
                        && (p.Servicing_Level__c == 'DealerOnly' || 
                            p.Servicing_Level__c == 'DealerMarketAreaProgram') ) {   
                
                // remove ids that already processed
                if(allRelatedAccountIds.contains(p.Account__c)) allRelatedAccountIds.remove(p.Account__c);

                if(allRelatedAccountIds.contains(currentUser.AccountId)) allRelatedAccountIds.remove(currentUser.AccountId);

                // create servicing store, if already doesn't exist     
                if(!existingServicingStores.contains(currentUser.AccountId + String.valueOf(p.Id)) ) {
                    ssToInsert.add(new Servicing_Store__c(Account__c = currentUser.AccountId, Program__c = p.Id, 
                                                        Servicing_Status__c = 'Active',
                                                        Program_Service_Level__c = p.Servicing_Level__c));
                }
                
                // iterate over all accounts related to program account
                for(Id aId : allRelatedAccountIds) {

                    // provide Read access for the accounts which are not in dealer group
                    String access = 'Read';

                    // if part of dealer group, provide edit access
                    if(dealerGroup.contains(aId)) {

                        access = 'Edit';
                    }
                    
                    // create servicing store, if already doesn't exist    
                    if(!existingServicingStores.contains(aId + String.valueOf(p.Id)) ) {
                        ssToInsert.add(new Servicing_Store__c(Account__c = aId, Program__c = p.Id, 
                                                        Servicing_Status__c = 'Active',
                                                        Program_Service_Level__c = p.Servicing_Level__c));
                    }
    
                    // get users related to accounts
                    Set<Id> userIds = accountIdToUserIds.get(aId);
                    
                    if(userIds == null) continue;
                    
                    // create account and program share records for the users
                    for(Id uId : userIds) {
                        programSharesToInsert.add(new Program__Share(
                                ParentId = p.Id,
                                AccessLevel = access,
                                UserorGroupId = uId
                            )
                        );
    
                        // intialize account share objects
                        accountSharesToInsert.add(
                            new AccountShare(AccountId = p.Account__c,
                                      UserorGroupId = uId,
                                      AccountAccessLevel = access,
                                      OpportunityAccessLevel = 'Read'
                                    )
                        );    
                    }
                }
            }

            //added by Joey, if Service level is RWSS +, share to Branded user group.
            if(p.Servicing_Level__c == 'RWSSPlus' && (allInternalUserIds.contains(p.OwnerId))){
                programSharesToInsert.add(new Program__Share(
                        ParentId = p.Id,
                        AccessLevel = 'Read',
                        UserorGroupId = brandedGroupId
                    )
                );

                // intialize account share objects
                accountSharesToInsert.add(
                    new AccountShare(AccountId = p.Account__c,
                              UserorGroupId = brandedGroupId,
                              AccountAccessLevel = 'Read',
                              OpportunityAccessLevel = 'Read')
                );  
            }

        }

        // insert servicing store records
        insert ssToInsert;
        
        // to avoid failure if a user already have a share record.
        Database.insert(programSharesToInsert, false);
        Database.insert(accountSharesToInsert, false); 
    }

    // method to remove account and program sharing when 
    // account or servicing level or owner id is changed on the program
    public static void removeProgramAndAccountAccess(List<Program__c> newList) {
        List<Program__c> relatedPrograms = new List<Program__c>();

        Set<Id> ownerIds = new Set<Id>();

        // get programs and ownerids the needs to be processed
        for(Program__c p : newList) {

            if(!String.valueOf(p.OwnerId).startsWith('005')) continue;

            relatedPrograms.add(p);

            ownerIds.add(p.OwnerId);
        }

        // exit if there no programs that need to be processed
        if(relatedPrograms.isEmpty()) return;

        // get users in ISM and NAM publich groups
        List<Set<Id>> ismAndNamUsers = RWS_UtilityClass.getIsmAndNamUser();

        Set<Id> ismUserIds = ismAndNamUsers[0];
        Set<Id> namUserIds = ismAndNamUsers[1];

        Set<Id> allInternalUserIds = new Set<Id>();

        allInternalUserIds.addAll(ismUserIds);
        allInternalUserIds.addAll(namUserIds);

        // get use details
        Map<Id, User> currentUsersMap 
            = new Map<Id, User>(
                [select Id, Contact.Account.Store_Ownership_Type__c, Contact.Account.Dealer__c, 
                                    Contact.Account.Region_Code__c, Contact.AccountId, AccountId,
                 					Contact.Account.Sharing_Old_Values__c,
                                    Contact.Account.Sharing_Status__c
                            from User
                            where Id = :ownerIds
                            and IsActive = true]
                );

        //updated by Joey, to fit Branded_user scenario.
        //query all 3 groups and assign Dealer and Corperate to grouplist as before
        //assign Branded User separately to brandedGroupId.

        // get group details
        list<Group> groupList = [select Id, DeveloperName from Group where DeveloperName in ('Branded_Users', 'Dealer_Users', 'Corporate_Users')];

        // initialize variables with group details
        Set<Id> validGroups = new Set<Id>();
        Id brandedGroupId;
        for(Group g: groupList){
            if(g.DeveloperName == 'Dealer_Users' ||g.DeveloperName == 'Corporate_Users'){
                validGroups.add(g.Id);
            }if(g.DeveloperName == 'Branded_Users'){
                brandedGroupId = g.Id;
            }
        }

        // get truck manager group id
        Id truckManagerGroup = [select Id from Group 
                                    where DeveloperName = 'Truck_Managers'].Id;



        Set<ID> accountIdsSet = new Set<ID>();
        // get account ids
        for (Program__c p : relatedPrograms) {

            if(p.Account__c != null)  accountIdsSet.add(p.Account__c);
        }

        // if accounts set is empty, exit
        if(accountIdsSet.isEmpty()) return;

        // get account details
        Map<Id, Account> accountsMap = new Map<Id, Account>([select Id, Dealer__c, Region_Code__c, 
            OwnerId from Account where Id in :accountIdsSet]);
        
        Set<Id> allAccountIds = new Set<Id>();

        allAccountIds.addAll(accountIdsSet);

        // get dealer id and region code
        Set<Id> dealerIds = new Set<Id>();
        Set<String> regionCodes = new Set<String>();
        for(User currentUser : currentUsersMap.values()) {
            allAccountIds.add(currentUser.Contact.AccountId);
            dealerIds.add(currentUser.Contact.Account.Dealer__c);
            regionCodes.add(currentUser.Contact.Account.Region_Code__c);
        }
        

        Map<Id, Set<Id>> dealerIdToDealerGroup = new Map<Id, Set<Id>>();
        
        // if dealer ids set is not empty
        if(!dealerIds.isEmpty()) {

            // get accounts based on dealer id
            for(Account a : [select Id, Dealer__c from Account 
                             where Dealer__c != null and Dealer__c in :dealerIds]) {

                // populate map, dealer id > accounts in dealer group
                Set<Id> dealerGroup = dealerIdToDealerGroup.get(a.Dealer__c);
    
                if(dealerGroup == null) {
                    dealerGroup = new Set<Id>();
                    dealerIdToDealerGroup.put(a.Dealer__c, dealerGroup);                
                }
    
                dealerGroup.add(a.Id);
                allAccountIds.add(a.Id);
            }
        }

        Map<String, Set<Id>> regionCodeToDealerGroup = new Map<String, Set<Id>>();
        Map<String, Set<Id>> regionCodeToCorporateGroup = new Map<String, Set<Id>>();

        // if region codes set is not empty
        if(!regionCodes.isEmpty()) {

            // get accounts base on region code
            for(Account a : [select Id, Region_Code__c, Store_Ownership_Type__c from Account 
                                where Region_Code__c != null 
                                    and Region_Code__c in :regionCodes 
                                    and Store_Ownership_Type__c != null]) {
    
                // if account type is Dealer
                if(a.Store_Ownership_Type__c == 'Dealer') {

                    // populate map, region code > dealer accounts in region
                    Set<Id> dealerGroup = regionCodeToDealerGroup.get(a.Region_Code__c);
    
                    if(dealerGroup == null) {
                        dealerGroup = new Set<Id>();
                        regionCodeToDealerGroup.put(a.Region_Code__c, dealerGroup);                
                    }
    
                    dealerGroup.add(a.Id);
                }
    
                // if account type is Corporate
                if(a.Store_Ownership_Type__c == 'Corporate') {

                    // populate map, region code > company accounts in region
                    Set<Id> dealerGroup = regionCodeToCorporateGroup.get(a.Region_Code__c);
    
                    if(dealerGroup == null) {
                        dealerGroup = new Set<Id>();
                        regionCodeToCorporateGroup.put(a.Region_Code__c, dealerGroup);                
                    }
    
                    dealerGroup.add(a.Id);
                }
    
                allAccountIds.add(a.Id);
            }
        }

        Map<Id, Set<Id>> accountIdToUserIds = new Map<Id, Set<Id>>();

        // get users under account
        for(User u : [select Id, AccountId from User where AccountId in :allAccountIds]) {

            // populate map, account id > users under the account
            Set<Id> userIds = accountIdToUserIds.get(u.AccountId);

            if(userIds == null) {
                userIds = new Set<Id>();
                accountIdToUserIds.put(u.AccountId, userIds);
            }

            userIds.add(u.Id);
        }

        Set<Id> programIdsForShareDelete = new Set<Id>();
        Set<Id> accountIdsForShareDelete = new Set<Id>();
        Set<Id> userOrGroupdIdsForShareDelete = new Set<Id>();

        // Gets a map of all account exceptions mapped by region - Added by BW 4/18/2018
        Map<String, Region_Exception__c> csMap = Region_Exception__c.getAll();
        
        for(Program__c p : relatedPrograms) {

            // account is null, move to next record
            if(p.Account__c == null) continue;

            // get owner of the program and treat is a the currently logged in user
            User currentUser = currentUsersMap.get(p.OwnerId);

            // if current user info is not found, move to next record
            if(currentUser == null) continue;

            // get account type
            String accountType = currentUser.Contact.Account.Store_Ownership_Type__c;

            // get account details
            Account acc = accountsMap.get(p.Account__c);

            // get accounts in dealer group
            Set<Id> dealerGroup = dealerIdToDealerGroup.get(currentUser.Contact.Account.Dealer__c);

            if(dealerGroup == null) dealerGroup = new Set<Id>();

            // get dealers in region code
            Set<Id> dealers =  regionCodeToDealerGroup.get(currentUser.Contact.Account.Region_Code__c);
			
            // if custom setting map has a key that matches current user's region code
            if (csMap.containsKey(currentUser.Contact.Account.Region_Code__c)){
              
                Set<Id> dealerExceptionSet = new Set<Id>();
                
                // Get custom setting data set for user region
		        Region_Exception__c cs = csMap.get(currentUser.Contact.Account.Region_Code__c); 
                
                // split the CSV field into a List<String> of Account Ids
                List<String> dealerExceptions = cs.Accounts_CSV__c.split(',');
                
                // for every String in list add the Id value of the string to dealer Id set
                for (String IdString : dealerExceptions){
                	dealerExceptionSet.add(Id.valueOf(IdString));                    
                }
                
                // add dealer exception Id Set to dealer Id Set
                dealers.addAll(dealerExceptionSet);
            }			
            
            if(dealers == null) dealers = new Set<Id>();

            // get companies in region code
            Set<Id> companies =  regionCodeToCorporateGroup.get(currentUser.Contact.Account.Region_Code__c);

            if(companies == null) companies = new Set<Id>();

            Set<Id> allRelatedAccountIds = new Set<Id>();

            // if account onwership type is Dealer
            // AND
            // program servicing level is either DealerOnly OR DealerMarketAreaProgram
            if(accountType == 'Dealer' && (p.Servicing_Level__c == 'DealerOnly' || p.Servicing_Level__c == 'DealerMarketAreaProgram')) {

                // add current user account
                allRelatedAccountIds.add(currentUser.Contact.AccountId);
                
                // add accounts in dealer group
                allRelatedAccountIds.addAll(dealerGroup);
            }

            
            // if account onwership type is Dealer
            // AND 
            // program servicing level is DealerMarketAreaProgram
            if(accountType == 'Dealer' && p.Servicing_Level__c == 'DealerMarketAreaProgram') {
                // add dealers in region code
                allRelatedAccountIds.addAll(dealers);

                // add companies in region code
                allRelatedAccountIds.addAll(companies);
            }
            
            // Program Owner is an internal user and account onwership type is Corporate OR program servicing level is RWSS
            // OR
            // Program Owner is an internal user and program servicing level is RWSSPlus
            if( (
                (accountType == 'Corporate' || allInternalUserIds.contains(p.OwnerId)) 
                && p.Servicing_Level__c == 'RWSS')
                || 
                (allInternalUserIds.contains(p.OwnerId) && p.Servicing_Level__c == 'RWSSPlus') ) {

                allRelatedAccountIds.addAll(dealerGroup);

                        
                // get program, account and groups ids
                for(Id gId : validGroups) {

                    // add program id
                    programIdsForShareDelete.add(p.Id);

                    // add program account id
                    accountIdsForShareDelete.add(p.Account__c);

                    // add public group id
                    userOrGroupdIdsForShareDelete.add(gId);
                }
            }
            
            // if acc Owner is an internal user
            if(allInternalUserIds.contains(acc.OwnerId)) {

                // add program id
                programIdsForShareDelete.add(p.Id);

                // add truck manager group id
                userOrGroupdIdsForShareDelete.add(truckManagerGroup);
            }
            
            // this portion is related to dealer and corporate users
            if(accountType == 'Dealer' || accountType == 'Corporate') {
            
                // get users under current user account
                Set<Id> currentUserCoworkers = accountIdToUserIds.get(currentUser.AccountId);
                
                if(currentUserCoworkers != null) {
    
                    for(Id uId : currentUserCoworkers) {

                        // add program id
                        programIdsForShareDelete.add(p.Id);

                        // add program account id
                        accountIdsForShareDelete.add(p.Account__c);

                        // add co-worker user id
                        userOrGroupdIdsForShareDelete.add(uId);  
                    }
                }
            }
            
            // this portion is related to dealer users only
            if(accountType == 'Dealer') {    
                
                // remove account that is already processed
                if(allRelatedAccountIds.contains(p.Account__c)) allRelatedAccountIds.remove(p.Account__c);
                
                // iterate over all accounts related to program account
                for(Id aId : allRelatedAccountIds) {
                    
                    
                    // get users user the account
                    Set<Id> userIds = accountIdToUserIds.get(aId);
                    
                    if(userIds == null) continue;
                    
                    // iterate over user is 
                    for(Id uId : userIds) {
                        
                         // add program id
                        programIdsForShareDelete.add(p.Id);

                        // add program account id
                        accountIdsForShareDelete.add(p.Account__c);

                        // add co-worker user id
                        userOrGroupdIdsForShareDelete.add(uId);
                    }
                }
            }

            //added by Joey, if Service level is RWSS +, delete the old sharing.
            if(p.Servicing_Level__c == 'RWSSPlus'){
                // add program id
                programIdsForShareDelete.add(p.Id);

                // add program account id
                accountIdsForShareDelete.add(p.Account__c);

                // add co-worker user id
                userOrGroupdIdsForShareDelete.add(brandedGroupId);
            }
        }
        
        // delete program share records
        delete [select Id from Program__Share 
                    where ParentId in :programIdsForShareDelete 
                        and UserorGroupId in :userOrGroupdIdsForShareDelete
                        and RowCause = 'Manual'];

        // delete account share records
        delete [select Id from AccountShare 
                    where AccountId in :accountIdsForShareDelete 
                        and UserorGroupId in :userOrGroupdIdsForShareDelete
                        and RowCause = 'Manual'];
    }
    
    
}