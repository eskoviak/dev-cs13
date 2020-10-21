public with sharing class RWS_ProgramProducts_Queue  implements Queueable {
	private Id programId;
	private Boolean createTemplate;
	private String programName;
	public RWS_ProgramProducts_Queue(Id programId, Boolean createTemplate, String programName) {
		this.programId = programId;
		this.createTemplate = createTemplate;
		this.programName = programName;
    }

    public class Product {
    	public Decimal filterNumber {get; set;}
    	public Decimal discount {get; set;}
    	public Boolean isFixedPrice {get; set;}

    	public Product(Decimal f, Decimal d, Boolean fp) {
    		filterNumber = f;
    		discount = d;
    		isFixedPrice = fp;
    	}
    }

    public void execute(QueueableContext context) {
    	List<Pricebook2> pb = [select Id
                                from Pricebook2 
                                where  Program__c != null 
                                and Program__c = :programId 
                                and IsStandard = false 
                            limit 1];

        List<Filter_Criteria__c> fcs = [select Results_Count__c,
                    Filter_Number__c,
                    Discount__c,
                    Filter_Display__c,
                    Product_Code__c
                from Filter_Criteria__c
                where Program__c = :this.programId
                and IA_Feature__c = null
                and Filter_Number__c != null
                Order by Filter_Number__c desc];


        Map<String, Product> productsMap = new Map<String, Product>();

        for(Filter_Criteria__c fc : fcs) {

        	if( String.isBlank(fc.Product_Code__c) ) continue;

            if(fc.Discount__c == null) fc.Discount__c = 0;

            String codesSet = fc.Product_Code__c.split('-FPC-')[0];
            String fpcSet = fc.Product_Code__c.split('-FPC-')[1];

            Set<String> fpCodes =  (Set<String>) JSON.deserialize(fpcSet, Set<String>.class);

            if(fc.Filter_Number__c > 0 ) {
                Set<String> productCodes = (Set<String>) JSON.deserialize(codesSet, Set<String>.class);
                

                for(String code : productCodes) {
                	Boolean isFixedPrice = fpCodes.contains(code);

                	Product p = productsMap.get(code);

                	if(p == null) {
                		p = new Product(fc.Filter_Number__c, fc.Discount__c, isFixedPrice);
                		productsMap.put(code, p);
                	}

                	if(fc.Discount__c > p.discount) {
                		p.discount = fc.Discount__c;
                		p.filterNumber = fc.Filter_Number__c;
                		p.isFixedPrice = isFixedPrice;
                	}
                }
                
            } else {
                Map<String, Decimal> productCodes = (Map<String, Decimal>) JSON.deserialize(codesSet, Map<String, Decimal>.class);

                for(String code : productCodes.keySet()) {
                	Decimal discount = productCodes.get(code);

                	if(discount == null) discount = 0;

                	Boolean isFixedPrice = fpCodes.contains(code);

                	Product p = productsMap.get(code);

                	if(p == null) {
                		p = new Product(0, discount, isFixedPrice);
                		productsMap.put(code, p);
                	}

                	if(discount > p.discount) {
                		p.discount = discount;
                		p.filterNumber = 0;
                		p.isFixedPrice = isFixedPrice;
                	}
                }
            }
        }


        Id stdPriceBookId;
        if(Test.isRunningTest()) {
            stdPriceBookId = Test.getStandardPricebookId();
        }
        else if (stdPriceBookId == null) {
            stdPriceBookId    = [select id, name from Pricebook2 where isStandard = true limit 1].id;
        }

        List<PricebookEntry> stdPbes = [SELECT UnitPrice,
                                            ProductCode,
                                            Product2Id
                                        FROM PricebookEntry 
                                        WHERE Pricebook2Id = :stdPriceBookId 
                                        AND IsActive = true 
                                        AND ProductCode in :productsMap.keySet()
                                        AND Product2.Product_Style__c != null
                                        AND Product2.IsActive = true
                                        AND CurrencyISOCode = :UserInfo.getDefaultCurrency()];


        Map<Id, PriceBookEntry> pricebookentry_Map = new Map<Id,PriceBookEntry>();
    	Set<Id> productIds = new Set<Id>();
    	Set<String> productCodesProcessed = new Set<String>();

        for(PricebookEntry spbe : stdPbes) {
        	if(productCodesProcessed.contains(spbe.ProductCode)) continue;

        	Product p = productsMap.get(spbe.ProductCode);

        	if(p == null) continue;

        	productCodesProcessed.add(spbe.ProductCode);

        	PriceBookEntry pbe = new PriceBookEntry();
            pbe.Pricebook2id = pb[0].Id;
            pbe.IsActive = true;
            pbe.Product2Id = spbe.Product2Id;
            pbe.Discount__c = p.discount;

             // get standard price
        	Double stdUnitPrice = spbe.UnitPrice;

        	if(stdUnitPrice == null) stdUnitPrice = 0;

        	// set on program pricebook entry
        	pbe.UnitPrice = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (pbe.Discount__c / 100) * stdUnitPrice).setScale(2);

            
            pbe.Fixed_Price__c = p.isFixedPrice;
            pbe.Filter_Number__c = p.filterNumber;

            pricebookentry_Map.put(pbe.Product2Id, pbe);
            productIds.add(pbe.Product2Id);
        }


        if(!pricebookentry_Map.isEmpty()) {

            //List<Product2> prods = [select Id from Product2 where Id in :productIds for update];

            // As upsert for pricebookentry is not possible, the below method is followed.
            List<PricebookEntry> pbe_check_Lst 
                = [select Id, Product2Id, Unitprice, Fixed_Price__c, Discount__c, IsActive
                        From PricebookEntry 
                        Where Pricebook2Id = :pb[0].Id 
                        and Product2Id in :pricebookentry_Map.keyset()
                        AND Product2.IsActive = true
                        AND CurrencyISOCode = :UserInfo.getDefaultCurrency()];
            
            List<pricebookentry> pricebookentry_updatelst = new List<pricebookentry>();
            if(!pbe_check_Lst.isEmpty()) {
                for(pricebookentry p : pbe_check_Lst ) {

                	PriceBookEntry otherPbe = pricebookentry_Map.get(p.Product2Id);

                    if(p.Discount__c > otherPbe.discount__c) {
                        pricebookentry_Map.remove(p.Product2Id);
                        continue;
                    }

                    PriceBookEntry pbe = new PriceBookEntry();
                    pbe.id = p.Id;
                    pbe.unitprice = otherPbe.Unitprice;
                    pbe.discount__c = otherPbe.Discount__c;
                    pbe.Fixed_Price__c = otherPbe.Fixed_Price__c;
                    pbe.Filter_Number__c = otherPbe.Filter_Number__c;

                    pbe.IsActive = true;

                    pricebookentry_updatelst.add(pbe);

                    /*                    
                    if(pricebookentry_updatelst.size() == 200) {
                        
                    	insertUpdateRecords(pricebookentry_updatelst, false);

                    	pricebookentry_updatelst = new List<PricebookEntry>();
                    }
                    */

                    pricebookentry_Map.remove(p.Product2Id);
                }
            }

            if(!pricebookentry_updatelst.isEmpty()) {
                insertUpdateRecords(pricebookentry_updatelst, false);
                //update pricebookentry_updatelst;
            }

            List<PricebookEntry> pricebookentry_insertlst = new List<PricebookEntry>();

            for(PricebookEntry p : pricebookentry_Map.values() ) {
            	pricebookentry_insertlst.add(p);

                /*
                if(pricebookentry_insertlst.size() == 200) {
                	insertUpdateRecords(pricebookentry_insertlst, true);

                	pricebookentry_insertlst = new List<PricebookEntry>();
                }
                */
            }

            if(!pricebookentry_insertlst.isEmpty()) {
                insertUpdateRecords(pricebookentry_insertlst, true);
                //insert pricebookentry_insertlst;
            }

            RWS_PriceBookEntry_Util.createPublishPriceBookEntries(pb[0].Id, productIds);
        }

        Program__c existingProgram = new Program__c(Id = programId,
                    Processing_Status__c = 'Completed'
        );   

        update existingProgram;

        for(Filter_Criteria__c fc : fcs) {
        	fc.Product_Code__c = null;
        }

        update fcs;

        if(createTemplate && !Test.isRunningTest()) {
        	System.enqueueJob(new RWS_ProgramTemplate_Queue(programId, programName));
        }
    }

    private void insertUpdateRecords(List<PricebookEntry> pbes, Boolean insertRecords) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                if(insertRecords) insert pbes; 
                if(!insertRecords) update pbes; 
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    }
}