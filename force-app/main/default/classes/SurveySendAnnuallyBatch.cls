global class SurveySendAnnuallyBatch implements Database.Batchable<sObject> {

    public string query = 'Select Id, Send_Annual_Survey__c, (Select Id, CreatedDate From Tasks where Subject LIKE \'Email: Red Wing Shoes Survey%\' order by CreatedDate desc limit 1) From Contact where Do_Not_Send_Surveys__c = false AND HasOptedOutOfEmail = false AND Active__c = true';
    
    global database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, Sobject[] scope)
    {
        List<Contact> contactsToUpdate = new List<Contact>();
                
        for (sObject s : scope) {
            Contact c = (Contact)s;
            Task[] arrTasks = c.Tasks;
            if(arrTasks.isEmpty()) {
                c.Send_Annual_Survey__c = true;
                contactsToUpdate.add(c);
            }
            for(Task t : c.Tasks) {
                if(t.CreatedDate < system.today().addDays(-365)) {
                    c.Send_Annual_Survey__c = true;
                    c.Survey_Count__c = 0;
                    c.Survey_Threshold_Reached__c = false;
                    ContactsToUpdate.add(c);
                }
            }
        }
        
        if(!contactsToUpdate.isEmpty() && contactsToUpdate.size() > 0) {
            update contactsToUpdate;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}