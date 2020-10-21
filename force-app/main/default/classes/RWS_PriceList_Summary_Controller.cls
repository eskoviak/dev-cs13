/********************************************************************************
*   PURPOSE : Show PriceBook Entries relate to a Program.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/17/2016  Usman Aslam/M360        Initial version
*	03/08/2018  Brandon Willard/M360    Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_PriceList_Summary_Controller {

    

    // Instance variables
    private transient Id pricebookId;
    public transient List<Publish_PriceBook_Entry__c> entries {get; private set;}  
    
    public transient Map<Id, Double> msrpUnitPriceMap {get; private set;}
    public Id programId {get; set;}
    public Id accountId {get; private set;}
    public transient List<PriceListWrap> ProductPriceList;
    public Boolean firstLoad {get; set;}
    public Boolean isProgramActive {get; set;}
    public List<FilterCriteria> criterias {get; set;}
    private Boolean isTemplate;
    public String processingStatus {get; set;}
    public String fcsWithProducts {get; set;}

    public Boolean showTable {get; set;}

    public String loadEntriesJSON {
        get {
            if(firstLoad) entriesJSON = null;
            if(entriesJSON == null) {
                loadEntriesJSON = '';
                firstLoad = false;
                
                initialize();
            }
            return loadEntriesJSON;
        } 
        private set;
    }
    
    public transient String entriesJSON { get; private set;}

    public Program__c program {get; set;}
    public String ProgramEffectiveDate {
        get {
            return program != null && program.Activation_Date__c != null ? program.Activation_Date__c.format() : '';
        }
    }
    public String ExpirationDate { 
        get {
            return program != null && program.Expiration_Date__c != null ? program.Expiration_Date__c.format() : '';
        }
    }

    private List<Filter_Criteria__c> fcs;

    // Constructor
    public RWS_PriceList_Summary_Controller() {
        isProgramActive = false;
        fcsWithProducts = '';
        searchTerm = '';
        searchResult = '';
        showResult = false;
        firstLoad = true;
        pricebookId = ApexPages.currentPage().getParameters().get('id');
        System.debug('******************pricebookID in constructor: '+pricebookId);
        System.debug('******************programID in constructor: '+programId);
		System.debug('******************program in constructor: '+program);

        if(pricebookId == null) return;
        
        List<Publish_PriceBook__c> ppb = [select Id, IsActive__c, Program__c,
                                    Program__r.Account__c,
                                    Program__r.Active__c
                                from Publish_PriceBook__c
                                where Id = :pricebookId limit 1];
         

        if(ppb.isEmpty()) return;

        if(ppb[0].Program__c == null)                    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Invalid Program.'));

        /*if(ppb[0].IsStandard)                    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Standard Pricebook.'));
		*/

        if(ApexPages.hasMessages()) 
            return;
		getProgram();
        init(ppb);
    }

    private void initialize() {
                System.debug('******************programID in intialize(): '+programId);

        List<Publish_PriceBook__c> ppb = [select Id, IsActive__c, Program__c,
                                Program__r.Account__c,
                                Program__r.Active__c
                                from Publish_PriceBook__c 
                                where  Program__c != null 
                                and Program__c = :programId                                 
                            limit 1];
        getProgram();
        init(ppb);
    }

    public Boolean hasFilters {get; private set;}
    public List<List<Filter_Criteria__c>> features {get; set;}

    public String selectedFilter {get; set;}

    private void init(List<Publish_PriceBook__c> ppb) {
        isProgramActive = false;
        fcsWithProducts = '';
        showTable = false;
        entriesJSON = '';
        selectedFilter = '';
        criterias = new List<FilterCriteria>();
        fcs = new List<Filter_Criteria__c>();
        


        Map<Integer, FilterCriteria> criteriasMap = new Map<Integer, FilterCriteria>();

        features = new List<List<Filter_Criteria__c>>();
        ProductPriceList = new List<PriceListWrap>();
        msrpUnitPriceMap = new Map<Id, Double>();


        if(ppb.isEmpty()) return;

        // get ids, used for redirect buttons on the page
        programId = ppb[0].Program__c;
        accountId = ppb[0].Program__r.Account__c;

        
        //possibly move query here
        System.debug('******************programId in init: '+programId);

        Integer oldNumber = 0;
        fcs = [select Results_Count__c,
                    Filter_Number__c,
                    Discount__c,
                    Filter_Display__c,
                    Product_Code__c
                from Filter_Criteria__c
                where Program__c = :programId
                and IA_Feature__c = null
                and Filter_Number__c != null
                Order by Filter_Number__c desc];

        isProgramActive = ppb[0].Program__r.Active__c;

        //disableButton = pb[0].Program__r.Active__c;

        for(Filter_Criteria__c fc : fcs) {

            if( String.isBlank(fc.Product_Code__c) )  {
                if(fcsWithProducts != '') fcsWithProducts += ',';
                fcsWithProducts += String.valueOf(fc.Filter_Number__c.intValue());
            }

            if(String.isBlank(fc.Filter_Display__c)) continue;
        
            if(fc.Discount__c == null) fc.Discount__c = 0;

            oldNumber = fc.Filter_Number__c.intValue();

            FilterCriteria fcw = criteriasMap.get(oldNumber);

            if(fcw == null) {
                fcw = new FilterCriteria(oldNumber, fc.Discount__c);
                criteriasMap.put(oldNumber, fcw);
            }

            fcw.postText = fc.Filter_Display__c;

            if( String.isBlank(fc.Product_Code__c) ) continue;

            String codesSet = fc.Product_Code__c.split('-FPC-')[0];
            if(fc.Filter_Number__c > 0 ) {
                Set<String> productCodes = (Set<String>) JSON.deserialize(codesSet, Set<String>.class);
                fcw.productCodes.addAll(productCodes);
            } else {
                Map<String, Decimal> productCodes = (Map<String, Decimal>) JSON.deserialize(codesSet, Map<String, Decimal>.class);
                fcw.productCodes.addAll(productCodes.keySet());
            }

        }
        
        getProgram();
       	System.debug('******************program in init after getProgram(): '+program);

        if(program.Processing_Status__c == 'Completed'){
            showTable = true;
        }
      
        //if(!showTable) showTable = String.isBlank(program.Processing_Status__c) || program.Processing_Status__c == 'Completed';

        
        //commemted out by BW
        /* get related price book entries
        entries = [SELECT Id, Name, Publish_PriceBook__c, Product_ID__c, Fixed_Price__c,
                    Product2.Category__c,
                    Product2.ProductCode,
                    Product2.Name, 
                    List_Price__c, IsActive__c, 
                    Style_Number__c, Discount__c, 
                    MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                    Filter_Number__c 
                FROM Publish_PriceBook_Entry__c
                WHERE Publish_PriceBook__c = :ppb[0].Id
                AND Product2.Product_Style__c != null
                AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()
                AND (Filter_Number__c in :criteriasMap.keySet() OR Filter_Number__c = 0)]; */
        
        		
         // get related publish price book entries
        entries = [SELECT Id, Name, Publish_PriceBook__c, Product_Id__c, Fixed_Price__c,                   
                    List_Price__c, Active__c, 
                    Style_Number__c, Discount__c, 
                    MSRP_Effective_Date__c, MSRP_Expiration_Date__c,
                    Filter_Number__c 
                FROM Publish_PriceBook_Entry__c
                WHERE Publish_PriceBook__c = :ppb[0].Id
                AND Active__c = true
                AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()
                AND (Filter_Number__c in :criteriasMap.keySet() OR Filter_Number__c = 0)];
	
        
        Set<Id> productIds = new Set<Id>();
        Map<Id, Product2> prodMap = new Map<Id, Product2>();
        
        for(Publish_PriceBook_Entry__c ppbe : entries) {
        	productIds.add(ppbe.Product_Id__c);
        }
        
        Set<Id> prodIdSet = new Set<Id>();
        for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE Product_Style__c != null AND Id IN : productIds]){
            prodIdSet.add(prod.Id);
            prodMap.put(prod.Id, prod);
        }
        
        for(Integer i = 0; i < entries.size(); i++){
            if (!prodIdSet.contains(entries[i].Product_Id__c)){
            	entries.remove(i);    
            }
        }
        
        productIds.clear();
        
        Map<Id, Id> PPBEProdIdMap = new Map<Id, Id>();        
        Map<Id, Publish_PriceBook_Entry__c> ProdPPBEMap = new Map<Id, Publish_Pricebook_Entry__c>();  

        for(Publish_PriceBook_Entry__c ppbe : entries) {
            System.debug(ppbe.Id);
            System.debug(ppbe.Product_ID__c);
            PPBEProdIdMap.put(ppbe.Id, ppbe.Product_Id__c);
            ProdPPBEMap.put(ppbe.Product_Id__c, ppbe);
            
            if(ppbe.Filter_Number__c == null) ppbe.Filter_Number__c = 0;

            oldNumber = ppbe.Filter_Number__c.intValue();

            FilterCriteria fcw = criteriasMap.get(oldNumber);

            if(fcw == null) {
                fcw = new FilterCriteria(oldNumber, 0);
                criteriasMap.put(oldNumber, fcw);
            }

            //fcw.productCodes.add(pbe.Product2.ProductCode);

            if(fcw.productCodes.isEmpty()) fcw.recordsCount ++;

            productIds.add(ppbe.Product_Id__c);
            
        }
        
 	    criterias = criteriasMap.values();

        criterias.sort();

        hasFilters = criterias.size() > 0;

        for(FilterCriteria fc : criterias) {
            if(!fc.productCodes.isEmpty()) fc.recordsCount = fc.productCodes.size();

            if(fc.filterNumber == 0) {
                fc.preText = 'CUSTOM LIST';
            } else {
                fc.preText = 'PRICE RULE ' + fc.filterNumber;

                fc.postText += (fc.discount > 0 ? ' WITH (' + fc.discount + '% DISCOUNT)' : '') ;
            }
        }

        if(!showTable) return;

        // get MSRP from standard pricebook
        for(PricebookEntry pbe : [SELECT Product2Id, 
                    UnitPrice 
                FROM PricebookEntry
                WHERE Pricebook2.IsStandard = true
                AND Pricebook2.IsActive = true
                AND Product2Id in :productIds
                AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()]) {

            msrpUnitPriceMap.put(pbe.Product2Id, pbe.UnitPrice);
        }

        // set 0 from missing products
        for(Id pId : productIds) {
            if(msrpUnitPriceMap.get(pId) == null) msrpUnitPriceMap.put(pId, 0);
        }
        
       
        // Populate wrappers class object so it can be used for JSON
        for(Publish_PriceBook_Entry__c ppbe : entries) {
            PriceListWrap obj = new PriceListWrap();
             obj.ProdPriceObj = ppbe;
             obj.prodObj = prodMap.get(ppbe.Product_ID__c);
             obj.MSRP = msrpUnitPriceMap.get(ppbe.Product_Id__c);
             
             ProductPriceList.add(obj);
        }

        // generate JSON
        jsonFormatter();
    }
    
    private void getProgram() {
        program = new Program__c();

        if(programId != null){
            program = [SELECT Id, Name, Account__c, Account__r.Name, Owner.Name,
              Accessories_Allowed_on_Subsidy__c,
              Accessories_Allowed_on_Payroll_Deduction__c, 
              Activation_Date__c,
              Active__c,
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
              Processing_Status__c
            FROM Program__c where Id = :programId];
        } else {
            program.Auto_Add_Products__c = true;
            program.Auto_Update_Price__c = true;
        }
       
        
        isTemplate = program.Template__c;

    } 

    // code related to deletion of Pricebook Entry
    public String entryId {get; set;}
    public void removeEntry() {
        try {
            delete new Publish_PriceBook_Entry__c(Id = entryId);
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
        }
        
    }

    public String searchTerm {set; get;}
    public String searchResult {set; get;}
    public Boolean showResult {set; get;}

    public void searchProduct() {
        if(String.isBlank(searchTerm) ) return;

        showResult = true;

        Decimal maxDiscount = 0;
        Decimal filter = 0;
        Boolean productFound = false;



        for(Filter_Criteria__c fc : fcs) {
            Decimal discount = 0;

            if( String.isBlank(fc.Product_Code__c) ) continue;

            String codesSet = fc.Product_Code__c.split('-FPC-')[0];

            if(fc.Filter_Number__c > 0 ) {
                Set<String> productCodes = (Set<String>) JSON.deserialize(codesSet, Set<String>.class);

                if(!productCodes.contains(searchTerm)) continue;

                productFound = true;

                discount = fc.Discount__c;

                if(discount > maxDiscount) {
                    maxDiscount = discount;
                    filter = fc.Filter_Number__c;
                }

            } else {
                Map<String, Decimal> productCodes = (Map<String, Decimal>) JSON.deserialize(codesSet, Map<String, Decimal>.class);

                discount = productCodes.get(searchTerm);

                if(discount == null) continue;

                productFound = true;

                if(discount > maxDiscount) {
                    maxDiscount = discount;
                    filter = fc.Filter_Number__c;
                    //showResult = searchTerm ' found in CUSTOM LIST' + (discount > 0 ? 'WITH ' )  (WITH Discount ' + discount + '%'
                }
            }
        }

        if(!productFound) {
            List<Publish_PriceBook__c> ppbs = [SELECT Id
                                FROM Publish_PriceBook__c where Program__c = :programId];


            List<Publish_PriceBook_Entry__c> ppbes = [select Id, Discount__c, Filter_Number__c 
                                            from Publish_PriceBook_Entry__c
                                        where Publish_PriceBook__c in :ppbs
                                        and Style_Number__c = :searchTerm limit 1];



            if(!ppbes.isEmpty()) {
                productFound = true;
                filter = ppbes[0].Filter_Number__c == null ? 0 : ppbes[0].Filter_Number__c;
                maxDiscount = ppbes[0].Discount__c == null ? 0 : ppbes[0].Discount__c;
            }
        }

        if(productFound) {
            

            if(filter > 0) {
                searchResult = searchTerm + ' found in PRICE RULE ' + filter.intValue(); // + (discount > 0 ? 'WITH (' + discount + '% DISCOUNT)' : '');
            } else {
                searchResult = searchTerm + ' found in CUSTOM LIST ' + (maxDiscount > 0 ? 'WITH (' + maxDiscount.intValue() + '% DISCOUNT)' : '');
            }
        } else {
            searchResult = searchTerm + ' not found';
        }
    }
    
    
    
    
    public void updateProgram() {       
        System.debug('******************programId: '+programId);
		
        if (program == null){
            //getProgram();
            //program = [SELECT Id, Name, Template__c, Auto_Update_Price__c, Auto_Add_Products__c FROM Program__c WHERE Id =: programId];
        }
        
   		System.debug('******************program: '+program);

        
        Program__c existingProgram = new Program__c(Id = programId, Auto_Update_Price__c =  program.Auto_Update_Price__c, 
                    Auto_Add_Products__c = program.Auto_Add_Products__c,
                    Processing_Status__c = 'Scheduled'
        );   

        update existingProgram;

        Boolean createTemplate = program.Template__c && !isTemplate;
		
        insert new Program_Scheduler__c(Program__c = programId, 
            Program_Template_Name__c = createTemplate ? program.Name : null, 
            Processed__c = false);

    }

    public void removeAll() {
        Integer filterNumber = Integer.valueOf(selectedFilter);
		
        List<Publish_PriceBook_Entry__c> ppbes = [SELECT Id, Publish_Pricebook__c, Active__c, Expiration_Date__c 
                                                  FROM Publish_PriceBook_Entry__c 
                                                  WHERE Publish_PriceBook__r.Program__c = :programId
                								 and Filter_Number__c = :filterNumber];
        /*commented out by BW
        Id ppbId = [select Id, Program__c
                    from Publish_PriceBook__c 
                    where Program__c = :programId].Id;
        
        List<PricebookEntry> priceBookEntries = [select Id FROM PricebookEntry where Pricebook2.Program__c = :programId
                and Filter_Number__c = :filterNumber];
        
        Integer attempts = 5;
        while(attempts > 0){
            try {
                attempts --; 
                delete ppbes; 
                attempts = 0;
            } catch (System.DmlException dmlEx) {                
                if (!dmlEx.getMessage().contains('UNABLE_TO_LOCK_ROW')) {  attempts = 0;  }

                if(attempts == 0) { throw dmlEx; }
            } catch (System.Exception ex) {
             	System.debug(ex);   
            }
                // end of catch
        } // end of while retry loop
 		*/
		
        RWS_PriceBookEntry_Util.deactivatePublicPriceBookEntries(ppbes);
                
        delete [select Id FROM Filter_Criteria__c where Program__c = :programId
                and Filter_Number__c = :filterNumber];
        
        List<Publish_PriceBook__c> ppb = [select Id, IsActive__c, Program__c,
                        Program__r.Account__c, Program__r.Active__c
                        from Publish_PriceBook__c where Program__c = :programId  
                    limit 1];

        //System.debug(programId);
        //System.debug(pb);
        init(ppb);
    }

    // code related to update of Pricebook Entries
    public String updateJson {get; set;}
    public void updateEntries() {
        List<Publish_PriceBook_Entry__c> entriesToUpdate 
            = (List<Publish_PriceBook_Entry__c>) JSON.deserialize(updateJson, List<Publish_PriceBook_Entry__c>.class);

        try {
            update entriesToUpdate;    
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
        }
        
    }
    
    // wrapper class used for JSON
    public class PriceListWrap{
        public Publish_PriceBook_Entry__c ProdPriceObj {get;set;}
        public Product2 prodObj {get;set;}
        public double MSRP {get;set;}
    }
    
    // utility method to generate JSON of the list
    public String jsonFormatter(){
        entriesJSON = JSON.serialize(ProductPriceList);
        entriesJSON = String.escapeSingleQuotes(entriesJSON);
        return entriesJSON; 
    }

    public class FilterCriteria implements Comparable {
        public String preText {get; set;}
        public Integer filterNumber {get; set;}
        public String postText {get; set;}
        public Integer recordsCount {get; set;}
        public Decimal discount {get; set;}
        public Set<String> productCodes {get; set;}

        public FilterCriteria(Integer fn, Decimal d) {
            preText = postText = '';
            filterNumber = fn;
            recordsCount = 0;
            discount = d;
            productCodes = new Set<String>();
        }
        public Integer compareTo(Object compareTo) {
            FilterCriteria feature = (FilterCriteria) compareTo;
            if (filterNumber == feature.filterNumber) return 0;
            if (filterNumber < feature.filterNumber) return 1;
            return -1;        
        }
        
        

    }
}