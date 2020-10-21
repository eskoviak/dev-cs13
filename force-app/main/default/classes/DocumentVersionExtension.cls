public class DocumentVersionExtension {

    private Apexpages.StandardController controller;
    
    public Document_Version__c docVerRecord {get;set;}
       
    public DocumentVersionExtension(ApexPages.StandardController stdController){
 
        this.controller = stdController;
		String notNull = 'not null';
        docVerRecord = (Document_Version__c)stdController.getRecord();        
        docVerRecord.Name = notNull;
                           
    }

}