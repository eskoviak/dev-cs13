/********************************************************************************
*   PURPOSE : To stage PriceBookEntry records for outbound publishing
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/07/2016  Usman Aslam/M360        Initial version
*	03/08/18	Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
public without sharing class RWS_PriceBookEntry_Util {

    //commented out by BW
    // util method to get publish pricebook entry records for the pricebook and products
    public static void createPublishPriceBookEntries(Id pricebookId, Set<Id> productIds) {
        List<Publish_PriceBook_Entry__c> ppbEntries = [SELECT Id, Name, Publish_PriceBook__c, Product_ID__c, 
                        CurrencyIsoCode, List_Price__c, Active__c, 
                        /*UseStandardPrice,*/ CreatedDate, CreatedById, 
                        LastModifiedDate, LastModifiedById, SystemModstamp, 
                        Style_Number__c	, IsDeleted, //RWS_Last_Updated_Date__c, 
                        Discount__c, Fixed_Price__c, MSRP_Effective_Date__c, 
                        MSRP_Expiration_Date__c, //RWS_Id__c, 
                        Filter_Number__c, //Pricebook2.IsStandard,
                        Price_Level__c 
                    FROM Publish_PriceBook_Entry__c WHERE Product_ID__c in :productIds AND Publish_PriceBook__c = :pricebookId];

        createPublishPriceBookEntries(ppbEntries);
    }

    // util method to get PricebookEntry records for the PricebookEntries
    // re-quering just to make sure all the fields are included
    public static void createPublicPriceBookEntries(List<Publish_PriceBook_Entry__c> pbEntries) {
        pbEntries = [SELECT Id, Name, 	Publish_PriceBook__c, Product_ID__c, 
                        CurrencyIsoCode, List_Price__c, Active__c, Price_Book_ID__c,
                        /*UseStandardPrice,*/ CreatedDate, CreatedById, 
                        LastModifiedDate, LastModifiedById, SystemModstamp, 
                        Style_Number__c, IsDeleted, /*RWS_Last_Updated_Date__c,*/ 
                        Discount__c, Fixed_Price__c, MSRP_Effective_Date__c, 
                        MSRP_Expiration_Date__c, /*RWS_Id__c, */
                        Filter_Number__c, /*Pricebook2.IsStandard,*/
                        Price_Level__c 
                    FROM Publish_PriceBook_Entry__c where Id in :pbEntries];

        createPublishPriceBookEntries(pbEntries);
        
    }

    // util method to create publish pricebook entry records for PricebookEntries
    private static void createPublishPriceBookEntries(List<Publish_PriceBook_Entry__c> pbEntries) {

        Set<Id> priceBookIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        // get product and pricebook IDs
        for(Publish_PriceBook_Entry__c pbe : pbEntries) {
            priceBookIds.add(pbe.Publish_PriceBook__c);
            productIds.add(pbe.Product_ID__c);
        }

        Id stdPbId;

        // get standard pricebook id
        if(Test.isRunningTest()) 
            stdPbId = Test.getStandardPricebookId();
        else
            stdPbId = [select id, name from Pricebook2 where IsStandard = true limit 1].id;

        // get standard price book entries, as we need both MSRP price and the program price
        List<PricebookEntry> stdEntries = [SELECT Id, Name, Product2Id, 
                                         UnitPrice, 
                                        UseStandardPrice, Discount__c, 
                                        MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                                        IsActive,
                                        CurrencyIsoCode
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :stdPbId
                                    AND Product2Id in :productIds];

        System.debug('************stdEntries: '+stdEntries);
        
        // populate Product Id to Pricebook Entry Map
        Map<String, PricebookEntry> prodToPbeMap = new Map<String, PricebookEntry>();
        for(PricebookEntry pb : stdEntries) {
            prodToPbeMap.put(String.valueOf(pb.Product2Id) + pb.CurrencyIsoCode,  pb);
        }

        /*
        // create PriceBook to Publish Price Book Id map
        Map<Id, Id> pbToPpbIdMap = new Map<Id, Id>();
        for(Publish_PriceBook__c ppb : [select Id, 
                                            Price_Book__c
                                    from Publish_PriceBook__c 
                                    where Price_Book__c in :priceBookIds]) {

            pbToPpbIdMap.put(ppb.Price_Book__c, ppb.Id);
        }*/

        // get products information
        Map<Id, Product2> productsMap = new Map<Id, Product2>(
            [
                select Id, Name, RWS_Id__c, SKU__c, UPC__c, 
                        ProductCode, Style_Number_Unique_ID__c
                from Product2 
                    where Id in :productIds 
                    and Product_Style__c != null
            ]
        );

        // list to insert Publish Pricebook Entries
        List<Publish_PriceBook_Entry__c> ppbEntriesToInsert = new List<Publish_PriceBook_Entry__c>();

        // iterate over all PriceBookEntry records
        for(Publish_PriceBook_Entry__c ppbe : pbEntries) {

            // if Publish PriceBookEntry Id is null, move to next record
            if(ppbe.Id == null) continue;
			//system.debug('*****************Publish Pricebook: '+ppbe.Publish_PriceBook__c);
            // get the Publish Pricebook Id, if not found, move to next record
            //********Id ppbId = pbToPpbIdMap.get(ppbe.Price_Book_ID__c);
            //*****if(ppbId == null) continue;
			
            
            // get the Product record, if not found, move to next record
            Product2 p = productsMap.get(ppbe.Product_ID__c);
            if(p == null) continue;

            // get the Standard PricebookEntry record, if not found, move to next record
            PriceBookEntry stdPbe = prodToPbeMap.get(String.valueOf(ppbe.Product_ID__c) + ppbe.CurrencyIsoCode);
            if(stdPbe == null) continue;

            // Initialize Publish Pricebook Entry object
           /* Publish_PriceBook_Entry__c ppbe = new Publish_PriceBook_Entry__c();
            ppbe.Price_Book__c = pbe.Pricebook2Id;
            ppbe.Discount__c = pbe.Discount__c;
            ppbe.Price_Level__c = pbe.Price_Level__c;
            ppbe.Publish_PriceBook__c = ppbId;*/

            ppbe.Product_SKU__c = p.SKU__c;
            ppbe.Product_UPC__c = p.UPC__c;
            ppbe.Product_RWS_ID__c = p.RWS_Id__c;

            ppbe.Style_Number__c = p.ProductCode;
            ppbe.Style_Number_Unique_Id__c = p.Style_Number_Unique_ID__c;
            ppbe.Style_Name__c = p.Name;

            //ppbe.Pricebook_Entry_ID__c = pbe.Id;  //Set PriceBook_Entry_ID__c for upsert

            //ppbe.List_Price__c = pbe.UnitPrice;

            //System.debug('*************UnitPrice: '+stdPbe.UnitPrice);

            
            ppbe.MSRP__c = stdPbe.UnitPrice;
            
            //System.debug('*************MSRP: '+ppbe.MSRP__c);

            //ppbe.Active__c = pbe.IsActive;

         /*   // Standard Pricebook Entries are being processed, then fill Effective and Expiration date
            if(pbe.Pricebook2.IsStandard) {
                ppbe.MSRP_Effective_Date__c = pbe.MSRP_Effective_Date__c;
                ppbe.MSRP_Expiration_Date__c = pbe.MSRP_Expiration_Date__c;
            }
		 */
            // Add to List
            ppbEntriesToInsert.add(ppbe);
        }


        // no publish price book entry records initialized above, exit
        if(ppbEntriesToInsert.isEmpty()) return;

        // set the flag to true so HasPricebook__c logic is executed
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = true;

        // insert/update records
        insertUpdateRecord(ppbEntriesToInsert);

        // set the flag to false so HasPricebook__c logic is NOT executed again in the same invocation
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

    }
    
    // util method to insert/update Publish Pricebook Entry records
    // try five times, if a try fails because of ROW LOCK issue
    public static void insertUpdateRecord(List<Publish_PriceBook_Entry__c> ppbEntriesToInsert) {
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

     
     public static void deactivatePublicPriceBookEntries(List<Publish_PriceBook_Entry__c> ppbes) {
      /*  Set<Id> pbeIds = new Map<Id, Publish_PriceBook_Entry__c>(pbEntries).keySet();

        List<Publish_PriceBook_Entry__c> ppbes = [select Id, Active__c,
                                                        Pricebook_Entry_ID__c,
                                                        Expiration_Date__c 
                                                    from Publish_PriceBook_Entry__c
                                                    where Pricebook_Entry_ID__c in :pbeIds];
	*/
        if(ppbes.isEmpty()) return;

        for(Publish_PriceBook_Entry__c ppbe : ppbes) {
            ppbe.Active__c = false;
            ppbe.Expiration_Date__c = DateTime.now();
            ppbe.Filter_Number__c = null;
        }

        // set the flag to true so HasPricebook__c logic is executed
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = true;        

        insertUpdateRecord(ppbes);

        // set the flag to false so HasPricebook__c logic is NOT executed again in the same invocation
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

    }
     
    
     //Commented this out to remove Pricbook_Entry_ID__c reference as it was used to hold pbe IDs - BW
     /* public static void deactivatePublicPriceBookEntries(List<PricebookEntry> pbEntries) {
        Set<Id> pbeIds = new Map<Id, PricebookEntry>(pbEntries).keySet();

        List<Publish_PriceBook_Entry__c> ppbes = [select Id, Active__c,
                                                        Pricebook_Entry_ID__c,
                                                        Expiration_Date__c 
                                                    from Publish_PriceBook_Entry__c
                                                    where Pricebook_Entry_ID__c in :pbeIds];

        if(ppbes.isEmpty()) return;

        for(Publish_PriceBook_Entry__c ppbe : ppbes) {
            ppbe.Active__c = false;
            ppbe.Expiration_Date__c = DateTime.now();
        }

        // set the flag to true so HasPricebook__c logic is executed
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = true;        

        insertUpdateRecord(ppbes);

        // set the flag to false so HasPricebook__c logic is NOT executed again in the same invocation
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();

    }*/


    
    
    // util method to set price or discount and publish records
    public static void publishPublicPriceBookEntries(List<Publish_PriceBook_Entry__c> ppbEntries) {
        //Map<Id, Publish_PriceBook_Entry__c> pbesMap = new Map<Id, Publish_PriceBook_Entry__c>(pbEntries);


        Set<Id> productIds = new Set<Id>();
        // get product and pricebook IDs
        for(Publish_PriceBook_Entry__c pbe : ppbEntries) {
            productIds.add(pbe.Product_Id__c);
        }

        Id stdPbId;

        // get standard pricebook id
        if(Test.isRunningTest()) 
            stdPbId = Test.getStandardPricebookId();
        else
            stdPbId = [select id, name from Pricebook2 where IsStandard = true limit 1].id;

        // get standard price book entries
        List<PricebookEntry> stdEntries = [SELECT Id, Name, Product2Id, 
                                         UnitPrice, 
                                        UseStandardPrice, Discount__c, 
                                        MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                                        IsActive,
                                        CurrencyIsoCode
                                    FROM PricebookEntry
                                    WHERE Pricebook2Id = :stdPbId
                                    AND Product2Id in :productIds];

        // populate Product Id to Pricebook Entry Map
        Map<String, PricebookEntry> prodToPbeMap = new Map<String, PricebookEntry>();
        for(PricebookEntry pb : stdEntries) {
            prodToPbeMap.put(String.valueOf(pb.Product2Id) + pb.CurrencyIsoCode,  pb);
        }

        // get publish pricebook entry records
       /* List<Publish_PriceBook_Entry__c> ppbes = [select Id, Publish_Status__c, Pricebook_Entry_ID__c,
                                                        List_Price__c, Discount__c 
                                                    from Publish_PriceBook_Entry__c
                                                    where Pricebook_Entry_ID__c in :pbesMap.keySet()];*/

        // if associated publish pricebook entry records are not found, exit
        if(ppbEntries.isEmpty()) return;


        // iterate over all publish pricebook entry records
        for(Publish_PriceBook_Entry__c ppbe : ppbEntries) {

            // get related pricebook entry record
           // Publish_PriceBook_Entry__c pbe = pbesMap.get(ppbe.Pricebook_Entry_ID__c);

            // if not found, move to next record
            //if(pbe == null) continue;

            // get related standard pricebook entry record
            PriceBookEntry stdPbe = prodToPbeMap.get(String.valueOf(ppbe.Product_Id__c) + ppbe.CurrencyIsoCode);

            // if not found, move to next record
            if(stdPbe == null) continue;

            // set info on the publish pricebook entry record
            ppbe.MSRP__c = stdPbe.UnitPrice;

           // ppbe.List_Price__c = pbe.List_Price__c;
           // ppbe.Discount__c = pbe.Discount__c;

            
        }


        // update publish pricebook entry records
        insertUpdateRecord(ppbEntries);
    }


    // util method to insert/update Pricebook Entry records
    // try five times, if a try fails because of ROW LOCK issue
    public static void insertUpdateRecords(List<Publish_PriceBook_Entry__c> ppbes, Boolean insertRecords) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                if(insertRecords) insert ppbes; 
                if(!insertRecords) update ppbes; 
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    }

   /* // util method to delete Pricebook Entry records
    // try five times, if a try fails because of ROW LOCK issue
    public static void deleteRecords(List<Publish_PriceBook_Entry__c> entriesToDelete) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                delete entriesToDelete;
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    } */
    
    // util method to delete Pricebook Entry records
    // try five times, if a try fails because of ROW LOCK issue
    public static void deleteRecords(List<PricebookEntry> entriesToDelete) {
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                delete entriesToDelete;
                attempts = 0;
            } catch (System.DmlException dmlEx) {
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } // end of catch
        } // end of while retry loop
    }


    
}