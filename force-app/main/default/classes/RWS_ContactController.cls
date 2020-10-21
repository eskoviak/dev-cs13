public class RWS_ContactController {
    //Contact Properties
    public Boolean ContactEditOrView {get;set;}
    public List<contact> contactList {get;set;}
    public String PrimaryContactEmail {
        get{return 'ABC';}
    }
    public Contact con { get; set; }
    public String contactFirstName {get;set;}
    public String contactLastName {get;set;}
    public String contactEmail {get;set;}
    public String contactPhoneNo {get;set;}
    public String contactPhoneNoEdit {get;set;}
    public String contactPhoneNoExt {get;set;}
    public Boolean isActive {get;set;}
    public String contactTitle {get;set;}
    public String contactFax {get;set;}
    public String contactMobilePhone {get;set;}
    public String SelectContactPreference {get;set;}
    public Account editAccount { get; set; }
    public Contact editContact { get; set; }
    public Account createAccount { get; set; }
    public Contact createContact {get; set;}
    public String contactId   { get; set; }
    public String accountId {get;set;}
    public List<SelectOption> ContactPref {get;set;}
    public List<SelectOption> ContactRoles {get;set;}
    public String[] SelectedRoles {get;set;}
    public String SelectedRolesV2 {get;set;}
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
    public String SameAsPrimaryContactInfo {get;set;}
    public String ContactCompleteAddress {get;set;}

    public String SelectinvoiceOptions{get;set;}
    public Boolean primaryContactError {get; set;} 
   
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
    public String billingCountry {get;set;}
    public String sameAsbillingAddress {get;set;}

    public String EmailApplicableTo {get;set;}
    public String deletedContactId {get;set;}


    public List<SelectOption> ContactStateOptions {get;set;}  
    public List<SelectOption> ContactCountryOptions {get;set;} 
    public Boolean isNeedToLock{ get; set; }
    public string selectCreditStatus {get;set;}
    public final String STR_PENDING = 'Pending';
    public final String STR_APPROVED = 'Approved/Active';
    
    public RWS_ContactController(){
        initialize();
    }
    

    public pagereference initialize(){
 
      
      
        SelectedRoles = new List<string>();
        ContactAddressOptions = RWS_UtilityClass.getAddressPreference();
        ContactStateOptions = RWS_UtilityClass.getContactStates(); 
        ContactCountryOptions = RWS_UtilityClass.getContactCountries(); 
        ContactRoles = RWS_UtilityClass.getcontactRoles();
        selectContactAddressOptions = 'Same as Physical';
        createContact = new Contact();
        accountId = Apexpages.currentpage().getparameters().get('id');        
        if(accountId != null )
        {
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
                                   Tax_Exempt_Expiration_Date__c,Open_Date__c,Credit_Status__c,Requested_Credit_Limi__c,Credit_Limit__C,Billing_Frequency__c,
                                   BPC_Payment_Terms__c,Invoice_Delivery_Method__c,Preferred_Payment_Method__c,Email_Application_To__c,MSTS_ID__c,
                                   MultiService_Credit_Application_ID__c,Credit_Application_Sent_Date__c,Credit_Application_Approval_Date__c,Active__c,
                                   Requires_Invoicing__c,Send_Application__c,IA_Federal_ID_Nbr__c
                           FROM Account WHERE ID =: accountId];

            system.debug('***** RWS_ContactController : ' + editAccount != null ? 'Account Name' + editAccount.Name : 'Account not found');

            //Account Edit Details
            if(editAccount.Requires_Invoicing__c == null)
                SelectinvoiceOptions = 'No';
            else
                SelectinvoiceOptions = editAccount.Requires_Invoicing__c;

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

            if(String.isBlank(sameAsAccountAddress)) sameAsAccountAddress = 'There is no address entered for Account.' ;
            
            if( !String.isBlank(billingLine1) ) sameAsbillingAddress = billingLine1 ;
            if( !String.isBlank(billingLine2) ) sameAsbillingAddress += ', ' + billingLine2 ;
            if( !String.isBlank(billingLine3) ) sameAsbillingAddress += ', ' + billingLine3 ;
            if( !String.isBlank(billingCity) ) sameAsbillingAddress += ', ' + billingCity ;
            if( !String.isBlank(billingState) ) sameAsbillingAddress += ',\n ' + billingState ;
            if( !String.isBlank(billingCountry) ) sameAsbillingAddress += ', ' + billingCountry ;
            if( !String.isBlank(billingzipCode) ) sameAsbillingAddress += ', ' + billingzipCode ;

            if(String.isBlank(sameAsbillingAddress)) sameAsbillingAddress = 'There is no address entered for Account.' ;

            selectCreditStatus = editAccount.Credit_Status__c;
            isNeedToLock = selectCreditStatus == STR_PENDING || selectCreditStatus == STR_APPROVED ? true : false ;

            initContactAndAccount();
        }
        
        return null;  
    }

    private void initContactAndAccount() {
        if(accountId != null )
        {
            
            //need to load the contact list on first initialization        
            contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Title,Role__c from Contact where AccountId =:accountid  ];
            
            List<Contact> contactPrimary = [SELECT ID, name, FirstName, LastName, Email, Phone,BPR_Role__c,Title,Address_same_as_Accounts__c,Contact_Same_as_Primary__c,
                MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry, Role__c
                 from Contact where AccountId =:editAccount.id AND Contact_Identifier__c IN ('Primary & Billing', 'Primary') limit 1];
            
            if(contactPrimary != null && contactPrimary.size() > 0){
                
                SameAsAccountAddress = contactPrimary [0].FirstName + ', ' + contactPrimary [0].LastName + ',\n ' + contactPrimary [0].Email + ', ' + contactPrimary [0].Phone + ', ' + contactPrimary[0].Title;

                if(EmailApplicableTo == null || EmailApplicableTo == ''){
                    EmailApplicableTo = contactPrimary[0].Email;
                }
                
                contactFirstName = contactPrimary [0].FirstName;
                contactLastName = contactPrimary [0].LastName;
                contactEmail = contactPrimary [0].Email;
                contactPhoneNo = contactPrimary [0].Phone;
                if (contactPhoneNo != null){
                    if (contactPhoneNo.contains(' x')){
                        contactPhoneNoEdit = contactPhoneNo.substringBefore(' x');
                        contactPhoneNoExt = contactPhoneNo.substringAfter(' x');
                    } else {
                        contactPhoneNoEdit = contactPhoneNo;
                        contactPhoneNoExt = '';
                    }        
                }
                SelectContactAddressOptions = contactPrimary [0].Address_same_as_Accounts__c;
                SelectedRolesV2 = contactPrimary [0].Role__c ;
                SelectedRoles = String.isNotBlank(contactPrimary [0].Role__c) ? contactPrimary [0].Role__c.split('\\;') : null;
                contactTitle = contactPrimary [0].Title;
                contactStreetAddress = contactPrimary [0].MailingStreet;
                contactCity = contactPrimary [0].MailingCity;
                contactState = contactPrimary [0].MailingState;
                contactZipCode = contactPrimary [0].MailingPostalCode;
                contactCountry = contactPrimary [0].MailingCountry;

            }
        }
    }
    public void setToTrue(){
        ContactEditOrView = true;
    }
    
        
    
    public pagereference createContact(){
        
        System.debug('Begin RWS_ContactController.CreateContact *******' );
        
        try{
            primaryContactError = false;
            System.debug('Inside Contact****'+contactFirstName+'-=-=ContactEditOrView :'+ContactEditOrView +'SelectedRoles **'+SelectedRoles+'contactId***'+contactId);
            System.debug('+_+_+_+_+_+_+_+_+_+_+_+_ Roles for insert are ' + SelectedRoles);
            String accountid = Apexpages.currentpage().getparameters().get('id');//add sam

            if( String.isBlank(accountid)) {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Please fill account information first to create contact '));
                return null ;
            }

            System.debug('UAC: accountId ' + accountId );
            for(String role: SelectedRoles){
                if((role == 'Primary Contact' || role == 'Billing Contact')){// && null == contactId 
                    Integer primaryContactCount = [Select count() from Contact where AccountId =: accountid AND BPR_Role__c = :selectedRoles AND Id != :contactId];//'Primary Contact'
                    System.debug('UAC: primaryContactCount ' + primaryContactCount );
                    if(primaryContactCount>0){
                        //set member variable saying error occurred
                        primaryContactError = true;
                        contactId = '';
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Primary Contact already exists.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }

                }            
            }

            createAccount = [Select id, Name from Account where id =: accountId];
            
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
                
                //James Loghry (Demand Chain)
                //The logic here was wrong and would always append an "x" to the phone number, resulting in an invalid contact phone number (throws a validation rule error...)
                if(!String.isEmpty(contactPhoneNoExt)){
                    contactPhoneNo = contactPhoneNoEdit+' x'+contactPhoneNoExt;            
                } else {
                    contactPhoneNo = contactPhoneNoEdit;
                }
                createContact.Phone = contactPhoneNo;
                createContact.Title = contactTitle;
                
                
                string roles;
                //Commented out by Tory per discussion with Project Lead. Wizard workflow allows only one contact to be created.
                //ASSUMPTION: Wizard workflow only allows on contact to be created.
                //if(SelectedRoles == 'Primary Contact'){

                createContact.Role__c = string.join(SelectedRoles,';');
                createContact.Contact_Identifier__c = 'Primary';

                createContact.Address_same_as_Accounts__c = SelectContactAddressOptions;
                
                
                if(SelectContactAddressOptions == 'Different'){
                    createContact.MailingStreet = contactStreetAddress;
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
                for(String role: SelectedRoles){
                    if(role == 'Primary Contact'){
                        SameAsPrimaryContactInfo = createContact.FirstName + ', ' + createContact.LastName + ',\n ' + createContact.Email + ', ' + createContact.Phone + ', ' + createContact.Title;
                        if(EmailApplicableTo == null || EmailApplicableTo == ''){
                            EmailApplicableTo = createContact.Email;
                        }
                    }                    
                }

                initContactAndAccount();

                //createContact = new Contact();
                //createContact.id=null;
                /*
                contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Title,Role__c  from Contact where AccountId =:accountid AND BPR_Role__c != 'Billing Contact' ];
                System.debug('after insert Contact list -=-=-=-= '+contactList);
                */
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
        
        System.debug('End RWS_ContactController.CreateContact *******' );
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
        SelectContactAddressOptions = 'Same as Account';
        contactStreetAddress = '';
        contactCity = '';
        contactState = '';
        contactZipCode = '';
        contactCountry = '';
        contactId = '';
        ContactCompleteAddress = '';
        createContact = new contact();
    }
    
    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }

    public void deleteContact(){
        try{
            con = [Select Id,Name from Contact where id = :deletedContactId limit 1];
            delete con;
            
            contactList = [Select id, name, FirstName, LastName, Email, Phone,BPR_Role__c,Title from Contact where AccountId =:editAccount.id AND BPR_Role__c != 'Billing Contact'];
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
                              MailingStreet,
                              MailingCity ,
                              MailingState ,
                              MailingPostalCode ,
                              MailingCountry 
                              from Contact where id=:deletedContactId limit 1];
            
            contactFirstName = createContact.FirstName;
            contactLastName = createContact.LastName;
            contactEmail = createContact.Email;
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
            SelectContactAddressOptions = createContact.Address_same_as_Accounts__c;
            contactStreetAddress = createContact.MailingStreet;
            contactCity = createContact.MailingCity;
            contactState = createContact.MailingState;
            contactZipCode = createContact.MailingPostalCode;
            contactCountry = createContact.MailingCountry;
            contactId = createContact.id;
            ContactEditOrView = true;
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
}