global class batchAccountUpdate implements Database.Batchable<SObject>{

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id,Name FROM Account WHERE RecordType.Name = \'M3 Key/Corporate Account\' OR RecordType.Name = \'M3 Store Child Account\' OR RecordType.Name = \'M3 Store Parent Account\' OR RecordType.Name = \'M3 Wholesale Accounts\' ';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> scope) {
    for(Account a : scope)
    {
      a.Last_Batch_Update__c = System.Now();
    }
    update scope;
  }

  global void finish(Database.BatchableContext BC) {
  
  }

}