/********************************************************************************
*   PURPOSE : Handler class for RWS_InsertNewProducts_Batch
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/08/2016  Kotapati Keerthi/M360   Initial version
*   03/08/2018  Brandon Willard/M360    Modified for RWCP-3449
********************************************************************************/

public class RWS_InsertNewProducts_BatchHandler {
    
    public static void createProducts (Id programId) {

        // retrieve program with Pricebook, filter criterias (ordered by discount and records 
        // with NULL discount appearing at the end)
        Program__c program = [
                    select Id, CurrencyIsoCode, HasPricebook__c,
                    (select Id, CurrencyIsoCode, Program__c from Publish_PriceBooks__r),
                    (select IA_Feature__r.Name, 
                            Discount__c,
                            Filter_Number__c,
                            IA_Feature__r.Filter_Logic__c,
                            Filter_BE_Details__c,
                            Product_Code__c,
                            Results_Count__c
                        from Filter_Criteria__r
                        where Filter_Number__c != null and Filter_Number__c > 0 
                        order by Discount__c desc NULLS LAST)

                    from Program__c where id = :programId limit 1];
        

        // if no filter criterias found, exit
        if(program.Filter_Criteria__r == null || program.Filter_Criteria__r.isEmpty()) return;

        // if no pricebook found, exit
        if(program.Publish_PriceBooks__r == null 
                || program.Publish_PriceBooks__r.isEmpty() 
                || program.Publish_PriceBooks__r.size() > 1) return;

        // local variable for pricebook for easy reference in code
        Publish_PriceBook__c pbook = program.Publish_PriceBooks__r[0];
        
        // map that holds all style ids -> discount. 
        // Used to update discount on the pricebook entry and publish pricebook entry records
        Map<Id, Decimal> allStylesWithDiscount = new Map<Id, Decimal>();

        // map that holds all style ids -> filter number
        // Used to update discount on the pricebook entry records
        Map<Id, Decimal> allStylesWithFilterNumber = new Map<Id, Decimal>();

        // iterate over filter criteria and find highest discount for the product style and filter number
        for(Filter_Criteria__c fc : program.Filter_Criteria__r) {

            // if there no filter details on filter criteria, move to next record
            if(String.isBlank(fc.Filter_BE_Details__c)) continue;

            // if discount is not set, assume it as ZERO
            if(fc.Discount__c == null) fc.Discount__c = 0;

            // get styles that falls under the filter criteria
            Set<Id> filterStyles = RWS_FilterCriteria_Util.getProductStylesForFilter(fc);

            // if not style found, move to next filter criteria
            if(filterStyles.isEmpty()) continue;

            // iterate over product style ids 
            for(Id s : filterStyles) {
                // process the product style if already doesn't exists in the maps
                if(!allStylesWithDiscount.containsKey(s)) {

                    // add discount for the product style
                    allStylesWithDiscount.put(s, fc.Discount__c);

                    // add filter number for the product style
                    allStylesWithFilterNumber.put(s, fc.Filter_Number__c);
                }
            }
        }

        // get standard price book Id
        Id stdpbid;
        if(Test.isRunningTest()) // for test code
            stdpbid = Test.getStandardPricebookId();
        else // for actual run
            stdpbid = [select id, name from Pricebook2 where isStandard = true limit 1].id;


        // get active products related to all product styles relevant to all filter criterias
        List<Product2> products = [select Id from Product2 
                                        where Product_Style__c in :allStylesWithDiscount.keySet()
                                        and IsActive = true];
       
        // get products that are already there in Program Pricebook
        Set<String> existingProductIds = new Set<String>();

        for(Publish_PriceBook_Entry__c pd : [select Id, Style_Number__c, Product_ID__c
                    from Publish_PriceBook_Entry__c 
                    where Publish_PriceBook__c = :pbook.id]) {

            existingProductIds.add(pd.Product_ID__c);
        }


        // get active MSRP records using Standard Pricebook and Products relevant to all filter criterias
        List<PricebookEntry> product_lst = [select Id, CurrencyISOCode, 
                     Unitprice, Product2Id, Product2.Product_Style__c, Product2.Style_Number_Unique_ID__c, Product2.ProductCode, Product2.Name, 
                     ProductCode, Product2.RWS_ID__c, Product2.SKU__c, Product2.UPC__c, Price_Level__c
                 from PricebookEntry
                 where Pricebook2id = :stdpbid
                 and Product2Id in :products
                   and IsActive = true ];


        // List used to insert new PriceBookEntry records
        List<Publish_PriceBook_Entry__c> insertPublishPriceBookEntry_lst = new list<Publish_PriceBook_Entry__c>();

        Set<Id> productIds = new Set<Id>();        
        Set<String> prodCodeSet = new Set<String>(); //added by BW - RWCP-3600

        // iterate over MSRP records, find any missing products under program, 
        // and create pricebook entry recors for those missing products
        for(PricebookEntry pd : product_lst ) {


            // if MSRP currency is different than program pricebook currency, move to the next records
            if(pd.CurrencyIsoCode != pbook.CurrencyIsoCode) continue;

            // if product already exists under the program, move to next record
            if(existingProductIds.contains(pd.Product2Id)) continue;

            // keep track of new products added to the program
            productIds.add(pd.Product2Id);
            prodCodeSet.add(pd.Product2.ProductCode); //added by BW - RWCP-3600

            // initialize PricebookEntry object
            Publish_PriceBook_Entry__c ppbEntry = new Publish_PriceBook_Entry__c();
            ppbEntry.Product_Id__c = pd.Product2Id;
            ppbEntry.Publish_PriceBook__c = pbook.id;
            ppbEntry.Active__c = true;
            ppbEntry.CurrencyIsoCode = pbook.CurrencyIsoCode;
            ppbEntry.Style_Name__c = pd.Product2.Name;
            ppbEntry.Style_Number__c = pd.Product2.ProductCode;
            ppbEntry.Style_Number_Unique_Id__c = pd.Product2.Style_Number_Unique_ID__c;
            ppbEntry.Product_RWS_ID__c = pd.Product2.RWS_ID__c;
            ppbEntry.Product_SKU__c = pd.Product2.SKU__c;
            ppbEntry.Product_UPC__c = pd.Product2.UPC__c;
            ppbEntry.MSRP__c = pd.UnitPrice;
            ppbEntry.Price_Level__c = pd.Price_Level__c;    
            
            // assume max discount is zero for now
            Decimal maxDiscount = 0;

            Decimal discount = allStylesWithDiscount.get(pd.Product2.Product_Style__c );

            Decimal filterNumber = allStylesWithFilterNumber.get(pd.Product2.Product_Style__c);

            // if discount is found for the product style and is greater than zero, consider it as the maximum discount
            if(discount != null && discount > 0) {
                maxDiscount = discount;
            }

            // set discount
            ppbEntry.Discount__c = maxDiscount;

            // if filter is not found in allStylesWithFilterNumber, add that products to custom list
            if(filterNumber == null) filterNumber = 1;

            // set filter number
            ppbEntry.Filter_Number__c = filterNumber;

            Double stdUnitPrice = pd.UnitPrice;

            // set program product unit price using unit price of MSRP and discount
            ppbEntry.List_Price__c = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (ppbEntry.Discount__c / 100) * stdUnitPrice);

            // add variable to the list
            insertPublishPriceBookEntry_lst.add(ppbEntry);

            // insert 200 records at a time to avoid row locking issue
            if(insertPublishPriceBookEntry_lst.size() == 200) {
                RWS_PriceBookEntry_Util.insertUpdateRecords(insertPublishPriceBookEntry_lst, true);

                insertPublishPriceBookEntry_lst = new List<Publish_PriceBook_Entry__c>();
            }

        }

