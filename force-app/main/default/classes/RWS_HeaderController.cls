/********************************************************************************
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   7/07/2017  Joey Zhuang/M360        Add user access level indicator
********************************************************************************/
Public class RWS_HeaderController{

    public String LoggedInUserName {get;set;}
    //added by Joey
    public Boolean isFullAccessUser {get;set;}
    public Integer recourseNumber {get;set;}
    
    public RWS_HeaderController(){
        string userId = UserInfo.getUserId();
        User UserObj = [Select ID,Name from User where ID=:userId limit 1];
        LoggedInUserName = UserObj.Name;
        recourseNumber = 0;
        System.debug('-=-= USer name: '+LoggedInUserName );
        // added by Joey
        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();
        
        
        Id accountId = [select Contact.AccountId from User where Id = :UserInfo.getUserId()].Contact.AccountId;
        
        if(accountId == null) return;
        
        Set<Id> userIds = new Map<Id, User>(
            [select Id from User where Contact.AccountId = :accountId]
        ).keySet();
        
        if(userIds.isEmpty()) return;
        
        recourseNumber = [select Id from Account where OwnerId in :userIds and Recourse_Customer__c != null].size();
        
    }
    
}