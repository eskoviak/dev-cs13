global class RWS_ProgramSync_Batch implements Database.Batchable<sObject>, Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new RWS_ProgramSync_Batch(), 1);
    }

    global RWS_ProgramSync_Batch() { }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer lastDays = -1 * Integer.valueOf(Label.Number_of_Days);
        Datetime dt = Datetime.now().addDays(lastDays);

        String programKeyPrefix = Program__c.SObjectType.getDescribe().getKeyPrefix();

        Set<String> programIds = new Set<String>();

        for(String prId : Label.Program_Test_Run_Id.split(',')) {
            if(String.isBlank(prId)) continue;

            if(prId.startsWith(programKeyPrefix) && (prId.length() == 15 || prId.length() == 18) ) {
                if(!Test.isRunningTest()) programIds.add(prId);
            }
        }

        return Database.getQueryLocator('select Id, Active__c, HasPricebook__c, ' + 
                                '(select Id, CurrencyIsoCode from Publish_PriceBooks__r), ' + 
                                '(select IA_Feature__r.Name, ' +
                                    'Discount__c, ' +
                                    'Filter_Number__c, ' +
                                    'IA_Feature__r.Filter_Logic__c, ' +
                                    'Filter_BE_Details__c, ' +
                                    'Product_Code__c, ' +
                                    'Results_Count__c ' +
                                'from Filter_Criteria__r where Filter_Number__c != null and Filter_Number__c > 0 ' +
                            'order by Discount__c desc NULLS LAST) ' + 
                            'from Program__c where CreatedDate >= :dt ' + 
                        (programIds.isEmpty() ? '' : ' AND Id in :programIds ')  );
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {

        Program__c program = (Program__c) scope[0];

        if(program.Filter_Criteria__r == null || program.Filter_Criteria__r.isEmpty()) return;

        if(program.Publish_PriceBooks__r == null || program.Publish_PriceBooks__r.isEmpty() ) return;

        Publish_PriceBook__c pbook = program.Publish_PriceBooks__r[0];

        List<Publish_PriceBook_Entry__c> existing_product_lst  
            = [select Id, CurrencyISOCode, 
                     List_Price__c, Product_Id__c, 
                     //Product2.Category__c,
                     //Product2.Product_Style__c,
                     Filter_Number__c,
                     Discount__c,
                     Active__c,
                     Style_Number__c
                from Publish_PriceBook_Entry__c
                where Publish_PriceBook__c = :pbook.Id
                //and Product2.Product_Style__c != null
                and CurrencyISOCode = :pbook.CurrencyIsoCode];
        
        Set<Id> prodIds = new Set<Id>();
            
        for(Publish_PriceBook_Entry__c ppbe : existing_product_lst) {
            prodIds.add(ppbe.Product_Id__c);
        }
        
        Set<Id> prodIdSet = new Set<Id>(); 
        for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE Product_Style__c != null AND Id IN : prodIds]){
            prodIdSet.add(prod.Id);
        }
        
        for(Integer i = 0; i < existing_product_lst.size(); i++){
            if (!prodIdSet.contains(existing_product_lst[i].Product_Id__c)){
                existing_product_lst.remove(i);    
            }
        }
        

        Map<String, Publish_PriceBook_Entry__c> productToPBEMap  = new Map<String, Publish_PriceBook_Entry__c>();
        for(Publish_PriceBook_Entry__c ppbe : existing_product_lst) {
            productToPBEMap.put(ppbe.Style_Number__c, ppbe);
        }

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


        List<Product2> products = [select Id from Product2 
                                        where Product_Style__c in :allStylesWithDiscount.keySet()
                                        and IsActive = true];
                                        
        List<PricebookEntry> product_lst  
            = [select Id, CurrencyISOCode, 
                     Unitprice, Product2Id, 
                     Product2.Product_Style__c,
                     Filter_Number__c,
                     Discount__c,
                     IsActive,
                     ProductCode
                from PricebookEntry
                where Pricebook2Id = :stdpbid
                and Product2Id in :products
                and IsActive = true
                and Product2.Product_Style__c != null
                and CurrencyISOCode = :pbook.CurrencyIsoCode];

        List<Publish_PriceBook_Entry__c> insertPriceBookEntry_lst = new list<Publish_PriceBook_Entry__c>();
        List<Publish_PriceBook_Entry__c> updatePriceBookEntry_lst = new list<Publish_PriceBook_Entry__c>();
        Set<Id> productIds = new Set<Id>();
        Set<String> processedCode = new Set<String>();

        for(PricebookEntry pd : product_lst ) {

            if(processedCode.contains(pd.ProductCode)) continue;

            processedCode.add(pd.ProductCode);
            
            Publish_PriceBook_Entry__c pbEntry = productToPBEMap.get(pd.ProductCode);

            Decimal maxDiscount = 0;

            Decimal discount = allStylesWithDiscount.get(pd.Product2.Product_Style__c );

            Decimal filterNumber = allStylesWithFilterNumber.get(pd.Product2.Product_Style__c);

            if(discount != null && discount > 0) {
                maxDiscount = discount;
            }

            if(filterNumber == null) filterNumber = 1;

            if(pbEntry == null)  {
                pbEntry = new Publish_PriceBook_Entry__c();
                pbEntry.Product_ID__c = pd.Product2Id;
                pbEntry.Publish_PriceBook__c = pbook.id;
                pbEntry.CurrencyIsoCode = pbook.CurrencyIsoCode;
            }
            

            pbEntry.Active__c = true;

            pbEntry.Discount__c = maxDiscount;

            pbEntry.Filter_Number__c = filterNumber;

            Double stdUnitPrice = pd.UnitPrice;

            pbEntry.List_Price__c = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (pbEntry.Discount__c / 100) * stdUnitPrice);

            productIds.add(pbEntry.Product_ID__c);

            if(pbEntry.Id != null) {
                updatePriceBookEntry_lst.add(pbEntry);

                if(updatePriceBookEntry_lst.size() == 200) {
                    RWS_PriceBookEntry_Util.insertUpdateRecords(updatePriceBookEntry_lst, false);
                    updatePriceBookEntry_lst = new List<Publish_PriceBook_Entry__c>();
                }

            } else {
                insertPriceBookEntry_lst.add(pbEntry);

                if(insertPriceBookEntry_lst.size() == 200) {
                    RWS_PriceBookEntry_Util.insertUpdateRecords(insertPriceBookEntry_lst, true);
                    insertPriceBookEntry_lst = new List<Publish_PriceBook_Entry__c>();
                }
                
            }

            productToPBEMap.put(pd.ProductCode, pbEntry);
        }

        if(updatePriceBookEntry_lst.isempty() && insertPriceBookEntry_lst.isempty()) return;

        if(!updatePriceBookEntry_lst.isempty())  RWS_PriceBookEntry_Util.insertUpdateRecords(updatePriceBookEntry_lst, false);

        if(!insertPriceBookEntry_lst.isempty())  RWS_PriceBookEntry_Util.insertUpdateRecords(insertPriceBookEntry_lst, true);

        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

        RWS_PriceBookEntry_Util.createPublishPriceBookEntries(pbook.Id, productIds);

        List<Publish_PriceBook_Entry__c> entriesToDelete = [select Id from Publish_PriceBook_Entry__c where Publish_PriceBook__c in :program.Publish_PriceBooks__r 
                    //and Product2.Parent_Product_Style__c in :allStylesWithDiscount.keySet()
                    and Product_ID__c not in :productIds];
        
        prodIds.clear();            
        for(Publish_PriceBook_Entry__c ppbe : entriesToDelete) {
            prodIds.add(ppbe.Product_Id__c);
        }
        
        prodIdSet.clear(); 
        for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE Product_Style__c != null AND Id IN : prodIds]){
            prodIdSet.add(prod.Id);
        }
        
        for(Integer i = 0; i < entriesToDelete.size(); i++){
            if (!prodIdSet.contains(entriesToDelete[i].Product_Id__c)){
                entriesToDelete.remove(i);    
            }
        }
        

        //if(!entriesToDelete.isEmpty())  RWS_PriceBookEntry_Util.deleteRecords(entriesToDelete);
        if(!entriesToDelete.isEmpty())  RWS_PriceBookEntry_Util.deactivatePublicPriceBookEntries(entriesToDelete);
        
    }

    global void finish(Database.BatchableContext BC) {}
}