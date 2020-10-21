public with sharing class RWS_RwbaaARSummaryController {
	
	public string accountId {get;set;}
	public string query {get;set;}
	Id currentUserId {get; set;} 
	
	public String AccountName {get;set;}
    public String AccountNumber {get;set;}
	public String ARLastModifiedDate {get;set;}
	public String RwbaaId {get;set;}
	public String CurrentAmount {get;set;}
	public String UnappliedPayment {get;set;}	
	public String TotalCreditLine {get;set;}
	public String RemainingCredit {get;set;}
	public String DaysLate1to7 {get;set;}    
	public String DaysLate8to14 {get;set;}
	public String DaysLate15to30 {get;set;}
	public String DaysLate31to45 {get;set;}
	public String DaysLate46to60 {get;set;}    
	public String DaysLateOver60 {get;set;} 
	public List<Contact> RWFBContacts {get;set;}
	public List<RWBAA_Contacts__c> RWBAAContacts {get;set;}
	
	//Constructor
	public RWS_RwbaaARSummaryController(){
		currentUserId = UserInfo.getUserId(); 
		accountId = Apexpages.currentpage().getparameters().get('id');
		setQuery();
        getRwbaaARData();
	}
    
    public void setQuery(){
    	query = 'select id,Name, MSTS_ID__c, AccountNumber, ' +
	    			'(select id,LastModifiedDate, MSTS_AR_Current__c,MSTS_Unapplied_Payment__c,MSTS_Credit_Limit__c,MSTS_Available_Credit__c,' +
            			'MSTS_AR_1_to_7__c, MSTS_AR_8_to_14__c, MSTS_AR_15_to_30__c,MSTS_AR_31_to_45__c,' +
						'MSTS_AR_46_to_60__c,MSTS_AR_61_to_90__c,MSTS_AR_91_to_120__c,MSTS_AR_121_to_150__c,MSTS_AR_Over_150__c from RWBAA_AR_Data__r),' +
					'(select id, RWBAA_First_Name__c, RWBAA_Last_Name__c, RWBAA_Contact_Type__c,RWBAA_Phone__c,RWBAA_Email_Address__c,RWBAA_Bill_Send_Type__c,' +
						'RWBAA_Active__c from RWBAA_Contacts__r Order by RWBAA_Active__c DESC, RWBAA_Bill_Send_Type__c DESC),' + 
					'(select id, FirstName, LastName,Contact_Identifier__c,Phone,Title,Email,Active__c from Contacts Order by Active__c DESC, Contact_Identifier__c DESC)' + 
				'from account where id = :accountId limit 1000';
        System.debug('Query: ' + accountId + query);
    }
    
    public void getRwbaaARData(){
    	List<Account> account = Database.query(query);
    	User  myUser = [select id,TimeZoneSidKey from user where id = :currentUserId ];
    	System.debug('Returned Account: ' + myUser + account);
    	
    	for(Account acctObj : account){ 		
    		AccountName = acctObj.Name;
    		RwbaaId = acctObj.MSTS_ID__c;
            AccountNumber = acctObj.AccountNumber;
            RWBAAContacts = new List<RWBAA_Contacts__c>();
    			RWBAAContacts = acctObj.RWBAA_Contacts__r;
            RWFBContacts = new List<Contact>();
    			RWFBContacts = acctObj.Contacts;
    		if(acctObj.RWBAA_AR_Data__r.size() != 0)
            {
            	List<RWBAA_AR_Data__c> rwbaaARData = acctObj.RWBAA_AR_Data__r;
            	for(RWBAA_AR_Data__c arData : rwbaaARData)
            	{
    				CurrentAmount = checkNull('$' + arData.MSTS_AR_Current__c);
    				ARLastModifiedDate = checkNull(arData.LastModifiedDate.format('MM/dd/yyyy hh:mm a z', myUser.TimeZoneSidKey));
    				UnappliedPayment = checkNull('$' + arData.MSTS_Unapplied_Payment__c);
    				TotalCreditLine = checkNull('$' + arData.MSTS_Credit_Limit__c);
    				RemainingCredit = checkNull('$' + arData.MSTS_Available_Credit__c);
    				DaysLate1to7 = checkNull('$' + arData.MSTS_AR_1_to_7__c);                    
    				DaysLate8to14 = checkNull('$' + arData.MSTS_AR_8_to_14__c);
    				DaysLate15to30 = checkNull('$' +  arData.MSTS_AR_15_to_30__c);
    				DaysLate31to45 = checkNull('$' + arData.MSTS_AR_31_to_45__c);
    				DaysLate46to60 = checkNull('$' + arData.MSTS_AR_46_to_60__c);
    				DaysLateOver60 = checkNull('$' + (arData.MSTS_AR_61_to_90__c + arData.MSTS_AR_91_to_120__c 
    											+ arData.MSTS_AR_121_to_150__c + arData.MSTS_AR_Over_150__c));
            	}
            }
    		System.debug('RWFB Contacts: ' + RWFBContacts);
    		System.debug('RWBAA Contacts: ' + RWBAAContacts); 
    		System.debug('CurrentAmount: ' + CurrentAmount);
    		    		
    	}
    }
    
    private String checkNull(string data){
    	if(data.contains('null'))
    	{
    		return '-';
    	}
    	return data;
    }
}