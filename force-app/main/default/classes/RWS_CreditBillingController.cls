public class RWS_CreditBillingController {

   

   
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
    public String invoiceAttributes { get; set; }
    public String[] selectInvoiceAttributes { get; set; }
    public String displayInvoiceDelivery  { get; set; }
    public String displayPaymentTerms { get; set; }
    public String selectBillingParent { get; set; }
    public String selectInvoiceParent {get;set;}

    public List<SelectOption> attachTypeOptions {get;set;} 
    public String selectAttachType {get; set;}
    public Boolean selectCreditApplicationDoc {get; set;}

    public final String STR_PENDING = 'Pending';
    public final String STR_APPROVED = 'Approved/Active';
    public String parentAccountId {get; set;}
    public Account parentAccount{get; set; }
    public String parentContactId {get; set; }

    //helpers for view only state
    public Boolean isCentralizedBilling {
        get{
            return !String.isBlank(parentAccountId) && editAccount != null && selectBillingParent == 'Centralized';
        }
    }
    public Boolean isDecentralizedBilling {
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
    public Boolean outputBillingContact {
        get{
            return !String.isBlank(parentAccountId) && (!isInvoiceParentAccount || (isInvoiceParentAccount && isDecentralizedBilling));
        }
    }
  
    public String sendCreditErrorMsg {get; set;}
    public String SendCreditApplicationPopUp {get;set;}
    public String EmailApplicableTo {get;set;}
    public String contactPrimaryEmail {get; set;}
    public String SelectbillingcontactOptions{get;set;}
    public String SelectContactAddrBillOptions{get;set;}
    public String accountId {get;set;}
    public String SelectiReqCreditLimitOptions{get;set;}
    public Boolean creditappFlag {get;set;}
    public Boolean hasBillingContact {get; set;}
    public Account editAccount { get; set; }
    public Account editAccountForUpdate { get; set; }

    public String billingContactId { get; set; }
    public String billingLast { get; set; }
    public String billingFirst { get; set; }
    public String billingEmail { get; set; }
    public String billingPhone { get; set; }
    public String billingPhoneEdit { get; set; }
    public String billingPhoneExt { get; set; }
    public String billingStreet { get; set; }
    public List<SelectOption> billingRoles {get;set;}
    public String[] selectedBillingRole {get;set;}

    public String decContactId { get; set; }
    public String decFirst { get; set; }
    public String decLast { get; set; }
    public String decEmail { get; set; }
    public String decPhone { get; set; }
    public String decRoles { get; set; }
    public String[] decSelectedBillingRole {get;set;}
    public String decTitle { get; set; }
    public String decStreet { get; set; }
    public String decCity { get; set; }
    public String decState { get; set; }
    public String decZipCode { get; set; }
    public String decCountry  {get;set;}
    
    public String billingTitle { get; set; }
    public String mailingCity { get; set; }
    public String mailingState { get; set; }
    public String mailingzipCode { get; set; }
    public String billingCountry  {get;set;}
    public String billingContact { get; set; }
    public String contactAddress { get; set; }
    public String accountName {get;set;}
    public String accountLine1 { get; set;}
    public String accountLine2 { get; set;}
    public String accountLine3 { get; set;}
    public String accountCity {get;set;}
    public String accountState {get;set;}
    public String accountzipCode {get;set;}
    public String accountCountry {get;set;}
    public String billingLine1 { get; set;}
    public String billingLine2 { get; set;}
    public String billingLine3 { get; set;}
    public String billingCity { get; set;}
    public String billingState { get; set;}
    public String billingZipCode { get; set;}
    public String mailingCountry {get;set;}
    public String sameAsbillingAddress {get;set;}
    public String legalName {get; set;}

    public string selectCreditStatus {get;set;}
    public string selectbillingFrequency {get;set;}
    public string selectpaymentTerms {get;set;}
    public string selectinvoiceDelivery {get;set;}
    public double creditLimit {get;set;}
    public string selectpreferredPayment {get;set;}
    public String SelectinvoiceOptions{get;set;}
    public String federalIdNumber {get; set;}
    //public List<contact> contactList {get;set;}

    public String SameAsPrimaryContactInfo {get;set;}
    public String sameAsPrimaryContactAddress {get;set;}
    public Boolean isNeedToLock{ get; set; }
    public String SameAsAccountAddress {get;set;}
    public Boolean isAttachButtonDisabled {get; set;}  
    
    public List<SelectOption> ContactStateOptions {get;set;}
    public List<SelectOption> ContactCountryOptions {get;set;} 
    public List<SelectOption> billingFrequency {get;set;} 
    public List<SelectOption> paymentTerms {get;set;} 
    public List<SelectOption> invoiceDeliveryMethod {get;set;}
    public List<SelectOption> ReqCreditLimitOptions{get;set;}
    public List<SelectOption> invoiceOptions{get;set;}
    public List<SelectOption> billingcontactOptions{get;set;}
    public List<SelectOption> contactAddressBillingOptions{get;set;}
    public List<SelectOption> invoiceAttributesRequired{get;set;}        
    public Contact parentBillingContact {get; set;}
    public String selectStandardApplication { get; set; }
    public RWS_CreditBillingController(){
        initialize();
    }
    
       
    public pagereference initialize(){
        System.debug('Begin RWS_CreditBillingController() **********');
        //SelectiReqCreditLimitOptions = '--Select--';
        sameAsPrimaryContactInfo = 'There is no primary contact info available';
        invoiceOptions = RWS_UtilityClass.getrequiresInvoicing();
        ContactStateOptions = RWS_UtilityClass.getContactStates(); 
        ContactCountryOptions = RWS_UtilityClass.getContactCountries(); 
        billingFrequency = RWS_UtilityClass.getBillingFrequency();
        paymentTerms = RWS_UtilityClass.getPaymentTermsFiltered();
        invoiceDeliveryMethod = RWS_UtilityClass.getInvoiceDeliveryMethod();
        ReqCreditLimitOptions = RWS_UtilityClass.getRequestedCreditLimit();
        invoiceOptions = RWS_UtilityClass.getrequiresInvoicing();
        billingcontactOptions = RWS_UtilityClass.getcontactAddressPrimary();
        contactAddressBillingOptions = RWS_UtilityClass.getAddressPreference(); 
        invoiceAttributesRequired = RWS_UtilityClass.getInvoiceAttributesRequired(); 
        billingRoles = RWS_UtilityClass.getcontactRoles();

        accountId = Apexpages.currentpage().getparameters().get('id');
        parentAccountId = ApexPages.currentPage().getparameters().get('ParentId');
        parentAccount = new Account();
        selectBillingParent = 'Centralized';
        selectInvoiceParent = 'Yes';
        sameAsAccountAddress = 'There is no address entered for Account';
        SelectContactAddrBillOptions = 'Same as Physical';
        isAttachButtonDisabled = false;
        

        System.debug('Processing AccountId = ' + accountId);
        selectinvoiceOptions = 'Yes';
        selectbillingcontactOptions = 'Yes';
        editAccount = new Account();
        editAccountForUpdate = new Account();

        selectCreditApplicationDoc = true;
        attachTypeOptions = RWS_UtilityClass.getAttachType();

        if(accountId != null ){
            editAccount = [SELECT Id,Name,CreatedDate,Account_Number_BPC__c,Owner.Name, IA_Physical_Location_Address_Line_1__c, 
                                    IA_Physical_Location_Address_Line_2__c, IA_Physical_Location_Address_Line_3__c,
                                    IA_Physical_Location_City__c,
                                   toLabel(IA_Physical_Location_State_Province__c), IA_Physical_Location_ZIP_Postal_Code__c,
                                   toLabel(IA_Physical_Location_Country__c), 
                                   RWfB_Billing_Address_Line_1__c, RWfB_Billing_Address_Line_2__c,
                                   RWfB_Billing_Address_Line_3__c,RWfB_Billing_Address_City__c, 
                                   toLabel(RWfB_Billing_Address_State_Province__c), RWfB_Billing_Address_ZIP_Postal_Code__c,
                                   toLabel(RWfB_Billing_Address_Country__c), Phone,
                       Organization_Type__c,Account_Category__c,Company_Type__c,NA_Distribution_Method__c,DunsNumber,NA_Shoemobile_Frequency__c,
                       Tax_Exemption_Reason__c,Tax_Exemption_Reason__r.Name,Tax_Id_Type__c,Tax_Id_Number__c,Tax_Exempt__c,IA_Tax_Exempt_Certificate_Nbr__c,
                       Tax_Exempt_Expiration_Date__c,Open_Date__c,Credit_Status__c,Requested_Credit_Limi__c,Credit_Limit__C, Legal_Name__c, Billing_Frequency__c,
                       BPC_Payment_Terms__c,Invoice_Delivery_Method__c,Preferred_Payment_Method__c,Email_Application_To__c,MSTS_ID__c,
                       MultiService_Credit_Application_ID__c,Credit_Application_Sent_Date__c,Credit_Application_Approval_Date__c,Active__c,
                       Requires_Invoicing__c,Send_Application__c,IA_Federal_ID_Nbr__c,Invoice_Atributes_Required__c, ParentId,
                       FirstName, LastName, PersonEmail, Federal_ID__c, Payment_Terms__c, Invoice_Parent_Account__c, RWBAA_Standard_Application__c 
               FROM Account WHERE ID =: accountId];

               editAccountForUpdate.Id = editAccount.Id;

               parentBillingContact = new Contact();

            if(editAccount.ParentId != null && !String.isBlank(editAccount.ParentId )){
                parentAccountId = editAccount.ParentId ;
                try{
                    parentBillingContact = [SELECT ID, FirstName, LastName, Email, Phone,BPR_Role__c,Title,Address_same_as_Accounts__c,Contact_Same_as_Primary__c,
                    MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry, Role__c
                    from Contact where AccountId =: editAccount.ParentId AND Contact_Identifier__c IN ('Primary & Billing', 'Billing')limit 1];
                }catch(Exception e){
                    System.debug('Error occurred getting billing contact. ' + e.getMessage());
                }


                parentAccount = [SELECT Id,Billing_Frequency__c, IA_Federal_ID_Nbr__c, Legal_Name__c FROM Account WHERE ID =: parentAccountId];
                System.debug('-=-=-=-=-=-=-=-= parent account federal id number is ' + parentAccount.IA_Federal_ID_Nbr__c);
            }else{
                selectBillingParent = null;
            }
            if(parentBillingContact == null){
                parentBillingContact = new Contact();
            }
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
            accountName = editAccount.Name;
            
            accountLine1 = editAccount.IA_Physical_Location_Address_Line_1__c;
            if (!String.isBlank(editAccount.IA_Physical_Location_Address_Line_2__c) ){
                accountLine2 = editAccount.IA_Physical_Location_Address_Line_2__c;
            }
            if (!String.isBlank(editAccount.IA_Physical_Location_Address_Line_3__c)){
                accountLine3 = editAccount.IA_Physical_Location_Address_Line_3__c;
            }
            accountCity = editAccount.IA_Physical_Location_City__c;
            accountState = editAccount.IA_Physical_Location_State_Province__c;
            accountzipCode = editAccount.IA_Physical_Location_ZIP_Postal_Code__c;
            accountCountry = editAccount.IA_Physical_Location_Country__c; 
            
            billingLine1 = editAccount.RWfB_Billing_Address_Line_1__c;
            if (!String.isBlank(editAccount.RWfB_Billing_Address_Line_2__c) ){
                billingLine2 = editAccount.RWfB_Billing_Address_Line_2__c;
            }
            if (!String.isBlank(editAccount.RWfB_Billing_Address_Line_3__c) ){
                billingLine3 = editAccount.RWfB_Billing_Address_Line_3__c;
            }
            billingCity = editAccount.RWfB_Billing_Address_City__c;
            billingState = editAccount.RWfB_Billing_Address_State_Province__c;
            billingZipCode = editAccount.RWfB_Billing_Address_ZIP_Postal_Code__c;

            billingCountry = editAccount.RWfB_Billing_Address_Country__c;

            if( !String.isBlank(accountLine1) ) sameAsAccountAddress = accountLine1 ;
            if( !String.isBlank(accountLine2) ) sameAsAccountAddress += ', ' + accountLine2 ;
            if( !String.isBlank(accountLine3) ) sameAsAccountAddress += ', ' + accountLine3 ;
            if( !String.isBlank(accountCity) ) sameAsAccountAddress += ', ' + accountCity ;
            if( !String.isBlank(accountState) ) sameAsAccountAddress += ',\n ' + accountState ;
            if( !String.isBlank(accountCountry) ) sameAsAccountAddress += ', ' + accountCountry ;
            if( !String.isBlank(accountzipCode) ) sameAsAccountAddress += ', ' + accountzipCode ;

            if(String.isBlank(sameAsAccountAddress)) sameAsAccountAddress = 'There is no address entered for Account' ;
            
            if( !String.isBlank(billingLine1) ) sameAsbillingAddress = billingLine1 ;
            if( !String.isBlank(billingLine2) ) sameAsbillingAddress += ', ' + billingLine2 ;
            if( !String.isBlank(billingLine3) ) sameAsbillingAddress += ', ' + billingLine3 ;
            if( !String.isBlank(billingCity) ) sameAsbillingAddress += ', ' + billingCity ;
            if( !String.isBlank(billingState) ) sameAsbillingAddress += ',\n ' + billingState ;
            if( !String.isBlank(billingCountry) ) sameAsbillingAddress += ', ' + billingCountry ;
            if( !String.isBlank(billingzipCode) ) sameAsbillingAddress += ', ' + billingzipCode ;

            if(String.isBlank(sameAsbillingAddress)) sameAsbillingAddress = 'There is no address entered for Account' ;

            selectInvoiceAttributes = String.isNotBlank(editAccount.Invoice_Atributes_Required__c) ? editAccount.Invoice_Atributes_Required__c.split('\\;') : null;
            SelectiReqCreditLimitOptions = editAccount.Requested_Credit_Limi__c;

            federalIdNumber = editAccount.IA_Federal_ID_Nbr__c;
            selectCreditStatus = editAccount.Credit_Status__c;
            isNeedToLock = selectCreditStatus == STR_PENDING || selectCreditStatus == STR_APPROVED ? true : false ;
            if(null != editAccount.Email_Application_To__c  && editAccount.Email_Application_To__c != ''){
                EmailApplicableTo = editAccount.Email_Application_To__c;
            }
            if(null != editAccount.RWBAA_Standard_Application__c  && editAccount.RWBAA_Standard_Application__c != ''){
                selectStandardApplication = editAccount.RWBAA_Standard_Application__c;
            }
            creditLimit = editAccount.Credit_Limit__C;
            legalName = editAccount.Legal_Name__c;
            selectbillingFrequency = editAccount.Billing_Frequency__c;
            if(editAccount.Billing_Frequency__c == null || editAccount.Billing_Frequency__c == '')
                selectbillingFrequency = '--Select--';
            else{selectpaymentTerms = editAccount.BPC_Payment_Terms__c;}
            if(editAccount.BPC_Payment_Terms__c == null || editAccount.BPC_Payment_Terms__c == '')
                selectpaymentTerms = '30';            
            if (selectpaymentTerms == '30'){
                displayPaymentTerms = 'Net 30 Days';
            } else if (selectpaymentTerms == '45'){
                displayPaymentTerms = 'Net 45 Days';
            }else if (selectpaymentTerms == '60'){
                displayPaymentTerms = 'Net 60 Days';
            } else if (selectpaymentTerms == '90'){
                displayPaymentTerms = 'Net 90 Days';
            } else {
                displayPaymentTerms = 'Net 120 Days';
            }  
            
                
            selectinvoiceDelivery = editAccount.Invoice_Delivery_Method__c;
            if(editAccount.Invoice_Delivery_Method__c == null || editAccount.Invoice_Delivery_Method__c == '')
                selectinvoiceDelivery = 'PDF';
            if (selectinvoiceDelivery == 'PDF'){
                displayInvoiceDelivery = 'Email with PDF file';
            } else if (selectinvoiceDelivery == 'CSV'){
                displayInvoiceDelivery = 'Email with CSV file';
            }else if (selectinvoiceDelivery == 'Both'){
                displayInvoiceDelivery = 'Both PDF and CSV';
            } else {
                displayInvoiceDelivery = 'Special Invoice Handling';
            }   
                
            selectpreferredPayment = editAccount.Preferred_Payment_Method__c;
            
            System.debug('UAC: selectInvoiceAttributes ' + selectInvoiceAttributes );

            //need to load the contact list on first initialization  
            //NOTE: This is not used in the component / page. Seems to only be used to see if we have a billing contact later
            //but billing contact is saved prior to sending credit application. Just use a boolean hasBillingContact for the check later on.      
            //contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Title from Contact where AccountId =:accountid AND Contact_Identifier__c IN ('Primary & Billing', 'Billing') ];
            //Account Edit Details
            if(editAccount.Requires_Invoicing__c == null)
                SelectinvoiceOptions = 'No';
            else
                SelectinvoiceOptions = editAccount.Requires_Invoicing__c;
            List<Contact> billContact = [Select Id, Name, FirstName, LastName, Email, Phone,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,BPR_Role__c, Role__C,Title,Contact_Identifier__c,Contact_Same_as_Primary__c,Address_same_as_Accounts__c 
                from Contact where AccountId =:editAccount.id AND (Contact_Identifier__c IN ('Primary & Billing', 'Billing')) limit 1];
            List<Contact> contactPrimary = [SELECT ID, name, FirstName, LastName, Email, Phone,BPR_Role__c, Role__c,Title,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Address_same_as_Accounts__c,Contact_Same_as_Primary__c 
                from Contact where AccountId =:editAccount.id AND (Contact_Identifier__c IN ('Primary & Billing', 'Primary')) limit 1];
            
            if(contactPrimary != null && contactPrimary.size() > 0)
            {
                
                if( !String.isBlank(contactPrimary[0].FirstName) ) sameAsPrimaryContactInfo = contactPrimary[0].FirstName ;
                if( !String.isBlank(contactPrimary[0].LastName) ) sameAsPrimaryContactInfo += ', ' + contactPrimary[0].LastName ;
                if( !String.isBlank(contactPrimary[0].Email) ) sameAsPrimaryContactInfo += ',\n ' + contactPrimary[0].Email ;
                if( !String.isBlank(contactPrimary[0].Phone) ) sameAsPrimaryContactInfo += ', ' + contactPrimary[0].Phone ;
                if( !String.isBlank(contactPrimary[0].Title) ) sameAsPrimaryContactInfo += ', ' + contactPrimary[0].Title ;
                
                if( !String.isBlank(contactPrimary[0].MailingStreet) ) sameAsPrimaryContactAddress = contactPrimary[0].MailingStreet ;
                if( !String.isBlank(contactPrimary[0].MailingCity) ) sameAsPrimaryContactAddress += ', ' + contactPrimary[0].MailingCity ;
                if( !String.isBlank(contactPrimary[0].MailingState) ) sameAsPrimaryContactAddress += ',\n ' + contactPrimary[0].MailingState ;
                if( !String.isBlank(contactPrimary[0].MailingPostalCode) ) sameAsPrimaryContactAddress += ', ' + contactPrimary[0].MailingPostalCode ;
                if( !String.isBlank(contactPrimary[0].MailingCountry) ) sameAsPrimaryContactAddress += ', ' + contactPrimary[0].MailingCountry ;

                if(EmailApplicableTo == null || EmailApplicableTo == ''){
                    EmailApplicableTo = contactPrimary[0].Email;
                }
            }
            if(!billContact.isEmpty()){
                selectedBillingRole = String.isNotBlank(billContact[0].Role__c) ? billContact[0].Role__c.split('\\;') : null;
                hasBillingContact = true;
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

                if(SelectbillingcontactOptions != 'Yes') EmailApplicableTo = billContact[0].Email;
                
                billingContact = billContact[0].FirstName + ', ' + billContact[0].LastName + ',\n ' + billContact[0].Email + ', ' + billContact[0].Phone;
                
                if(null == billingContact || billingContact  == ''){
                    billingContact = 'There is no billing contact available.';
                }
                
                contactAddress = billContact[0].MailingStreet + ', ' + billContact[0].MailingCity + ',\n ' + billContact[0].MailingState + ', ' + billContact[0].MailingPostalCode+',' +billContact[0].MailingCountry;
                
                if(null == contactAddress || contactAddress == ''){
                    contactAddress = 'There is no billing contact address available.';
                }
            }
        }   
        
        setParentInvoiceInfo();

        System.debug('End RWS_CreditBillingController() **********');
        //this method doesn't need to do anything. I just need the action function to "touch" the controller to get the constructor to initialize
        
        return null;

        //CREDIT INFORMATION
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
        } catch (DmlException ex) { }
        
        return rwfb;
    }

    public void setParentInvoiceInfo()
    {
        // Added By UsmanAli Jira Task RWCP-1757
        if( !String.isBlank(parentAccountId))
        {
            parentAccount = [   SELECT FirstName, LastName, PersonEmail, Phone, Legal_Name__c, Billing_Frequency__c, Federal_ID__c, Payment_Terms__c, 
                                        Invoice_Delivery_Method__c, Credit_Limit__c, Invoice_Parent_Account__c, IA_Federal_ID_Nbr__c, BPC_Payment_Terms__c, Invoice_Atributes_Required__c, Requested_Credit_Limi__c,Email_Application_To__c,
                                    (select Id from Contacts where Contact_Identifier__c IN ('Primary & Billing', 'Billing') order by Contact_Identifier__c desc )
                                FROM Account WHERE Id = :parentAccountId ];
            if(parentAccount.Contacts.size() > 0 ){
                parentContactId = parentAccount.Contacts[0].Id ;
            }
            System.debug('UAC: parentAccountId ' + parentAccountId + ' selectInvoiceParent ' + selectInvoiceParent + ' selectBillingParent ' + selectBillingParent + ' parentContactId ' + parentContactId);
            if( selectInvoiceParent == 'Yes' && selectBillingParent == 'Centralized')
            {   
				editAccountForUpdate.Legal_Name__c = parentAccount.Legal_Name__c;
                editAccountForUpdate.Billing_Frequency__c = parentAccount.Billing_Frequency__c ;
                editAccountForUpdate.Federal_ID__c = parentAccount.Federal_ID__c ;
                editAccountForUpdate.Payment_Terms__c = parentAccount.Payment_Terms__c ;
                editAccountForUpdate.Invoice_Delivery_Method__c= parentAccount.Invoice_Delivery_Method__c ;
                editAccountForUpdate.Credit_Limit__c = parentAccount.Credit_Limit__c ;
            }
            else if(selectInvoiceParent == 'Yes' && selectBillingParent == 'Decentralized')
            {
                //editAccount.FirstName = null ;
                //editAccount.LastName = null ;
                //editAccount.PersonEmail = null ;
                //editAccount.Phone = null ;
                editAccountForUpdate.Invoice_Delivery_Method__c= null ;
                //editAccount.Invoice_Parent_Account__c = 'Yes - Decentralized Billing' ;
            }

        }
    }
    
    /*
    public Pagereference setCreditAttachFlag(){
        isAttachButtonDisabled = true;
        return null;
    }
    */
    
    public Pagereference updateCreditInfo(){
        
        sendCreditErrorMsg = '';
        Account creditAccount = new Account();
        Contact decContact = new Contact();
        decContact.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();

        if(!String.isBlank(accountId) && !String.isBlank(parentAccountId))
        {
            System.debug('before update account: ' + editAccountForUpdate);


            try {
                update editAccountForUpdate;    
            } catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    System.debug('... ' + e.getDmlMessage(i)); 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                }
            } 
            
            System.debug('after update account: ' + editAccountForUpdate);

            if( (!String.isBlank(parentContactId)) && selectInvoiceParent == 'Yes' && selectBillingParent == 'Centralized' )
            {
                Set<Id> existingContacts = new Set<Id>();
                for(AccountContactRelation acr : [SELECT ContactId FROM AccountContactRelation WHERE AccountId = :accountId ])
                {
                    existingContacts.add(acr.ContactId);
                }
                
                if(!existingContacts.contains(parentContactId))
                {
                    AccountContactRelation acr = new AccountContactRelation(AccountId = accountId, ContactId = parentContactId);
                    insert acr ;    
                    System.debug('UAC: acr ' + acr );
                }
               hasBillingContact = true;
            }
            
        }

        Contact billingContact = new Contact();
        if( !String.isBlank(accountId)) {

            System.debug('SelectbillingcontactOptions: ' + SelectbillingcontactOptions);
            creditAccount.Id = accountId;
            System.debug('Has parent is set to... ' + hasParent);
            System.debug('Select Invoice Parent is set to... ' + selectInvoiceParent);
            System.debug('Select Invoice Options is set to... ' + SelectinvoiceOptions);
            //if(hasParent == false || (hasParent == true && selectInvoiceParent == 'No')){
                if(SelectinvoiceOptions == 'Yes') {
                    List<Contact> primaryContact = [select id,name, Email from Contact where Contact_Identifier__c = 'Primary' AND AccountId =:accountId limit 1];
                    //Billing Contact Info same as Primary Contact Condition
                    if(SelectbillingcontactOptions == 'Yes'){// billing contact Same as Primary
                    
                    

                        if(!primaryContact.isEmpty()) {
                            primaryContact[0].Contact_Identifier__c = 'Primary & Billing';
                            //if(selectBillingParent == 'Centralized' && !String.isBlank(editAccount.ParentId)){
                                //edge case
                                //primaryContact[0].Contact_Identifier__c = 'Primary';
                            //}

                            //if(String.isBlank(EmailApplicableTo)) EmailApplicableTo = primaryContact[0].Email;

                            primaryContact[0].BPR_Role__c = 'Billing Contact';

                            try{
                                Upsert primaryContact[0];
                                //set flag
                                hasBillingContact = true;
                                List<Contact> billContList = [Select Id, Name from Contact where AccountId =:editAccount.id AND (BPR_Role__c = 'Billing Contact' OR Contact_Identifier__c = 'Billing') limit 1];

                                if(!billContList.isEmpty()) {
                                    billContList[0].Contact_Same_as_Primary__c = SelectbillingcontactOptions;

                                    update billContList;
                                }
                            }
                            catch(System.DmlException e){
                                for (Integer i = 0; i < e.getNumDml(); i++) {
                                    // Process exception here
                                    System.debug('An error occurred in the RWS_CreditBillingController controller trying to update the primary contact. ' +e.getDmlMessage(i)); 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                                }
                            } 
                        }

                    } else { //billing contact different
                    
                        System.debug('Need to create a new contact. Select Billing Contact set to ' + SelectbillingcontactOptions);
                        
                        
                        
                        
                        billingContact.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
                        billingContact.Contact_Identifier__c = 'Billing';
                        billingContact.AccountId = accountId;
                        billingContact.BPR_Role__c = 'Billing Contact';
                            billingContact.LastName = billingLast;
                            billingContact.FirstName = billingFirst;
                            billingContact.Email = billingEmail;
                        	if(billingPhoneExt != '' || null != billingPhoneExt){
                                billingPhone = billingPhoneEdit+' x'+billingPhoneExt;            
                            } else {
                                billingPhone = billingPhoneEdit;
                            }
                            billingContact.Phone = billingPhone;
                            billingContact.Title = billingTitle ;
                            billingContact.Role__c = selectedBillingRole != null ? string.join(selectedBillingRole,';') : null;
                            //EmailApplicableTo = billingEmail;
    
                            if(SelectContactAddrBillOptions == 'Different'){    
                                billingContact.MailingStreet = billingStreet;
                                billingContact.MailingCity = mailingCity;
                                billingContact.MailingState = mailingState;
                                billingContact.MailingPostalCode = mailingzipCode;
                                billingContact.MailingCountry = mailingCountry;
                                billingContact.Contact_Same_as_Primary__c = SelectbillingcontactOptions;
                                billingContact.Address_same_as_Accounts__c = SelectContactAddrBillOptions;
                            }               
                            
                            else if(SelectContactAddrBillOptions == 'Same as Physical') {
                                billingContact.MailingStreet = (String.isBlank(accountLine1) ? '' : accountLine1 + '\n') + 
                                                (String.isBlank(accountLine2) ? '' : accountLine2 + '\n') + 
                                                (String.isBlank(accountLine3) ? '' : accountLine3);
    
                                billingContact.MailingCity = accountCity;
                                billingContact.MailingState = accountState;
                                billingContact.MailingPostalCode = accountzipCode;
                                billingContact.MailingCountry = accountCountry;
                                billingContact.Contact_Same_as_Primary__c = SelectbillingcontactOptions;
                                billingContact.Address_same_as_Accounts__c = SelectContactAddrBillOptions;
                            } else { //same as billing
                                billingContact.MailingStreet = (String.isBlank(billingLine1) ? '' : billingLine1 + '\n') + 
                                                (String.isBlank(billingLine2) ? '' : billingLine2 + '\n') + 
                                                (String.isBlank(billingLine3) ? '' : billingLine3);
    
                                billingContact.MailingCity = billingCity;
                                billingContact.MailingState = billingState;
                                billingContact.MailingPostalCode = billingZipCode;
                                billingContact.MailingCountry = billingCountry;
                                billingContact.Contact_Same_as_Primary__c = SelectbillingcontactOptions;
                                billingContact.Address_same_as_Accounts__c = SelectContactAddrBillOptions;
                            }    
                        
                        
                        
                        
                        
                        
                       
                        
                        
                        
                        
                        
                        
                        List<Contact> billContList = [Select Id, Name, Contact_Identifier__c from Contact where AccountId =:editAccount.id AND Contact_Identifier__c IN ('Primary & Billing', 'Billing') limit 1];

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
                            
                        try{

                            Upsert billingContact;
                            hasBillingContact = true;
                        }
                        catch(System.DmlException e){
                            for (Integer i = 0; i < e.getNumDml(); i++) {
                                // Process exception here
                                System.debug('An error occurred in the RWS_CreditBillingController controller trying to insert a new the billing contact. ' + e.getDmlMessage(i)); 
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                            }
                        } 
                    }

                    //creditAccount.Id = accountId;
            
                    System.debug('-=-=selectCreditStatus'+selectCreditStatus+
                                 '\n-=-=-'+selectbillingFrequency+
                                 '\n-=-=-selectpaymentTerms'+selectpaymentTerms+
                                 '\n-=-=-selectinvoiceDelivery'+selectinvoiceDelivery);
                    creditAccount.Requested_Credit_Limi__c = SelectiReqCreditLimitOptions;
                    System.debug('UAC: selectInvoiceAttributes ' + selectInvoiceAttributes);

                    System.debug('UAC: selectInvoiceAttributes after ' + selectInvoiceAttributes);            
           
                   
                    creditAccount.Invoice_Atributes_Required__c = selectInvoiceAttributes != null ? string.join(selectInvoiceAttributes,';') : null;
                    if(selectCreditStatus!= '--None--')
                        creditAccount.Credit_Status__c = selectCreditStatus;
                    if(SelectiReqCreditLimitOptions != '--None--' && SelectiReqCreditLimitOptions != '--Select--')    
                        creditAccount.Credit_Limit__C = creditLimit;
                    if(legalName != '' || legalName != null)
                        creditAccount.Legal_Name__c = legalName;
                    if(selectbillingFrequency != '--None--' && selectBillingFrequency != '--Select--')
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

                    System.debug('#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#! Invoice Parent Account set to ' + creditAccount.Invoice_Parent_Account__c );
                    try{
                        creditAccount.Email_Application_To__c = EmailApplicableTo;
                        creditAccount.RWBAA_Standard_Application__c = selectStandardApplication;
                        if (creditappFlag){
                            creditAccount.Credit_Status__c = 'Submitted';
                            //creditAccount.Send_Credit_Application__c = 'Send';
                        }
                        
                        creditAccount.Requires_Invoicing__c = SelectinvoiceOptions;
                        creditAccount.Send_Application__c = creditappFlag;
                        creditAccount.IA_Federal_ID_Nbr__c = federalIdNumber;


                        if(EmailApplicableTo == '' || EmailApplicableTo == null){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter email application to.'));
                            
                        }
                        if(hasBillingContact == null || hasBillingContact != true){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Without a complete Billing Contact you cannot send a Credit Application for this Account. Billing Contacts must have a complete Mailing Address and be identified with the Contact Identifier Field.'));
                        }
                        if(creditappFlag == true && (accountId == null || editAccount == null)){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'In order to submit a Credit Application. All Address Fields, Payment Fields and Credit Fields must be filled out.'));
                        }
                        if(ApexPages.hasMessages()){
                            ApexPages.Message[] msgs = ApexPages.getMessages();
                            System.debug('*** ApexPages.msgs = ' + msgs[0]);
                            return null;
                        }

                        System.debug('creditAccount: ' + creditAccount.Requires_Invoicing__c);

                        if( selectInvoiceParent == 'Yes' && !String.IsBlank(editAccount.ParentId)) //when invoicing the parent, need to copy values down from the parent account
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

                        upsert creditAccount;
                        initialize();
                        if(creditappFlag){
                            SendCreditApplicationPopUp = 'Show pop up';

                        } else{
                            SendCreditApplicationPopUp  = '';
                        }
                        
                        
                        
                        
                    }
                    catch(System.DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            // Process exception here
                            System.debug('An error occurred in the RWS_CreditBillingController controller trying to update the account ' + e.getDmlMessage(i)); 
                            if (e.getDmlMessage(i).contains('The Parent Account cannot be invoiced')){
                                sendCreditErrorMsg = 'The Parent Account cannot be invoiced. Parent account credit status must be active or approved.';
                            } else {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));              
                            }
                        }
                    } 
                } else {
                    creditAccount.Requires_Invoicing__c = SelectinvoiceOptions;
                    try{
                        upsert creditAccount;
                        
                        if(creditappFlag){
                            SendCreditApplicationPopUp = 'Show pop up';
                        }
                        else{
                            SendCreditApplicationPopUp  = '';
                        }
                    } catch(System.DmlException e){
                        for (Integer i = 0; i < e.getNumDml(); i++) {
                            // Process exception here
                            System.debug('An error occurred trying to update the credit account. Account id is ' + accountId + ' and error message is ' + e.getDmlMessage(i)); 
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
                        }
                    }
                }
            //}
        } 
       
        return null;
        
    }

}