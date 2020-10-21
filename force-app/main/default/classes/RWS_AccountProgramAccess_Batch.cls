/********************************************************************************
*   PURPOSE :   Update Account and Program sharing based o.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/06/2017  Usman Aslam/M360        Initial version
********************************************************************************/
global class RWS_AccountProgramAccess_Batch implements Database.Batchable<sObject> , Schedulable, Database.Stateful {

    global RWS_AccountProgramAccess_Batch() { }

    private Set<Id> updatedAccountIds;
    private List<Account> accounts;
    private Set<Id> usersToRemove;

    // initialize batch job
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_AccountProgramAccess_Batch(), 10);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        updatedAccountIds = new Set<Id>();
        accounts = new List<Account>();
        usersToRemove = new Set<Id>();

        // created accounts after the last run
        Set<Id> accountCreatedIds = new Set<Id>();
        Set<String> accountCreatedWithRegionIds = new Set<String>();

        // updated accounts after the last run
        Set<Id> accountDealerUpdatedIds = new Set<Id>();
        Set<String> accountUpdatedWithRegionIds = new Set<String>();

        Set<Id> accountIds = new Set<Id>();

        for( User u : [select Id, Contact.AccountId, AccountId
                            from User
                            where IsActive = true
                            and CreatedDate >= YESTERDAY
                            and Contact.AccountId != null] ) {

            accountIds.add(u.Contact.AccountId);
        }

        accountIds.remove(null);

        accounts =  
                [select Id, Sharing_Status__c, Dealer__c, Sharing_Old_Values__c, Region_Code__c
                    from Account 
                where IsPartner = true and RecordType.DeveloperName in ('M3_Store_Parent_Account', 
                        'M3_Store_Child_Account')
                and Sharing_Status__c in ('Created', 'Updated')];

        for(Account a : accounts) {
            if(a.Dealer__c != null) {
                accountDealerUpdatedIds.add(a.Dealer__c);
            }
            
            if(a.Region_Code__c != null) {
                accountCreatedWithRegionIds.add(a.Region_Code__c);
            }

            if(a.Sharing_Status__c == 'Updated') {

                updatedAccountIds.add(a.Id);

                List<String> values = a.Sharing_Old_Values__c.split(',');
                
                try {
                    if(!String.isBlank(values.get(0)))
                        accountDealerUpdatedIds.add((Id) values.get(0));
                    
                    
                    if(!String.isBlank(values.get(2)))
                        accountUpdatedWithRegionIds.add(values.get(2));

                } catch(Exception ex) {}
            }
            
            accountIds.add(a.Id);
        }

        if( (!accountCreatedIds.isEmpty()) || (!accountDealerUpdatedIds.isEmpty())) {

            for(Account a : [select Id, Dealer__c from Account 
                                where Dealer__c in :accountCreatedIds 
                                or Dealer__c in :accountDealerUpdatedIds]) {

                accountIds.add(a.Id);
            }
        }

        if( (!accountCreatedWithRegionIds.isEmpty()) || (!accountUpdatedWithRegionIds.isEmpty())) {

            for(Account a : [select Id, Region_Code__c from Account 
                                where Region_Code__c in :accountCreatedWithRegionIds 
                                or Region_Code__c in :accountUpdatedWithRegionIds]) {
                accountIds.add(a.Id);
            }
        }

        Set<Id> userIds = new Set<Id>();


        for(User u : [select Id, Name, Contact.AccountId from User where Contact.AccountId in :accountIds]) {
            if(updatedAccountIds.contains(u.Contact.AccountId) ) usersToRemove.add(u.Id);
            userIds.add(u.Id);
        }
        return Database.getQueryLocator('select Id, OwnerId, Servicing_Level__c, Account__c ' +
                                        ' from Program__c where OwnerId in :userIds '
                                        + (accountIds.isEmpty() && !Test.isRunningTest() ?  ' and Id = null ' : '') );
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Program__c> programs = (List<Program__c>) scope;


        if(!updatedAccountIds.isEmpty()) {

            Set<Id> programIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();

            for(Program__c p : programs) {
                programIds.add(p.Id);

                if(p.Account__c != null) accountIds.add(p.Account__c);
            }

            // delete program share records
            delete [select Id from Program__Share 
                        where ParentId in :programIds 
                            and UserorGroupId in :usersToRemove
                            and RowCause = 'Manual'];

            // delete account share records
            if(!accountIds.isEmpty())
                    delete [select Id from AccountShare 
                        where AccountId in :accountIds 
                            and UserorGroupId in :usersToRemove
                            and RowCause = 'Manual'];

            RWS_ProgramTrigger_Handler.setExpirationDateOnServicingStores(programs);
        }

        RWS_ProgramTrigger_Handler.shareProgramAndAccount(programs);
    }

    global void finish(Database.BatchableContext BC) { 
        for(Account a : accounts) {
            a.Sharing_Status__c = 'Completed';
        }
        update accounts;
    }
}