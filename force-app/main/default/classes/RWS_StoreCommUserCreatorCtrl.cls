/**
 * RWSStoreCommUserCreatorCtrl
 * @description Visualforce controller for creating a single community user around the store.
 * @date 7/31/2017
 * @author James Loghry (Demand Chain Systems)
 */
public with sharing class RWS_StoreCommUserCreatorCtrl {

    private Account acct {get; set;}
    private String firstname {get; set;}
    private String lastname {get; set;}
    private String email {get; set;}
    private String username {get; set;}
    private String nickname {get; set;}
    private String profileId {get; set;}
    private String pass {get; set;}
    private String contactRecordTypeId {get; set;}
    
    /**
     * VF Extension Controller Constructor
     */
    public RWS_StoreCommUserCreatorCtrl(ApexPages.StandardController sc){
        //Prevent running into a long existing defect that arises 
        //when calling addFields when invoked in a test context.
        if(!Test.isRunningTest()){
            sc.addFields(new List<String>{'AccountNumber'});
        }
        acct = (Account)sc.getRecord();
        
        RWS_Store_Community_User_Setting__mdt setting = 
            [Select 
                Username__c,
                Default_Pass__c,
                Email__c,
                ProfileId__c,
             	Contact_Record_Type__c
             From 
                RWS_Store_Community_User_Setting__mdt 
            Where 
                QualifiedApiName='RWS'];
        
        Profile profile = [Select Id From Profile Where Name = :setting.ProfileId__c];
        
        RecordType rt = [Select Id From RecordType Where DeveloperName = :setting.Contact_Record_Type__c];

        this.firstname = 'Store';
        this.lastname = '' + acct.AccountNumber;
        this.email = setting.Email__c;
        this.profileId = profile.Id;
        this.contactRecordTypeId = rt.Id;
        
        List<String> formatParms = new List<String>{acct.AccountNumber};
        this.username = String.format(setting.Username__c,formatParms);
        this.pass = String.format(setting.Default_Pass__c,formatParms);
    }
    
    public PageReference createCommunityUser(){
        Id userId = null;
        Savepoint sp = Database.setSavepoint();
        try{
            Contact c = new Contact(
                Firstname = firstname
                ,Lastname = lastname
                ,Email = email
                ,AccountId = acct.Id
                ,RecordTypeId = contactRecordTypeId
            );
            insert c;
            
            User u = new User(
                Username = username
                ,Email = email
                ,Firstname = firstname
                ,Lastname = lastname
                //,UserPreferencesHideS1BrowserUI = true
                ,CommunityNickname = nickname
                ,ContactId = c.Id
                ,ProfileId = profileId
                ,LanguageLocaleKey='en_US'
                ,LocaleSidKey='en_US'
                ,TimezoneSidKey='America/Chicago'
                ,EmailEncodingKey='UTF-8'
                ,Alias='rwsstore'
            );
            
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail = false;
            dlo.optAllOrNone = true;
            Database.saveresult sr = Database.insert(u,dlo);
            
            System.setPassword(u.Id,pass);

            userId = u.Id;
            //Site.createPortalUser(u, acct.id, pass);      
            
            //Id userId = Site.createExternalUser(u,acct.Id);
            
        }catch(Exception ex){
            Database.rollback(sp);
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'..username: ' + this.username + ' ' + ex.getMessage()));
            return null;
        }
             
        if(ApexPages.getMessages().isEmpty()){
            String userLink = '<a href="/' + userId + '" target="_parent">' + userId + '</a>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'User successfully created, with id: ' + userLink));
        }
        return null;
    }
}