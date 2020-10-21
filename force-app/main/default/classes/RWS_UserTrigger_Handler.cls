public with sharing class RWS_UserTrigger_Handler {

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


    public static void beforeInsert(List<User> newRecords) {
        copyContactDataOnUser(newRecords);
    }

    public static void afterInsert(List<User> newRecords) {
        addUsersToPublicGroups(newRecords);
        assignPermissionSetToCommunityUser(newRecords);
    }

    public static void afterUpdate(List<User> newRecords, Map<Id, User> oldRecords) {
        Boolean allowUpdateRun = Boolean.valueOf(Label.Run_Update_Trigger);

        if(allowUpdateRun || Test.isRunningTest()) 
            addUsersToPublicGroups(newRecords);
    }


    private static void copyContactDataOnUser(List<User> newRecords)  {
        Set<Id> contactIds = new Set<Id>();

        for(User u : newRecords) {
            if(u.ContactId == null) continue;


            contactIds.add(u.ContactId);
        }

        if(contactIds.isEmpty()) return;

        String fields = '';

        for(String cf : conToUserFieldMap.keySet()) {
            if(fields != '') fields += ', ';

            fields += cf;
        }

        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
            (List<Contact>) Database.query('select Id, ' + fields + ' from Contact where Id in :contactIds'));

        for(User u : newRecords) {
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
    }

    private static void addUsersToPublicGroups(List<User> newRecords) {

        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        Id businessPartnerGroupId;
        for(Group g : [select Id, DeveloperName from Group 
                            where DeveloperName in ('Dealer_Users', 'Corporate_Users','Branded_Users', 'Business_Partner_Community')]) {

            if(g.DeveloperName == 'Business_Partner_Community') {
                businessPartnerGroupId = g.Id;
            } else {
                groupNameToIdMap.put(g.DeveloperName, g.Id);
            }
            
        }

        if(groupNameToIdMap.isEmpty()) return;

        Set<Id> accountIds = new Set<Id>();
        for(User u : newRecords) {
            if(u.AccountId == null) continue;

            accountIds.add(u.AccountId);
        }

        if(accountIds.isEmpty()) return;

        Map<Id, Account> accountsMap = new Map<Id, Account>(
                [select Id, Store_Ownership_Type__c from Account
                    where Id in :accountIds]
            );

        Set<String> existingMemberShips = new Set<String>();

        for(GroupMember gm : [select GroupId, UserOrGroupId 
                                from GroupMember where GroupId in :groupNameToIdMap.values()]) {
            existingMemberShips.add(String.valueOf(gm.GroupId) + String.valueOf(gm.UserOrGroupId));
        }

        List<GroupMember> membersToInsert = new List<GroupMember>();
        for(User u : newRecords) {
            if(u.AccountId == null) continue;

            Account a = accountsMap.get(u.AccountId);

            membersToInsert.add(new GroupMember(GroupId = businessPartnerGroupId,
                                                UserOrGroupId = u.Id));

            String groupName = '';

            if(a.Store_Ownership_Type__c == 'Dealer') {
                groupName = 'Dealer_Users';
            } else if(a.Store_Ownership_Type__c == 'Corporate') {
                groupName = 'Corporate_Users';
            } else if(a.Store_Ownership_Type__c == 'Branded') {
                groupName = 'Branded_Users';
            }

            if(String.isBlank(groupName)) continue;


            Id groupId = groupNameToIdMap.get(groupName);

            if(groupId == null) continue;

            if(!existingMemberShips.contains(String.valueOf(groupId) + String.valueOf(u.Id))) {
                membersToInsert.add(new GroupMember(GroupId = groupId,
                                                UserOrGroupId = u.Id));   
            }
            
        }

        if(membersToInsert.isEmpty()) return;

        Database.insert(membersToInsert, false);
    }
    
    
    Private static void assignPermissionSetToCommunityUser(List<User> lstUsers){
        Profile[] ProfileDetail = [select Id from Profile where Name='RWS Business Partner Community'];
        if(ProfileDetail!=null){
            List<PermissionSetAssignment> lstPsa = new List<PermissionSetAssignment>();
            PermissionSet[] pSet = [SELECT Id,Name FROM PermissionSet where Name='VTM_Permission_Set'];
            if(pSet!=null){
                for(User usr : lstUsers){
                    if(usr.ContactId!=null && ProfileDetail[0].id==usr.ProfileId && usr.IsActive){
                        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = pSet[0].id, AssigneeId = usr.id);
                        lstPsa.add(psa);  
                    }
                }
            }
            if(lstPsa.size()>0){
                insert lstPsa;
            }
        }

    }
    
}