/********************************************************************************
*   PURPOSE : Update Standard Pricebook and its entries based on data in Future Pricebook
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/17/2016  Usman Aslam/M360        Initial version
********************************************************************************/
public with sharing class RWS_UpdateStandardPricebookController {

    // Instance variables
    public Id pricebookId {get; private set;}
    private Future_Price__c fpb;

    public RWS_UpdateStandardPricebookController() {
        // get pricebook id
        pricebookId = ApexPages.currentPage().getParameters().get('id');
        
    }

    public PageReference updateStandardPricebook() {

        PageReference pr = new PageReference('/' + pricebookId);

        Id stdPbId;

        try {
            // get future pricebook
            fpb = [select Id, CurrencyIsoCode, Active__c, MSRP__c, Product__c, Effective_Date__c 
                            FROM Future_Price__c
                        where Id = :pricebookId];

            if(!fpb.Active__c) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Future Price is Inactive.'));
            }

            if(fpb.Effective_Date__c == null || fpb.Effective_Date__c > Date.today()) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Effective Date.'));
            }

            if(fpb.Product__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid Product.'));
            }

            if(fpb.MSRP__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid MSRP.'));
            }

            // get standard pricebook id
            if(Test.isRunningTest()) 
                stdPbId = Test.getStandardPricebookId();
            else
                stdPbId = [select id, name from Pricebook2 where IsStandard = true limit 1].Id;

        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }

        if(ApexPages.hasMessages()) return null;

        // set save point, so we can rollback in case of any error
		SavePoint sp = Database.setSavepoint();

		try {

            // get standard price book entries
    		List<PricebookEntry> stdEntries = [SELECT Id, Name, Product2Id, 
    										 UnitPrice, 
    										UseStandardPrice, Discount__c, 
    										MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                                            IsActive,
                                            CurrencyIsoCode
    									FROM PricebookEntry
    									WHERE Pricebook2Id = :stdPbId
                                        and Product2Id = :fpb.Product__c
                                        and CurrencyIsoCode = :fpb.CurrencyIsoCode];

            if(stdEntries.isEmpty()) return pr;

            // update standard pricebook entries
    		for(PricebookEntry spb : stdEntries) {
                spb.UnitPrice = fpb.MSRP__c;
                spb.IsActive = fpb.Active__c;
    		}
			update stdEntries;

            // update future pricebook
    		fpb.Active__c = false;
    		update fpb;

		} catch (DmlException ex) {
			System.debug(ex.getMessage());
			ApexPages.addMessages(ex);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
		}

		if(ApexPages.hasMessages()) {
			Database.rollback(sp);
			return null;
		}

        // retrurn to future pricebook
    	return new PageReference('/' + pricebookId);
    }
}