global class Daily_DealerScorecardCreation implements Schedulable 
{
   global void execute(SchedulableContext SC) 
   {
       Date today = System.Today();
       integer month = today.month();
       integer day = today.day();
       integer year = today.year();
       Id recordTypeId = [SELECT Id FROM RecordType Where Name = 'M3 Store Parent Account' LIMIT 1].Id;
       List<String> roles = new List<String>{'Regional Retail Director', 'Sales Rep', 'Industrial Sales Manager', 'Retail Operations Manager'};//, 'Credit Analyst'};
       List<Dealer_Scorecard__c> scorecards = new List<Dealer_Scorecard__c>();
       RecordType taskRecordType = [SELECT Id FROM RecordType WHERE Name = 'Sales ROM\'s and TSM\'s' LIMIT 1];
       Map<Id, List<Task>> accountTasks = new Map<Id, List<Task>>();
       User marketingUser = [SELECT Id FROM User WHERE email like 'michael.rudquist%' AND Firstname = 'Michael' AND Lastname = 'Rudquist' LIMIT 1];
       
       for(Account a : [SELECT Id, 
                        	   Name, 
                               (SELECT UserId, TeamMemberRole FROM AccountTeamMembers WHERE IsDeleted = false AND TeamMemberRole IN :roles)
                        FROM Account
                        WHERE Customer_Status_Description__c = 'Active'
                        AND Close_Date__c = null
                        AND RecordType.Id = :recordTypeId
                        AND Store_Ownership_Type__c = 'Dealer'
                        AND CALENDAR_YEAR(Open_Date__c) < :year
                        AND CALENDAR_MONTH(Open_Date__c) = :month 
                        AND DAY_IN_MONTH(Open_Date__c) = :day])
       {
           //Create Dealer scorecards and Tasks for any Accounts that match the criteria
           Dealer_Scorecard__c scorecard = new Dealer_Scorecard__c(
               Dealer__c = a.Id,
               Scorecard_Type__c = 'Annual Review'
           );
           scorecards.add(scorecard);
           Date dueDate = System.today().addDays(5);
           
           //Create tasks for each team member
           List<Task> tasks = new List<Task>();
           for(AccountTeamMember atm : a.AccountTeamMembers)
           {
               Task t = new Task(
                   OwnerId = atm.UserId,
                   RecordTypeId = taskRecordType.Id,
                   Type = 'Dealer Review',
                   Priority = 'Normal',
                   ActivityDate = dueDate,
                   Subject = 'An annual Dealer Scorecard is ready for you to complete',
                   Description = 'Please complete your evaluation of dealer ' + a.Name + '.'
               );
               tasks.add(t);
           }
           
           //Add marketing task
           if(string.isNotEmpty(marketingUser.Id))
           {
               Task marketingTask = new Task(
                       OwnerId = marketingUser.Id,
                       RecordType = taskRecordType,
                       Type = 'Dealer Review',
                       Priority = 'Normal',
                       ActivityDate = dueDate,
                       Subject = 'An annual Dealer Scorecard is ready for you to complete',
                       Description = 'Please complete your evaluation of dealer ' + a.Name + '.'
               );
               tasks.add(marketingTask);
           }
           
           accountTasks.put(a.Id, tasks);
       }
       
       Database.Insert(scorecards, false);
       
       //Loop through scorecards and add their id to the tasks
       List<Task> tasksToInsert = new List<Task>();
       for(Dealer_Scorecard__c s : scorecards)
       {
           List<Task> tasks = accountTasks.get(s.Dealer__c);
           for(Task t : tasks)
           {
               t.whatId = s.Id;
               tasksToInsert.add(t);
           }
       }
       
       //Insert tasks
       Database.DMLOptions dmlOptions = new Database.DMLOptions(); 
	   dmlOptions.EmailHeader.TriggerUserEmail = TRUE; 
	   Database.Insert(tasksToInsert, dmlOptions);
	}
}