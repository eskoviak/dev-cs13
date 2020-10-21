public class RWS_ppbButtonController {
    // Constructor - only matters if the autoRun function doesn't work right
    private final Publish_Pricebook__c ppb;
    public RWS_ppbButtonController(ApexPages.StandardController stdController) {
        this.ppb = (Publish_PriceBook__c)stdController.getRecord();
    }
     
    // Code invoked on page load.
    public PageReference autoRun() {
 
        String recordId = ApexPages.currentPage().getParameters().get('id');
 
        if (recordId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }
 
        List<Publish_PriceBook_Entry__c> ppbeList = [SELECT Id, Active__c, Publish_Status__c, Publish_PriceBook__c, Expiration_Date__c 
                                                    FROM Publish_PriceBook_Entry__c 
                                                    WHERE Publish_PriceBook__c =: recordId 
                                                    AND Active__c = true 
                                                    AND (Publish_Status__c = 'Waiting' OR Publish_Status__c = 'Deactivated')];
        
        for (Publish_Pricebook_Entry__c ppbe : ppbeList){
            if (ppbe.Publish_Status__c == 'Deactivated')
                ppbe.Expiration_Date__c = null;
            
            ppbe.Publish_Status__c = 'ReadyToPublish';
        }
        
        try{
            update ppbeList;  
            
            // Redirect the user back to the original page
            PageReference pageRef = new PageReference('/' + recordId);
            pageRef.setRedirect(true);
            return pageRef;
            
        } catch (DMLException e){
            System.debug('Exception: '+e);
            
            // Display the Visualforce page's content if DML error
            return null;
        }
        
    }
}