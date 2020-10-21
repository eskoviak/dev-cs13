public class RWS_EditAccounController {

    public String duplicationMessage { get; set; }
    public Account editAccount { get; set; }
    public Contact editContact { get; set; }
    public List<Account> accList;
    public Account createAccount;
    public Contact createContact;
    public String accountId;
    
    
    // Controller 
    public RWS_EditAccounController(){
        string Id= Apexpages.currentpage().getparameters().get('id');
        //accountId = Apexpages.currentpage().getparameters().get('id');
        createAccount = new Account();
        createContact = new Contact();
        accList = new List<Account>();
        duplicationMessage = '';
        editAccount = [select id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode from Account where id =: Id];//accountId
        editContact = [select id,FirstName,LastName,Email,Phone,Title,Fax,AccountId from Contact where AccountId =:editAccount.id limit 1];
        
    }
    
    // Save Account,Contact
    public void updateAcccountContact(){
            System.debug('*********Update Account Contact method');
        //Check duplication of Account based on Account Details 
        accList = [select Id,Name from Account where Name =:editAccount.Name]; 
        //AND BillingStreet = :accountStreet
        //AND BillingCity = :accountCity 
        //AND BillingState = :accountState
        //AND BillingPostalCode = :accountZipCode];
        system.debug('accList ===: ' + accList.size());
        if(accList.size()>0){
            duplicationMessage = 'We detected an account already established for : ' + editAccount.Name;
            //throw error message for duplication account 
        }
        else{
            finalUpdateAcccountContact();  // Method to update Account and contact records.
        }
        system.debug('duplicationMessage ===: ' + duplicationMessage);
        
    }
    
    public void finalUpdateAcccountContact(){
        createAccount.Id = editAccount.Id;
        createAccount.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M3 Wholesale Accounts').getRecordTypeId();
        createAccount.Name = editAccount.Name;
        if (editAccount.BillingStreet!= null){
            createAccount.BillingStreet =  editAccount.BillingStreet;
        }
        createAccount.BillingCity = editAccount.BillingCity;
        createAccount.BillingState = editAccount.BillingState;
        createAccount.BillingPostalCode = editAccount.BillingPostalCode;
        createAccount.NA_Account_Status__c = 'Inactive';
        try{
            update createAccount;
            if(createAccount.id!=Null){
                createContact.Id = editContact.Id;
                createContact.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General Contact').getRecordTypeId();
                createContact.AccountId = createAccount.id;
                createContact.FirstName = editContact.FirstName;
                createContact.LastName = editContact.LastName;
                createContact.Email = editContact.Email;
                createContact.Phone = editContact.Phone;
                //createContact.Active__c = isActive;
                createContact.Title = editContact.Title;
                createContact.Fax = editContact.Fax;
                //createContact.MobilePhone = contactmobilePhone;
                //createContact.Role__c = contactRole;
                //createContact.Contact_Preference__c = contactPreference;
                update createContact;
            }
        }
        catch(Exception e){
            //TODO: implement something here?
        }
    }
}