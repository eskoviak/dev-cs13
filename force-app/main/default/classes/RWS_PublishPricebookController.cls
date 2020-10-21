/********************************************************************************
*   PURPOSE :   Generate Publish Pricebook Entries from Pricebook native layout .
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/09/2016  Usman Aslam/M360        Initial version
********************************************************************************/
public with sharing class RWS_PublishPricebookController {
	private Id pricebookId;
    public RWS_PublishPricebookController() {
        // get price book id
        pricebookId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference publishPricebookEntries() {

        // get price book entries
    	List<Publish_PriceBook_Entry__c> entries = [SELECT Id, Name, Publish_PriceBook__c, Product_ID__c, 
    										CurrencyIsoCode, List_Price__c, Active__c, 
    										/*UseStandardPrice,*/ CreatedDate, CreatedById, 
    										LastModifiedDate, LastModifiedById, SystemModstamp, 
    										Style_Number__c, IsDeleted, Discount__c, 
    										MSRP_Effective_Date__c, MSRP_Expiration_Date__c 
    									FROM Publish_PriceBook_Entry__c	
    									WHERE Publish_PriceBook__c = :pricebookId
                                        /*AND Product2.IsActive = true*/];
        
        Set<Id> prodIds = new Set<Id>();
            
        for(Publish_PriceBook_Entry__c ppbe : entries) {
            prodIds.add(ppbe.Product_Id__c);
        }
        
        Set<Id> prodIdSet = new Set<Id>(); 
        for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE IsActive = true AND Id IN : prodIds]){
            prodIdSet.add(prod.Id);
        }
        
        for(Integer i = 0; i < entries.size(); i++){
            if (!prodIdSet.contains(entries[i].Product_Id__c)){
                entries.remove(i);    
            }
        }
        
        
        

    	if(!entries.isEmpty()) {
    		try {

                // generate Publish Pricebook Entries
    			RWS_PriceBookEntry_Util.createPublicPriceBookEntries(entries);
    		} catch (DmlException ex) {
    			ApexPages.addMessages(ex);
    		}
    	}

        // return to price book
    	return new PageReference('/' + pricebookId);
    }
}