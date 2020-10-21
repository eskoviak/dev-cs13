/*********************************************************************
*Name          :  RWS_AccountSetupController 
*Description   :  Account Setup Class to create account,contact
*Author        :  
*Modification Log
----------------------------------------------------------------------

*   =============================================================================
*   Date        Name                    Description
*   7/07/2017   Joey Zhuang/M360        Add user access level indicator 
*   3/08/2018   Brandon Willard/M360    Modified for RWCP-3449
*********************************************************************/
public with sharing class RWS_AccountSetupController{

    public String AttachCertificateName { get; set; }
    
    //added by Joey
    public Boolean isFullAccessUser {get;set;}
    
    //added by Rajani RW: RWBAA URL
    public Boolean isStoreOwner {get;set;}
    public String URLRwbaaSummary {get;set;} 
    
    //account summary accordion variables - added by BW 7/12/17
    public Boolean isCollapsedAccInfo {get;set;}
    public Boolean isCollapsedContact {get;set;}
    public Boolean isCollapsedBilling {get;set;}
    public Boolean isCollapsedChildAcc {get;set;}
    public Boolean isCollapsedPrograms {get;set;}
    public Boolean isCollapsedAttachments {get;set;}



    
    public List<String> errors{
        get{
            List<String> msgs = new List<String>();
            List<Apexpages.Message> messages = ApexPages.getMessages(); 
            for (Apexpages.Message error : messages)  {
                msgs.add( error.getSummary() );
            }
            return msgs;
        }
    } 
    public Boolean hasErrors{
        get{
            return errors.size() > 0;
        }
    }
   
    public Boolean getErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    
     
   public PageReference SaveProgramDetails() {
        return null;
    }
    public String billingTitle { get; set; }
    public List<SelectOption> billingRoles {get;set;}
    public String[] selectedBillingRole {get;set;}
    public String NAM { get; set; }
    public String ISM { get; set; }
    public String[] selectInvoiceAttributes { get; set; }
    public String[] selectInvoiceAttributesLock { get; set; }
    public List<SelectOption> invoiceAttributesRequired { get; set; }
    public String owningStore { get; set; }
    public String otherInfoDescription { get; set; }
    public String otherInfoRequired { get; set; }
    public String contactIdentier {get; set;}
    public final String STR_PENDING = 'Pending';
    public final String STR_APPROVED = 'Approved/Active';
    public Boolean isNeedToLock{ get; set; }
    public Boolean resendCredit{ get; set; }
    public String tabFocus{get; set; }
    public String URLSummary {get;set;}
    public Boolean creditappFlag {get;set;}
    public String SelectinvoiceOptions{get;set;}
    public List<SelectOption> invoiceOptions{get;set;}
    public String[] invoiceAttrLabels {get;set;}
    public String creditApplicationMessage { get; set; }
    public Contact con { get; set; }
    public String deletedContactId {get;set;}
    public String payrollAccessories { get; set; }
    public String payrollDeduction { get; set; }
    public String annualOption { get; set; }
    public String voucherDistro { get; set; }
    public String eligibilityOption { get; set; }
    public String subTax { get; set; }
    public String allowedPairs { get; set; }
    public String accessoriesAllowed { get; set; }
    public String maxAmount { get; set; }
    public String subsidyPercent { get; set; }
    public String subsidyFrequency { get; set; }
    public String subsidyAmount { get; set; }
    public String subsidyType { get; set; }
    public String notes { get; set; }
    public String expiration { get; set; }
    public String activation { get; set; }
    public String programName { get; set; }
    public String type { get; set; }    
    public String billingPhone { get; set; }
    public String billingPhoneEdit { get; set; }
    public String billingPhoneExt { get; set; }
    public String billingEmail { get; set; }
    public String billingLast { get; set; }
    public String billingContactId { get; set; }
    public String billingFirst { get; set; }
    public String emailTo { get; set; }
    public String Terms { get; set; }
    public String Frequency { get; set; }
    public String paymentBy { get; set; }
    public String deliveryBy { get; set; }
    public String billingContact { get; set; }
    public String contactStreet { get; set; }
    public String contactRole { get; set; }
    public String contactAddress { get; set; }
    public ID parentId {get;set;}
    public String attid {get;set;}
    public Boolean billingSame {get;set;}
    public String selectBillingAddressOption {get;set;}
    public List<SelectOption> billingAddressOptions {get;set;}
    public User userVar {get; set;}
    public String sendCreditErrorMsg {get; set;}
    public String pageName {get; set;}
    public String SendCreditApplicationErrors {get; set;}
    
    //Tax Exemption Properties
    public List<Tax_Exemption_Reason__c> taxsearchresultList {get;set;}
    public String searchStateString {get;set;}
    public String selecttaxName    {get;set;}
    public String exemptionreasonName {get;set;}
    public List<SelectOption> exemptionreasonOption {get;set;}
    public List<Tax_Exemption_Reason__c> taxexemptReasonList {get;set;}
    
    
    public String contactPhone { get; set; }
    public String contactName { get; set; }
    public String billingStreet { get; set; }
    public String billingStatus { get; set; }
    public String billingName { get; set; }
    public String mailingzipCode { get; set; }
    public String mailingState { get; set; }
    public String mailingCity { get; set; }
    public String mailingStreet { get; set; }
    public String mailingCountry  {get;set;}
    public String billingCountry  {get;set;}
    public String billingCountryLabel  {get;set;}

    
    public String StreetAddress { get; set; }
    
    //Account properties
    public String accountName {get;set;}
    public String accountOwner {get;set;}
    public String accountNumber {get;set;}
    public String accountAddress {get;set;}
    //public String accountStreet {get;set;}
    public String accountLine1 { get; set;}
    public String accountLine2 { get; set;}
    public String accountLine3 { get; set;}
    public String accountCity {get;set;}
    public String accountState {get;set;}
    public String accountStateLabel {get;set;}
    public String accountzipCode {get;set;}
    public String accountCountry {get;set;}
    public String accountCountryLabel {get;set;}
    public String accountPhone {get;set;}
    public String accountPhoneEdit {get;set;}
    public String accountPhoneExt {get;set;}
    public String billingLine1 { get; set;}
    public String billingLine2 { get; set;}
    public String billingLine3 { get; set;}
    public String billingCity { get; set;}
    public String billingState { get; set;}
    public String billingStateLabel {get;set;}
    public String billingZipCode { get; set;}

    public List<Account> accList;
    public String dupliactionMessage {get;set;}
    public String duplicationMessage {get;set;}
    public String selectOrgType {get;set;}
    public String selectAccountCategory {get;set;}
    public String selectAccountType {get;set;}
    public String SelectTaxIdType {get;set;}
    public String SelectTaxExempt {get;set;}
    public List<SelectOption> OrgType {get;set;}
    public List<SelectOption> AccountCategory {get;set;}
    public List<SelectOption> AccountType {get;set;}
    public List<SelectOption> serviceMethods {get;set;}
    public List<String> selectedserviceMethods {get;set;}
    public List<SelectOption> shoemobileFrequency {get;set;}
    public List<SelectOption> TaxIdType {get;set;}
    public List<SelectOption> TaxExempt {get;set;}
    public String selectshoemobileFrequency {get;set;}
    public String dunsNumber {get;set;}
    public Attachment AttachCertificate {get;set;}
    public string redirectToProgram {get;set;}
    public string ReloadIfNoAttachment {get;set;}
    
    //Tax related fields
    public String TaxNumber {get;set;}
    public String TaxCertificateNumber {get;set;}
    public date TaxExpiryDate {get;set;}
    public String displayTaxExpiryDate {get;set;}
    public date openDate {get;set;}
    public String exemptReason { get; set; }
    public String industrialAccount { get; set; }
    public String nationalAccount { get; set; }
    public String cityExempt { get; set; }
    public String stateExempt { get; set; }
    public String countyExempt { get; set; }
    public String countryExempt { get; set; }
        
    public List<SelectOption> IndustrialAccountOptions{get;set;}
    public List<SelectOption> NationalAccountOptions{get;set;}
    public List<SelectOption> CityExemptOptions{get;set;}
    public List<SelectOption> StateExemptOptions{get;set;}
    public List<SelectOption> CountyExemptOptions{get;set;}
    public List<SelectOption> CountryExemptOptions{get;set;}
    public List<SelectOption> StateOptions {get;set;}
    public List<SelectOption> CountryOptions {get;set;}
    public List<SelectOption> ContactStateOptions {get;set;}  
    public List<SelectOption> ContactCountryOptions {get;set;} 
    public List<SelectOption> BillingCountryOptions {get;set;} 
    public String billingDifferentCountry  {get;set;}
    
    // Credit related variables
    public double requestedCreditLimit {get;set;} 
    public List<SelectOption> creditStatus {get;set;}
    public string selectCreditStatus {get;set;}
    public double creditLimit {get;set;}
    public string MSTSCustomerNo {get;set;}
    public string creditApplicationID {get;set;}
    public String creditApplicationSentDate {get;set;}
    public String creditApplicationApprovedDate {get;set;}
    
    //PAYMENT TERMS & INVOICE PREFERENCES Properties
    public string legalName {get;set;}
    public string selectbillingFrequency {get;set;}
    public List<SelectOption> billingFrequency {get;set;}
    public string selectpaymentTerms {get;set;}
    public List<SelectOption> paymentTerms {get;set;}
    public String displayPaymentTerms {get; set;}
    public string selectinvoiceDelivery {get;set;}
    public List<SelectOption> invoiceDeliveryMethod {get;set;}
    public String displayInvoiceDelivery {get; set;}
    public String SelectiReqCreditLimitOptions{get;set;}
    public List<SelectOption> ReqCreditLimitOptions{get;set;}
    public string selectpreferredPayment {get;set;}
    public List<SelectOption> preferredPaymentMethod {get;set;}
    public String selectStandardApplication {get;set;}
    public String EmailApplicableTo {get;set;}
    public String EmailApplicableToModal {get;set;}
    public String SendCreditApplicationPopUp {get;set;}
    public String federalIdNumber {get; set;}

    
    //Contact Properties
    public Boolean ContactEditOrView {get;set;}
    public List<contact> contactList {get;set;}
    public List<contact> contactListForTable {get; set;}
    public String PrimaryContactEmail {
        get{return 'ABC';}
    }
    public String contactFirstName {get;set;}
    public String contactLastName {get;set;}
    public String contactEmail {get;set;}
    public Boolean ManuallyVerifiedEmail {get;set;}
    public String contactPhoneNo {get;set;}
    public String contactPhoneNoEdit {get;set;}
    public String contactPhoneNoExt {get;set;}
    public Boolean isActive {get;set;}
    public String contactTitle {get;set;}
    public String contactFax {get;set;}
    public String contactMobilePhone {get;set;}
    //public String contactPreference {get;set;}
    public String SelectContactPreference {get;set;}
    public Account editAccount { get; set; }
    public Contact editContact { get; set; }
    public Account createAccount { get; set; }
    public Contact createContact {get;set;}
    public String contactId   { get; set; }
    public String accountId {get;set;}
    public String rwfbId {get;set;}
    public List<SelectOption> ContactPref {get;set;}
    public List<SelectOption> ContactRoles {get;set;}
    public String[] SelectedRoles {get;set;}
    public string selectedUsertype {get;set;}
    public List<SelectOption> userTypes {get;set;}
    public Boolean EditMode {get;set;}
    public String contactStreetAddress {get;set;}
    public String contactCity {get;set;}
    public String contactState {get;set;}
    public String contactZipCode {get;set;}
    public String contactCountry {get;set;}
    public List<SelectOption> ContactAddressOptions{get;set;}
    public String SelectContactAddressOptions{get;set;}
    public List<SelectOption> contactAddressBillingOptions{get;set;}
    public String SelectContactAddrBillOptions{get;set;}
    public List<SelectOption> billingcontactOptions{get;set;}
    public String SelectbillingcontactOptions{get;set;}
    public String SameAsAccountAddress {get;set;}
    public String SameAsBillingAddress {get;set;}
    public String SameAsPrimaryContactInfo {get;set;}
    public String ContactCompleteAddress {get;set;}
    
    public Boolean showSection {get;set;}
    //Create Purchasing Account Properties
    
    public Boolean issetupAccount {get;set;}
    public Boolean isalternatePayment {get;set;}
    public String SummeryEditButton {get;set;}
    
    
    // Create or Assign Purchasing Program Properties
    public Boolean isnewProgram {get;set;}
    public Boolean isassignexistProgram {get;set;}
    public Boolean isnotReady {get;set;}
    public List<Program__c> ListofNonAccountPrograms {get;set;}
    public List<Program__c> ListofAccountPrograms {get;set;}
    public List<ProgramsWrapper> ListOfProgramWrap {get;set;}
    public List<ProgramsWrapper> SelectedPrograms {get;set;}
    public List<Program__c> ProgramSelected {get;set;}
    
    public List<AccountWrapper> childAccounts {get; set; }
    public String parentAccountId {get; set; }
    public Boolean hasParentAccountAccess {get; set; }
    public String deleteChildAccountId {get; set; }

    public string AccountStatus {get;set;}
    public String AccountStatusMessage {get;set;}
    public Boolean primaryContactError {get; set;}
    public String contactPrimaryEmail {get; set;}
    public String createdProgramId {get; set;}

    public void populateProgramId() {
        System.debug(createdProgramId);
    }
    
    public Attachment attachment {
        get {
        if (attachment == null)
            attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    //attachment Type 
    public List<SelectOption> attachTypeOptions {get;set;} 
    public String selectAttachType {get; set;}
    public Boolean selectCreditApplicationDoc {get; set;}
    
    //invoice parent
    public String selectInvoiceParent {get;set;}
    public String selectBillingParent { get; set; }
    public Contact parentBillingContact {get; set;}    
    public Account parentAccount{get; set; }
    public String decContactId { get; set; }
    public String decFirst { get; set; }
    public String decLast { get; set; }
    public String decEmail { get; set; }
    public String decPhone { get; set; }
    public String decStreet { get; set; }
    public String decCity { get; set; }
    public String decState { get; set; }
    public String decZipCode { get; set; }
    public String decCountry  {get;set;}
    public String parentContactId {get; set; }
    public String[] decSelectedBillingRole {get; set; }
    public String decTitle {get; set; }
    
    // for attaching file
    public String fileName {get; set;}    
    
    public Boolean renderUserType {get; set;}
    public Boolean contactMSTS {get; set;}
    
    
    
    
    
    //helpers for view only state
    public Boolean isCentralizedBilling{
        get{
            return !String.isBlank(parentAccountId) && editAccount != null && selectBillingParent == 'Centralized';
        }
    }
    public Boolean isDecentralizedBilling{
        get{
            return !String.isBlank(parentAccountId) && editAccount != null && selectBillingParent == 'Decentralized';
        }
    }    
    public Boolean hasParent{
        get{
            return !String.isBlank(parentAccountId) && editAccount != null;
        }
    }
    public Boolean isInvoiceParentAccount{
        get{
            return SelectInvoiceParent == 'Yes';
        }
    }
 
    public Boolean hasEditAccess {get; private set;}

    //Constructor
    public RWS_AccountSetupController(){
        
        ManuallyVerifiedEmail = false;
        // added by Joey
       
        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();

        //account summary accordion variables set by utility class - BW 7/12/17
        isCollapsedAccInfo = RWS_UtilityClass.isCollapsedAccInfo();
        isCollapsedContact = RWS_UtilityClass.isCollapsedContact();
        isCollapsedBilling = RWS_UtilityClass.isCollapsedBilling();
        isCollapsedChildAcc = RWS_UtilityClass.isCollapsedChildAcc();
        isCollapsedPrograms = RWS_UtilityClass.isCollapsedPrograms();
        isCollapsedAttachments = RWS_UtilityClass.isCollapsedAttachments();
        System.debug('Account Summary Accordion Vars: '+ 'Account info: ' + isCollapsedAccInfo + 'Contact: ' + isCollapsedContact + 'Billing: ' +
            isCollapsedBilling + 'Child accounts: ' + isCollapsedChildAcc + 'Programs: ' + isCollapsedPrograms + 'Attachments: ' + isCollapsedAttachments);
        
        //selectAttachType = 'Proposal';
        selectCreditApplicationDoc = false;
        selectBillingParent = 'Centralized';
        SelectInvoiceParent = 'Yes';
        renderUserType = false;
        parentBillingContact = new Contact();
        parentAccount = new Account();
        hasEditAccess = true;
        selectInvoiceAttributes = new List<String>();
        SelectedRoles = new List<String>();
        primaryContactError = false;
        isActive = false;
        isNeedToLock = false ;
        resendCredit = false ;
        EditMode = false;
        selectTaxExempt = 'No';
        billingAddressOptions = RWS_UtilityClass.getAddressPreference();
        billingAddressOptions.remove(1);        
        selectContactAddressOptions = 'Same as Physical';
        selectContactAddrBillOptions = 'Same as Physical';
        selectBillingAddressOption = 'Yes';
        billingSame = true;
        selectbillingcontactOptions = 'Yes';
        selectinvoiceOptions = 'No';
        taxExpiryDate = null;
        //selectbillingFrequency = '--Select--';
        selectpaymentTerms = '30';
        selectinvoiceDelivery = 'PDF';
        //selectiReqCreditLimitOptions = '--Select--';
        selectStandardApplication = 'Yes';
        billingRoles = RWS_UtilityClass.getcontactRoles();
        createContact = new Contact();
        attachCertificate = new Attachment();
        childAccounts = new List<AccountWrapper>();
        System.debug('======== This is account setup constructor');
        
        sameAsAccountAddress = 'There is no address entered for Account';
        sameAsBillingAddress = 'There is no address entered for Account';
        sameAsPrimaryContactInfo = 'There is no primary contact info available';
        billingContact = 'There is no billing contact info available';
        contactAddress = 'There is no billing contact address available';
        getAllPickListValues(); // Set all picklist valies whcih are in page.
        
        listOfProgramWrap = new List<ProgramsWrapper>();
        listofNonAccountPrograms = [SELECT Id,Purchase_Program_Notes__c,Name,Description__c,Active__c,Program_Notes_Trimmed__c, Type__c,  Activation_Date__c, Expiration_Date__c 
                FROM Program__c 
                WHERE Template__c = true
                AND Processing_Status__c = 'Completed'];
        for( Program__c pgm: listofNonAccountPrograms )
        {    
            
           
            ProgramsWrapper pgmW = new ProgramsWrapper(pgm);                          
            listOfProgramWrap.add(pgmW);
        }
        
        System.debug('\n-=-= pgm list'+listOfProgramWrap);
        taxsearchresultList = new List<Tax_Exemption_Reason__c>();
        exemptionreasonOption =  new List<SelectOption>();
        exemptionreasonOption.add(new SelectOption('--Select--','--Select--'));

        
        openDate = System.today();          // This is to show user todays date, The date when Account is getting inserted (Before insert)
        accountOwner = userInfo.getName();
        
        System.debug('-=-=-=-open date before edit'+openDate);
        //URLSummary = 'RWS_AdvancedAccountSetup?tab=account'; //RWCP-1564 - Same functionality is available via AccountSymmary page to complete Advanced Account setup. Not developing separate page.
        URLSummary = 'AccountSummary?tab=account';

        accountId = Apexpages.currentpage().getparameters().get('id');
        
        tabFocus = '0';
       
        parentAccountId = ApexPages.currentPage().getparameters().get('ParentId');

        System.debug('UAC: tabFocus ' + tabFocus );


        invoiceAttributesRequired = RWS_UtilityClass.getInvoiceAttributesRequired();
        
        initAccount();

        getStateTaxExempt();
        setParentInvoiceInfo();
        System.debug('-=-=- EmailApplicableTo at EOC:'+EmailApplicableTo);
    }

    
    private void initAccount() {
        if(accountId != null )
        {
            ReloadIfNoAttachment = 'AccountSummary?tab=account&id='+accountId;
            tabFocus = '1';
            editMode = true;
            contactList = new List<contact>();
            accList = new List<Account>();
            duplicationMessage = '';
            editAccount = [SELECT IsPersonAccount,Id,Name,CreatedDate,Account_Number_BPC__c,Owner.Name, IA_Physical_Location_Address_Line_1__c, IA_Physical_Location_Address_Line_2__c, IA_Physical_Location_Address_Line_3__c,
                                    IA_Physical_Location_City__c,
                                   IA_Physical_Location_State_Province__c, IA_Physical_Location_ZIP_Postal_Code__c,IA_Physical_Location_Country__c,RWfB_Billing_Address_Line_1__c, RWfB_Billing_Address_Line_2__c,
                                   RWfB_Billing_Address_Line_3__c,RWfB_Billing_Address_City__c, RWfB_Billing_Address_State_Province__c,RWfB_Billing_Address_ZIP_Postal_Code__c,RWfB_Billing_Address_Country__c,Phone,
                                   Organization_Type__c,Account_Category__c,Company_Type__c,NA_Distribution_Method__c,DunsNumber,NA_Shoemobile_Frequency__c,
                                   Tax_Exemption_Reason__c,Tax_Exemption_Reason__r.Name,Tax_Id_Type__c,Tax_Id_Number__c,Tax_Exempt__c,IA_Tax_Exempt_Certificate_Nbr__c,
                                   Tax_Exempt_Expiration_Date__c,Open_Date__c,Credit_Status__c,Requested_Credit_Limi__c,Credit_Limit__C, Legal_Name__c, Billing_Frequency__c,
                                   BPC_Payment_Terms__c, Invoice_Delivery_Method__c,Preferred_Payment_Method__c,Email_Application_To__c,MSTS_ID__c,
                                   MultiService_Credit_Application_ID__c,Credit_Application_Sent_Date__c,Credit_Application_Approval_Date__c,Active__c,
                                   Requires_Invoicing__c,Send_Application__c,IA_Federal_ID_Nbr__c, ParentId, Invoice_Atributes_Required__c, RWBAA_Standard_Application__c, Owning_Store__c, NAM__c, 
                                   ISM__c, IAS__c, Other_Information_Required__c, Other_Information_Description__c,Federal_ID__c,Payment_Terms__c, RWfB_same_as_Physical_Address__c, Invoice_Parent_Account__c, Recourse_Customer__c, Publish_Status__c
                           FROM Account WHERE ID =: accountId];
                           
             
        //Rajani RW: Start Rwbaa URL 
         User currentUser = [select Id, CompanyName
                            from User 
                            where Id = :UserInfo.getUserId()];
		System.debug('Userinfo Before:' + isStoreOwner + currentUser);                            
        if(currentUser.CompanyName  == editAccount.Owning_Store__c)
        {
        	isStoreOwner = true;
	        System.debug('Userinfo After:' + isStoreOwner + currentUser);
	        URLRwbaaSummary = 'RWS_AccountRwbaaSummary?id='+accountId;
        }
        //End Rwbaa URL 
            
            if(editAccount.Invoice_Parent_Account__c != null){
                if(editAccount.Invoice_Parent_Account__c == 'No'){
                    SelectInvoiceParent = 'No';
                }else if(editAccount.Invoice_Parent_Account__c == 'Centralized'){
                    SelectInvoiceParent = 'Yes';
                    selectBillingParent = 'Centralized';
                }else if(editAccount.Invoice_Parent_Account__c == 'Decentralized'){
                    SelectInvoiceParent = 'Yes';
                    selectBillingParent = 'Decentralized';
                }
            }
            hasEditAccess = RWS_UtilityClass.getUserRecordEditAccess(editAccount.Id);
            
            if(editAccount.ParentId != null ) {
                parentAccountId = editAccount.ParentId ;
            }
            
            if(editAccount.Credit_Status__c == 'Approved/Active'){
                renderUserType = true;
            }
        
            if(editAccount.Id != null ){             
                URLSummary = 'AccountSummary?tab=account&id='+editAccount.Id;
            }

            if( !String.isBlank(parentAccountId) ) {
                hasParentAccountAccess = RWS_UtilityClass.getUserRecordAccess(editAccount.ParentId);

                try {
                    parentBillingContact = [SELECT ID, tdc_tvte__Result_text__c, FirstName, LastName, Email, Phone,BPR_Role__c,Title,Address_same_as_Accounts__c,Contact_Same_as_Primary__c,
                    MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry, Role__c
                    from Contact where AccountId =: editAccount.ParentId AND Contact_Identifier__c IN ('Primary & Billing', 'Billing')limit 1];
                } catch(Exception e){
                    System.debug('Error occurred getting billing contact. ' + e.getMessage());
                }

                parentAccount = RWS_UtilityClass.getParentAccountConstructor(parentAccountId);

                System.debug('-=-=-=-=-=-=-=-= parent account federal id number is ' + parentAccount.IA_Federal_ID_Nbr__c);                
            }

            List<Contact> contactPrimary = [SELECT ID, name, tdc_tvte__Result_text__c ,FirstName, LastName, Email, Phone,BPR_Role__c,Title,Address_same_as_Accounts__c,Contact_Same_as_Primary__c 
                from Contact where AccountId =:editAccount.id AND Contact_Identifier__c IN ('Primary & Billing', 'Primary') limit 1];
            contactList = [Select ID, name, FirstName, LastName, Email, Phone,BPR_Role__c,Role__c ,Title,Contact_Identifier__c,Address_same_as_Accounts__c,Contact_Same_as_Primary__c, MSTS_User__c, RWBAA_User_Type__c, tdc_tvte__Result_text__c 
                from Contact where AccountId = :editAccount.id ];
            
          
            contactListForTable = contactList;
            if(editAccount.Credit_Status__c != null ){ 
                selectCreditStatus = editAccount.Credit_Status__c;
            
                isNeedToLock = selectCreditStatus == STR_PENDING || selectCreditStatus == STR_APPROVED;            
                resendCredit = selectCreditStatus != STR_APPROVED && selectCreditStatus != null;
            }
            // ***** Condition to check if There are any contacts assigned to the contact
            if(!contactPrimary.isEmpty()){
                tabFocus = '2';
                SameAsPrimaryContactInfo = contactPrimary[0].FirstName + ' ' + contactPrimary[0].LastName + ',\n ' + contactPrimary[0].Email + ', ' + contactPrimary[0].Phone + ', ' + contactPrimary[0].Title;
                contactPrimaryEmail = contactPrimary[0].Email ;

                if(null == SameAsPrimaryContactInfo || SameAsPrimaryContactInfo  == ''){
                    SameAsPrimaryContactInfo = 'There is no primary contact available.';
                }
                
                EmailApplicableTo = contactPrimary[0].Email;
                System.debug('-=-=- primary contact email to email applicable:'+EmailApplicableTo);
            }
            
            //Account Edit Details
            if(editAccount.Requires_Invoicing__c == null)
                SelectinvoiceOptions = 'No';
            else{
                SelectinvoiceOptions = editAccount.Requires_Invoicing__c;
                tabFocus = '3';
            }
            isActive = editAccount.Active__c;
            
            if(isActive == true)
                AccountStatus = 'Active';
            else
                AccountStatus = 'Inactive';
            
            federalIdNumber = editAccount.IA_Federal_ID_Nbr__c;
            if(!String.isBlank(editAccount.Email_Application_To__c) ){
                EmailApplicableTo = editAccount.Email_Application_To__c;
            }

            accountName = editAccount.Name;
            accountLine1 = editAccount.IA_Physical_Location_Address_Line_1__c;
            if (editAccount.IA_Physical_Location_Address_Line_2__c != null ){
                accountLine2 = editAccount.IA_Physical_Location_Address_Line_2__c;
            }            
            if (editAccount.IA_Physical_Location_Address_Line_3__c != null ){
                accountLine3 = editAccount.IA_Physical_Location_Address_Line_3__c;
            } 
            accountCity = editAccount.IA_Physical_Location_City__c;
            accountState = editAccount.IA_Physical_Location_State_Province__c;
            accountzipCode = editAccount.IA_Physical_Location_ZIP_Postal_Code__c;
            accountCountry = editAccount.IA_Physical_Location_Country__c; 
            
            billingLine1 = editAccount.RWfB_Billing_Address_Line_1__c;
            if (editAccount.RWfB_Billing_Address_Line_2__c != null ){
                billingLine2 = editAccount.RWfB_Billing_Address_Line_2__c;
            }
            if (editAccount.RWfB_Billing_Address_Line_3__c != null ){
                billingLine3 = editAccount.RWfB_Billing_Address_Line_3__c;
            }
            billingCity = editAccount.RWfB_Billing_Address_City__c;
            billingState = editAccount.RWfB_Billing_Address_State_Province__c;
            billingZipCode = editAccount.RWfB_Billing_Address_ZIP_Postal_Code__c;

            billingCountry = editAccount.RWfB_Billing_Address_Country__c;
            
            if (editAccount.RWfB_same_as_Physical_Address__c != null){
                billingSame = editAccount.RWfB_same_as_Physical_Address__c;
                if (billingSame == false) {
                    selectBillingAddressOption = 'Different';
                }
            } 
            
            getStateCountryLabel();
            
            invoiceAttrLabels = new List<String>();
                        
            selectInvoiceAttributes = String.isNotBlank(editAccount.Invoice_Atributes_Required__c) ? editAccount.Invoice_Atributes_Required__c.split('\\;') : null;
            if (selectInvoiceAttributes != null){
                Map<String, String> invoiceAttrOptions = new Map<String, String>();
                System.debug('Attributes Required: ' + invoiceAttributesRequired);
                for (SelectOption so : invoiceAttributesRequired){
                    invoiceAttrOptions.put(so.getValue(), so.getLabel());            
                }            
                System.debug('map: '+invoiceAttrOptions);
                
                    for (String attr : selectInvoiceAttributes){
                        invoiceAttrLabels.add(invoiceAttrOptions.get(attr));          
                    }
                
                string.join(invoiceAttrLabels,';');
                System.debug('label values: '+invoiceAttrLabels);
            }
            if( !String.isBlank(accountLine1) ) sameAsAccountAddress = accountLine1 ;
            if( !String.isBlank(accountLine2) ) sameAsAccountAddress += ', ' + accountLine2 ;
            if( !String.isBlank(accountLine3) ) sameAsAccountAddress += ', ' + accountLine3 ;
            if( !String.isBlank(accountCity) ) sameAsAccountAddress += ', ' + accountCity ;
            if( !String.isBlank(accountState) ) sameAsAccountAddress += ',\n ' + accountStateLabel ;
            if( !String.isBlank(accountCountry) ) sameAsAccountAddress += ', ' + accountCountryLabel ;
            if( !String.isBlank(accountzipCode) ) sameAsAccountAddress += ', ' + accountzipCode ;
            
            if(String.isBlank(sameAsAccountAddress)) sameAsAccountAddress = 'There is no address entered for Account' ;
            
            if( !String.isBlank(billingLine1) ) sameAsbillingAddress = billingLine1 ;
            if( !String.isBlank(billingLine2) ) sameAsbillingAddress += ', ' + billingLine2 ;
            if( !String.isBlank(billingLine3) ) sameAsbillingAddress += ', ' + billingLine3 ;
            if( !String.isBlank(billingCity) ) sameAsbillingAddress += ', ' + billingCity ;
            if( !String.isBlank(billingState) ) sameAsbillingAddress += ',\n ' + billingStateLabel ;
            if( !String.isBlank(billingCountry) ) sameAsbillingAddress += ', ' + billingCountryLabel ;
            if( !String.isBlank(billingzipCode) ) sameAsbillingAddress += ', ' + billingzipCode ;

            if(String.isBlank(sameAsbillingAddress)) sameAsbillingAddress = 'There is no address entered for Account' ;
                        
            accountPhone = editAccount.Phone;
            if (accountPhone != null){
                if (accountPhone.contains(' x')){
                    accountPhoneEdit = accountPhone.substringBefore(' x');
                    accountPhoneExt = accountPhone.substringAfter(' x');
                } else {
                    accountPhoneEdit = accountPhone;
                }   
            }
            isActive = editAccount.Active__c;
            TaxNumber = editAccount.Tax_Id_Number__c;
            dunsNumber = editAccount.DunsNumber;
            selectOrgType = editAccount.Organization_Type__c;
            selectAccountCategory = editAccount.Organization_Type__c;
            selectAccountType = editAccount.Company_Type__c;
            selectTaxIdType = editAccount.Tax_Id_Type__c;
            TaxExpiryDate = editAccount.Tax_Exempt_Expiration_Date__c;
            if(editAccount.Tax_Exempt_Expiration_Date__c != null)
                displayTaxExpiryDate = editAccount.Tax_Exempt_Expiration_Date__c.format();
            TaxCertificateNumber = editAccount.IA_Tax_Exempt_Certificate_Nbr__c;
            System.debug('-=-=-=-open date bla bla edit'+openDate);
            //openDate = date.ValueOf(editAccount.CreatedDate.year()+'-'+editAccount.CreatedDate.month()+'-'+editAccount.CreatedDate.day());
            //System.debug('-=-=-=-created date afetr edit'+editAccount.CreatedDate);
            //System.debug('-=-=-=-open date afetr edit'+openDate);
            accountOwner = editAccount.owner.name;
            accountNumber = editAccount.Account_Number_BPC__c;
            if(null != editAccount.NA_Distribution_Method__c){
                selectedserviceMethods = editAccount.NA_Distribution_Method__c.split(';');
            }
            owningStore = editAccount.Owning_Store__c;
            
            
            NAM = editAccount.NAM__c;
            ISM = editAccount.ISM__c;
            //userVar = [SELECT Id, Name FROM User WHERE Id =: ISM];
            
            
                      
            otherInfoDescription = editAccount.Other_Information_Description__c;
            otherInfoRequired = editAccount.Other_Information_Required__c;
            selectshoemobileFrequency = editAccount.NA_Shoemobile_Frequency__c;
            SelectTaxExempt = editAccount.Tax_Exempt__c;
            //openDate = editAccount.Open_Date__c;
            SelectiReqCreditLimitOptions = editAccount.Requested_Credit_Limi__c;
            if(editAccount.Requested_Credit_Limi__c == null || editAccount.Requested_Credit_Limi__c == '')
                SelectiReqCreditLimitOptions = '--Select--';
            creditLimit = editAccount.Credit_Limit__C;
           // requestedCreditLimit = editAccount.Requested_Credit_Limi__c;
            selectStandardApplication = editAccount.RWBAA_Standard_Application__c;
            if(editAccount.RWBAA_Standard_Application__c == null || editAccount.RWBAA_Standard_Application__c == '')
                selectStandardApplication = 'Yes';
            if(editAccount.Legal_Name__c != null && editAccount.Legal_Name__c != '')
                legalName = editAccount.Legal_Name__c;
            selectbillingFrequency = editAccount.Billing_Frequency__c;
            if(editAccount.Billing_Frequency__c == null || editAccount.Billing_Frequency__c == '')
                selectbillingFrequency = '--Select--';
            else{selectpaymentTerms = editAccount.BPC_Payment_Terms__c;}            
            if(editAccount.BPC_Payment_Terms__c == null || editAccount.BPC_Payment_Terms__c == '')
                selectpaymentTerms = '30';

            Map<String, String> paymentTermOptions = new Map<String, String>();
            for (SelectOption so : paymentTerms){
                paymentTermOptions.put(so.getValue(), so.getLabel());            
            }            
            
            displayPaymentTerms = paymentTermOptions.get(selectPaymentTerms);
            

            selectinvoiceDelivery = editAccount.Invoice_Delivery_Method__c;
            if(editAccount.Invoice_Delivery_Method__c == null || editAccount.Invoice_Delivery_Method__c == '')
                selectinvoiceDelivery = 'PDF';
            
            Map<String, String> invoiceDeliveryOptions = new Map<String, String>();
            for (SelectOption so : invoiceDeliveryMethod){
                invoiceDeliveryOptions.put(so.getValue(), so.getLabel());            
            }            
            
            displayInvoiceDelivery = invoiceDeliveryOptions.get(selectinvoiceDelivery);
             
            selectpreferredPayment = editAccount.Preferred_Payment_Method__c;
            
            system.debug('EmailApplicableTo'+EmailApplicableTo);
            MSTSCustomerNo = editAccount.MSTS_ID__c;
            creditApplicationID = editAccount.MultiService_Credit_Application_ID__c;
            if(editAccount.Credit_Application_Sent_Date__c != null)
                creditApplicationSentDate = editAccount.Credit_Application_Sent_Date__c.format();
            if(editAccount.Credit_Application_Approval_Date__c != null)
                creditApplicationApprovedDate = editAccount.Credit_Application_Approval_Date__c.format();
            selecttaxName = editAccount.Tax_Exemption_Reason__c;
            exemptionreasonName = editAccount.Tax_Exemption_Reason__r.Name;
            if(null != selecttaxName && selecttaxName != '--Select--' && selecttaxName != '--Enter State--')
                AssignTaxExempt();
            
            //AttachCertificate 
            list<Account> acList = [Select Id, IsPersonAccount, (Select Name,Id From RWfB_Attachments__r Where Type__c = 'Tax Exempt Certificate' And Public__c = true) From Account where Id = : accountId limit 1];
            if(acList.size()>0){
                if(acList[0].RWfB_Attachments__r.size()>0){
                    rwfbId = acList[0].RWfB_Attachments__r[0].Id;
                }    

                List<Attachment> CheckAttachments = [Select id,Name,parentid  from Attachment where parentid  In : acList[0].RWfB_Attachments__r ORDER BY Id DESC LIMIT 1];
                
                if(CheckAttachments.size() > 0){
                    //attid  = CheckAttachments[0].id;
                    AttachCertificate = CheckAttachments[0];
                }
            }
            
            System.debug('-=-=- Attachment: '+AttachCertificate );
            
            List<Contact> billContact = [Select Id, Name, FirstName, LastName, Email, Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,BPR_Role__c,Role__c,Title,Contact_Identifier__c,Contact_Same_as_Primary__c,Address_same_as_Accounts__c, tdc_tvte__Result_text__c from Contact where AccountId =:editAccount.id 
            AND Contact_Identifier__c IN ('Primary & Billing', 'Billing')AND (BPR_Role__c = 'Billing Contact' OR Contact_Identifier__c = 'Billing') limit 1];
            if(!billContact.isEmpty()){
                selectedBillingRole = String.isNotBlank(billContact[0].Role__c) ? billContact[0].Role__c.split('\\;') : null;
                billingTitle = billContact[0].Title;
                billingContactId = billContact[0].Id;
                billingLast = billContact[0].LastName;
                billingFirst = billContact[0].FirstName;
                billingEmail = billContact[0].Email;
                billingPhone =  billContact[0].Phone;
                if (billingPhone != null){
                    if (billingPhone.contains(' x')){
                        billingPhoneEdit = billingPhone.substringBefore(' x');
                        billingPhoneExt = billingPhone.substringAfter(' x');
                    } else {
                        billingPhoneEdit = billingPhone;
                        billingPhoneExt = '';
                    }        
                }
                billingStreet = billContact[0].MailingStreet;
                mailingCity = billContact[0].MailingCity;
                mailingState = billContact[0].MailingState;
                mailingzipCode = billContact[0].MailingPostalCode;
                mailingCountry = billContact[0].MailingCountry;
                SelectbillingcontactOptions =  billContact[0].Contact_Same_as_Primary__c;
                SelectContactAddrBillOptions = billContact[0].Address_same_as_Accounts__c;
                
                if(SelectbillingcontactOptions != 'Yes' && 
                    String.isBlank(editAccount.Email_Application_To__c))  EmailApplicableTo = billContact[0].Email;
                
                billingContact = billContact[0].FirstName + ', ' + billContact[0].LastName + ',\n ' + billContact[0].Email + ', ' + billContact[0].Phone;
                
                if(null == billingContact || billingContact  == ''){
                    billingContact = 'There is no billing contact available.';
                }
                
                contactAddress = billContact[0].MailingStreet + ', ' + billContact[0].MailingCity + ',\n ' + billContact[0].MailingState + ', ' + billContact[0].MailingPostalCode+',' +billContact[0].MailingCountry;
                
                if(null == contactAddress || contactAddress == ''){
                    contactAddress = 'There is no billing contact address available.';
                }
            }
            
            ListofAccountPrograms = new list<Program__c>();
            for(Program__c p: [Select Id, Name, Description__c, toLabel(Type__c), Active__c, Activation_Date__c, Expiration_Date__c, Program_Notes_Trimmed__c from Program__c Where Account__c =: accountId ORDER BY Active__c DESC,Name]){
                if(!isFullAccessUser){
                    if(p.Active__c){
                        ListofAccountPrograms.add(p);
                    }
                }else{
                    ListofAccountPrograms.add(p);
                }
            }
            SummeryEditButton = 'RWS_Account_Creation?tab=account&id='+editAccount.Id;
            
            if(accountId != null ) getChildAccounts();

        }

        EmailApplicableToModal = EmailApplicableTo;
    }

    private void getStateCountryLabel() {
        accountStateLabel = '';
        for(SelectOption so : StateOptions) {
            if(so.getValue() == accountState) {
                accountStateLabel = so.getLabel();
                break;
            }

        }

        accountCountryLabel = '';
        for(SelectOption so : CountryOptions) {
            if(so.getValue() == accountCountry) {
                accountCountryLabel = so.getLabel();
                break;
            }

        }

        billingStateLabel = '';
        for(SelectOption so : StateOptions) {
            if(so.getValue() == billingState) {
                billingStateLabel = so.getLabel();
                break;
            }

        }

        billingCountryLabel = '';
        for(SelectOption so : CountryOptions) {
            if(so.getValue() == billingCountry) {
                billingCountryLabel = so.getLabel();
                break;
            }

        }
    }

    public void setParentInvoiceInfo()
    {
        // Added By UsmanAli Jira Task RWCP-1757
        if( !String.isBlank(parentAccountId))
        {
            hasParentAccountAccess = RWS_UtilityClass.getUserRecordAccess(parentAccountId);

            parentAccount = RWS_UtilityClass.getParentAccountInvoiceInfo(parentAccountId);

            System.debug('UAC: parentAccountId ' + parentAccountId + ' selectInvoiceParent ' + selectInvoiceParent + ' selectBillingParent ' + selectBillingParent );

        }
    }
    
    public void getChildAccounts()
    {
        if(childAccounts.size() > 0) childAccounts.clear();

        for(Account ac:  [  SELECT Id, Name,IsPersonAccount, Owning_Store__c, Active__c, IA_Physical_Location_City__c, IA_Physical_Location_State_Province__c, (select Id, Name, Email, MailingStreet,MailingCity, MailingCountry, MailingState, tdc_tvte__Result_text__c from Contacts WHERE BPR_Role__c = 'Primary Contact' ) 
                            FROM Account WHERE ParentId = :accountId ])
        {
            AccountWrapper aw = new AccountWrapper();
            aw.ac = ac ;
            if(ac.Contacts.size() > 0 )
            {
                aw.con = ac.Contacts[0];
            }
            else
            {
                aw.con = new Contact();
            }
            childAccounts.add(aw);
            System.debug('UAC: aw ' + aw );
        }   
    }

    public class AccountWrapper
    {
        public AccountWrapper(){}

        public Account ac {get; set;}
        public Contact con{get; set; }
    }
    
    public void deleteChildAccount(Id childAccount)
    {
        System.debug('UAC: childAccount ' + childAccount );
        try{
            delete [SELECT Id FROM Account WHERE ID = :deleteChildAccountId ];
        }
        catch(DmlException de){}
    }
    
    
    // Check duplication of Account else create Account
    public pagereference createAccountContact(){
        System.debug('*********Create Account Contact method');
        //Check duplication of Account based on Account Details 
        pagereference pr;
        Boolean ValidUser = isValidUser(Userinfo.getProfileId());
        if(ValidUser){
            String recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
            
            accList = [ SELECT Id,Name,IsPersonAccount,IA_Physical_Location_Address_Line_1__c,
                    IA_Physical_Location_City__c,IA_Physical_Location_ZIP_Postal_Code__c 
                        FROM Account 
                        WHERE ((Name = :accountName OR ( (IA_Physical_Location_Address_Line_1__c = :accountLine1 And IA_Physical_Location_Address_Line_1__c != null) AND 
                                                    ((IA_Physical_Location_City__c = :accountCity AND IA_Physical_Location_City__c != null)  
                                                                OR (IA_Physical_Location_ZIP_Postal_Code__c = :accountZipCode AND IA_Physical_Location_ZIP_Postal_Code__c != null)) )) 
                                                    AND RecordTypeid =: recordType AND ParentId = null) 
                        LIMIT 1];
            if(accList.size() > 0 && EditMode == false && String.isBlank(parentAccountId)){
                duplicationMessage = 'We detected an account already established for : ' + accountName;
                redirectToProgram = 'RWS_Account_Creation?tab=account&id='+accList[0].Id + '&rts=1';
                //throw error message for duplication account 
            }
            else{             
                pr = insertAccount();  // Method to insert Account 
                if(null != pr){
                    pr.setRedirect(true);
                    return pr;
                }
            }
        }

        return null;
    }

    public Pagereference insertAccount(){
    system.debug('Begin RWS_AccountSetupController.insertAccount ************');    
    system.debug(accountzipCode + 'UAC : accountzipCode'); 
    system.debug('SelectTaxExempt is set to... ' + SelectTaxExempt);

        Boolean Error = false;
        if(accountName == '' || null == accountName){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Account name.'));
            Error = True;
        }
        
        if(accountLine1 == '' || null == accountLine1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Street address.'));
            Error = True;
        }
        
        if(accountCity == '' || null == accountCity){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter City.'));
            Error = True;
        }
        
       if(accountState == '' || null == accountState){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter State.'));
            Error = True;
        } 
        
        if(accountCountry == '' || null == accountCountry){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Country.'));
            Error = True;
        }
        
        if(accountzipCode == '' || null == accountzipCode){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Zip code.'));
            Error = True;
        }
        system.debug(accountzipCode + 'UAC2 : accountzipCode');    
         if(accountPhoneEdit == '' || null == accountPhoneEdit){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Phone number.'));
            Error = True;
        } else {
            accountPhone = accountPhoneEdit;
        }
        
        if(accountPhoneExt != '' || null != accountPhoneExt){
            accountPhone += ' x'+accountPhoneExt;            
        }
        
        if(SelectTaxExempt == 'Yes' &&  (null == TaxCertificateNumber || TaxCertificateNumber == '')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Certificate number.'));
            Error = True;
        }
        
        if(SelectTaxExempt == 'Yes' &&  null == TaxExpiryDate){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Expiration date.'));
            Error = True;
        }
        
        if(SelectTaxExempt == 'Yes' && (selecttaxName  == '' || null == selecttaxName || '--Select--' == selecttaxName || '--Enter State--' == selecttaxName)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select a tax exemption reason.'));
            Error = True;
        }
        
        
        if(Error == false){        
            System.debug('-=-=-=-= This is just to create account.-=-=-=-='+accountId);
            createAccount = new Account();
            if(Null != accountId)
                createAccount.Id = accountId;
            createAccount.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
            createAccount.Name = accountName;
            createAccount.IA_Physical_Location_Address_Line_1__c =  accountLine1;
            
            if (accountLine2 != null ){
                createAccount.IA_Physical_Location_Address_Line_2__c =  accountLine2;
            }
            if (accountLine3 != null ){
                createAccount.IA_Physical_Location_Address_Line_3__c =  accountLine3;
            }
            
            createAccount.IA_Physical_Location_City__c = accountCity;
            createAccount.IA_Physical_Location_State_Province__c = accountState; //Jas-temp change
            createAccount.IA_Physical_Location_ZIP_Postal_Code__c = accountzipCode;
            createAccount.IA_Physical_Location_Country__c = accountCountry;  //Jas-temp
            
            if (selectBillingAddressOption == 'Different'){
                billingSame = false;
                createAccount.RWfB_Billing_Address_Line_1__c = billingLine1;
                if (billingLine2 != null){
                    createAccount.RWfB_Billing_Address_Line_2__c = billingLine2;
                }

                if(billingLine3 != null){                    
                    createAccount.RWfB_Billing_Address_Line_3__c = billingLine3;
                }
                createAccount.RWfB_Billing_Address_City__c = billingCity;
                createAccount.RWfB_Billing_Address_State_Province__c = billingState;
                createAccount.RWfB_Billing_Address_ZIP_Postal_Code__c = billingZipCode;
                createAccount.RWfB_Billing_Address_Country__c = billingCountry;
            } else {
                billingSame = true;
            }
            
            createAccount.RWfB_same_as_Physical_Address__c = billingSame;

            getStateCountryLabel();
            
            
            createAccount.Phone = accountPhone;
            createAccount.Active__c = isActive;
            createAccount.company_Type__c = selectAccountType;
            createAccount.Account_Category__c = 'Local';
            
            
            if(selectTaxIdType != '--None--')
                createAccount.Tax_Id_Type__c= selectTaxIdType;
            
            createAccount.Tax_Exempt__c = SelectTaxExempt;
           
            
            
            if(SelectTaxExempt == 'Yes'){                
                createAccount.Tax_Exemption_Reason__c = selecttaxName ;   
                createAccount.Tax_Exempt_Expiration_Date__c=TaxExpiryDate;
                createAccount.IA_Tax_Exempt_Certificate_Nbr__c= TaxCertificateNumber;
            }
            else{
                createAccount.IA_Tax_Exempt_Certificate_Nbr__c='';
                createAccount.Tax_Exemption_Reason__c = null;
                createAccount.Tax_Exempt_Expiration_Date__c=null;
            }
            
            
            try{
                System.debug('AccountName****'+accountName);
                upsert createAccount;
                
                if(null == accountId || accountId  == ''){
                    accountId = createAccount.id; 
                    parentId = createAccount.id; 
                }
                
                System.debug('-=-=-=: accountId'+accountId);
                /*System.debug('AttachCertificate****'+AttachCertificate);
                
                if(null != AttachCertificate){
                    AttachCertificate.ParentId = createAccount.id;
                    Insert AttachCertificate;
                }*/
                
                ReloadIfNoAttachment = 'AccountSummary?tab=account&id='+createAccount.id;
                /*
                pagereference pr = new pagereference('RWS_Account_Creation?tab=account&id='+createAccount.id);
                pr.setRedirect(true);
                return pr;// add sam
                */
            }
            catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    System.debug(e.getDmlMessage(i)); 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getDmlMessage(i)));
                }
            } 
        }
        else{
            return null;
        }
        
        system.debug('End RWS_AccountSetupController.insertAccount ************');    
        return null;
        
    }
    
    public Pagereference saveeditAccount(){
        System.debug('saveeditAccount*********'+accountId);
        System.debug('UAC: AttachCertificate ' + AttachCertificate );
        PageReference pr = null;
        //PageReference pr;
        createAccount = new Account();
        if(accountId != null) createAccount.Id = accountId;
    
        createAccount.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
        createAccount.company_Type__c = selectAccountType;
        createAccount.Name = accountName;
        createAccount.IA_Physical_Location_Address_Line_1__c =  accountLine1;
        
        if (accountLine2 != null){
            createAccount.IA_Physical_Location_Address_Line_2__c =  accountLine2;
        }
        if (accountLine3 != null){
            createAccount.IA_Physical_Location_Address_Line_3__c =  accountLine3;
        }
        
        createAccount.IA_Physical_Location_City__c = accountCity;
        createAccount.IA_Physical_Location_State_Province__c = accountState; //Jas-temp change
        createAccount.IA_Physical_Location_ZIP_Postal_Code__c = accountzipCode;
        createAccount.IA_Physical_Location_Country__c = accountCountry; //Jas-temp chgange
        
        if (selectBillingAddressOption == 'Different'){
            billingSame = false;
            createAccount.RWfB_Billing_Address_Line_1__c = billingLine1;
            if (billingLine2 != null){
                createAccount.RWfB_Billing_Address_Line_2__c = billingLine2;
            }
            if (billingLine3 != null){                    
                createAccount.RWfB_Billing_Address_Line_3__c = billingLine3;
            }
            createAccount.RWfB_Billing_Address_City__c = billingCity;
            createAccount.RWfB_Billing_Address_State_Province__c = billingState;
            createAccount.RWfB_Billing_Address_ZIP_Postal_Code__c = billingZipCode;
            createAccount.RWfB_Billing_Address_Country__c = billingCountry;
        } else {
            billingSame = true;
        }

        createAccount.RWfB_same_as_Physical_Address__c = billingSame;

        getStateCountryLabel();

        createAccount.IA_Federal_ID_Nbr__c = federalIdNumber;
        if(accountPhoneExt != '' || null != accountPhoneExt){
            accountPhone = accountPhoneEdit+' x'+accountPhoneExt;            
        } else {
            accountPhone = accountPhoneEdit;
        }
        
        createAccount.Phone = accountPhone;
        createAccount.Organization_Type__c = selectAccountCategory;
        createAccount.Active__c = isActive;
        if(selectTaxIdType != '--None--')
            createAccount.Tax_Id_Type__c= selectTaxIdType;
        createAccount.Tax_Id_Number__c = TaxNumber;
        //createAccount.Tax_Id_Number__c = SelectTaxExempt;
        System.debug('TaxExpiryDate**'+TaxExpiryDate);
        createAccount.Tax_Exempt_Expiration_Date__c=TaxExpiryDate;
        //createAccount.Open_Date__c= openDate;
        createAccount.Tax_Exempt__c = SelectTaxExempt;
        if(SelectTaxExempt == 'Yes'){
            if(SelectTaxExempt == 'Yes' && null != selecttaxName && selecttaxName != '--Select--' && selecttaxName != '--Enter State--'){
                createAccount.Tax_Exemption_Reason__c = selecttaxName ;
            }   
            else if(SelectTaxExempt == 'No'){
                createAccount.Tax_Exemption_Reason__c = null;
            }
            createAccount.IA_Tax_Exempt_Certificate_Nbr__c= TaxCertificateNumber;
        }
        else{
            createAccount.Tax_Exemption_Reason__c = null;
        }
        try{
            System.debug('AccountName****'+accountName);
            upsert createAccount;
            System.debug('UAC: createAccount ' + createAccount );
        }
        catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug('Exception: ' + e.getDmlMessage(i)); 

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
            }
        }   

        //When record is new then refresh page 
        //if( createAccount.Id != null) pr = new Pagereference(Label.Community_Name + 'AccountSummary?tab=account&id=' + createAccount.Id );

        initAccount();
        return null ;
    }
    
    
       
    
    public pagereference createContact(){
        System.debug('Begin RWS_AccountSetupController.CreateContact *******' );
        try{
            primaryContactError = false;
            System.debug('Inside Contact****'+contactFirstName+'-=-=ContactEditOrView :'+ContactEditOrView +'SelectedRoles **'+SelectedRoles+'contactId***'+contactId);
            
            String accountid = Apexpages.currentpage().getparameters().get('id');//add sam

            if( String.isBlank(accountid))
            {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please fill account information first to create contact '));
                return null ;
            }
            System.debug('UAC: accountId ' + accountId );

            createAccount = [Select id, Name,IsPersonAccount from Account where id =: accountId];
            
            if(createAccount.id!=Null){
                //Contact createContact = new Contact();
                if((Null != contactId || contactId != '') && ContactEditOrView == true){
                    System.debug('Inside Contact****'+contactId+'-=-=ContactEditOrView '+ContactEditOrView);
                    createContact.Id = contactId;
                }
                createContact.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
                createContact.AccountId = createAccount.id;
                createContact.FirstName = contactFirstName;
                createContact.LastName = contactLastName;
                createContact.Email = contactEmail;
                createContact.Manually_Verified_Email__c = ManuallyVerifiedEmail;
                
                if(contactPhoneNoExt != '' || null != contactPhoneNoExt){
                    contactPhoneNo = contactPhoneNoEdit+' x'+contactPhoneNoExt;            
                } else {
                    contactPhoneNo = contactPhoneNoEdit;
                }
                if(!Test.isRunningTest()){
                    createContact.Phone = contactPhoneNo;
                }
                createContact.Title = contactTitle;
                createContact.Role__c = string.join(SelectedRoles,';');
                createContact.RWBAA_User_Type__c = selectedUserType;


                //new requirement: Only need to create ONE primary contact in the contact section.
                //billing contact or switching contact identifier will be handled in credit section of page
                Integer primaryContactCount = [Select count() from Contact where AccountId =: accountid AND Contact_Identifier__c IN ('Primary & Billing', 'Primary')];
                System.debug('UAC: primaryContactCount ' + primaryContactCount );
                if(primaryContactCount == 0){
                    //set member variable saying error occurred
                    createContact.Contact_Identifier__c = 'Primary';
                    System.debug('Set Contact identifier to Primary ');
                }


                createContact.Address_same_as_Accounts__c = SelectContactAddressOptions;


                /*if(SelectContactAddressOptions == 'Same as Physical'){
                    createContact.MailingStreet = accountLine1;
                    createContact.MailingCity = accountCity;
                    createContact.MailingState = accountStateLabel;
                    createContact.MailingPostalCode = accountzipCode;
                    createContact.MailingCountry = accountCountryLabel;
                } 
                else*/

                if(SelectContactAddressOptions == 'Different') {
                    createContact.MailingStreet = contactStreet;
                    createContact.MailingCity = contactCity;
                    createContact.MailingState = contactState;
                    createContact.MailingPostalCode = contactZipCode;
                    createContact.MailingCountry = contactCountry;
                }
                
                
                System.debug('before insert createContact -=-=-= '+createContact);
                upsert createContact;
                contactId = createContact.Id ;

                if(EmailApplicableTo == null || EmailApplicableTo == ''){
                    EmailApplicableTo = createContact.Email;
                }
                //SameAsPrimaryContactInfo 
                //for(String role: SelectedRoles){
                    if(createContact.Contact_Identifier__c == 'Primary'){
                        SameAsPrimaryContactInfo = createContact.FirstName + ' ' + createContact.LastName + ',\n ' + createContact.Email + ', ' + createContact.Phone + ', ' + createContact.Title;
                        EmailApplicableTo = createContact.Email;
                    }
                //}
                //createContact = new Contact();
                //createContact.id=null;
                contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Role__c,Title,Contact_Identifier__c, RWBAA_User_Type__c, MSTS_User__c, tdc_tvte__Result_text__c from Contact where AccountId = :accountid 
                                // AND BPR_Role__c != 'Billing Contact' - UA: removed where clause
                                ];
                                
                System.debug('First Contact Email: '+contactList[0].Email);
                System.debug('First Contact Phone: '+contactList[0].Phone);
                System.debug('First Contact Identifier: '+contactList[0].Contact_Identifier__c);
                System.debug('First Contact Name: '+contactList[0].Name);                
                System.debug('after insert Contact list -=-=-=-= '+contactList);
                //resetContactFields();
                
            }
        } 
        catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
            }            
        } 
        System.debug('End RWS_AccountSetupController.CreateContact *******' );
        
        SelectContactAddressOptions = 'Same as Physical';
        viewContact();
        return null;
    }
        
    // Method to check whether user is a valid user or no.
    public Boolean isValidUser(id loggedUserProfileId){
        
        string ProfileName = [Select Id,Name from Profile Where ID =: loggedUserProfileId].Name;
        if(ProfileName == 'System Administrator' || ProfileName == 'Partner Community User' || ProfileName == 'RWS Business Partner Community'){
            return true;
        }
        else{
            return false;
        }
    }   
    
    
    public void getAllPickListValues(){
        
        ContactPref = RWS_UtilityClass.getcontactPreference();
        ContactRoles = RWS_UtilityClass.getcontactRoles();
        OrgType = RWS_UtilityClass.getorganizationTypes();
        AccountCategory = RWS_UtilityClass.getaccountCategorys();
        AccountType = RWS_UtilityClass.getaccountTypes();
        serviceMethods = RWS_UtilityClass.getaccountserviceMethods();
        shoemobileFrequency = RWS_UtilityClass.getshoemobileceFrequency();
        TaxIdType = RWS_UtilityClass.getTaxIdType();
        TaxExempt = RWS_UtilityClass.getTaxExempts();
        creditStatus = RWS_UtilityClass.getcreditStatus();
        billingFrequency = RWS_UtilityClass.getBillingFrequency();
        paymentTerms = RWS_UtilityClass.getPaymentTermsFiltered();
        invoiceDeliveryMethod = RWS_UtilityClass.getInvoiceDeliveryMethod();
        preferredPaymentMethod = RWS_UtilityClass.getPreferredPaymentMethod();
        userTypes = RWS_UtilityClass.getContactUserType();
        IndustrialAccountOptions = RWS_UtilityClass.getIndustrialAccountOptions();
        NationalAccountOptions = RWS_UtilityClass.getNationalAccountOptions();
        CityExemptOptions = RWS_UtilityClass.getCityExemptOptions();
        StateExemptOptions = RWS_UtilityClass.getStateExemptOptions();
        CountyExemptOptions = RWS_UtilityClass.getCountyExemptOptions();
        CountryExemptOptions = RWS_UtilityClass.getCountryExemptOptions(); 
        ContactAddressOptions = RWS_UtilityClass.getAddressPreference();
        contactAddressBillingOptions = RWS_UtilityClass.getAddressPreference();
        billingcontactOptions = RWS_UtilityClass.getcontactAddressPrimary();
        invoiceOptions = RWS_UtilityClass.getrequiresInvoicing();
        ReqCreditLimitOptions = RWS_UtilityClass.getRequestedCreditLimit(); 

        StateOptions = RWS_UtilityClass.getStates(); 
        if( stateOptions != null && stateOptions.size() > 0 ) accountState = stateOptions[0].getValue();
        CountryOptions = RWS_UtilityClass.getCountries(); 

        ContactStateOptions = RWS_UtilityClass.getContactStates(); 
        ContactCountryOptions = RWS_UtilityClass.getContactCountries();
        BillingCountryOptions = RWS_UtilityClass.getContactCountries();
        attachTypeOptions = RWS_UtilityClass.getAttachType();
    }
    
    
    public pagereference RedirectToNewProgram(){
        
        System.debug('RedirectToNewProgram : '+ accountId);
        
        if(null != accountId || accountId != ''){
            System.debug('-=-=-= 740 -=-=-');
            System.debug('-=-=-=- This is redirect link call'+accountId);
            //pagereference pr = new pagereference('RWS_Account_Creation');
            pagereference pr = new pagereference(Label.Community_Name + 'RWS_NewProgramSetup?tab=account&id='+accountId);
            pr.setRedirect(true);
            return pr;
        }
        
        return null;
    }

    
    //CREDIT INFORMATION
    public pagereference updateCreditInfo(){
        sendCreditErrorMsg = '';   

        System.debug('1276: ' + EmailApplicableToModal);
        System.debug('selectBillingAddressOption: ' + selectBillingAddressOption);
        System.debug('billingLine1: ' + billingLine1);
        System.debug('billingLine2: ' + billingLine2);
        System.debug('billingLine3: ' + billingLine3);

        Account createAccount = new Account(Id = accountId);

        if (selectBillingAddressOption == 'Different'){
            billingSame = false;
            createAccount.RWfB_Billing_Address_Line_1__c = billingLine1;
            if (!String.isBlank(billingLine3)){
                createAccount.RWfB_Billing_Address_Line_2__c = billingLine2;
            }

            if (!String.isBlank(billingLine3)){                    
                createAccount.RWfB_Billing_Address_Line_3__c = billingLine3;
            }
            createAccount.RWfB_Billing_Address_City__c = billingCity;
            createAccount.RWfB_Billing_Address_State_Province__c = billingState;
            createAccount.RWfB_Billing_Address_ZIP_Postal_Code__c = billingZipCode;
            createAccount.RWfB_Billing_Address_Country__c = billingCountry;
        } else {
            billingSame = true;
        }

        createAccount.RWfB_same_as_Physical_Address__c = billingSame;
        
        try {
            update createAccount;
        } catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here               
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
            }
        } 
        
        
             
        System.debug(SelectinvoiceOptions + 'updateCreditInfo*******'+accountId+' requestedCreditLimit '+ SelectiReqCreditLimitOptions +'****creditappFlag'+creditappFlag);
        Account creditAccount = new Account();

        if(Null != accountId || accountId !=''){
            creditAccount.Id = accountId;
            
            if(SelectinvoiceOptions == 'Yes'){
            List<Contact> primaryContact = [select id,name, Email, tdc_tvte__Result_text__c from Contact where Contact_Identifier__c IN ('Primary & Billing', 'Primary') AND AccountId =:accountId limit 1];
            
            Contact billingContact = new Contact(); 
            //Billing Contact Info same as Primary Contact Condition
            System.debug('#!#!#!#!#!#!#!#!#!#!#!#!# Update Credit Info. Billing contact same as primary set to ' + SelectbillingcontactOptions);
            
            if(SelectbillingcontactOptions == 'Yes' ){//Same as Primary
                
                if(!primaryContact.isEmpty()) {
                    primaryContact[0].Contact_Identifier__c = 'Primary & Billing';
                    primaryContact[0].Contact_Same_as_Primary__c = SelectbillingcontactOptions; //why do we need this?
                    //EmailApplicableTo = primaryContact[0].Email;
                    /*if(SelectContactAddrBillOptions == 'Same as Account'){
                        primaryContact[0].MailingStreet = accountStreet;
                        primaryContact[0].MailingCity = accountCity;
                        primaryContact[0].MailingState = accountState;
                        primaryContact[0].MailingPostalCode = accountzipCode;
                        primaryContact[0].MailingCountry = accountCountry;
                    }
                    else{
                        primaryContact[0].MailingStreet = billingStreet;
                        primaryContact[0].MailingCity = mailingCity;
                        primaryContact[0].MailingState = mailingState;
                        primaryContact[0].MailingPostalCode = mailingzipCode;
                        primaryContact[0].MailingCountry = billingCountry;
                    }*/
                    try{
                        Upsert primaryContact[0];

                        /* No idea what this code is even supposed to do. I don't think we need it
                        List<Contact> billContList = [Select Id, Name from Contact where AccountId =:editAccount.id 
                        AND (BPR_Role__c = 'Billing Contact' OR Contact_Identifier__c = 'Billing') limit 1];

                        if(!billContList.isEmpty()) {
                            billContList[0].Contact_Same_as_Primary__c = SelectbillingcontactOptions;

                            update billContList;
                        }
                        */
                    }
                    catch(System.DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            // Process exception here
                            System.debug(e.getDmlMessage(i)); 
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                        }
                    } 
                }
            }
            else{
                                  
                    billingContact.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
                    billingContact.Contact_Identifier__c = 'Billing';
                    billingContact.AccountId = accountId;
                    //billingContact.BPR_Role__c = 'Billing Contact';
                    billingContact.LastName = billingLast;
                    billingContact.FirstName = billingFirst;
                    billingContact.Email = billingEmail;
                    if(billingPhoneExt != '' || null != billingPhoneExt){
                        billingPhone = billingPhoneEdit+' x'+billingPhoneExt;            
                    } else {
                        billingPhone = billingPhoneEdit;
                    }
                    billingContact.Phone = billingPhone;
                    //EmailApplicableTo = billingEmail;
                    billingContact.Role__c = selectedBillingRole == null ? '' : string.join(selectedBillingRole,';');
                    billingContact.Title = billingTitle ;
                
                
                    System.debug('Country Value Billing Contact: '+mailingCountry);
                    System.debug('State Value Account: '+accountStateLabel);
                    System.debug('Country Value Account: '+accountCountryLabel);

                if(SelectContactAddrBillOptions != 'Same as Physical'){ //DIFFERENT first?    
                    billingContact.MailingStreet = billingStreet;
                    billingContact.MailingCity = mailingCity;
                    billingContact.MailingState = mailingState;
                    billingContact.MailingPostalCode = mailingzipCode;
                    billingContact.MailingCountry = mailingCountry;
                    billingContact.Contact_Same_as_Primary__c = SelectbillingcontactOptions;
                    billingContact.Address_same_as_Accounts__c = SelectContactAddrBillOptions;

                }
                else{
                    billingContact.MailingStreet = accountLine1;
                    billingContact.MailingCity = accountCity;
                    billingContact.MailingState = accountStateLabel;
                    billingContact.MailingPostalCode = accountzipCode;
                    billingContact.MailingCountry = accountCountryLabel;
                    billingContact.Contact_Same_as_Primary__c = SelectbillingcontactOptions;
                    billingContact.Address_same_as_Accounts__c = SelectContactAddrBillOptions;
                }

                List<Contact> billContList = [Select Id, Name, Contact_Identifier__c, tdc_tvte__Result_text__c from Contact where AccountId =:editAccount.id AND Contact_Identifier__c IN ('Primary & Billing', 'Billing') limit 1];

                if(!billContList.isEmpty()) {
                    String old = billContList[0].Contact_Identifier__c;
                    if(billContList[0].Contact_Identifier__c == 'Primary & Billing'){
                        billContList[0].Contact_Identifier__c = 'Primary';  
                    }
                    else if(billContList[0].Contact_Identifier__c == 'Billing'){
                        billContList[0].Contact_Identifier__c = null;  
                    }
                    System.debug('Updating contact identifier from ' + old + ' to the new value of ' + billContList[0].Contact_Identifier__c);
                    try{
                        upsert  billContList[0]; 
                    }
                    catch(System.DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            // Process exception here
                            System.debug('Error occurred trying to update the contact identifier ' + e.getDmlMessage(i)); 
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                        }
                    } 

                }
            
                //if(null != billingContactId)
                   //billingContact.Id = billingContactId;
                    
                try{
                    insert billingContact;
                }
                catch(System.DmlException e){
                    for (Integer i = 0; i < e.getNumDml(); i++) {
                        // Process exception here
                        System.debug('Error occurred trying to create a new billing contact ' + e.getDmlMessage(i)); 
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                    }
                } 
            }
            
                        
            //creditAccount.Id = accountId;
            
            System.debug('-=-=selectCreditStatus '+selectCreditStatus+
                         '\n-=-=-'+selectbillingFrequency+
                         '\n-=-=-selectpaymentTerms '+selectpaymentTerms+
                         '\n-=-=-selectinvoiceDelivery '+selectinvoiceDelivery);

            
            creditAccount.Requested_Credit_Limi__c = SelectiReqCreditLimitOptions;
            if(selectCreditStatus!= '--None--')
                creditAccount.Credit_Status__c = selectCreditStatus;
            creditAccount.Credit_Limit__C = creditLimit;
            creditAccount.Legal_Name__c = legalName;
            if(selectbillingFrequency!= '--None--')
                creditAccount.Billing_Frequency__c = selectbillingFrequency;
            if(selectpaymentTerms!= '--None--')
                creditAccount.BPC_Payment_Terms__c = selectpaymentTerms;
            if(selectinvoiceDelivery!= '--None--')
                creditAccount.Invoice_Delivery_Method__c = selectinvoiceDelivery;
            if(selectpreferredPayment!= '--None--')
                creditAccount.Preferred_Payment_Method__c = selectpreferredPayment;
              //only set invoice parent if there really is a parent id
            if(!String.isBlank(parentAccountId)){
                if(SelectInvoiceParent == 'No'){
                    creditAccount.Invoice_Parent_Account__c = 'No';
                }else if(selectBillingParent == 'Centralized'){
                    creditAccount.Invoice_Parent_Account__c = 'Centralized';
                }else if(selectBillingParent == 'Decentralized'){
                    creditAccount.Invoice_Parent_Account__c = 'Decentralized';
                } 
            }
            creditAccount.RWBAA_Standard_Application__c = selectStandardApplication;

            System.debug('1463: ' + EmailApplicableTo + ' #!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#! Invoice Parent Account set to ' + creditAccount.Invoice_Parent_Account__c );               

            try{
                creditAccount.Email_Application_To__c = EmailApplicableTo;

                if(!String.isBlank(EmailApplicableToModal)){
                    creditAccount.Email_Application_To__c = EmailApplicableToModal;
                }
                
                if (creditappFlag)
                    creditAccount.Credit_Status__c = 'Submitted';

                creditAccount.Requires_Invoicing__c = SelectinvoiceOptions;
                creditAccount.Send_Application__c = creditappFlag;
                creditAccount.IA_Federal_ID_Nbr__c = federalIdNumber;                             
                creditAccount.Invoice_Atributes_Required__c = selectInvoiceAttributes == null ? '' : string.join(selectInvoiceAttributes,';');
                
                //updated by Joey: RWCP-3181
                //update the Primary Contact Email (Primary_Contact_Email_c) with the Email Application To (Email_Application_To_c) field value. 
                creditAccount.Primary_Contact_Email__c = creditAccount.Email_Application_To__c;


                if(EmailApplicableTo == '' || EmailApplicableTo == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter email application to.'));
                    
                }
                if(contactList == null || contactList.size() < 1){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Without a complete Billing Contact you cannot send a Credit Application for this Account. Billing Contacts must have a complete Mailing Address and be identified with the Contact Identifier Field.'));
                }
                if(creditappFlag == true && (accountId == null || editAccount == null)){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'In order to submit a Credit Application. All Address Fields, Payment Fields and Credit Fields must be filled out.'));
                }
                if(ApexPages.hasMessages()){
                    System.debug('*** ApexPages.msgs = ' + ApexPages.getMessages());

                    return null;
                }


                System.debug(creditAccount.Requested_Credit_Limi__c + ' - ' + selectInvoiceParent + ' - ' + parentAccount);
                if( selectInvoiceParent == 'Yes' && !String.isBlank(parentAccountId)) //when invoicing the parent, need to copy values down from the parent account
                {   
                    creditAccount.BPC_Payment_Terms__c = parentAccount.BPC_Payment_Terms__c;
                    creditAccount.Legal_Name__c = parentAccount.Legal_Name__c;
                    creditAccount.Billing_Frequency__c = parentAccount.Billing_Frequency__c;
                    creditAccount.Invoice_Atributes_Required__c = parentAccount.Invoice_Atributes_Required__c;
                    creditAccount.Invoice_Delivery_Method__c = parentAccount.Invoice_Delivery_Method__c;
                    creditAccount.IA_Federal_ID_Nbr__c = parentAccount.IA_Federal_ID_Nbr__c;
                    creditAccount.Requested_Credit_Limi__c = parentAccount.Requested_Credit_Limi__c;
                    if(selectBillingParent == 'Centralized'){
                        creditAccount.Email_Application_To__c = parentAccount.Email_Application_To__c;
                    }
                }
                
                System.debug(creditAccount.Requested_Credit_Limi__c + ' - ' + creditAccount.Requires_Invoicing__c + ' - ' + creditAccount.Id);

                RWS_AccountTrigger_Handler.RUN_PUBLISH_RECORDS_ONCE = true;
                upsert creditAccount;

                if(creditappFlag){
                    SendCreditApplicationPopUp = 'Show pop up';
                                    isNeedToLock = true;
                } else{
                    SendCreditApplicationPopUp  = '';
                }
            }
            catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    System.debug('Find Me Now: '+e.getDmlMessage(i)); 
                    if (e.getDmlMessage(i).contains('The Parent Account cannot be invoiced')){
                        sendCreditErrorMsg = 'The Parent Account cannot be invoiced. Parent account credit status must be active or approved.';
                    } else {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));              
                    }
                }
            } 
            
            
           
            
        } 
        else{
            
            creditAccount.Requires_Invoicing__c = SelectinvoiceOptions;
            try{
                upsert creditAccount;
                
                if(creditappFlag){
                    SendCreditApplicationPopUp = 'Show pop up';
                }
                else{
                    SendCreditApplicationPopUp  = '';
                }
            }
            catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    System.debug(e.getDmlMessage(i));      
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));                    
                }
               
            }
           
        }  
       }

       initAccount();

       return null;
        
    }
    
    //Get Tax Exemption Reason based on Account State 
    public void getStateTaxExempt(){  
        System.debug('UAC: accountState ' + accountState );

        taxsearchresultList = new List<Tax_Exemption_Reason__c>();

        String soql = 'select id, Name,Applicable_To__c from Tax_Exemption_Reason__c Where Active__c = true AND ( Applicable_To__c = \'All State/Provinces\'';
        if(accountState != '' && accountState != null)
            soql = soql +  ' OR Applicable_To__c =: accountState';
        soql = soql + ') ';
        soql = soql + ' limit 100';
        System.debug(soql);
        taxsearchresultList = database.query(soql); 
        System.debug('****************'+taxsearchresultList+ '***'+accountState);
        exemptionreasonOption =  new List<SelectOption>();
        exemptionreasonOption.add(new SelectOption('--Select--','--Select--'));
        for(Tax_Exemption_Reason__c taxReason : taxsearchresultList){
            exemptionreasonOption.add(new SelectOption(taxReason.id,taxReason.Name));
        }
    }
    
    public void AssignTaxExempt(){
        
        System.debug('**********selecttaxName :'+selecttaxName);
        Tax_Exemption_Reason__c ExemptReasons = new Tax_Exemption_Reason__c();
        if(null != selecttaxName && selecttaxName != '--Select--' && selecttaxName != '--Enter State--')
            ExemptReasons = [Select id, Name,
                             Industrial_Account_Allowed__c,
                             National_Account_Allowed__c,
                             City_Exempt__c,
                             State_Exempt__c,
                             County_Exempt__c,
                             Country_Exempt__c
                             From Tax_Exemption_Reason__c 
                             Where id =: selecttaxName];
        
        if(ExemptReasons.Industrial_Account_Allowed__c == 'Yes'){
            
            industrialAccount = 'Allowed';
        }
        else if(ExemptReasons.Industrial_Account_Allowed__c == 'No'){
            
            industrialAccount = 'NotAllowed';
        }
        
        if(ExemptReasons.National_Account_Allowed__c== 'Yes'){
            
            nationalAccount= 'Allowed';
        }
        else if(ExemptReasons.National_Account_Allowed__c== 'No'){
            
            nationalAccount= 'Not Allowed';
        }
        
        if(ExemptReasons.City_Exempt__c== 'Yes'){
            cityExempt = 'Exempt';
        }
        else if(ExemptReasons.City_Exempt__c== 'No'){
            cityExempt = 'NotExempt';
        }
        
        if(ExemptReasons.State_Exempt__c== 'Yes'){
            stateExempt = 'Exempt';
        }    
        else if(ExemptReasons.State_Exempt__c== 'No'){
            stateExempt= 'NotExempt';
        }
        
        if(ExemptReasons.County_Exempt__c== 'Yes'){
            countyExempt= 'Exempt';
        }
        else if(ExemptReasons.County_Exempt__c== 'No'){
            countyExempt= 'NotExempt';
        }
        
        if(ExemptReasons.Country_Exempt__c== 'Yes'){
            countryExempt= 'Exempt';
        }
        else if(ExemptReasons.Country_Exempt__c== 'No'){
            countryExempt= 'NotExempt';
        }
        
        System.debug('********industrialAccount :'+industrialAccount);
    }
    
    public void deleteContact(){
        try{
            con = [Select Id,Name from Contact where id=:deletedContactId limit 1];
            delete con;
            
            contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Role__c,Title,Contact_Identifier__c from Contact where AccountId =:editAccount.id AND BPR_Role__c != 'Billing Contact'];
        }
        catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
            }
        } 
    }
    
    public pagereference viewContact(){
        System.debug('-=-=View contact method: ');
        try{            
            createContact  = [Select Id,
                              Name, 
                              FirstName, 
                              LastName, 
                              Email, 
                              Phone, 
                              BPR_Role__c,
                              Role__c,
                              Title,
                              Address_same_as_Accounts__c,
                              //mailingAddress,
                              MailingStreet,
                              MailingCity ,
                              MailingState ,
                              MailingPostalCode ,
                              MailingCountry,
                              Contact_Identifier__c,
                              RWBAA_User_Type__c,
                              MSTS_User__c,Manually_Verified_Email__c
                              from Contact where id=:deletedContactId limit 1];
            contactIdentier = createContact.Contact_Identifier__c;
            contactFirstName = createContact.FirstName;
            contactLastName = createContact.LastName;
            contactEmail = createContact.Email;
            ManuallyVerifiedEmail = createContact.Manually_Verified_Email__c;
            contactPhoneNo = createContact.Phone;
            if (contactPhoneNo != null){
                if (contactPhoneNo.contains(' x')){
                    contactPhoneNoEdit = contactPhoneNo.substringBefore(' x');
                    contactPhoneNoExt = contactPhoneNo.substringAfter(' x');
                } else {
                    contactPhoneNoEdit = contactPhoneNo;
                    contactPhoneNoExt = '';
                }        
            }
            contactTitle = createContact.Title;
            SelectedRoles = String.isNotBlank(createContact.Role__c) ? createContact.Role__c.split('\\;') : null;
            SelectedUserType = createContact.RWBAA_User_Type__c;
            SelectContactAddressOptions = createContact.Address_same_as_Accounts__c;
            contactStreetAddress = createContact.MailingStreet;
            contactCity = createContact.MailingCity;
            contactState = createContact.MailingState;
            contactZipCode = createContact.MailingPostalCode;
            contactCountry = createContact.MailingCountry;
            contactId = createContact.id;
            ContactEditOrView = true;
            contactMSTS = createContact.MSTS_User__c;
            
            
            
            ContactCompleteAddress = contactStreetAddress + ', ' 
                + contactCity + ', ' 
                + contactState + ', ' 
                + contactCountry + ', ' 
                + contactZipCode;
            System.debug('-=-=conntactRecord: '+createContact);
            System.debug('-=-=SelectContactAddressOptions: '+SelectContactAddressOptions);
            
        }
        catch(Exception e){
            
        }
        
        return null;
    }
    
   
    
    public void resetContactFields(){
        ContactEditOrView = false;
        contactFirstName = '';
        contactLastName = '';
        contactEmail = '';
        contactPhoneNo = '';
        contactPhoneNoEdit = '';
        contactPhoneNoExt = '';
        contactTitle = '';
        SelectedRoles = new List<String>();
        selectedUserType = null;
        SelectContactAddressOptions = 'Same as Physical';
        contactStreetAddress = '';
        contactCity = '';
        contactState = '';
        contactZipCode = '';
        contactCountry = '';
        contactId = '';
        ContactCompleteAddress = '';
        createContact = new contact();
        contactIdentier = '';
    }
    
    public class ProgramsWrapper{
        public Boolean Selected {get;set;}
        public Program__C PgmObj {get;set;}
        
        ProgramsWrapper(Program__C Obj){
            Selected = False;
            PgmObj = obj;
        }
    }
    
    
    public PageReference AddProgramToAccount()
    {
        List<Id> programIds = new List<Id>();
        for(ProgramsWrapper obj : listOfProgramWrap) {
            if(obj.Selected == true) programIds.add(obj.PgmObj.Id);
        }

        programSelected =   [SELECT Id, Name, Account__c, Account__r.Name, Owner.Name,
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
              Type__c, 
              Voucher_Distribution__c,
              Processing_Status__c
                             FROM Program__c
                             WHERE Id IN :programIds ];  

        Map<Id, Program__c> oldIdToNewProgramMap = new Map<Id, Program__c>();

        try{
            Id programRecordTypeId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Program', 'Program__c');
            String invoiceAttributesRequired = [SELECT Invoice_Atributes_Required__c FROM Account WHERE Id =: accountId].Invoice_Atributes_Required__c;
            System.debug('****** invoice attributes: '+invoiceAttributesRequired);
            for(Program__c obj: programSelected)
            {
                Program__c clonedProgram = obj.clone(false, true);
                clonedProgram.Account__c = accountId;
                clonedProgram.Invoice_Attributes_Required__c = invoiceAttributesRequired;
                clonedProgram.RecordTypeId = programRecordTypeId;
                clonedProgram.Template__c = false;
                clonedProgram.OwnerId = UserInfo.getUserId();
                clonedProgram.Processing_Status__c = 'Scheduled';

                oldIdToNewProgramMap.put(obj.Id, clonedProgram);
            }

            insert oldIdToNewProgramMap.values();

            System.debug('******oldIdToNewProgramMap: '+oldIdToNewProgramMap.values());


            List<Publish_PriceBook__c> ppbs = [SELECT Name, CurrencyIsoCode, IsActive__c, 
                                       /* Description, */
                                        Program__c, /*Type__c, */
                                        Discount__c/*, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                        Future_Pricebook__c, Effective_Date__c*/ 
                                    FROM Publish_PriceBook__c where Program__c in :oldIdToNewProgramMap.keySet()];

            Map<Id, Publish_PriceBook__c> oldIdToNewPpbMap = new Map<Id, Publish_PriceBook__c>();

            for(Publish_PriceBook__c ppb : ppbs) {
                Program__c newProgram = oldIdToNewProgramMap.get(ppb.Program__c);

                if(newProgram == null) continue;

                Publish_PriceBook__c clonePpb = ppb.clone(false, true);

                clonePpb.Program__c = newProgram.Id;

                oldIdToNewPpbMap.put(ppb.Id, clonePpb);
            }

            insert oldIdToNewPpbMap.values();
            

            Map<Id, List<Filter_Criteria__c>> programIdToFCsMap = new Map<Id, List<Filter_Criteria__c>>();

            for(Filter_Criteria__c fc : [SELECT OwnerId, CurrencyIsoCode, Discount__c, 
                                        Filter_BE_Details__c, Filter_Display__c, 
                                        Filter_Number__c, IA_Feature__c, 
                                        Program__c, Results_Count__c,
                                        Product_Code__c 
                                    FROM Filter_Criteria__c 
                                    where Program__c in :oldIdToNewProgramMap.keySet()] ) {

                Program__c newProgram = oldIdToNewProgramMap.get(fc.Program__c);

                if(newProgram == null) continue;

                List<Filter_Criteria__c> fcs = programIdToFCsMap.get(newProgram.Id);

                if(fcs == null) {
                    fcs = new List<Filter_Criteria__c>();
                    programIdToFCsMap.put(newProgram.Id, fcs);
                }

                fcs.add(fc);
            }
            /*
            Map<Id, List<PricebookEntry>> programIdToPBEsMap = new Map<Id, List<PricebookEntry>>();
            for(PricebookEntry pbe : [select Pricebook2.Program__c, Pricebook2Id, Product2Id, CurrencyIsoCode, 
                                            UnitPrice, IsActive, UseStandardPrice, 
                                            Discount__c, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                            MSRP_Effective_Date__c, MSRP_Expiration_Date__c, 
                                            Fixed_Price__c, Filter_Number__c, Price_Level__c,
                                            ProductCode  
                                        FROM PricebookEntry where Pricebook2Id in :oldIdToNewPbMap.keySet()
                                        AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()]) {*/
            
            Map<Id, List<Publish_PriceBook_Entry__c>> programIdToPPBEsMap = new Map<Id, List<Publish_PriceBook_Entry__c>>();
            for(Publish_PriceBook_Entry__c ppbe : [select Publish_PriceBook__r.Program__c, Publish_PriceBook__c, Product_ID__c, CurrencyIsoCode, 
                                            List_Price__c, Active__c, Discount__c, MSRP_Effective_Date__c, MSRP_Expiration_Date__c, 
                                            Fixed_Price__c, Filter_Number__c, Price_Level__c,
                                            Style_Number__c  
                                        FROM Publish_PriceBook_Entry__c where Publish_PriceBook__c in :oldIdToNewPpbMap.keySet()
                                        AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()]) {

                Program__c newProgram = oldIdToNewProgramMap.get(ppbe.Publish_PriceBook__r.Program__c);

                if(newProgram == null) continue;

                List<Publish_PriceBook_Entry__c> ppbes = programIdToPPBEsMap.get(newProgram.Id);

                if(ppbes == null) {
                    ppbes = new List<Publish_PriceBook_Entry__c>();
                    programIdToPPBEsMap.put(newProgram.Id, ppbes);
                }

                ppbes.add(ppbe);
            }

            List<Program_Scheduler__c> pss = new List<Program_Scheduler__c>();
            List<Filter_Criteria__c> newCriterias = new List<Filter_Criteria__c>();
            for(Program__c newProgram : oldIdToNewProgramMap.values()) {
                List<Publish_PriceBook_Entry__c> ppbes = programIdToPPBEsMap.get(newProgram.Id);

                if(ppbes == null) ppbes = new List<Publish_PriceBook_Entry__c>();

                List<Filter_Criteria__c> fcs = programIdToFCsMap.get(newProgram.Id);

                if(fcs == null) fcs = new List<Filter_Criteria__c>();

                pss.add(RWS_UseTemplate_Util.scheduleProgram(newProgram.Id, fcs, ppbes, false));

                if(RWS_UseTemplate_Util.newCriterias != null) newCriterias.addAll(RWS_UseTemplate_Util.newCriterias);
            }

            if(!newCriterias.isEmpty()) insert newCriterias;

            if(!pss.isEmpty()) insert pss;

        } catch(exception e){}
        
        PageReference pr = new PageReference(Label.Community_Name + 'AccountSummary?tab=account&id=' + accountId);
        pr.setRedirect(true);
        
        return pr;
    }
    
    
    
    public void AccountActivate(){
        //CreditStatus should be Approved/Active
        //There has to be atleast one active program
        Account accObj = [Select ID, Name, Active__c,
                            Credit_Status__c,IsPersonAccount 
                          from Account where id = :accountId limit 1];
                          

        Boolean activeWithCashCarry = false;
        Boolean activeWithoutCashCarry = false;
        
        for(Program__c p : [Select Id, Type__c 
                                from Program__C 
                            where Account__c = :accountId 
                            and Active__c = true]) {
                            
            if(p.Type__c == 'CashandCarry' || p.Type__c == 'SubsidywithPcard') activeWithCashCarry = true;
            if(p.Type__c != 'CashandCarry' && p.Type__c != 'SubsidywithPcard' && !String.isBlank(p.Type__c)) activeWithoutCashCarry = true;
        }
        
        if((accObj.Credit_Status__c == 'Approved/Active' && activeWithoutCashCarry) || activeWithCashCarry ){
            try{
                accObj.Active__c = true;
                update accObj;
                AccountStatus = 'Active';
                isActive = true;
                AccountStatusMessage = accountName +' account is activated';
            }
            catch(Exception e){
                AccountStatusMessage = e.getMessage();
            }
            
        }
        else{
            AccountStatus = 'InActive';
            AccountStatusMessage = 'Account must be either credit approved with one active program or use an active Cash and Carry or Subsidy with Pcard program.';
        }
       
       System.debug('-=-=-=-= Account status msg'+AccountStatusMessage);
    }

    public void AccountDeactivate(){
        
        Account AccObj = [Select ID, Name, Active__c, Credit_Status__c,IsPersonAccount from Account where id =: accountId limit 1];
        System.debug('AccountActivate**** : ->'+AccObj);
        try{
            AccObj.Active__c = false;
            update AccObj;
            AccountStatus = 'InActive';
            isActive = false;
            AccountStatusMessage = accountName +' account is deactivated';
            System.debug('-=-=-=-= Account status msg'+AccountStatusMessage);
       }
       catch(exception e){
           AccountStatusMessage = accountName +' account cannot be activated';
       }
    }
    
    /************** file upload methods start ***************/
    
    
    @RemoteAction
    public static PageReference doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId, String PageNameToReload) {
        if(acctId != null) {
            Account acct = [Select id, Name,IsPersonAccount from Account where id =: acctId limit 1];
            if(acct != null) {
                if(attachmentBody != null) {
                    System.debug('-=-=-= attachmentId: '+attachmentId);
                    Attachment att = getAttachment(acct.id);
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    System.debug('-=-=attachmentId: '+acct);
                    /*if(attachmentId == null) {
                        
                        
                    }*/
                    att.Name = attachmentName;
                    att.parentId = acct.Id;
                    upsert att;
                    
                    //String pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
                    //System.debug('-=-= Page name:'+ApexPages.currentPage());
                    //String pageName = 
                    System.debug('-=-= Page redirects to:'+PageNameToReload);
                    pagereference pr = new pagereference(Label.Community_Name + PageNameToReload+'?tab=account&id='+acctId);
                    pr.setRedirect(true);
                    System.debug('-=-= Page redirects to:'+pr);
                    return pr;
                    
                    //return att.Id;
                } else {
                    //return 'Attachment Body was null';
                    return null;
                }
            } else {
                //return 'Account could not be found';
                return null;
            }
        } else {
            //return 'Account Id was null';
            return null;
        }
    }
     
    @RemoteAction
    public static String doSubmitForm(String acctId, String description, String website, String phone) {
        if(acctId != null) {
            Account acct = [Select id, Name,IsPersonAccount from Account where id =: acctId limit 1]; //getAccount(acctId);
            if(acct != null) {
                acct.Description = description;
                acct.Website = website;
                acct.Phone = phone;
                update acct;
                return 'Success';
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
     
    /*private static Account getAccount(String acctId) {
        list<Account> accounts = [SELECT Id, Name, Counter__c
                                  FROM Account
                                  WHERE Id =: acctId];
        if(accounts.isEmpty()) {
            return null;
        } else {
            return accounts[0];
        }
    }
     */
    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body
                                        FROM Attachment 
                                        WHERE parentid =: attId];
        if(attachments.isEmpty()) {
        //if(null == attachments){
            Attachment a = new Attachment();
            return a;
        } else {
            delete attachments;
            Attachment a = new Attachment();
            return a;
            //return attachments[0];
        }
    }
    
    
    
    
    /************** file upload methods end ****************/
    

    /****added by Joey, list of attachments***/
    public list<RWFBAttachment> getAtttachmentList() {
            list<RWFBAttachment> returnMe = new list<RWFBAttachment>();
            list<RWfB_Attachment__c> rwfbList = [Select Id,Type__c,Public__c,Document_for_Credit_Application__c, (Select Id, Name, CreatedDate from Attachments order by CreatedDate DESC limit 1) From RWfB_Attachment__c Where Public__c = true and Account__c = : accountId];
            if(rwfbList.size()>0){
                for(RWfB_Attachment__c r: rwfbList){
                    for(Attachment a: r.Attachments){
                        returnMe.add(new RWFBAttachment(r));
                    }
                }
            }
            return returnMe;
    }

    @RemoteAction
    public static RWfB_Attachment__c insertRWFB(String accId, String attachType, Boolean creaditAppDoc) {
        RWfB_Attachment__c rwfb = new RWfB_Attachment__c();
        rwfb.Type__c = attachType;
        rwfb.Public__c = true;
        rwfb.Account__c = accId;
        rwfb.Document_for_Credit_Application__c = creaditAppDoc;
        try {
            insert rwfb;    
        } catch (DmlException ex) { 
            System.debug('exception caught: ' + ex);
        }
        
        return rwfb;
    }
    
    
    
    public PageReference deleteRWFB() {        
        rwfbId = Apexpages.currentPage().getParameters().get('attachId');
        System.debug('rwfbId: '+rwfbId);
        if(rwfbId != null){
            delete [Select Id from RWfB_Attachment__c where Id =: rwfbId];
        }
        return null;
    }

    /*Attachment data model can be exposed on FE*/
    //on FE modal, use 
    //{!rwfbAtt.attType} for attachment type
    //{!rwfbAtt.att.Name} for attachment name
    //{!rwfbAtt.att.Body} for attachment body
    public RWFBAttachment rwfbAtt {
        get{
            System.debug('rwfbATT get: ' + rwfbATT);
            if(rwfbAtt == null){
                rwfbAtt = new RWFBAttachment();
            }
            System.debug('rwfbATT return: ' + rwfbATT);
            return rwfbAtt;
        }   
        set;
    }

    /*Attachment upload method*/
    public class RWFBAttachment {
        public string name {get;set;}
        public string rwfbId {get;set;}
        public string attType {get;set;}
        public Boolean isPublic {get;set;}
        public DateTime createdDate {get;set;}
        public Attachment att {get;set;}
        public Boolean isCreditAppDoc {get;set;}

        public RWFBAttachment(RWfB_Attachment__c r){
            rwfbId = r.Id;
            name = r.Attachments[0].Name;
            attType = r.Type__c;
            isPublic = r.Public__c;
            isCreditAppDoc = r.Document_for_Credit_Application__c;
            createdDate = r.Attachments[0].CreatedDate;
            att = r.Attachments[0];
        }
        public RWFBAttachment(){
            att = new Attachment();
        }
    }
    
    
    
    
    
}