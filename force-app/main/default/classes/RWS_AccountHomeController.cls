Public with sharing class RWS_AccountHomeController{

   
    // UA: 05-Oct: added transient keyword to avoid view state limit
    public transient String jsonResult     {set;get;}
    public transient List<AccountWrap> accListWrap {get;set;}
    
    //added by Joey
    public Boolean isFullAccessUser {get;set;}
    
    //added by BW for accountList search
    public String searchBoxFilter { get; set; }
    
    public List<SelectOption> accountViews
    {
        get
        {
            if(accountViews == null )
            {
                accountViews = new List<SelectOption>();
                accountViews.add(new SelectOption('National Accounts', 'National Accounts'));
                accountViews.add(new SelectOption('Active Store Accounts', 'Active Store Accounts'));
                accountViews.add(new SelectOption('Inactive Store Accounts', 'Inactive Store Accounts'));
            }
            return accountViews ;
        }
        set; 
    }
    
    public String selectedAccountView {get; set; }
   
    //query variables
    public String searchTerm {get; set;}
    public String query {get; set;}
    Id currentUserId {get; set;}        
    String recordtypeid {get; set;}
    String programSubQuery {get; set;}
    set<id> editableAccts {get; set;}
        
            
    //Constructor
    public RWS_AccountHomeController()
    {
        //initialize and assign values to query variables
        currentUserId = UserInfo.getUserId();        
        recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
        programSubQuery = '';
        editableAccts = new set<Id>();
        searchTerm = '';
        searchBoxFilter = 'active';
        
        // added by Joey
        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();      
        
       
        
        //sets the correct list view for user based on limited user custom setting - BW 7/7/17
        if (isFullAccessUser){
            selectedAccountView = 'Active Store Accounts';
        } else {
            selectedAccountView = 'National Accounts';
        }
        
        setQueryListView();        
        getAccounts();
        
    }
    
    //method to set query for list views
    //RW: (Rajani on 9/13/2019) --- Adding RWBAA AR Data on Account Screen
    public void setQueryListView(){
        system.debug('1*****==>' +selectedAccountView);
        
        query = 'SELECT Credit_Approval_Indicator__c, Id, Name, Active__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, NA_Account_Status__c, Activation_Date__c, Account_Number_BPC__c, ' +
                    'Credit_Status__c, IA_Physical_Location_City__c, IA_Physical_Location_State_Province__c, AccountNumber, Owning_Store__c, Recourse_Customer__c, (SELECT Id, Name FROM Programs__r ' + programSubQuery + ') , ' +
					'(SELECT Accounts_Receivable_Alert__c, Accounts_Receivable_Alert_Color__c, '+ 
					'Credit_Hold_Alert__c, Credit_Hold_Alert_Color__c, '+
					'Credit_Limit_Alert__c, Credit_Limit_Alert_Color__c FROM RWBAA_AR_Data__r)' +
					'FROM Account ' +
                    'WHERE RecordTypeId = :recordtypeid ';
        
        
       
        
            if(selectedAccountView == 'National Accounts') query += ' AND Organization_Type__c =\'National\' and Active__c = true ' ;
            if(selectedAccountView == 'Active Store Accounts') query += ' AND (Owner.Contact.Account.RecordType.Name = \'M3 Store Parent Account\' OR Owner.Contact.Account.RecordType.Name = \'M3 Store Child Account\')  and Active__c = true ' ;
            if(selectedAccountView == 'Inactive Store Accounts') query += ' AND (Owner.Contact.Account.RecordType.Name = \'M3 Store Parent Account\' OR Owner.Contact.Account.RecordType.Name = \'M3 Store Child Account\')  and Active__c = false ' ;
        
        
        query += ' limit 1000 ';


    }
    
    //method to set query for search box
    public void setQuerySearch(){
        system.debug('2*****==>'+searchTerm+'----'+searchBoxFilter);        
        query = 'SELECT Credit_Approval_Indicator__c, Id, Name, Active__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, NA_Account_Status__c, Activation_Date__c, Account_Number_BPC__c, ' +
                    'Credit_Status__c, IA_Physical_Location_City__c, IA_Physical_Location_State_Province__c, Recourse_Customer__c, AccountNumber, Owning_Store__c, (SELECT Id, Name FROM Programs__r ' + programSubQuery + ') , ' +
					'(SELECT Accounts_Receivable_Alert__c, Accounts_Receivable_Alert_Color__c, '+ 
					'Credit_Hold_Alert__c, Credit_Hold_Alert_Color__c, '+
					'Credit_Limit_Alert__c, Credit_Limit_Alert_Color__c FROM RWBAA_AR_Data__r)' +
                    'FROM Account ' +
                    'WHERE RecordTypeId = :recordtypeid ';//Id =\'001W000000Xrnsn\' and 
        
        
         //Sets query for Active Accounts Only search box option
        if (searchBoxFilter == 'active'){
            query += 'AND Active__c = true';
        }

       
        
        //Sets query for My Store Accounts search box option
        if (searchBoxFilter == 'myStore'){
            
            for(AccountShare acs : [select AccountAccessLevel, AccountId from AccountShare where UserOrGroupId =: UserInfo.getUserId() and (AccountAccessLevel = 'Edit' or AccountAccessLevel = 'All') ]){
                editableAccts.add(acs.AccountId);
            }
            query += 'AND Id in: editableAccts';
        }
        
         if(!String.isBlank(searchTerm)) {
            searchTerm = String.escapeSingleQuotes(searchTerm);
            query += ' AND (Name like \'%' + searchTerm + '%\' OR AccountNumber like \'%' + searchTerm + '%\') ' ;
         }
         
        query += ' limit 1000 ';


    }
        
    public void getAccounts()
    {
        accListWrap = new List<AccountWrap>();
       
        //Id currentUserId = UserInfo.getUserId() ;
        
        /*
        User currentUser = [select Id, Contact.Account.Store_Ownership_Type__c, Contact.Account.Dealer__c, 
                                    Contact.Account.Region_Code__c, Contact.AccountId, AccountId
                            from User 
                            where Id = :UserInfo.getUserId()];

        Set<Id> allAccountIds = new Set<Id>();
        
        if(currentUser.Contact.AccountId != null)
            allAccountIds.add(currentUser.Contact.AccountId);
        
        if(currentUser.Contact.Account.Dealer__c != null) {
            for(Account a : [select Id, Dealer__c from Account 
                             where Dealer__c = :currentUser.Contact.Account.Dealer__c]) {
                                 
                allAccountIds.add(a.Id);
            }
        }
        
        Set<Id> userIds = new Set<Id>();
        for(User u : [select Id from User where Contact.AccountId in :allAccountIds]) {
            userIds.add(u.Id);
        }
        
        userIds.add(currentUser.Id);
        */

        
        // if(selectedAccountView == 'Store Accounts' || selectedAccountView == 'Pending Accounts') 
        //    programSubQuery = ' where Active__c = true ';

      /*  
      
        String recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Partner Community').getRecordTypeId();
        String programSubQuery = '';
      
        query = 'SELECT Credit_Approval_Indicator__c, Id, Name, Active__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, NA_Account_Status__c, Activation_Date__c, Account_Number_BPC__c, ' +
                    'Credit_Status__c, IA_Physical_Location_City__c, IA_Physical_Location_State_Province__c, AccountNumber, Owning_Store__c, (SELECT Id, Name FROM Programs__r ' + programSubQuery + ') ' +
                    'FROM Account ' +
                    'WHERE RecordTypeId = :recordtypeid ';//' AND Id IN :industrialAccountSet ';
        


        //Sets query for Active Accounts Only search box option
        if (searchBoxFilter == 'active'){
            query += 'AND Active__c = true';
        }

        set<id> editableAccts = new set<Id>();
        
        //Sets query for My Store Accounts search box option
        if (searchBoxFilter == 'myStore'){
            
            for(AccountShare acs : [select AccountAccessLevel, AccountId from AccountShare where UserOrGroupId =: UserInfo.getUserId() and (AccountAccessLevel = 'Edit' or AccountAccessLevel = 'All') ]){
                editableAccts.add(acs.AccountId);
            }
            query += 'AND Id in: editableAccts';
        }
        
        System.debug('Find Me: ' + query);

        if(!String.isBlank(searchTerm)) {
            searchTerm = String.escapeSingleQuotes(searchTerm);
            query += ' AND (Name like \'%' + searchTerm + '%\' OR AccountNumber like \'%' + searchTerm + '%\') ' ;
        } else {
            if(selectedAccountView == 'National Accounts') query += ' AND Organization_Type__c =\'National\' and Active__c = true ' ;
            if(selectedAccountView == 'Store Accounts') query += ' AND (Owner.Account.RecordType.Name = \'M3 Store Parent Account\' OR Owner.Account.RecordType.Name = \'M3 Store Child Account\')  and Active__c = true ' ;
            if(selectedAccountView == 'Pending Accounts') query += ' AND (Owner.Account.RecordType.Name = \'M3 Store Parent Account\' OR Owner.Account.RecordType.Name = \'M3 Store Child Account\')  and Active__c = false ' ;
        }
        
        query += ' limit 1000 ';
        */
        
        System.debug('Query to be run: ' + query);
        
        List<Account> accountList = Database.query(query);
        
        System.debug('Returned Account List: ' + accountList);
        
        User currentUser = [select Id, CompanyName
                            from User 
                            where Id = :currentUserId];
        System.debug('User Info: ' + currentUser);
                           
        for(Account obj : accountList)
        {            
            AccountWrap wrapObj = new AccountWrap();            
            wrapObj.AccountAlerts = new Map<string,string>();
            wrapObj.NoOfPrograms = obj.Programs__r.size();                    
            if(currentUser.CompanyName == obj.Owning_Store__c)
            {
	 			if(obj.RWBAA_AR_Data__r.size() != 0)
	            {
	                List<RWBAA_AR_Data__c> rwbaaList = obj.RWBAA_AR_Data__r;
	                for(RWBAA_AR_Data__c rwbaa : rwbaaList)
	                {    
	                    System.debug('Company Name: ' + currentUser.CompanyName + ' ' + ' ' + obj.Owning_Store__c);                    
	
	                        if(rwbaa.Accounts_Receivable_Alert__c != null){        		            		
	                            wrapObj.AccountAlerts.Put(rwbaa.Accounts_Receivable_Alert__c, rwbaa.Accounts_Receivable_Alert_Color__c);
	                        }  
	                        if(rwbaa.Credit_Hold_Alert__c != null)    
	                        {      		
	                            wrapObj.AccountAlerts.Put(rwbaa.Credit_Hold_Alert__c, rwbaa.Credit_Hold_Alert_Color__c);     
	                        }     
	                        if(rwbaa.Credit_Limit_Alert__c != null){   		
	                            wrapObj.AccountAlerts.Put(rwbaa.Credit_Limit_Alert__c, rwbaa.Credit_Limit_Alert_Color__c);            		
	                        }
	                         System.debug('RWBAA to Map: ' + wrapObj.AccountAlerts);
	                }
	            }
	            else if (obj.Credit_Status__c == 'Credit Hold'){
	            	wrapObj.AccountAlerts.Put('CH','RED');
	            }
            }
            wrapObj.AccountAlertSize = wrapObj.AccountAlerts.size();
            wrapObj.URLEdit = 'RWS_Account_CreationV2?tab=account&link=edit&id='+obj.id;
            wrapObj.URLSummary = 'AccountSummary?tab=account&id='+obj.id;
            wrapObj.URLAccountAlert = 'RWS_AccountRwbaaSummary?id='+obj.id;
            wrapObj.accObj = obj;
            
            if(obj.Active__c == False){
                wrapObj.Active = 'Inactive';
            }
            else{
                wrapObj.Active = 'Active';
            }
            
            //Sets Location column for Accounts list datatable - BW 7/7/17
            if  (obj.IA_Physical_Location_City__c == null && obj.IA_Physical_Location_City__c == null){
                 wrapObj.Location = 'Not Available';
            } else if (obj.IA_Physical_Location_City__c == null && obj.IA_Physical_Location_City__c != null){
                 wrapObj.Location = obj.IA_Physical_Location_State_Province__c ;
            } else if (obj.IA_Physical_Location_City__c != null && obj.IA_Physical_Location_City__c == null){
                 wrapObj.Location =  obj.IA_Physical_Location_City__c;
            } else {
                wrapObj.Location =  obj.IA_Physical_Location_City__c + ', ' + obj.IA_Physical_Location_State_Province__c ;
            }
            accListWrap.Add(wrapObj);
        }
        
        searchTerm = '';
        
        System.debug('Account List Wrapper: ' + accListWrap);
        
        jsonAccountList();

    }
    public void jsonAccountList(){
        jsonResult = JSON.serialize(AccListWrap);
        jsonResult = String.escapeSingleQuotes(jsonResult);
        
        System.debug('JSON account list: '+ jsonResult);
    }
    
    public PageReference RedirectToEdit(String Id){
        return null;
    }

    public class AccountWrap{
        String URLEdit {get;set;}
        String URLSummary {get;set;}
        String URLAccountAlert {get;set;}
        Integer NoOfPrograms {get;set;}        
        String Active {get;set;}
        String Location {get;set;}
        Map<string,string> AccountAlerts {get;set;}
        Integer AccountAlertSize {get;set;}
        Account AccObj {get;set;}
    }
}