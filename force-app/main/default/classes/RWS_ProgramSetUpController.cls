/********************************************************************************
*   PURPOSE : Controller for program creation
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*               M360                    Initial version*
*   03/08/18    Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_ProgramSetUpController{

       
    public String filter { get; set; }

    public String discountAll { get; set; }
    
    //Account object
    public Account AccObj {get;set;}
    public String AccountName {get;set;}
    public String programId {get;set;}
    public Boolean EditMode {get;set;}
    public Program__c program { get; set; }
    public Program__c editProgram { get; set; }
    public String accName {get;set;}
    public String proOwner {get;set;}
    public String redirectToAccount {get;set;}
    
    //PROGRAM DETAILS Properties 
    public String programName {get;set;}
    public String programOwner    {get;set;}
    public Date activationDate {get;set;}
    public String displayactivationDate {get;set;}
    public Date expirationDate {get;set;}
    public String displayexpirationDate {get;set;}
    public String programNotes {get;set;}
    public String selectType {get;set;}
    public String selectTypeB {get;set;}
    public String displaySelectType {get; set;}
    public List<SelectOption> Type {get;set;}
    public String ProgramStatus {get;set;}
    public Boolean ProgramActive {get;set;}
    public Boolean AutoUpdatePrice {get;set;}
    public Boolean AutoAddProducts {get;set;}
    public List<selectOption> pCardOptions { get; set;}
    public String selectedPCardOption { get; set;}
    public String displaySelectedPCardOption { get; set;}
    public String recordType {get; set;}
    public Boolean isTemplate {get; set;}
    public List<selectOption> salesContractOptions { get; set; }
    public String selectedSalesContract { get; set; }
    public List<Sales_Contract_References__c> contractReasonList {get;set;}
    public List<SelectOption> contractReasonOptions {get; set;}
    public String selectedContractReason {get; set;}
    public String displaySelectedContractReason {get; set;}
    public String contractReasonLabel {get; set;}    
    public List<SelectOption> serviceLevel { get; set; }
    public String selectedServiceLevel { get; set; }
    public String proposalNotes{get; set; }
    public Boolean isScheduled { get; set; }
    public String processingStatus { get; set; }
    public String invoiceAttributes {get; set;}
    
    //SUBSIDY - BASED ON TYPE Properties
    public String selectsubsidyType {get;set;}
    public List<SelectOption> subsidyType {get;set;}
    public String selectsubsidyFrequency {get;set;}
    public List<SelectOption> subsidyFrequency {get;set;}
    public Double subsidyAmountDbl    {get;set;}
    public Double subsidyAmount    {get;set;}
    public String selectaccessallowsubsidy {get;set;}
    public String selectAccessories {get; set;}
    public List<SelectOption> accessallowsubsidy {get;set;}
    public Double subsidyPercentDbl    {get;set;}
    public Double subsidyPercent    {get;set;}
    public Double maxAmountDbl    {get;set;}
    public Double maxAmount    {get;set;}
    public Integer numberPairsAllow    {get;set;}
    
    //ELIGIBILITY - BASED ON SUBSIDY Properties
    public String selecteligibilityOption {get;set;}
    public List<SelectOption> eligibilityOption {get;set;}
    public String selectRollingBalance {get;set;} 
    public List<SelectOption> RollingBalance {get;set;}
    public String selectVoucherDistribution {get;set;}
    public List<SelectOption> VoucherDistribution {get;set;}
    public String selectAnnualResetorRollover {get;set;}
    public List<SelectOption> AnnualResetorRollover {get;set;}
    public String selectRequireUpload {get;set;}
    public List<SelectOption> requireUpload {get;set;}
    public String selectSubsidyTax {get;set;}
    public List<SelectOption> SubsidyTax {get;set;} 
    
    //PAYROLL DEDUCTION - BASED ON TYPE Properties
    public String selectMandatory {get;set;} 
    public List<SelectOption> Mandatory {get;set;}
    public String selectAccessAllowPayrollDeduction {get;set;}
    public List<SelectOption> accessAllowPayrollDeduction {get;set;} 
    
    //PRICE LIST Fields  
    public String selectautoaddProduct {get;set;} 
    public List<SelectOption> autoaddProduct {get;set;}
    public String selectFixed {get;set;}
    public List<SelectOption> FixedOption {get;set;} 
    
    //Additional field for ProgramSummary  - RWCP-1121 - Akhil
    public string standardPriceBookId {get;set;}
    public string PriceListName {get;set;}
    public string PriceListId {get;set;}
    public string PriceBookActive {get;set;}
    
    //Edit Button
    public string EditSummery {get;set;}
    public Boolean show    {get;set;}
    public String ProgramSaved {get;set;}
    
    public string task {get;set;}
    public String errorMsg {get;set;}
    public string ProgramActivationStatus {get;set;}
    public String accountId;
    private Boolean isWizard = false;
    public String accRequiresInvoicing {get; set;}
    
    public Boolean hasEditAccess {get; private set;}
    public Boolean hasBeenActive {get; set;}
    public Boolean isFullAccessUser {get; set;}
    public RWS_ProgramSetUpController(){
       isFullAccessUser = RWS_UtilityClass.isFullAccessUser();
       hasEditAccess = true;
       selectTypeB = '';
       system.debug('RWS_ProgramSetUpController Begin ************');
       
       AccObj = new Account();
       program = new Program__c();
       EditMode = false;
       hasBeenActive = false;
       programId = Apexpages.currentpage().getparameters().get('proid'); 
       task = Apexpages.currentpage().getparameters().get('task'); 
       activationDate = Date.today();
       numberPairsAllow = 1;
       expirationDate = null;

       String pageURL = Test.isRunningTest() ? 'RWS_NewProgramSetup' : ApexPages.currentPage().getUrl();
       
       getAllPickListValues(); // Set all picklist valies whcih are in page.
       selectSubsidyTax = 'SubsidyTaxed';
       
      
       
       
       if(null != programId){
           EditMode = true;
           EditSummery = 'RWS_NewProgramSetup?tab=program&proid='+programId;
           program = new Program__c();
           editProgram = [  SELECT  Id,Name, Account__c, Account__r.Requires_Invoicing__c, 
                                    Account__r.Name, Owner.Name, Active__c, Activation_Date__c, 
                                    Expiration_Date__c, Purchase_Program_Notes__c, Alternative_Payment__c,
                                    toLabel(Type__c),toLabel(Subsidy_Type__c),Subsidy_Frequency__c,Subsidy_Amount__c,
                                    Accessories_Allowed_on_Subsidy__c,Subsidy_Percent__c,Max_Amount__c,
                                    Number_of_Pairs_Allowed__c,toLabel(Eligibility_Option__c),Rolling_Balance__c,
                                    Voucher_Distribution__c,Annual_Reset_or_Rollover__c, Require_Upload_of_Company_Voucher__c,
                                    Mandatory__c,Accessories_Allowed_on_Payroll_Deduction__c,
                                    Auto_Add_Products__c,Auto_Update_Price__c,toLabel(Subsidy_Tax__c),Fixed__c,Invoice_Attributes_Required__c,
                                    toLabel(Servicing_Level__c), Processing_Status__c, Proposal_Notes__c, HasBeenActive__c, RecordType.Name, Sales_Contract__c, Sales_Contract_Reference__c

                            FROM Program__c
                            WHERE Id =:programId];
                                    //Auto_Add_Products__c,
            hasEditAccess = RWS_UtilityClass.getUserRecordEditAccess(editProgram.Id);      
                              
            if(null != editProgram){
                
               accRequiresInvoicing = editProgram.Account__r.Requires_Invoicing__c;
               accName = editProgram.Account__r.Name;
               AccountName = editProgram.Account__r.Name;
               proOwner = editProgram.Owner.Name;
                programName = editProgram.Name;
                recordType = editProgram.RecordType.Name;
                if (editProgram.RecordType.Name == 'program'){
                    isTemplate = false;
                } else {
                    isTemplate = true;
                }    
                //= editProgram.Account__c;
                activationDate = editProgram.Activation_Date__c;
                if(editProgram.Processing_Status__c != null) {
                    processingStatus = editProgram.Processing_Status__c;
                    if (processingStatus == 'Scheduled'){
                        isScheduled = true;
                    } else {
                        isScheduled = false;
                    }  
                }  
                if(editProgram.Activation_Date__c != null)
                    displayactivationDate = editProgram.Activation_Date__c.format();
                expirationDate = editProgram.Expiration_Date__c;
                if(editProgram.Expiration_Date__c != null)
                    displayexpirationDate = editProgram.Expiration_Date__c.format();                    
                System.debug('=-=-=-=-=-=-=-= Program Activation Date: ' + activationDate);
                System.debug('=-=-=-=-=-=-=-= Program Expiration Date: ' + expirationDate);                
                
                invoiceAttributes = editProgram.Invoice_Attributes_Required__c;
                programNotes = editProgram.Purchase_Program_Notes__c;
                
                hasBeenActive = editProgram.HasBeenActive__c;
                
                selectType = editProgram.Type__c;
                system.debug('Look for this: ' +selectType);
                if (selectType == 'Cash and Carry'){
                    displaySelectType ='Cash and Carry';
                } else if (selectType == 'Payroll Deduction'){
                    displaySelectType ='Payroll Deduction';
                } else if (selectType == 'Subsidy'){
                    displaySelectType ='Subsidy';
                } else if (selectType == 'Subsidy and Payroll Deduction'){
                    displaySelectType ='Subsidy and Payroll Deduction';
                } else if (selectType == 'Subsidy with Pcard'){
                    displaySelectType ='Subsidy with Pcard';
                }
                selecteligibilityOption = editProgram.Eligibility_Option__c;

                selectSubsidyTax = editProgram.Subsidy_Tax__c;

                selectedServiceLevel = editProgram.Servicing_Level__c;
                
                selectedPCardOption = editProgram.Alternative_Payment__c;
                if (selectedPCardOption == 'True'){
                    displaySelectedPCardOption = 'Allowed';
                } else {
                    displaySelectedPCardOption = 'Not Allowed';
                }
                selectedSalesContract = editProgram.Sales_Contract__c;
                if (selectedSalesContract == 'TXMAS'){
                    selectedContractReason = editProgram.Sales_Contract_Reference__c;
                    Sales_Contract_References__c contractRef = [SELECT Id, Name, Sales_Contract_Name__c FROM Sales_Contract_References__c WHERE Id =: selectedContractReason LIMIT 1];
                    displaySelectedContractReason = contractRef.Name + ' ' + contractRef.Sales_Contract_Name__c;                    
                }
                
                selectsubsidyType = editProgram.Subsidy_Type__c;

                if(pageURL.containsIgnoreCase('RWS_NewProgramSetup')) {
                    
                    getContractReason();
                    
                    for(SelectOption so : Type) {
                        if(so.getLabel() == selectType)
                            selectType = so.getValue();
                    }


                    for(SelectOption so : eligibilityOption) {
                        if(so.getLabel() == selecteligibilityOption)
                            selecteligibilityOption = so.getValue();
                    }


                    for(SelectOption so : SubsidyTax) {
                        if(so.getLabel() == selectSubsidyTax)
                            selectSubsidyTax = so.getValue();
                    }


                    for(SelectOption so : serviceLevel) {
                        if(so.getLabel() == selectedServiceLevel)
                            selectedServiceLevel = so.getValue();
                    }


                    for(SelectOption so : subsidyType) {
                        if(so.getLabel() == selectsubsidyType)
                            selectsubsidyType = so.getValue();
                    }
                    
                }
                
                selectsubsidyFrequency = editProgram.Subsidy_Frequency__c;
                subsidyAmountDbl = editProgram.Subsidy_Amount__c != null ? editProgram.Subsidy_Amount__c : 0 ;
                subsidyAmount = subsidyAmountDbl;
                system.debug('1. Subsidy Accessories Allowed:' + selectaccessallowsubsidy);
                selectAccessories = editProgram.Accessories_Allowed_on_Subsidy__c;
                if (selectAccessories != null){
                    if (selectAccessories == 'Yes'){
                        selectaccessallowsubsidy = 'Allowed';
                    } else {
                        selectaccessallowsubsidy = 'Not Allowed';
                    }
                }
                system.debug('2. Subsidy Accessories Allowed:' + selectaccessallowsubsidy);
                subsidyPercentDbl = editProgram.Subsidy_Percent__c != null ? editProgram.Subsidy_Percent__c : 0 ;
                subsidyPercent = subsidyPercentDbl;

                maxAmountDbl = editProgram.Max_Amount__c != null ? editProgram.Max_Amount__c : 0;
                maxAmount = maxAmountDbl;
                numberPairsAllow = Integer.valueOf(editProgram.Number_of_Pairs_Allowed__c);
                selectRollingBalance = editProgram.Rolling_Balance__c;
                selectVoucherDistribution = editProgram.Voucher_Distribution__c;
                selectAnnualResetorRollover = editProgram.Annual_Reset_or_Rollover__c;
                selectRequireUpload = editProgram.Require_Upload_of_Company_Voucher__c;
                selectMandatory = editProgram.Mandatory__c;
                selectAccessAllowPayrollDeduction = editProgram.Accessories_Allowed_on_Payroll_Deduction__c;
                autoAddProducts = editProgram.Auto_Add_Products__c;
                selectFixed = editProgram.Fixed__c;
                autoUpdatePrice = editProgram.Auto_Update_Price__c ;
                proposalNotes = editProgram.Proposal_Notes__c;

                
                if(editProgram.Active__c == true){
                    ProgramStatus = 'Active';
                    ProgramActive = true;
                }
                else{
                    ProgramStatus = 'Inactive';
                    ProgramActive = false;
                }
                
                redirectToAccount = 'AccountSummary?tab=account&id='+editProgram.Account__c;
           }                         
       }
       programOwner = userInfo.getName();
       
       List<Publish_PriceBook__c> PriceBookList = [Select id, Name, IsActive__c ,Price_Book_ID__c from Publish_PriceBook__c where Program__c=: programId limit 1];
       
       if(PriceBookList.size() != 0){
           
           //standardPriceBookId = PriceBookList[0].id;
           PriceListName = PriceBookList[0].Name;
           PriceListId = PriceBookList[0].Price_Book_ID__c;
           if(PriceBookList[0].IsActive__c){
               PriceBookActive = 'Active';
           }
           else{
               PriceBookActive = 'Inactive';
           }
           
        }
       
        if(null != Apexpages.currentpage().getparameters().get('id')){
           accountId = Apexpages.currentpage().getparameters().get('id');
           isWizard = true;
        }
        if(null != Apexpages.currentpage().getparameters().get('AccountId')){
            accountId = Apexpages.currentpage().getparameters().get('AccountId');

        }
        System.debug('***************** account id is set to ' + accountId);
       if(null != accountId && accountId != ''){
           //AccObj = new Account();
           AccObj =[Select Id,Name,Credit_Status__c, Tax_Exempt__c, Requires_Invoicing__c from Account where id =: accountId limit 1];
           if(AccObj != null){
               AccountName = AccObj.Name;
               accRequiresInvoicing = accObj.Requires_Invoicing__c;
               if (AccObj.Tax_Exempt__c == 'Yes'){
                   selectSubsidyTax = 'SubsidyTaxed';
               } else {
                   selectSubsidyTax = 'TaxedUpToSubsidy';
               }
           }

       }
      system.debug('RWS_ProgramSetUpController End************');
    }

    public void reloadProductsReview() {}
    

    public PageReference SaveProgramDetails(){
        system.debug('SaveProgramDetails Begin************');
        errorMsg = '';
    
        if(ProgramActive == null) ProgramActive = false;
        
        try{
            PageReference pr;
            
                  
            //PROGRAM DETAILS Fields
            program = new Program__c(Id = programId);
            program.Account__c = accountid;
            program.Name = programName;
            List<Account> acList;
            if(EditMode == false){
                if(Null != AccObj)
                    program.Account__c = AccObj.Id;
            }
            else{
                program = [Select id,Account__c from Program__c where id=: programId limit 1];
                acList = [Select Id,Name,Credit_Status__c, Requires_Invoicing__c from Account where id = : program.Account__c];
                if(!acList.isEmpty())
                     AccObj =   acList[0];
                    program.id = programId;
                
            }
            
            System.debug('*****AccObj.Credit_Status__c'+AccObj);
            program.Activation_Date__c = activationDate;
            program.Expiration_Date__c = expirationDate;
            System.debug('=-=-=-=-=-=-=-= Program Activation Date: ' + activationDate);
            System.debug('=-=-=-=-=-=-=-= Program Expiration Date: ' + expirationDate);
            
            if(null == acList || acList.size() == 0 ){
                program.Active__c = ProgramActive == null || !ProgramActive ? false : true ;
            } /*
            else if(ProgramActive == true && (AccObj.Credit_Status__c == 'Approved/Active'  || selectType =='CashandCarry')){
                program.Active__c = ProgramActive == null || !ProgramActive ? false : true ;
                ProgramActivationStatus = 'Program is not active.';
            }
           else if(AccObj.Credit_Status__c != 'Approved/Active'  || selectType !='CashandCarry'){
                ProgramActivationStatus = 'Program cannot be activated, Please wait untill credit is approved or make a cash and carry payment';
                program.Active__c = false;
            } */
            
            //program.Auto_Add_Products__c = AutoAddProducts == null ? false : AutoAddProducts;
            program.Auto_Add_Products__c = AutoAddProducts == null ? true : AutoAddProducts;
            //program.Auto_Update_Price__c = autoUpdatePrice == null || !autoUpdatePrice ? false : true ;
            program.Auto_Update_Price__c = autoUpdatePrice == null ? true : autoUpdatePrice;
            
            //Program Owner
            //Status
            program.Name = programName;
            program.Purchase_Program_Notes__c = programNotes;
            //P-Card
            program.Alternative_Payment__c = selectedPCardOption;
            if (selectedSalesContract != '--None--')
                program.Sales_Contract__c = selectedSalesContract;
            if (selectedSalesContract == 'TXMAS'){
                if (selectedSalesContract != '--Select--')                
                program.Sales_Contract_Reference__c = selectedContractReason;
            }
            //Program Type
            if(selectType != '--None--')
                program.Type__c = selectType;
            //Service Level
            if (selectedServiceLevel != '--None--')
                program.Servicing_Level__c = selectedServiceLevel;
            

            //SUBSIDY - BASED ON TYPE Fields
            if(selectsubsidyType != '--None--')
                program.Subsidy_Type__c = selectsubsidyType;
            if(selectsubsidyFrequency != '--None--')
                program.Subsidy_Frequency__c = selectsubsidyFrequency;

            if(subsidyAmount != null) 
                subsidyAmountDbl = Double.valueOf(subsidyAmount);

            program.Subsidy_Amount__c = subsidyAmountDbl;

            //if(subsidyAmountDbl != null)
                //subsidyAmount = subsidyAmountDbl.intValue();
            
            if(selectaccessallowsubsidy != null){
                if (selectaccessallowsubsidy == 'Allowed'){
                    selectAccessories = 'Yes';
                } else {
                    selectAccessories = 'No';
                }
                
                                
                program.Accessories_Allowed_on_Subsidy__c = selectAccessories;
            }
             
            if(subsidyPercent != null) subsidyPercentDbl = Double.valueOf(subsidyPercent);
            
            program.Subsidy_Percent__c = subsidyPercentDbl;

            //if(subsidyPercentDbl != null)
                //subsidyPercent = subsidyPercentDbl.intValue();

            //Allowed # of Paris
            if(maxAmount != null) maxAmountDbl = Double.valueOf(maxAmount);
            program.Max_Amount__c = maxAmountDbl;

            //if(maxAmountDbl != null)
                //maxAmount = maxAmountDbl.intValue();
            
                program.Number_of_Pairs_Allowed__c = numberPairsAllow;
            
            //Sub Tax Method
            
            //ELIGIBILITY - BASED ON SUBSIDY Fields
            if(selecteligibilityOption != '--None--')
            program.Eligibility_Option__c = selecteligibilityOption; 
            if(selectRollingBalance != '--None--')  
            program.Rolling_Balance__c = selectRollingBalance;  
            if(selectVoucherDistribution != '--None--')
            program.Voucher_Distribution__c = selectVoucherDistribution;
            if(selectAnnualResetorRollover != '--None--')
            program.Annual_Reset_or_Rollover__c = selectAnnualResetorRollover; 
            if(selectRequireUpload  != '--None--')
            program.Require_Upload_of_Company_Voucher__c = selectRequireUpload;
            
            
            
            
            // PAYROLL DEDUCTION - BASED ON TYPE Fields
            if(selectMandatory != '--None--')
            program.Mandatory__c = selectMandatory; 
            if(selectAccessAllowPayrollDeduction != '--None--')
            program.Accessories_Allowed_on_Payroll_Deduction__c = selectAccessAllowPayrollDeduction;
            //program.Processing_Status__c = 'Scheduled';
            
            //PRICE LIST Fields
            if(selectautoaddProduct != '--None--')
            //program.Auto_Add_Products__c = selectautoaddProduct; 
            if(selectFixed != '--None--')
            program.Fixed__c = selectFixed; 
            
            program.Subsidy_Tax__c = selectSubsidyTax;
            program.Template__c = program.Account__c == null;
            
            
            if(null != task){
                program.id = null;
            }
            System.debug('*****before upsert program'+program);
            
              
            
            upsert program; // Insert or Update program.
            if(program.Id != null && !editMode ) ApexPages.currentPage().getParameters().put('proid', program.Id );
            System.debug('*****program'+program);
            
            
            programId = program.Id;
               
            ProgramSaved = ''; 
            if(EditMode == true){
                ProgramSaved = 'Updated'; 
                pr = new PageReference(Label.Community_Name + 'ProgramSummary?tab=program&proid='+program.id);
                pr.setRedirect(true);
                return pr;
            }  else if(accountId != null && isWizard) {
               return null;
            } else {
                pr = new PageReference(Label.Community_Name + 'RWS_NewProgramSetup?tab=program&proid='+program.id);
                pr.setRedirect(true);
                return pr;
            }
        }
        catch(System.DmlException e){
            ProgramSaved = 'ERROR'; 
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug('-=-=- Program error msgs:'+e.getDmlMessage(i)); 

                errorMsg +=  e.getDmlMessage(i) + '\n';

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));

            }
            
        }
        catch(Exception e){
            ProgramSaved = 'ERROR'; 
            System.debug('Error occurred in SaveProgramDetails. Error is: ' + e);
            errorMsg +=  e.getMessage() + '\n';

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is some back end issue. Please contact system admin.'));
        }

           
        system.debug('SaveProgramDetails End************');
        return null;
    }
    
    public PageReference cancel() {
        PageReference pr;
        if(!String.isBlank(task)){
            pr = new PageReference(Label.Community_Name + 'ProgramSummary?tab=program&proid='+program.id);
        } else{
            pr = new PageReference(Label.Community_Name + 'RWS_ProgramHomePage?tab=program');
        }
        
        pr.setRedirect(true);
        return pr;
    }
    
         
    // This method is used to set all picklist values in that program page.
    public void getAllPickListValues(){
    
        Type = RWS_UtilityClass.getType();
        subsidyType = RWS_UtilityClass.getsubsidyType();
        subsidyFrequency = RWS_UtilityClass.getsubsidyFrequency();
        accessallowsubsidy = RWS_UtilityClass.getaccessoriesAllowedSubsidy();
        eligibilityOption = RWS_UtilityClass.geteligibilityOption();
        RollingBalance = RWS_UtilityClass.getRollingBalanceOption();
        VoucherDistribution = RWS_UtilityClass.getVoucherDistributionOption(); 
        AnnualResetorRollover = RWS_UtilityClass.getAnnualResetorRolloverOption();
        RequireUpload = RWS_UtilityClass.getRequireUpload();
        Mandatory = RWS_UtilityClass.getMandatoryOption(); 
        accessAllowPayrollDeduction = RWS_UtilityClass.getAccessoriesAllowPayrollDeduction();
        FixedOption = RWS_UtilityClass.getFixed(); 
        SubsidyTax = RWS_UtilityClass.getSubsidyTaxMethods();
        serviceLevel = RWS_UtilityClass.getServicingLevel();
        pCardOptions = RWS_UtilityClass.getPCard();
        salesContractOptions = RWS_UtilityClass.getSalesContract();        
        

    }
    
    //display fields based on subsidy type selection
    public void subsidyFields(){
        //public Boolean show {get;set;}
        System.debug('subsidyFields*****'+selectsubsidyType);
        if(selectsubsidyType == 'Open'){
            show = true;
        }
    
    }
    
    //Method to activate program
    public void ActivateProgram() {
         try {
            
            Program__c pgmObj = [SELECT Id, Name, Account__c,
                                    Account__r.Id, Account__r.Name, Account__r.Credit_Status__c,
                                    Type__c, Active__c, 
                                    Activation_Date__c,
                                    Expiration_Date__c,
                                    HasPricebook__c,
                                    HasBeenActive__c 
                                FROM Program__c WHERE id=: programId limit 1];
            
            Account accObj;
            if( pgmObj.Account__c != null )
                accObj = pgmObj.Account__r;
            
            if( pgmObj.Type__c == 'CashandCarry' && pgmObj.HasPricebook__c == false && pgmObj.HasBeenActive__c == false ) {
            
                errorMsg = 'You cannot activate a cash and carry program without adding products.';
           
            } else {
                 PgmObj.Active__c = true;
                 PgmObj.Activation_Date__c = System.today();
                 update PgmObj;               
                
                 ProgramStatus = 'Active';
                 ProgramActive = true;
                 ProgramActivationStatus = '';
            }

        } catch(DMLException ex){
            for(Integer i = 0; i < ex.getNumDml(); i++)
                ProgramActivationStatus = ex.getDmlMessage(i) + '<br/>';
            
        } catch(exception e){
            ProgramActivationStatus = e.getMessage();
        }
    }
    
    //Method to deactivate program
    public void DeActivateProgram(){
                
        try{
                   //ProgramActivationStatus 
                Program__c PgmObj = [Select id, name, Account__c,Type__c,Active__c, Expiration_Date__c from Program__c where id=: programId limit 1];
                ProgramActivationStatus = 'Program is now deactivated.';
                PgmObj.Active__c = false;
                PgmObj.Expiration_Date__c = Date.today();
                
                update PgmObj;
                
                displayexpirationDate = PgmObj.Expiration_Date__c.format();
                
                ProgramStatus = 'Inactive';
                ProgramActive = false;
                System.debug('-=-=-=Deactivate - ProgramActivationStatus : '+ProgramActivationStatus );
        }
            
        catch(exception e){
            ProgramActivationStatus = e.getMessage();
            system.debug('-=-=-= ProgramActivationStatus is... ' + ProgramActivationStatus);
        }
    }


    public void saveProposalNotes()
    {
        Program__c program = new Program__c(Id = programId);

        program.Proposal_Notes__c = proposalNotes ;

        try{
            update program;
        }catch(DmlException de){}
    }

    public void updateProcessingStatus(){
        Program__c program = [Select id, Processing_Status__c from Program__c where id = :programId limit 1];        
        if(program.Processing_Status__c != null) {
            processingStatus = program.Processing_Status__c;
            if (processingStatus == 'Scheduled'){
                isScheduled = true;
            } else {
                isScheduled = false;
            }  
        }  
        
    }
    
    
    //Get Sales Contract Reason based on Sales Contract Value 
    public void getContractReason(){ 
        try{
            System.debug('UAC: selectedSalesContract ' + selectedSalesContract);

            contractReasonList= new List<Sales_Contract_References__c>();

            String soql = 'select Id, Name, Applicable_To__c, Sales_Contract_Name__c from Sales_Contract_References__c';
            if(selectedSalesContract != '' && selectedSalesContract != null)
                soql = soql +  ' WHERE Applicable_To__c =: selectedSalesContract';
            soql += ' ORDER BY Name ASC';
            System.debug(soql);
            contractReasonList= database.query(soql); 
            System.debug('****************'+contractReasonList+ '***'+selectedSalesContract);
            contractReasonOptions =  new List<SelectOption>();
            contractReasonOptions.add(new SelectOption('--Select--','--Select--'));
            for(Sales_Contract_References__c contractReason : contractReasonList){
                contractReasonLabel = contractReason.Name+' '+contractReason.Sales_Contract_Name__c;        
                contractReasonOptions.add(new SelectOption(contractReason.Id, contractReasonLabel));
            }
        }catch(Exception e){
            system.debug('error occurred: ' + e);
            ApexPages.addMessages(e);

        } 

    }
    
    
    
}