public with sharing class RWS_ProgramPublishProducts_Queue  implements Queueable {
	private Id pricebookId;
	private Id templatePricebookId;
	private Set<Id> productIds;

    public RWS_ProgramPublishProducts_Queue(Id pbId, Id tpbId, Set<Id> pIds) {
        pricebookId = pbId;
        templatePricebookId = tpbId;
        productIds = pIds;
    }

    public void execute(QueueableContext context) {
		//if(pricebookId != null) RWS_PriceBookEntry_Util.createPublishPriceBookEntries(pricebookId, productIds);    	 
		if(templatePricebookId != null) RWS_PriceBookEntry_Util.createPublishPriceBookEntries(templatePricebookId, productIds);    	 
    }


    //RWS_PriceBookEntry_Util.createPublishPriceBookEntries(pb[0].Id, productIds);
}