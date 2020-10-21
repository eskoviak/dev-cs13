/********************************************************************************
*   PURPOSE : Handler class for RWS_ProgramProducts_Batch
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*                                       Initial version
*   03/08/2018  Brandon Willard/M360    Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_ProgramProducts_BatchHandler {
   
    private Id programId;
    private Boolean createTemplate;
    private String programName;
    

    public RWS_ProgramProducts_BatchHandler(Id programId, Boolean createTemplate, String programName) {
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

    public void execute() {
        List<Publish_PriceBook__c> ppb = [select Id, CurrencyIsoCode
                                from Publish_PriceBook__c 
                                where  Program__c != null 
                                and Program__c = :programId                                 
                            limit 1];

        if(ppb.isEmpty()) return;

     List<Filter_Criteria__c> fcs = [SELECT OwnerId, CurrencyIsoCode, Discount__c, 
                    Filter_BE_Details__c, Filter_Display__c, 
                    Filter_Number__c, IA_Feature__c, 
                    Program__c, Results_Count__c,
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

            System.debug('Filter Number: ' + fc.Filter_Number__c);
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
            stdPriceBookId = [select id, name from Pricebook2 where isStandard = true limit 1].id;
        }

        List<PricebookEntry> stdPbes = [SELECT UnitPrice,
                                            ProductCode,
                                            Product2Id,
                                            Product2.ProductCode,
                                            Product2.Category__c,
                                            Product2.Style_Number_Unique_ID__c,
                                            Product2.Name,
                                            Product2.RWS_Id__c,
                                            Product2.SKU__c,
                                            Product2.UPC__c,
                                            Price_Level__c
                                        FROM PricebookEntry 
                                        WHERE Pricebook2Id = :stdPriceBookId 
                                        AND IsActive = true 
                                        AND ProductCode in :productsMap.keySet()
                                        AND Product2.Product_Style__c != null
                                        AND Product2.IsActive = true
                                        AND CurrencyISOCode = :ppb[0].CurrencyISOCode];


        Map<String, Publish_PriceBook_Entry__c> publishPricebookentry_Map = new Map<String,Publish_PriceBook_Entry__c>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productCodesProcessed = new Set<String>();
        

        
        //Creates PPBE for each standard pricebook entry
        for(PricebookEntry spbe : stdPbes) {
            if(productCodesProcessed.contains(spbe.ProductCode)) continue;

            Product p = productsMap.get(spbe.ProductCode);

            if(p == null) continue;

            productCodesProcessed.add(spbe.ProductCode);

            Publish_PriceBook_Entry__c ppbe = new Publish_PriceBook_Entry__c();
            ppbe.Publish_PriceBook__c = ppb[0].Id;
            ppbe.Active__c = true;
            ppbe.Product_ID__c = spbe.Product2Id;
            ppbe.Discount__c = p.discount;
            ppbe.CurrencyIsoCode = ppb[0].CurrencyISOCode;
            ppbe.Style_Name__c = spbe.Product2.Name;
            ppbe.Style_Number__c = spbe.Product2.ProductCode;
            ppbe.Style_Number_Unique_Id__c = spbe.Product2.Style_Number_Unique_ID__c;
            ppbe.Product_RWS_ID__c = spbe.Product2.RWS_ID__c;
            ppbe.Product_SKU__c = spbe.Product2.SKU__c;
            ppbe.Product_UPC__c = spbe.Product2.UPC__c;
            ppbe.MSRP__c = spbe.UnitPrice;
            ppbe.Price_Level__c = spbe.Price_Level__c;

             // get standard price
            Double stdUnitPrice = spbe.UnitPrice;

            if(stdUnitPrice == null) stdUnitPrice = 0;

            // set on program pricebook entry
            ppbe.List_Price__c = stdUnitPrice == 0 ? 0 : (stdUnitPrice - (ppbe.Discount__c / 100) * stdUnitPrice).setScale(2);

            
            ppbe.Fixed_Price__c = p.isFixedPrice;

            System.debug('p.filterNumber: ' + p.filterNumber);
            ppbe.Filter_Number__c = p.filterNumber;

            
            //add to map Key:ProductCode / Value:PPBE
            publishPricebookentry_Map.put(spbe.ProductCode, ppbe);
            productIds.add(ppbe.Product_ID__c);
        }
        
        
        
        //Get list of all PPBE's related to program and if PPBE is in list
        //update the FN  and to set to active, ad to publishPricebookEntry_Map
        
        //Use product map to get FN
        

        Boolean withoutProductCodes = true;
        if(!publishPricebookentry_Map.isEmpty()) {
            withoutProductCodes = false;

            //List<Product2> prods = [select Id from Product2 where Id in :productIds for update];

     //This checks to see if the PPBE already exists for the program and if so removes it from the new PPBE checklst
            
            // As upsert for pricebookentry is not possible, the below method is followed.
            List<Publish_PriceBook_Entry__c> ppbe_check_Lst 
                = [select Id, Product_ID__c, List_Price__c, Fixed_Price__c, Discount__c, Active__c, Style_Number__c, Price_Level__c, Program_ID__c
                        From Publish_PriceBook_Entry__c 
                        Where Publish_PriceBook__c = :ppb[0].Id
                        and Style_Number__c in :publishPricebookentry_Map.keyset()
                        //AND Product2.IsActive = true
                        //AND Product2.Product_Style__c != null
                        AND CurrencyISOCode = :ppb[0].CurrencyISOCode];
            
            
            Set<Id> prodIds = new Set<Id>();
            
            for(Publish_PriceBook_Entry__c ppbe : ppbe_check_Lst) {
                prodIds.add(ppbe.Product_Id__c);
            }
            
            Set<Id> prodIdSet = new Set<Id>(); 
            for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode 
                    FROM Product2 WHERE Product_Style__c != null AND IsActive = true AND Id IN : prodIds]){
                prodIdSet.add(prod.Id);
            }
            
            for(Integer i = 0; i < ppbe_check_Lst.size(); i++){
                if (!prodIdSet.contains(ppbe_check_Lst[i].Product_Id__c)){
                    ppbe_check_Lst.remove(i);    
                }
            }
            
            String progPubStatus = [SELECT Id, Publish_Status__c FROM Program__c WHERE Id =: programId LIMIT 1].Publish_Status__c;
        
            //Sets already existing PPBEs to the values of the PPBEs created from the standard pricebook for the program - Sets the PPBE to Active           
            List<Publish_PriceBook_Entry__c> publishpricebookentry_updatelst = new List<Publish_PriceBook_Entry__c>();
            if(!ppbe_check_Lst.isEmpty()) {
                for(Publish_PriceBook_Entry__c p : ppbe_check_Lst ) {

                    Publish_PriceBook_Entry__c otherPpbe = publishPricebookentry_Map.get(p.Style_Number__c);

                    if(otherPpbe == null) continue;
                    
                    /*
                    if(p.Discount__c != otherPbe.discount__c) {
                        pricebookentry_Map.remove(p.ProductCode);
                        continue;
                    }
                    */

                    Publish_PriceBook_Entry__c ppbe = new Publish_PriceBook_Entry__c();
                    ppbe.id = p.Id;
                    ppbe.List_Price__c = otherPpbe.List_Price__c;
                    ppbe.discount__c = otherPpbe.Discount__c;
                    ppbe.Fixed_Price__c = otherPpbe.Fixed_Price__c;
                            
                    ppbe.Product_ID__c = otherPpbe.Product_ID__c;
                    ppbe.CurrencyIsoCode = otherPpbe.CurrencyISOCode;
                    ppbe.Style_Number__c = otherPpbe.Style_Number__c;
                    ppbe.Style_Name__c = otherPpbe.Style_Name__c;
                    ppbe.Style_Number_Unique_Id__c = otherPpbe.Style_Number_Unique_ID__c;
                    ppbe.Product_RWS_ID__c = otherPpbe.Product_RWS_ID__c;
                    ppbe.Product_SKU__c = otherPpbe.Product_SKU__c;
                    ppbe.Product_UPC__c = otherPpbe.Product_UPC__c;
                    ppbe.Price_Level__c = otherPpbe.Price_Level__c;
                    //ppbe.Pricebook_Entry_ID__c = otherPpbe.Pricebook_Entry_ID__c;
                    
                    System.debug('otherPpbe.Filter_Number__c: ' + otherPpbe.Filter_Number__c);
                    ppbe.Filter_Number__c = otherPpbe.Filter_Number__c;
                    ppbe.Publish_Status__c = (progPubStatus == 'Published' ? 'ReadyToPublish' : progPubStatus);
                    ppbe.Active__c = true;
                                                         
                    ppbe.Expiration_Date__c = null;

                        
                    publishpricebookentry_updatelst.add(ppbe);
                   
                    if(publishpricebookentry_updatelst.size() == 200) {
                        
                        //insertUpdateRecords(publishpricebookentry_updatelst, fcs, false);
                        RWS_PriceBookEntry_Util.insertUpdateRecords(publishpricebookentry_updatelst, false);

                        
                        publishpricebookentry_updatelst = new List<Publish_PriceBook_Entry__c>();
                    }

                    //Removes the PPBE from the map if we are updating as the ones left will go on to be inserted as new
                    publishpricebookentry_Map.remove(p.Style_Number__c);
                }
            }

            if(!publishpricebookentry_updatelst.isEmpty()) {
                //insertUpdateRecords(publishpricebookentry_updatelst, fcs, false);
                RWS_PriceBookEntry_Util.insertUpdateRecords(publishpricebookentry_updatelst, false);

            }

            List<Publish_PriceBook_Entry__c> publishpricebookentry_insertlst = new List<Publish_PriceBook_Entry__c>();

            for(Publish_PriceBook_Entry__c p : publishpricebookentry_Map.values() ) {
                publishpricebookentry_insertlst.add(p);

                if(publishpricebookentry_insertlst.size() == 200) {
                    //insertUpdateRecords(publishpricebookentry_insertlst, fcs, true);
                    RWS_PriceBookEntry_Util.insertUpdateRecords(publishpricebookentry_insertlst, true);

                    publishpricebookentry_insertlst = new List<Publish_PriceBook_Entry__c>();
                }
            }

            if(!publishpricebookentry_insertlst.isEmpty()) {
                //insertUpdateRecords(publishpricebookentry_insertlst, fcs, true);
                RWS_PriceBookEntry_Util.insertUpdateRecords(publishpricebookentry_insertlst, true);

            }

        } else {
            
            Set<Id> prodIds = new Set<Id>();
            List<Publish_PriceBook_Entry__c> ppbes = [select Id, Product_ID__c 
                                                    From Publish_PriceBook_Entry__c  
                                                    Where Publish_PriceBook__c = :ppb[0].Id  
                                                    //AND Product2.IsActive = true 
                                                    //AND Product2.Product_Style__c != null 
                                                    AND CurrencyISOCode = :ppb[0].CurrencyISOCode];
            
            for(Publish_PriceBook_Entry__c ppbe : ppbes) {
                prodIds.add(ppbe.Product_Id__c);
            }            
            
            for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE Product_Style__c != null AND IsActive = true AND Id IN : prodIds]){
                productIds.add(prod.Id);                
            }
            
            
            /*
            for(PricebookEntry pbe : [select Id, Product2Id From PricebookEntry  Where Pricebook2Id = :pb[0].Id  AND Product2.IsActive = true AND Product2.Product_Style__c != null AND CurrencyISOCode = :pb[0].CurrencyISOCode]) {
                productIds.add(pbe.Product2Id);
            }
            */
            
        }

        productIds.remove(null);

        if(!withoutProductCodes) { 
            /*
            Map<Id, PricebookEntry> allPBEsMap = new Map<Id, PricebookEntry>([select Id, Product2Id, Unitprice, Fixed_Price__c, Discount__c, IsActive
                            From PricebookEntry 
                            Where Pricebook2Id = :pb[0].Id 
                            AND Product2.IsActive = true
                            AND CurrencyISOCode = :pb[0].CurrencyISOCode
                            AND IsActive = true
                            AND Product2Id not in :productIds]);
            
            
            List<Publish_PriceBook_Entry__c> ppbes = [select Id, Active__c,
                                                            Pricebook_Entry_ID__c,
                                                            Expiration_Date__c 
                                                        from Publish_PriceBook_Entry__c
                                                        where Pricebook_Entry_ID__c in :allPBEsMap.keySet()];

            for(Publish_PriceBook_Entry__c pbe : ppbes) {
                allPBEsMap.remove(pbe.Pricebook_Entry_ID__c);
            }

            for(PriceBookEntry pbe : allPBEsMap.values()) {
                productIds.add(pbe.Product2Id);
            }

           
            */
            
           /*******************************************************************************************************
            * BW - Commented this out as it seems to create publish pricebook entries for pricebook entries
            * that do not have a corresponding publish pricebook entry. Being that we are now only using publish
            * pricebook entries, this code should not be needed
            * *****************************************************************************************************/ 
           List<Publish_PriceBook_Entry__c> ppbeList = new List<Publish_PriceBook_Entry__c>([select Id, Product_ID__c, List_Price__c, Fixed_Price__c, Discount__c, Active__c,
                                                                                             Pricebook_Entry_ID__c, Expiration_Date__c
                                                                                                From Publish_PriceBook_Entry__c 
                                                                                                Where Publish_PriceBook__c = :ppb[0].Id 
                                                                                                AND CurrencyISOCode = :ppb[0].CurrencyISOCode
                                                                                                AND Active__c = true
                                                                                                AND Product_ID__c not in :productIds]);
            
            Set<Id> prodIds = new Set<Id>();            
            
            for(Publish_PriceBook_Entry__c ppbe : ppbeList) {
                prodIds.add(ppbe.Product_Id__c);
            }
            
            Set<Id> prodIdSet = new Set<Id>(); 
            for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE IsActive = true AND Id IN : prodIds]){
                prodIdSet.add(prod.Id);
            }
            
            for(Integer i = 0; i < ppbeList.size(); i++){
                if (!prodIdSet.contains(ppbeList[i].Product_Id__c)){
                    ppbeList.remove(i);    
                }
            }
            
            Map<Id, Publish_PriceBook_Entry__c> allPPBEsMap = new Map<Id, Publish_PriceBook_Entry__c>();
            
            for (Publish_Pricebook_Entry__c ppbe : ppbeList){
                allPPBEsMap.put(ppbe.Id, ppbe);
            }

            for(Publish_PriceBook_Entry__c ppbe : allPPBEsMap.values()) {
                productIds.add(ppbe.Product_ID__c);
            }
        }
        
        if(!productIds.isEmpty()) {
            RWS_PriceBookEntry_Util.createPublishPriceBookEntries(ppb[0].Id, productIds);
        }
        
        

        Program__c existingProgram = new Program__c(Id = programId,
            Processing_Status__c = 'Completed'
        );   

        update existingProgram;

        Program__c program = [SELECT Id, Name, Account__c, Account__r.Name, Owner.Name,
                  Accessories_Allowed_on_Subsidy__c,
                  Accessories_Allowed_on_Payroll_Deduction__c, 
                  Activation_Date__c,
                  Active__c,
                  HasPricebook__c,
                  Alternative_Payment__c,
                  Annual_Reset_or_Rollover__c,
                  Auto_Add_Products__c ,
                  Auto_Update_Price__c,
                  Description__c, 
                  Eligibility_Option__c, 
                  Exclusive__c,
                  Expiration_Date__c,
                  Fixed__c,
                  Frequency__c,
                  GSA_Pricing__c,
                  Mandatory__c, 
                  Max_Amount__c,
                  Number_of_Eligible_Employees__c,
                  Number_of_Locations__c, 
                  Number_of_Pairs_Allowed__c,
                  Open_Subsidy__c, 
                  Outbound_Message_Type__c,
                  Proposal_Notes__c,
                  Publish_Status__c,
                  Published_Date__c, 
                  Purchase_Program_Notes__c,
                  Require_Upload_of_Company_Voucher__c,
                  Rolling_Balance__c,
                  Sales_Opportunity_Pairs__c,
                  Servicing_Level__c,
                  Subsidy_Amount__c,
                  Subsidy_Frequency__c,
                  Subsidy_Notes__c, 
                  Subsidy_Percent__c,
                  Subsidy_Tax__c,
                  Subsidy_Type__c, 
                  Template__c,
                  TXMAS_Pricing__c,
                  toLabel(Type__c), 
                  Voucher_Distribution__c,
                  Processing_Status__c,
                  RecordTypeId
                FROM Program__c where Id = :programId];

        for(Filter_Criteria__c fc : fcs) {
            if(program.Active__c) fc.Product_Code__c = null;
        }

        update fcs;

        Id templatePricebookId;
        if(createTemplate) {
            

            Id programRecordTypeId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Program_Template', 'Program__c');

            program.RecordTypeId = programRecordTypeId;

            program.Account__c = null;
            program.Id = null;
            program.Active__c = false;
            program.Name = programName;

            for(SelectOption so : RWS_UtilityClass.getType() ) {
                if(so.getLabel() == program.Type__c) {
                    program.Type__c = so.getValue();
                    break;
                }
            }

            insert program;


            List<Filter_Criteria__c> newFcs = new List<Filter_Criteria__c>();

            for(Filter_Criteria__c fc : fcs) {

                Filter_Criteria__c cloneFc = fc.clone(false, true);

                cloneFc.Program__c = program.Id;

                newFcs.add(cloneFc);
            }

            insert newFcs;


            List<Publish_PriceBook__c> ppbs = [SELECT Name, CurrencyIsoCode, IsActive__c, 
                                       //Description, 
                                        Program__c, //Type__c, 
                                        Discount__c//, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                        //Future_Pricebook__c, Effective_Date__c 
                                    FROM Publish_PriceBook__c where Program__c = :programId];

            if(!ppbs.isEmpty()) {

                Publish_PriceBook__c newPpb = ppbs[0].clone(false, true);
                newPpb.Program__c = program.Id;

                insert newPpb;

                templatePricebookId = newPpb.Id;

                List<Publish_PriceBook_Entry__c> ppbes = [select Id, Publish_PriceBook__c, Product_ID__c, CurrencyIsoCode, 
                                            List_Price__c, Active__c, //UseStandardPrice, 
                                            Discount__c, //RWS_Last_Updated_Date__c, RWS_Id__c, 
                                            MSRP_Effective_Date__c, MSRP_Expiration_Date__c, 
                                            Fixed_Price__c,
                                            Filter_Number__c 
                                        FROM Publish_PriceBook_Entry__c where Publish_PriceBook__c = :ppbs[0].Id
                                        and CurrencyIsoCode = :ppb[0].CurrencyISOCode];

                List<Publish_PriceBook_Entry__c> newPpbes = new List<Publish_PriceBook_Entry__c>();
                productIds = new Set<Id>();

                for(Publish_PriceBook_Entry__c ppbe : ppbes) {
                    Publish_PriceBook_Entry__c clonePpbe = ppbe.clone(false, true);
                    productIds.add(ppbe.Product_ID__c);

                    clonePpbe.Publish_PriceBook__c = newPpb.Id; 

                    newPpbes.add(clonePpbe);

                    if(newPpbes.size() == 200) {
                        RWS_PriceBookEntry_Util.insertUpdateRecords(newPpbes, true);

                        newPpbes = new List<Publish_PriceBook_Entry__c>();
                    }
                }

                if(!newPpbes.isEmpty()) {
                    RWS_PriceBookEntry_Util.insertUpdateRecords(newPpbes, true);
                }

               // if(productIds.isEmpty()) return;

               // if(!Test.isRunningTest()) System.enqueueJob(new RWS_ProgramPublishProducts_Queue(ppb[0].Id, templatePricebookId, productIds));
            }

        }
        
    }
    
    /*
    // util method to insert/update Publish Pricebook Entry records
    // Checks that the PPBE filter number belongs to the FC of the program.
    public static void insertUpdateRecords(List<Publish_PriceBook_Entry__c> publishpricebookentrylst, Boolean isInsert) {
        
        System.debug('insert update called');
        System.debug('isInsert: '+isInsert);
        if (isInsert){
            RWS_PriceBookEntry_Util.insertUpdateRecords(publishpricebookentrylst, true);
            
        } else { 
            
            Set<Id> styleIdSet = new Set<Id>();
            Map<Id, Integer> styleFilterNumMap = new Map<Id, Integer>();
            for(Filter_Criteria__c fc : fcs) {
               styleIdSet.addAll(RWS_FilterCriteria_Util.getProductStylesForFilter(fc));
                for (Id prodStyle : styleIdSet){
                    styleFilterNumMap.put(prodStyle, Integer.valueOf(fc.Filter_Number__c));
                }
            }
            
            List<Product2> prodList = [SELECT Id, ProductCode, Product_Style__c FROM Product2 WHERE Product_Style__c IN : styleIdSet];
            Map<String, Integer> prodCodeMap = new Map<String, Integer>();
            for (Product2 prod : prodList){
                Integer filterNum = styleFilterNumMap.get(prod.Product_Style__c);                               
                prodCodeMap.put(prod.ProductCode, filterNum);
            }
            
            List<Publish_Pricebook_Entry__c> ppbeLst = new List<Publish_Pricebook_Entry__c>([select Id, Publish_PriceBook__c, Product_ID__c, CurrencyIsoCode, 
                                                                                                   List_Price__c, Active__c, 
                                                                                                   Discount__c, 
                                                                                                   MSRP_Effective_Date__c, MSRP_Expiration_Date__c, 
                                                                                                   Fixed_Price__c,
                                                                                                   Filter_Number__c,
                                                                                                   Publish_Status__c,
                                                                                                   Style_Number__c
                                                                                                   FROM Publish_PriceBook_Entry__c where Style_Number__c IN: prodCodeMap.keySet()
                                                                                                   AND Id IN: publishpricebookentrylst
                                                                                                   ORDER BY Id DESC]);
            
            
            Set<String> processedProds = new Set<String>();
            for (Publish_Pricebook_Entry__c ppbe : ppbeLst){
                if (!processedProds.contains(ppbe.Style_Number__c)){
                    ppbe.Publish_Status__c = '';
                    ppbe.Filter_Number__c = prodCodeMap.get(ppbe.Style_Number__c);
                    processedProds.add(ppbe.Style_Number__c);
                }                           
            }      
                       
            RWS_PriceBookEntry_Util.insertUpdateRecords(ppbeLst, false);
            
        }
    }
    */
 
}