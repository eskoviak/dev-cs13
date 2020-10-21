public with sharing class RWS_AccountController {

  public Attachment attachment {
  get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
  set;
  }
    //added by Joey
    public String rwfbId {get;set;}
    public String owningStore {get; set;}
    public String ownerPhone {get; set;}
    public String ownerName {get; set;}
    public Boolean redWingOwned {get; set;}
    public String fileData {get;set;}
    public String accountTypeSelect { get; set; }

    public String parentAccountId {get; set; }
    public Boolean hasParentAccountAccess {get; set; }
    public String parentAccountName {get; set; }

    //properties
    public String EmailApplicableTo {get;set;}
    public string selectCreditStatus {get;set;}
    public string AccountStatus {get;set;}
    public String federalIdNumber {get; set;}
    public String AccountStatusMessage {get;set;}
    public Boolean EditMode {get;set;}
    public ID parentId {get;set;} 
    public Boolean isActive {get;set;}
    public String accountId {get;set;}
    public String duplicationMessage {get;set;}
    public String SelectTaxExempt {get;set;}    
    public String SelectinvoiceOptions{get;set;}
    public String SelectbillingcontactOptions{get;set;}
    public Account editAccount { get; set; } 
    public Account parentAccount { get; set; } 
    public Account createAccount { get; set; }
    public String accountName {get;set;}
    public String accountOwner {get;set;}
    public String accountNumber {get;set;}
    public String accountAddress {get;set;}    
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
    public String billingZipCode { get; set;}
    public String billingCountry { get; set;}
    public List<SelectOption> billingAddressOptions { get; set;}
    public String selectBillingAddressOptions { get; set;}
    public List<Account> accList;
    public String selectOrgType {get;set;}
    public String selectAccountCategory {get;set;}
    public String selectAccountType {get;set;}
    public String SelectTaxIdType {get;set;}
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

    public String TaxCertificateNumber {get;set;}
    public date TaxExpiryDate {get;set;}   
    public String URLSummary {get;set;}
    public String selecttaxName    {get;set;}
    public String displaySelectTaxName {get; set;}

        //Tax Exemption Properties
    public List<Tax_Exemption_Reason__c> taxsearchresultList {get;set;}
    public String searchStateString {get;set;}
    public String exemptionreasonName {get;set;}
    public List<SelectOption> exemptionreasonOption {get;set;}
    public List<Tax_Exemption_Reason__c> taxexemptReasonList {get;set;}
    public List<SelectOption> StateOptions {get;set;}
    public List<SelectOption> CountryOptions {get;set;}
    public String industrialAccount { get; set; }
    public String nationalAccount { get; set; }
    public String cityExempt { get; set; }
    public String stateExempt { get; set; }
    public String countyExempt { get; set; }
    public String countryExempt { get; set; }
    public String TaxNumber {get;set;}
    public String displayTaxExpiryDate {get;set;}
    public String AttachCertificateName {get; set;}
    public String AttachCertificateId {get; set;}
    public String removeAttachmentId {get; set;}
    public Boolean isNeedToLock{ get; set; }
    public Boolean billingSame {get;set;}

    public final String STR_PENDING = 'Pending';
    public final String STR_APPROVED = 'Approved/Active';

   //constructor
    public RWS_AccountController(){
        initialize();
    }


    public String billingStateLabel { get; set; }
    public String billingCountryLabel { get; set; }

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

    public pagereference initialize(){
            //attach = new Attachment();
        //set defaults
        System.debug('======== This is RWS_AccountController constructor');
        CountryOptions = RWS_UtilityClass.getCountries(); 
        AccountType = RWS_UtilityClass.getaccountTypes();
        billingAddressOptions = RWS_UtilityClass.getAddressPreference();
        billingAddressOptions.remove(1);
        selectBillingAddressOptions = 'Same as Physical';
        billingSame = true;
        TaxExempt = RWS_UtilityClass.getTaxExempts();
        isActive = false;
        EditMode = false;
        selectTaxExempt = 'No';
        selectbillingcontactOptions = 'Yes';
        selectinvoiceOptions = 'Yes';
        taxExpiryDate = null;
        attachCertificate = new Attachment();
        redWingOwned = false;
        accountId = Apexpages.currentpage().getparameters().get('id');
        parentAccountId = ApexPages.currentPage().getparameters().get('ParentId');
        editAccount = new Account();
        attachCertificate = new Attachment();
        System.debug('UAC: accountId ' + accountId );
        
        if(accountId != null )
        {
                        editMode = true;
                        accList = new List<Account>();
            editAccount = [SELECT Id,Name,CreatedDate,Account_Number_BPC__c,Owner.Name,IA_Physical_Location_Address_Line_1__c,IA_Physical_Location_Address_Line_2__c,IA_Physical_Location_Address_Line_3__c,
                            IA_Physical_Location_City__c,
                           IA_Physical_Location_State_Province__c, IA_Physical_Location_ZIP_Postal_Code__c,IA_Physical_Location_Country__c,RWfB_Billing_Address_Line_1__c, RWfB_Billing_Address_Line_2__c,
                           RWfB_Billing_Address_Line_3__c,RWfB_Billing_Address_City__c, RWfB_Billing_Address_State_Province__c,RWfB_Billing_Address_ZIP_Postal_Code__c,RWfB_Billing_Address_Country__c, Phone,
                           Organization_Type__c,Account_Category__c,Company_Type__c,NA_Distribution_Method__c,DunsNumber,NA_Shoemobile_Frequency__c,
                           Tax_Exemption_Reason__c,Tax_Exemption_Reason__r.Name,Tax_Id_Type__c,Tax_Id_Number__c,Tax_Exempt__c,IA_Tax_Exempt_Certificate_Nbr__c,
                           Tax_Exempt_Expiration_Date__c,Open_Date__c,Credit_Status__c,Requested_Credit_Limi__c,Credit_Limit__C,Billing_Frequency__c,
                           BPC_Payment_Terms__c,Invoice_Delivery_Method__c,Preferred_Payment_Method__c,Email_Application_To__c,MSTS_ID__c,
                           MultiService_Credit_Application_ID__c,Credit_Application_Sent_Date__c,Credit_Application_Approval_Date__c,Active__c,
                           Requires_Invoicing__c,Send_Application__c,IA_Federal_ID_Nbr__c,RWfB_same_as_Physical_Address__c, ParentId, Parent.Name
                   FROM Account WHERE ID =: accountId];
        }

        if(editAccount.ParentId != null) {
            parentAccountId = editAccount.ParentId;
        }

        if(!String.isBlank(parentAccountId)){

            hasParentAccountAccess = RWS_UtilityClass.getUserRecordAccess(parentAccountId);

            parentAccount = RWS_UtilityClass.getParentAccountForComponent(parentAccountId);
        }

        
        if(parentAccount != null){
            //if the edit account doesn't have a parent, but the parentAccountId param came in from the URL, then we are creating a new CHILD account
            parentAccountId = parentAccount.Id;
            parentAccountName = parentAccount.Name ;
        }

        if(editAccount.Id != null ){             
            URLSummary = 'AccountSummary?tab=account&id='+editAccount.Id;
        }
        StateOptions = RWS_UtilityClass.getStates(); 
        if( stateOptions != null && stateOptions.size() > 0 ){
            accountState = stateOptions[0].getValue();
        }

                    //Account Edit Details
            if(editAccount.Requires_Invoicing__c == null)
                SelectinvoiceOptions = 'No';
            else
                SelectinvoiceOptions = editAccount.Requires_Invoicing__c;
            isActive = editAccount.Active__c;
            
            if(isActive == true)
                AccountStatus = 'Active';
            else
                AccountStatus = 'InActive';
            
            federalIdNumber = editAccount.IA_Federal_ID_Nbr__c;
            if(null != editAccount.Email_Application_To__c  && editAccount.Email_Application_To__c != ''){
                EmailApplicableTo = editAccount.Email_Application_To__c;
            } 
            selectCreditStatus = editAccount.Credit_Status__c;
            isNeedToLock = selectCreditStatus == STR_PENDING || selectCreditStatus == STR_APPROVED ? true : false ;               
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
            if (!String.isBlank(editAccount.RWfB_Billing_Address_Line_3__c)){
                billingLine3 = editAccount.RWfB_Billing_Address_Line_3__c;
            }
            billingCity = editAccount.RWfB_Billing_Address_City__c;
            billingState = editAccount.RWfB_Billing_Address_State_Province__c;
            billingZipCode = editAccount.RWfB_Billing_Address_ZIP_Postal_Code__c;

            billingCountry = editAccount.RWfB_Billing_Address_Country__c;
            
            
            
            getStateCountryLabel();

            selectCreditStatus = editAccount.Credit_Status__c; 
            
        	accountPhone = editAccount.Phone;
            if (accountPhone != null){
                if (accountPhone.contains(' x')){
                    accountPhoneEdit = accountPhone.substringBefore(' x');
                    accountPhoneExt = accountPhone.substringAfter(' x');
                } else {
                    accountPhoneEdit = accountPhone;
                    accountPhoneExt = '';
                }        
            }
            SelectTaxExempt = editAccount.Tax_Exempt__c == null ? 'No' : editAccount.Tax_Exempt__c ;
            TaxNumber = editAccount.Tax_Id_Number__c;
            accountTypeSelect = editAccount.Company_Type__c;
            dunsNumber = editAccount.DunsNumber;
            selectOrgType = editAccount.Organization_Type__c;
            selectAccountCategory = editAccount.Account_Category__c;
            selectAccountType = editAccount.Company_Type__c;
            selectTaxIdType = editAccount.Tax_Id_Type__c;
            TaxExpiryDate = editAccount.Tax_Exempt_Expiration_Date__c;
            if(editAccount.Tax_Exempt_Expiration_Date__c != null){
                displayTaxExpiryDate = editAccount.Tax_Exempt_Expiration_Date__c.format();
            }
            TaxCertificateNumber = editAccount.IA_Tax_Exempt_Certificate_Nbr__c;
            accountOwner = editAccount.owner.name;
            accountNumber = editAccount.Account_Number_BPC__c;
            if(null != editAccount.NA_Distribution_Method__c){
                selectedserviceMethods = editAccount.NA_Distribution_Method__c.split(';');
            }
            selecttaxName = editAccount.Tax_Exemption_Reason__c;


            list<Account> acList = [Select Id, (Select Name,Id From RWfB_Attachments__r Where Type__c = 'Tax Exempt Certificate' And Public__c = true) From Account where Id = : accountId];
            if(acList.size()>0){
            
                List<Attachment> CheckAttachments = [Select id,Name,parentid  from Attachment where parentid In : acList[0].RWfB_Attachments__r ORDER BY Id DESC LIMIT 1];
                
                if(CheckAttachments.size() > 0){
                    //attid  = CheckAttachments[0].id;
                    AttachCertificate = CheckAttachments[0];
                    AttachCertificateName = AttachCertificate.Name;
                    AttachCertificateId = AttachCertificate.Id;
                }
            }
            getStateTaxExempt();
            displaySelectTaxName = getTaxExemptName();
            return null;
    }
    private String getTaxExemptName(){
        String retval = 'Unknown';
        for(SelectOption opt : exemptionreasonOption){
            if(opt.getValue() == selecttaxName){
                retval = opt.getLabel();
            }
        }
        return retval;
    }
    public Pagereference insertAccount(){
        system.debug('Begin RWS_AccountSetupController.insertAccount ************');    
        system.debug(accountzipCode + 'UAC : accountzipCode'); 
        system.debug('SelectTaxExempt is set to... ' + SelectTaxExempt);
        system.debug('Attachment name is ' + attachment.name);

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
            if(null != parentAccountId){
                createAccount.ParentId = parentAccountId;
                createAccount.Invoice_Parent_Account__c = 'No';
            }
            
            createAccount.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
            createAccount.Name = accountName;
            createAccount.IA_Physical_Location_Address_Line_1__c =  accountLine1;
            if (!String.isBlank(accountLine2)){
                createAccount.IA_Physical_Location_Address_Line_2__c = accountLine2;
            }

            if (!String.isBlank(accountLine3)){
                createAccount.IA_Physical_Location_Address_Line_3__c = accountLine3;
            }   

            createAccount.IA_Physical_Location_City__c = accountCity;
            createAccount.IA_Physical_Location_State_Province__c = accountState; //Jas-temp change
            createAccount.IA_Physical_Location_ZIP_Postal_Code__c = accountzipCode;
            createAccount.IA_Physical_Location_Country__c = accountCountry;  //Jas-temp
            
            
            createAccount.RWfB_Billing_Address_Line_1__c=  billingLine1;
            if (!String.isBlank(billingLine2)){
                createAccount.RWfB_Billing_Address_Line_2__c = billingLine2;
            }

            if (!String.isBlank(billingLine2)){
                createAccount.RWfB_Billing_Address_Line_3__c = billingLine3;
            }   

            createAccount.RWfB_Billing_Address_City__c= billingCity;
            createAccount.RWfB_Billing_Address_State_Province__c = billingState; 
            createAccount.RWfB_Billing_Address_ZIP_Postal_Code__c= billingZipCode;
            createAccount.RWfB_Billing_Address_Country__c= billingCountry;              
            
            if (selectBillingAddressOptions == 'Different'){
                billingSame = false;
            }
            
            createAccount.RWfB_same_as_Physical_Address__c = billingSame;
            
            getStateCountryLabel();

            createAccount.Phone = accountPhone;
            createAccount.Active__c = isActive;
            
            createAccount.Account_Category__c = 'Local';

            if(accountTypeSelect != '--Select--')
                createAccount.Company_Type__c =  accountTypeSelect;
            
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
                System.debug('Account object is ' + createAccount);
                System.debug('AccountName****'+accountName);
                upsert createAccount;
                
                //added by Joey, when init Account, also init the rwfb object, if SelectTaxExempt is slected
                if(SelectTaxExempt == 'Yes'){
                    RWfB_Attachment__c rwfb = new RWfB_Attachment__c();
                    rwfb.Account__c = createAccount.Id;
                    rwfb.Type__c = 'Tax Exempt Certificate';
                    rwfb.Public__c = true;
                    insert rwfb;
                    rwfbId = rwfb.Id;
                }

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
                
                ReloadIfNoAttachment = Label.Community_Name + 'RWS_Account_CreationV2?tab=account&id='+createAccount.id + '&rts=1';
                EditMode = true; //set to true because we just saved the account and have a new id
                /*
                pagereference pr = new pagereference('RWS_Account_CreationV2?tab=account&id='+createAccount.id);
                pr.setRedirect(true);
                return pr;// add sam
                */
            }
            catch(System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    System.debug('Error occurred in insert account ' + e.getDmlMessage(i)); 
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

        // Check duplication of Account else create Account
    public pagereference createAccountContact(){
        System.debug('*********Create Account Contact method');
        //Check duplication of Account based on Account Details 
        pagereference pr;
        duplicationMessage = '';
        Boolean ValidUser = isValidUser(Userinfo.getProfileId());
        if(ValidUser){
            String recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
            System.debug('UAC: accountName ' + accountName + ' accountLine1 ' + accountLine1 + ' accountLine2 ' + accountLine2 + ' accountLine3 ' + accountLine3 +' accountCity ' + accountCity + ' accountZipCode ' + accountZipCode);
            accList = [ SELECT Id,Name,IA_Physical_Location_Address_Line_1__c, Owning_Store__c, Account_Owner_Phone__c, Account_Owner_Name__c, 
                        IA_Physical_Location_City__c,IA_Physical_Location_ZIP_Postal_Code__c, IsRedWingOwned__c 
                        FROM Account 
                        WHERE ((Name = :accountName OR ( (IA_Physical_Location_Address_Line_1__c = :accountLine1 And IA_Physical_Location_Address_Line_1__c != null)  AND 
                                                            ((IA_Physical_Location_City__c = :accountCity AND IA_Physical_Location_City__c != null)  
                                                                OR (IA_Physical_Location_ZIP_Postal_Code__c = :accountZipCode AND IA_Physical_Location_ZIP_Postal_Code__c != null)) )) 
                                                    AND RecordTypeid =: recordType AND ParentId = null) 
                        LIMIT 1];
            System.debug('UAC: editMode ' + editMode +  'accList '+accList);
            
            
            
            if(accList.size()>0 && EditMode == false && accList[0].isRedWingOwned__c == false && String.isBlank(parentAccountId)){
                duplicationMessage = 'We detected an account already established for : ' + accountName;
                redirectToProgram = 'RWS_Account_CreationV2?tab=account&id='+accList[0].Id + '&rts=1';
            } else if (accList.size()>0 && EditMode == false && accList[0].isRedWingOwned__c == true && String.isBlank(parentAccountId)) {
                owningStore = accList[0].Owning_Store__c;
                ownerName = accList[0].Account_Owner_Name__c;
                ownerPhone = accList[0].Account_Owner_Phone__c;                
                duplicationMessage = 'We detected an account already established for : ' + accountName + '<br/> Account Owner: <br/>'+ ownerName + 
                                            (String.isBlank(owningStore) ? '' : '<br/>'+ owningStore) + 
                                            (String.isBlank(ownerPhone) ? '' : '<br/>'+ ownerPhone);
                redWingOwned = true;
            } else {             
                pr = insertAccount();  // Method to insert Account 
                system.debug('-== Here is the control'+pr);
                if(null != pr){
                    pr.setRedirect(true);
                    return pr;
                }
            }
        }
        system.debug('duplicationMessage ===: ' + duplicationMessage);
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

        //Get Tax Exemption Reason based on Account State 
    public void getStateTaxExempt(){ 
        try{
            System.debug('UAC: accountState ' + accountState );

            taxsearchresultList = new List<Tax_Exemption_Reason__c>();

            String soql = 'select id, Name,Applicable_To__c from Tax_Exemption_Reason__c Where Active__c = true AND ( Applicable_To__c = '+'\'All State/Provinces\'';
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
        }catch(Exception e){
            system.debug('error occurred: ' + e);
            ApexPages.addMessages(e);

        } 

    }

    public void AssignTaxExempt(){
        
        System.debug('**********selecttaxName :'+selecttaxName);
        try{
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
        
        if(ExemptReasons.Industrial_Account_Allowed__c == 'Y'){
            
            industrialAccount = 'Allowed';
        }
        else if(ExemptReasons.Industrial_Account_Allowed__c == 'N'){
            
            industrialAccount = 'NotAllowed';
        }
        
        if(ExemptReasons.National_Account_Allowed__c== 'Y'){
            
            nationalAccount= 'Allowed';
        }
        else if(ExemptReasons.National_Account_Allowed__c== 'N'){
            
            nationalAccount= 'Not Allowed';
        }
        
        if(ExemptReasons.City_Exempt__c== 'TRUE'){
            cityExempt = 'Exempt';
        }
        else if(ExemptReasons.City_Exempt__c== 'FALSE'){
            cityExempt = 'NotExempt';
        }
        
        if(ExemptReasons.State_Exempt__c== 'TRUE'){
            stateExempt = 'Exempt';
        }    
        else if(ExemptReasons.State_Exempt__c== 'FALSE'){
            stateExempt= 'NotExempt';
        }
        
        if(ExemptReasons.County_Exempt__c== 'TRUE'){
            countyExempt= 'Exempt';
        }
        else if(ExemptReasons.County_Exempt__c== 'FALSE'){
            countyExempt= 'NotExempt';
        }
        
        if(ExemptReasons.Country_Exempt__c== 'TRUE'){
            countryExempt= 'Exempt';
        }
        else if(ExemptReasons.Country_Exempt__c== 'FALSE'){
            countryExempt= 'NotExempt';
        }
        }catch(Exception e){
            system.debug('################################ Error occurred in AssignTaxExempt ' + e);
        }

        
        System.debug('********industrialAccount :'+industrialAccount);
    }

    @RemoteAction
    public static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId, String PageNameToReload) {
        if(acctId != null) {
            Account acct = [Select id, Name from Account where id =: acctId limit 1];
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
                    //pr.setRedirect(true);
                    //System.debug('-=-= Page redirects to:'+pr);
                    //return pr;
                    return ''+PageNameToReload+'?tab=account&id='+acctId;
                    
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
    public void removeTaxCertificate(){
        system.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Inside attachCertificate metnod');
        system.debug('fileData is ' + fileData);
    }
    
}