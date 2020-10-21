@isTest
private class Daily_DealerScorecardCreation_Tests {
    
	static List<Account> SetupAccounts(Id recordTypeId) {
        List<Account> accounts = new List<Account>();
        // insert 2 accounts
        for (Integer i=0;i<2;i++) {
            accounts.add(new Account(name='Account'+i, 
                                     Customer_Status_Description__c = 'Active',
                                     Close_Date__c = null,
                                     RecordTypeId = recordTypeId,
                                     Store_Ownership_Type__c = 'Dealer',
            						 Open_Date__c = Date.today().addYears(-1)));
        }
        // insert accounts that will be unaffected by batch job
        accounts.add(new Account(name='Account3', 
                                     Customer_Status_Description__c = 'Active',
                                     Close_Date__c = null,
                                     RecordTypeId = recordTypeId,
                                     Store_Ownership_Type__c = 'Dealer',
            						 Open_Date__c = Date.today().addDays(-1)));
        accounts.add(new Account(name='Account4', 
                                     Customer_Status_Description__c = 'Inactive',
                                     Close_Date__c = null,
                                     RecordTypeId = recordTypeId,
                                     Store_Ownership_Type__c = 'Dealer',
            						 Open_Date__c = Date.today().addYears(-1)));
        accounts.add(new Account(name='Account5', 
                                     Customer_Status_Description__c = 'Active',
                                     Close_Date__c = Date.today(),
                                     RecordTypeId = recordTypeId,
                                     Store_Ownership_Type__c = 'Dealer',
            						 Open_Date__c = Date.today().addYears(-1)));
        accounts.add(new Account(name='Account6', 
                                     Customer_Status_Description__c = 'Active',
                                     Close_Date__c = null,
                                     RecordTypeId = recordTypeId,
                                     Store_Ownership_Type__c = 'Dealer',
            						 Open_Date__c = Date.today().addYears(1)));
        insert accounts;
        return accounts;
    }
        
    static List<User> SetupUsers(List<Account> accounts, List<string> roles) {
        // create the Users
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        for (Integer i = 0; i < roles.size(); i++) {
            // observe the same name for Opp and TSG
            userList.add(
                new User(
                    FirstName = roles[i], 
                    LastName = 'Test',
                    Alias = 'Test',
                    TimeZoneSidKey = 'GMT',
            		EmailEncodingKey = 'UTF-8',
                    ProfileId = p.Id,
            		LocaleSidKey = 'eu_ES',
                    LanguageLocaleKey = 'en_US',
                    Username='test' + i + Datetime.now().getTime() + '@blah.com',
                    Email='test'+ i + '@blah.com'
                )
            );
        }
        
        // insert marketing user
        userList.add(
            new User(
                FirstName='Michael',
                LastName='Rudquist',
                Alias = 'Test',
                TimeZoneSidKey = 'GMT',
                EmailEncodingKey = 'UTF-8',
                ProfileId = p.Id,
                LocaleSidKey = 'eu_ES',
                LanguageLocaleKey = 'en_US',
                Email='michael.rudquist@redwingshoes.com.test',
                Username='michael.rudquisttest' + Datetime.now().getTime() + '@redwingshoes.com.test'
            )
        );
        insert userList;
        return userList;
    }
    
    static List<AccountTeamMember> SetupAccountTeamMembers(List<Account> accounts, List<User> userList, List<string> roles) {
        //Create the AccountTeam
        List<AccountTeamMember> teamList = new List<AccountTeamMember>();
        for (Integer i = 0; i < roles.size(); i++) {
            for(Integer j = 0; j < accounts.size(); j++)
            {
                AccountTeamMember member = new AccountTeamMember(AccountId = accounts[j].Id, TeamMemberRole = roles[i], UserId = userList[i].ID);
        		teamList.add(member);
            }
        }
        insert teamList;
        return teamList;
    }
    
    static testmethod void test() {        
        Test.startTest();
        List<String> roles = new List<String>{'Regional Retail Director', 'Sales Rep', 'Industrial Sales Manager', 'Retail Operations Manager', 'Blah'};
        Id recordTypeId = [SELECT Id FROM RecordType Where Name = 'M3 Store Parent Account' LIMIT 1].Id;
        List<Account> accounts = SetupAccounts(recordTypeId);
        List<User> users = SetupUsers(accounts, roles);
        List<AccountTeamMember> atms = SetupAccountTeamMembers(accounts, users, roles);
        Daily_DealerScorecardCreation ddsc = new Daily_DealerScorecardCreation();      
        String sch = '0 0 0 1 1 ? 2050';
        System.schedule('Test check', sch, ddsc);
        Test.stopTest();
        
        // after the testing stops, assert records were updated properly
        List<Dealer_Scorecard__c> scorecards = [SELECT Id, Scorecard_Type__c From Dealer_Scorecard__c WHERE Dealer__c in :accounts];
        System.assertEquals(2, scorecards.size());
        for(Dealer_Scorecard__c scorecard : scorecards)
        {
            System.assertEquals('Annual Review', scorecard.Scorecard_Type__c);
        }
        Id taskRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Sales ROM\'s and TSM\'s' LIMIT 1].Id;
        List<Task> tasks = [SELECT Id, RecordTypeId, Type, Priority, ActivityDate, Subject, Description FROM Task WHERE WhatId in :scorecards];
        System.assertEquals(10, tasks.size());
        Date dueDate = Date.today().AddDays(5);
        for(Task t : tasks)
        {
            System.assertEquals(taskRecordTypeId, t.RecordTypeId);
            System.assertEquals('Dealer Review', t.Type);
            System.assertEquals('Normal', t.Priority);
            System.assertEquals(dueDate, t.ActivityDate);
            System.assertEquals('An annual Dealer Scorecard is ready for you to complete', t.Subject);
        }
    }
}