global class RWS_InsertPPBE_Batch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_InsertPPBE_Batch(), 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer count = [select Id from Product2 where LastModifiedDate >= YESTERDAY 
                        and IsActive = true limit 1].size();

        Integer featureCount = [select Id from Product_Style_Features__c where LastModifiedDate >= YESTERDAY limit 1].size();

        return Database.getQueryLocator('Select Id From Program__c where Auto_Add_Products__c = true '
                                        + (featureCount == 0 && count == 0 && !Test.isRunningTest() ?  ' and Id = null ' : '') );
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Id> programId= new List<Id>();
        //convert scope to actual segments
        for (sObject p : scope) {
            Program__c program = (Program__c) p;
            createProducts(program.Id);
        }
        
    }  

    private static void createProducts (Id programId) {

        Program__c program = [
                    select Id, CurrencyIsoCode, HasPricebook__c,
                    (select Id, CurrencyIsoCode from Price_Books__r),
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

        if(program.Filter_Criteria__r == null || program.Filter_Criteria__r.isEmpty()) return;

        if(program.Price_Books__r == null || program.Price_Books__r.isEmpty() ) return;

        Pricebook2 pbook = program.Price_Books__r[0];

        Map<Id, Decimal> allStylesWithDiscount = new Map<Id, Decimal>();
        Map<Id, Decimal> allStylesWithFilterNumber = new Map<Id, Decimal>();

        for(Filter_Criteria__c fc : program.Filter_Criteria__r) {
            if(String.isBlank(fc.Filter_BE_Details__c)) continue;

            if(fc.Discount__c == null) fc.Discount__c = 0;

            Set<Id> filterStyles = RWS_FilterCriteria_Util.getProductStylesForFilter(fc);

            if(filterStyles.isEmpty()) continue;

            for(Id s : filterStyles) {
                if(!allStylesWithDiscount.containsKey(s)) {
                    allStylesWithDiscount.put(s, fc.Discount__c);
                    allStylesWithFilterNumber.put(s, fc.Filter_Number__c);
                }
            }
        }

        Id stdpbid;
        if(Test.isRunningTest()) 
            stdpbid = Test.getStandardPricebookId();
        else
            stdpbid = [select id, name from Pricebook2 where isStandard = true limit 1].id;


        Set<Id> validProducts = new Map<Id, Product2>([select Id from Product2 
                                        where Product_Style__c in :allStylesWithDiscount.keySet()
                                        and IsActive = true]).keySet();

        List<PricebookEntry> product_lst 
            = Database.query('select Id, CurrencyISOCode, ' + 
 '                    Unitprice, Product2Id, Product2.Product_Style__c, ' + 
 '                    Product2.SKU__c, ' + 
 '                    Product2.UPC__c, ' + 
 '                    Product2.RWS_Id__c, ' + 
 '                    Product2.ProductCode, ' + 
 '                    Product2.Style_Number_Unique_ID__c, ' + 
 '                    Product2.Name, ' +
 '                    Product2.Id ' +  
 '                from PricebookEntry ' + 
 '                where Pricebook2id = :stdpbid' +  
 '                and Product2Id in :validProducts' +
 '                  and IsActive = true ');


        // create PriceBook to Publish Price Book Id map
        Map<Id, Id> pbToPpbIdMap = new Map<Id, Id>();

        Id ppbId = [select Id, 
                            Price_Book__c
                    from Publish_PriceBook__c 
                    where Price_Book__c = :pbook.id].Id;

        Map<Id, Publish_PriceBook_Entry__c> ppbeMap = new Map<Id, Publish_PriceBook_Entry__c>();

        Set<Id> productIds = new Set<Id>();

        for(Publish_PriceBook_Entry__c ppbe : [select Id, Product_Id__c, 
        											Discount__c,
        											Product_SKU__c,
        											Product_UPC__c,
        											Product_RWS_ID__c,
        											Style_Number_Unique_Id__c,
        											Style_Name__c,
        											List_Price__c,
        											MSRP__c,
        											Active__c,
        											Publish_PriceBook__c
			        							from Publish_PriceBook_Entry__c 
			        						where Publish_PriceBook__c = :ppbId
			        						and Product_Id__c in :validProducts] ) {

        	ppbeMap.put(ppbe.Product_Id__c, ppbe);
        }

        List<Publish_PriceBook_Entry__c> ppbEntriesToInsert = new List<Publish_PriceBook_Entry__c>();

        for(PricebookEntry pd : product_lst ) {

            if(ppbId == null) continue;

            if(pd.CurrencyIsoCode != pbook.CurrencyIsoCode) continue;

            productIds.add(pd.Product2Id);

            Product2 p = pd.Product2;

            Publish_PriceBook_Entry__c existingPpbe = ppbeMap.get(pd.Product2Id);

            Decimal maxDiscount = 0;

            Decimal discount = allStylesWithDiscount.get(p.Product_Style__c );

            Decimal filterNumber = allStylesWithFilterNumber.get(p.Product_Style__c);

            if(filterNumber == null) filterNumber = 1;

            if(discount != null && discount > 0) {
                maxDiscount = discount;
            }

            if(existingPpbe != null && existingPpbe.Publish_PriceBook__c == ppbId &&
            	existingPpbe.Style_Number_Unique_Id__c == p.Style_Number_Unique_ID__c &&
            	existingPpbe.MSRP__c == pd.UnitPrice &&
				existingPpbe.Discount__c == maxDiscount &&
				existingPpbe.Filter_Number__c == filterNumber ) continue;

            Publish_PriceBook_Entry__c ppbe = new Publish_PriceBook_Entry__c( Id = existingPpbe == null ? null : existingPpbe.Id );

            ppbe.Price_Book__c = pbook.id;

            

            ppbe.Discount__c = maxDiscount;
            ppbe.Publish_PriceBook__c = ppbId;

            ppbe.Product_SKU__c = p.SKU__c;
            ppbe.Product_UPC__c = p.UPC__c;
            ppbe.Product_RWS_ID__c = p.RWS_Id__c;

            ppbe.Style_Number__c = p.ProductCode;
            ppbe.Style_Number_Unique_Id__c = p.Style_Number_Unique_ID__c;
            ppbe.Style_Name__c = p.Name;
            ppbe.Product_Id__c = p.Id;

            //ppbe.Pricebook_Entry_ID__c = ppbId + '-' + p.Id;

            

            ppbe.Filter_Number__c = filterNumber;

            Double stdUnitPrice = pd.UnitPrice;

            ppbe.List_Price__c = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (ppbe.Discount__c / 100) * stdUnitPrice);

            ppbe.MSRP__c = pd.UnitPrice;

            ppbe.Active__c = true;

            // Add to List
            ppbEntriesToInsert.add(ppbe);

            if(ppbEntriesToInsert.size() == 200) {
            	insertUpdateRecord(ppbEntriesToInsert);

                ppbEntriesToInsert = new List<Publish_PriceBook_Entry__c>();
            }

        }

        if(!ppbEntriesToInsert.isempty())  insertUpdateRecord(ppbEntriesToInsert);

        if(!productIds.isEmpty()) deactivatePublicPriceBookEntries(ppbId, productIds);

    }

    private static void insertUpdateRecord(List<Publish_PriceBook_Entry__c> ppbEntriesToInsert) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                upsert ppbEntriesToInsert; 
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    }

    public static void deactivatePublicPriceBookEntries(Id ppbId, Set<Id> productIds) {

        List<Publish_PriceBook_Entry__c> ppbes = [select Id, Active__c,
                                                       // Pricebook_Entry_ID__c,
                                                        Expiration_Date__c 
                                                    from Publish_PriceBook_Entry__c
                                                    where Product_Id__c not in :productIds
                                                    and Publish_PriceBook__c = :ppbId];

        if(ppbes.isEmpty()) return;

        for(Publish_PriceBook_Entry__c ppbe : ppbes) {
            ppbe.Active__c = false;
            ppbe.Expiration_Date__c = DateTime.now();
        }

        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = true;        

        insertUpdateRecord(ppbes);

        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

    }

    
    global void finish(Database.BatchableContext BC) {} 
}