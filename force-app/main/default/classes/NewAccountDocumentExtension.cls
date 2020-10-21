public class NewAccountDocumentExtension {
    
    private Apexpages.StandardController controller;
    
    public Account_Document__c acctDocRecord {get;set;}
       
    public NewAccountDocumentExtension(ApexPages.StandardController stdController){
 
        this.controller = stdController;
        
        //Link to Account
        acctDocRecord = (Account_Document__c)stdController.getRecord();  
        String accid = ApexPages.currentPage().getParameters().get('accid');
        acctDocRecord.Account__c = accid;
            
        //Set Record Type
        String rt = ApexPages.currentPage().getParameters().get('RecordType');
        acctDocRecord.RecordTypeId = rt;    
                                        
    }

}