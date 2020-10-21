global class RWS_ProductStyle_Batch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_ProductStyle_Batch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // assuming job will run at 10 or 11 PM
        return Database.getQueryLocator([select Id, Style_Number_Unique_ID__c, Item_Status_Code__c, 
                                                Product_Style__c,
                                                Parent_Product_Style__c
                                        from Product2
                                        where LastModifiedDate >= TODAY
                                        and Item_Status_Code__c != null
                                        and (Product_Style__c != null or Parent_Product_Style__c != null) ]);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<Product2> products = (List<Product2>) scope;
        
        Map<Id, Product_Style__c> productStyleMap = new Map<Id, Product_Style__c>();
        
        for(Product2 p : products) {
            Product_Style__c ps;
            
            Id psId;
            
            if(p.Product_Style__c != null) psId = p.Product_Style__c;
            if(p.Parent_Product_Style__c != null) psId = p.Parent_Product_Style__c;
            
            if(psId == null) continue;
            
            ps = productStyleMap.get(psId);
            
            if(ps == null) {
                ps = new Product_Style__c(Id = psId, Item_Status_Code__c = p.Item_Status_Code__c);
                productStyleMap.put(psId, ps);
            }
            
            if(Integer.valueOf(p.Item_Status_Code__c) <  Integer.valueOf(ps.Item_Status_Code__c)) {
                ps.Item_Status_Code__c = p.Item_Status_Code__c;
            }
        }
        
        update productStyleMap.values();
    }

    global void finish(Database.BatchableContext BC) { }
}