        // if new records were initialized in the code above
        if(!insertPublishPriceBookEntry_lst.isEmpty()) {

            // insert those records
            RWS_PriceBookEntry_Util.insertUpdateRecords(insertPublishPriceBookEntry_lst, true); 
            
            // create publish pricebook records for those records
            //RWS_PriceBookEntry_Util.createPublishPriceBookEntries(pbook.Id, productIds);

            // find any products under programs that are not added from this batch job (productIds variable)
            // and belong to program filter criterias
            // and are no longer active (Product2.Parent_Product_Style__c set)
            List<Publish_PriceBook_Entry__c> entriesToDelete = [select Id, Product_Id__c, Style_Number__c from Publish_PriceBook_Entry__c where Publish_PriceBook__c in :program.Publish_PriceBooks__r 
                   // and Product2.Parent_Product_Style__c in :allStylesWithDiscount.keySet()
                   // and Style_Number__c not in :prodCodeSet
                   ];

            prodCodeSet.clear();
            for(Publish_PriceBook_Entry__c ppbe : entriesToDelete) {
                prodCodeSet.add(ppbe.Product_Id__c);
            }
            
            Set<String> prodCodes = new Set<String>(); 
            for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE Parent_Product_Style__c in :allStylesWithDiscount.keySet() AND Id IN :prodCodeSet]){
                prodCodes.add(prod.Id);
            }
            
            for(Integer i = 0; i < entriesToDelete.size(); i++){
                if (!prodCodes.contains(entriesToDelete[i].Product_Id__c)){
                    entriesToDelete.remove(i);
                    i--;    
                }
            }

            // deactivate publish pricebook entry records so the outbound message is sent to update extermal system
            if(!entriesToDelete.isEmpty())  RWS_PriceBookEntry_Util.deactivatePublicPriceBookEntries(entriesToDelete);
        }
    }
}