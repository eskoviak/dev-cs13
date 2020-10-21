/********************************************************************************
*   PURPOSE :   Handler class for trigger on Product2 object.

*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/01/2016  Usman Aslam/M360        Initial version
********************************************************************************/
public with sharing class RWS_ProductTrigger_Handler {

    // method to handle before insert event of the trigger 
    public static void beforeInsert(List<Product2> newRecords) {
        // create/set product style on new records
        createProductStyles(newRecords, null, false);
    }

    // method to handle before update event of the trigger 
    public static void beforeUpdate(List<Product2> newRecords, Map<Id, Product2> oldRecords) {

        // custom label to turn off update code
        Boolean allowUpdateRun = Boolean.valueOf(Label.Run_Update_Trigger);

        if(allowUpdateRun || Test.isRunningTest())
              createProductStyles(newRecords, oldRecords, true);

        // update related standard pricebook publish pricebook entries when product is deactivated
        //updatePublishPricebookEntries(newRecords, oldRecords); - removed due to DML errors, deactivating Product does not need to update PPBE related records
    }

    private static void updatePublishPricebookEntries(List<Product2> newRecords, Map<Id, Product2> oldRecords) {
        // set to hold inactive product ids
        Set<Id> inactiveProductIds = new Set<Id>();

        // iterate over all records
        for(Product2 p : newRecords) {
            // if both Product_Style and Parent Product Style are changed and
            // Parent Product Style is filled and
            // Parent Product Style is empty
            if(p.Product_Style__c != oldRecords.get(p.Id).Product_Style__c &&
                p.Parent_Product_Style__c != oldRecords.get(p.Id).Parent_Product_Style__c
                && p.Parent_Product_Style__c != null 
                && p.Product_Style__c == null ) {

                // add the product id
                inactiveProductIds.add(p.Id);

            }
        }

        // if not product falls in the criteria above, exit
        if(inactiveProductIds.isEmpty() ) return;

        Id stdPbId;

        // get standard pricebook id
        if(Test.isRunningTest()) 
            stdPbId = Test.getStandardPricebookId();
        else
            stdPbId = [select id, name from Pricebook2 where IsStandard = true limit 1].id;
        
        // get standard pricebook entry ids
        Set<Id> prodIds = new Set<Id>();
        for (PricebookEntry pbe :  [select Id, Product2Id from PricebookEntry where Product2Id in :inactiveProductIds and Pricebook2Id = :stdPbId]){
            prodIds.add(pbe.Product2Id);
        }        

        // if no standard pricebook entry ids are found, exit
        if(prodIds.isEmpty()) return;

        // get related publish pricebook entry records
        List<Publish_PriceBook_Entry__c> ppbes = [select Id, Active__c
                                                    from Publish_PriceBook_Entry__c
                                                    where Product_ID__c in :prodIds];

        // if no publish pricebook entry records found, exit
        if(ppbes.isEmpty()) return;

        // set active = false on publish pricebook entry record
        for(Publish_PriceBook_Entry__c ppbe : ppbes) {
            ppbe.Active__c = false;
        }

        // do not run HasPricebook logic
        RWS_PublishPriceBookEntryTrigger_Handler.RUN_PROGRAM_UPDATE = Test.isRunningTest();
        
        // update publish pricebook entry records
        update ppbes;
    }


    // flag to avoid recursion
    private static Boolean RUN_ONCE = true;

    // create/set product style on new records
    private static void createProductStyles(List<Product2> newRecords, Map<Id, Product2> oldRecords, Boolean isUpdate) {

        // update the flag value
        RUN_ONCE = Test.isRunningTest();

        // intialize variables
        Set<String> uniqueStyles = new Set<String>();
        Set<String> categories = new Set<String>();

        // iterate over records in trigger context
        for(Product2 p : newRecords) {

            // if unique id is empty, move to next record
            if(p.Style_Number_Unique_ID__c == null) continue;

            // if category is empty, move to next record
            if(p.Category__c == null) continue;

            uniqueStyles.add(p.Style_Number_Unique_ID__c);

            categories.add(p.Category__c);

            // in case of update, category or unique id is changed or it is being inserted
            // clear product style/ parent product style
            if((!isUpdate) || (isUpdate && (p.Style_Number_Unique_ID__c != oldRecords.get(p.Id).Style_Number_Unique_ID__c || 
                            p.Category__c != oldRecords.get(p.Id).Category__c ))) {
                p.Product_Style__c = null;
                p.Parent_Product_Style__c = null;
            }
        }

        // exit if unique id was not filled on any record
        if(uniqueStyles.isEmpty()) return;

        // map to hold product style
        Map<String, ProductStyle> nameToProductSyleMap = new Map<String, ProductStyle>();

        // get product style style records for the unique ids of records in trigger context
        for(Product_Style__c ps : [select Id, Name, Category__c, Style_Number_Unique_ID__c,
                                        (select Id from Products__r where Product_Style__c != null limit 1) 
                                    from Product_Style__c
                                        where Style_Number_Unique_ID__c in :uniqueStyles
                                        and Category__c in :categories]) {
            
            ProductStyle psw = new ProductStyle(ps, 
                                                ps.Products__r != null && ps.Products__r.size() > 0 ? ps.Products__r[0].Id : null,
                                                ps.Products__r != null && ps.Products__r.size() > 0); 

            // add style
            nameToProductSyleMap.put(ps.Style_Number_Unique_ID__c + ps.Category__c, psw);
        }


        // list used to insert new product styles
        List<Product_Style__c> psToInsert = new List<Product_Style__c>();

        // iterate over records in trigger context
        for(Product2 p : newRecords) {

            // if unique id is empty, move to next record
            if(p.Style_Number_Unique_ID__c == null) continue;

            // if category is empty, move to next record
            if(p.Category__c == null) continue;

            // if product style already exists, move to next product
            if(nameToProductSyleMap.keySet().contains(p.Style_Number_Unique_ID__c + p.Category__c)) continue;

            // initialize product style for insert
            Product_Style__c ps = new Product_Style__c(Style_Number_Unique_ID__c = p.Style_Number_Unique_ID__c, 
                                                       Category__c = p.Category__c);
            nameToProductSyleMap.put(p.Style_Number_Unique_ID__c + p.Category__c, new ProductStyle(ps, null, false));
            psToInsert.add(ps);
            
        }

        // insert product styles, if any
        if(!psToInsert.isEmpty()) insert psToInsert;

        // iterate over records in trigger context
        for(Product2 p : newRecords) {

            // if unique id is empty, move to next record
            if(p.Style_Number_Unique_ID__c == null) continue;

            // if category is empty, move to next record
            if(p.Category__c == null) continue;

            // get product style
            ProductStyle psw = nameToProductSyleMap.get(p.Style_Number_Unique_ID__c + p.Category__c);

            // otherwise set as Product Stle for this product
            if(p.IsActive) { 
                if(!psw.hasProduct) { 
                    p.Product_Style__c = psw.productStyle.Id;
                    p.Parent_Product_Style__c = null;
                    psw.hasProduct = true;
                } else {
                    if(p.Id != psw.activeProductId) {
                        p.Product_Style__c = null;
                        p.Parent_Product_Style__c = psw.productStyle.Id;
                    }
                }
            } else {
                p.Product_Style__c = null;
                p.Parent_Product_Style__c = psw.productStyle.Id;
            }

        }
    }

    // wrapper class for product style insert/set logic
    public class ProductStyle {
        public Product_Style__c productStyle;
        public Boolean hasProduct;
        public Id activeProductId;

        public ProductStyle(Product_Style__c ps, Id prodId, Boolean hp) {
            productStyle = ps;
            hasProduct = hp;
            activeProductId = prodId;
        }
    }
}