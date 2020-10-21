public class accountDocumentExtension {

    private Apexpages.StandardController controller;
    
    public Account_Document__c acctRecord {get;set;}
       
    public accountDocumentExtension(ApexPages.StandardController stdController){
 
         this.controller = stdController;
 
        //Get the IP Address
        String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');  
    
        acctRecord = (Account_Document__c)stdController.getRecord();  
        acctRecord.Document_Accepted__c = true;     
        acctRecord.Document_Accpeted_Date_Time__c = datetime.now(); 
        acctRecord.Document_Accepted_IP_Address__c = ipAddress;                     
    }

    public PageReference save(){
        this.controller.save();
        PageReference newPage = New PageReference('http://www.redwingshoes.com');
        newPage.setRedirect(true);
        return newPage;
    }

}