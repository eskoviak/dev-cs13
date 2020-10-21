/********************************************************************************
*   PURPOSE : Controller for printable pages.
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*               M360                    Initial version
*   03/08/18    Brandon Willard(M360)   Modified for RWCP-3449
*   03/06/19    Erik Reitter(RWS)       Modified for TFS 58702 + 58587
********************************************************************************/
public without sharing class RWS_Print_ProgramPricelistCont 
{    
    Id programId ;
    public Program__c program {get; set; } 
    public String proposalNotes{get; set; }
    public Contact currentUserContact {get; set; }
    public Contact primaryContact{get; set; }
    public User programOwnerUser{get; set;}
    public Map<Integer,List<PriceListWrap>> entriesMap {get; set; }
    public List<PriceListWrap> entries{ get; set; }
    public Set<Integer> repeatValues{get; set; }
    public String expirationDate {get; set;}
    public String activationDate {get; set;}
    public String legalName {get; set;}
    public Date dActive {get; set;}
    public Date dExpire {get; set;}
    public DateTime dtActive {get; set;}
    public DateTime dtExpire {get; set;}
    public String subsidyAmt { get; set;}
    public Boolean subsidyNull { get; set;}
    public Boolean subsidyOpen { get; set;}
    public Boolean subsidyPercent { get; set;}
    public Boolean subsidyDollar { get; set;}
    public String eligibility {get; set;}
    public Boolean isDealer {get; set;}
    public Boolean isCorporate {get; set;}
    public Boolean isFullAccessUser {get; set;}
    public String payrollDeduction {get; set;}
    public String accessoriesAllowedPayroll {get; set;}
    public String accessoriesAllowedSubsidy {get; set;}
    public String netTerms {get; set;}
    public String billingFreq {get; set;}
    public String invoiceDelivery {get; set;}
    public String invoiceAttributes {get; set;}
    public String progName {get; set;}
    public String progType {get; set;}
    private Id userId;
    private User currentUser;

    
    // Constructor
    public RWS_Print_ProgramPricelistCont() 
    {
        entriesMap = new Map<Integer,List<PriceListWrap>>();
        entries = new List<PriceListWrap>();
        program = new Program__c();
        currentUserContact = new Contact();
        primaryContact = new Contact();
		programOwnerUser = new User();
        
        repeatValues = new Set<Integer>{1, 2};
        // Get ProgramId from URL
        programId = ApexPages.currentPage().getParameters().get('ProgramId');
        System.debug('UAC: programId ' + programId );

        proposalNotes = ApexPages.currentPage().getParameters().get('pn');
        System.debug('UAC: proposalNotes ' + proposalNotes );
    }

    public void getProgramDetails()
    {
        if(String.isBlank(programId)) return ; 

        Set<Id> priceBookIds = new Set<Id>();        
        Map<Id, Double> msrpUnitPriceMap = new Map<Id, Double>();
        Map<Id, Product2> prodMap = new Map<Id, Product2>();

        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();
        
        program = [ SELECT  Id, Proposal_Notes__c, Activation_Date__c, Expiration_Date__c, Max_Amount__c, Mandatory__c, Accessories_Allowed_on_Payroll_Deduction__c, 
                            Subsidy_Amount__c, Subsidy_Percent__c, Subsidy_Type__c, Accessories_Allowed_on_Subsidy__c, Eligibility_Option__c, Name, Account_Name__c, Purchase_Program_Notes__c,
                            Online_Pricelist_URL__c, toLabel(Type__c), Owning_Store_Type__c,
                            
                            Account__c, toLabel(Account__r.BPC_Payment_Terms__c), Account__r.Billing_Frequency__c, toLabel(Account__r.Invoice_Delivery_Method__c), toLabel(Account__r.Invoice_Atributes_Required__c),
                            Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode, Account__r.Legal_Name__c,
                            
                            Owner.FirstName, Owner.LastName, OwnerId 
                    FROM Program__c WHERE Id = :programId ];
        userId = UserInfo.getUserId();
        legalName = program.Account__r.Legal_Name__c;
         
        if (program.Owning_Store_Type__c == 'Dealer'){
            isDealer = true;
            isCorporate = false;
        } else {
            isDealer = false;
            isCorporate = true;
        }
        
        system.debug('Store Type Booleans:' + isDealer + isCorporate);
        
        try {
            programOwnerUser = [SELECT FirstName, LastName, Phone, Email, CompanyName FROM User WHERE ID = :program.OwnerId];
        } catch(Exception ex) {
            programOwnerUser = new User();
        }
        
        if (program.Expiration_Date__c != null) {
            Date dExpire = program.Expiration_Date__c;        
            Datetime dtExpire = datetime.newInstance(dExpire.year(), dExpire.month(), dExpire.day());
            expirationDate = dtExpire.format(' MMMM d,  yyyy');
        } else {
            expirationDate = ' TBD';
        }
        
        if (program.Eligibility_Option__c != null){
            if (program.Eligibility_Option__c == 'True'){
                eligibility = 'Yes';
            } else {
                eligibility = 'No';
            }
        } else {
            eligibility = 'N/A';
        }
        
        if (program.Mandatory__c == null){
            payrollDeduction = 'N/A';
        } else {
            payrollDeduction = program.Mandatory__c;
        }
        
        if (program.Accessories_Allowed_on_Payroll_Deduction__c == null){
            accessoriesAllowedPayroll = 'N/A';
        } else {
            accessoriesAllowedPayroll = program.Accessories_Allowed_on_Payroll_Deduction__c;
        }
        
        if (program.Name == null) {
            progName = 'N/A';
        } else {
            progName = program.Name;
        }
        
        if (program.Type__c == null) {
            progType = 'N/A';
        } else {
            progType = program.Type__c;
        }
              
        if (program.Accessories_Allowed_on_Subsidy__c == null){
            accessoriesAllowedSubsidy = 'N/A';
        } else {
            accessoriesAllowedSubsidy = program.Accessories_Allowed_on_Subsidy__c;
        }
        
        if (program.Account__r.BPC_Payment_Terms__c == null){
            netTerms = 'N/A';
        } else {
            netTerms = program.Account__r.BPC_Payment_Terms__c;
        }
        
        if (program.Account__r.Billing_Frequency__c == null){
            billingFreq = 'N/A';
        } else {
            billingFreq = program.Account__r.Billing_Frequency__c;
        }
        
        if (program.Account__r.Invoice_Delivery_Method__c == null){
            invoiceDelivery = 'N/A';
        } else {
            invoiceDelivery = program.Account__r.Invoice_Delivery_Method__c;
        }
        
        if (program.Account__r.Invoice_Atributes_Required__c == null){
            invoiceAttributes = 'N/A';
        } else {
            invoiceAttributes = program.Account__r.Invoice_Atributes_Required__c;
        }
        
        
        if (program.Activation_Date__c != null) {
            Date dActive = program.Activation_Date__c;        
            Datetime dtActive = datetime.newInstance(dActive.year(), dActive.month(), dActive.day());
            activationDate = dtActive.format(' MMMM d,  yyyy');
        } else {
            activationDate = ' TBD';
        }
        
        if (program.Subsidy_Type__c == 'dollar') {
            subsidyAmt = '$' + program.Subsidy_Amount__c;            
        } else if (program.Subsidy_Type__c == 'percentage') {
            subsidyAmt = program.Subsidy_Percent__c + '% up to $' + program.Max_Amount__c ;             
        } else if (program.Subsidy_Type__c == 'open') {
            subsidyAmt = '$' + program.Max_Amount__c;            
        } else {
            subsidyAmt = 'N/A';            
        }
        
                
        // Get PriceBooks related to Program
        for( Publish_PriceBook__c ppb : [SELECT Id FROM Publish_PriceBook__c WHERE Program__c =: programId ])
        {
            priceBookIds.add(ppb.Id);
        }
        if(Test.isRunningTest()) priceBookIds.add(Test.getStandardPricebookId());

        Integer i = 1 ;
        

        // Get related PriceBookEntries
        List<Publish_PriceBook_Entry__c> priceBookEntries =  [  SELECT Id, Name, Product_ID__c, Style_Number__c, List_Price__c
                                                    FROM Publish_PriceBook_Entry__c
                                                    WHERE Publish_PriceBook__c IN :priceBookIds 
                                                    AND Active__c = true          
                                                    ]; /* AND Product2.Product_Style__c != null */

        Set<Id> prodIds = new Set<Id>();
        
        
        // Get ProductIds from PriceBookEntries
        for(Publish_PriceBook_Entry__c ppbe : priceBookEntries ) {
            // Put intial value for each product 
            msrpUnitPriceMap.put(ppbe.Product_ID__c, 0);
            // put product Id into set
            prodIds.add(ppbe.Product_ID__c);            
        }
        
        
        // Get products related to PricebookEntries and add to product map
        for(Product2 prod : [SELECT Id, Category__c, Brand_Code__c, IsDiscontinued__c FROM Product2 WHERE Id IN :prodIds /*AND Product_Style__c != null*/]){
            prodMap.put(prod.Id, prod);
        }
        
                
       // Get Unit Price 
        for(PricebookEntry pbe : [  SELECT Product2Id, UnitPrice FROM PricebookEntry 
                                    WHERE Pricebook2.IsStandard = true AND Pricebook2.IsActive = true AND Product2Id IN :msrpUnitPriceMap.keySet()]){
            msrpUnitPriceMap.put(pbe.Product2Id, pbe.UnitPrice);            
        }      
        
        
        // Iterate over PriceBookEntries and populate wrapper list
        for(Publish_PriceBook_Entry__c ppbe : priceBookEntries ) 
        {
            // Create a wrapper class instance
            PriceListWrap plw = new PriceListWrap();

            // Put priceBookEntry, Product, Unit price, and Style
            plw.prodPriceObj = ppbe;
            plw.prodObj = prodMap.get(ppbe.Product_ID__c);
            plw.style = ppbe.Style_Number__c;
            plw.listPrice = plw.prodPriceObj.List_Price__c;
            
            // Add into list 
            entries.add(plw);
        }

        entries.sort();

        List<Contact> contacts = [  SELECT Id, Name, BPR_Role__c, MailingStreet, MailingCity, MailingCountry, MailingPostalCode, MailingState
                                    FROM Contact WHERE AccountId = :program.Account__c 
                                    AND (Contact_Identifier__c = 'Primary & Billing' OR Contact_Identifier__c = 'Primary')];
        
        if(contacts != null && contacts.size() > 0 ) primaryContact = contacts[0];

    }

    public class PriceListWrap implements Comparable {
        public Publish_PriceBook_Entry__c prodPriceObj {get;set;}
        public Product2 prodObj {get;set;}
        public string style {get; set;}
        public double listPrice {get;set;}
        
        public Integer compareTo(Object compareTo) {
            
            PriceListWrap price = (PriceListWrap) compareTo;
            
            if (style == price.style) return 0;
            if (style < price.style) return -1;
            return 1;        
        }
    }
}