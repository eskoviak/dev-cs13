public class RecordSynchUtil {

    public static RecordSynchWrapper mapRecords(Schema.SObjectType targetType, List<sObject> events){
        DescribeSObjectResult describeResult = targetType.getDescribe();
        String sObjectApiName = describeResult.getName();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
    
        RecordUpdateMap__mdt recordUpdateMap = [Select QualifiedApiName,(Select ExternalId__c,QualifiedApiName,ReferenceTo__c,Source__c,StaticValue__c,Target__c From Fields__r) From RecordUpdateMap__mdt Where QualifiedApiName = :sobjectApiName];
        
        String externalId = null;
        
        RecordSynchWrapper rsw = new RecordSynchWrapper();
        rsw.records = new List<sObject>();
        
        for(sObject event : events){
            sObject record = targetType.newSObject();
            for(FieldMapping__mdt field : recordUpdateMap.Fields__r){
                
                if(field.StaticValue__c){
                    record.put(field.Target__c, field.Source__c);
                }else if(!String.isEmpty(field.ReferenceTo__c)){
                	Schema.SObjectField parentField = fieldMap.get(field.ReferenceTo__c);
                    Schema.DescribeFieldResult dfr = parentField.getDescribe();
                    Schema.SObjectType parentType = dfr.getReferenceTo().get(0);
                    sObject parentRecord = parentType.newSObject();
                    parentRecord.put(field.Target__c, field.Source__c);
                    record.putSObject(dfr.getRelationshipName(),parentRecord);
                }else{
                	record.put(field.Target__c,event.get(field.Source__c));
                }
                
                if(field.ExternalId__c && String.isEmpty(externalId)){
                    rsw.externalId = fieldMap.get(field.Target__c);
                }
            }
            rsw.records.add(record);
        }
        
        
        return rsw;
    }
    
    public class RecordSynchWrapper{
        public Schema.SObjectField externalId {get; set;}
        public List<sObject> records {get; set;}
    }
}