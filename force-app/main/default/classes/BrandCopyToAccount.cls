global class BrandCopyToAccount /*implements ITriggers.HandlerInterface*/ {

    public BrandCopyToAccount(){
    //Do Nothing
    }
/* 2020-07-10 Chris Mollet Commented out - DC Case 8433
    List<Brand__c> newCollection = trigger.new;
    Map<Id, Brand__c> oldCollection = (Map<Id, Brand__c>)trigger.oldMap;
    Boolean isInsert = trigger.isInsert;
    Boolean isUpdate = trigger.isUpdate;
    Boolean isDelete = trigger.isDelete;
    
    global void handle() {
        copyBrandsToAccount(getAccountIds());
    }
    
    private Set<Id> getAccountIds() {
        Set<Id> accountIds = new Set<Id>();
        if(isInsert || isUpdate) {
            for(Brand__c b : newCollection) {
                if(isInsert || b.Brand__c != oldCollection.get(b.Id).Brand__c) accountIds.add(b.Account__c);
            }
        }
        if(isDelete) {
            for(Brand__c b : oldCollection.values()) {
                accountIds.add(b.Account__c);
            }
        }
        return accountIds;
    }
    
    private void copyBrandsToAccount(Set<Id> accountIds) {
        String brand = '';
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        if(!accountIds.isEmpty()) { 
            for(Account a : [select Id, Brands__c, (select Brand__c from BrandEntries__r) from Account where Id in :accountIds])
            {
                a.Brands__c = '';
                for (Brand__c b : a.BrandEntries__r)
                {
                    a.Brands__c += b.Brand__c + ';';
                }
                if(a.Brands__c.length() > 0) a.Brands__c = a.Brands__c.substring(0,a.Brands__c.length()-1);
                    accountsToUpdate.put(a.Id, a);
            }       
            if(!accountsToUpdate.isEmpty() && accountsToUpdate.size() > 0) {
                update accountsToUpdate.values();
            }
        }
    }*/
}