public class TruckMobileExpirationNotify {

/**
*   {Purpose}  �  Public class that will be used via a Scheduled APEX Job
*                 
*   {Function}  �  Support of scheduled tasks to send emails based on Account and Truck contract metrics
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20131007    Andy Boettcher DCS      Created
*   =============================================================================
*/
    
    private static AutomatedEmailNotifications__c csEmailSettings;
    
    private static Boolean bolEmailSettings(String strSettingName) {
        
        Boolean bolReturn = false;
        List<AutomatedEmailNotifications__c> lstAENs = AutomatedEmailNotifications__c.getAll().values();
        
        for(AutomatedEmailNotifications__c aen : lstAENs) {
            if(aen.Name == strSettingName && aen.IsActive__c) {
                csEmailSettings = aen;
                bolReturn = true;
            }
        }
        
        return bolReturn;
        
    }
    
    
    @future
    public static void processExpirations(String strSettingName) {
        
        Map<Id, Truck_for_Store__c> mapScope = new Map<Id, Truck_for_Store__c>();
        //List<Truck__c> lstUpdateTrucks = new List<Truck__c>();
        Map<Id, Truck__c> mapUpdateTrucks = new Map<Id, Truck__c>();
        //List<Account> lstUpdateAccounts = new List<Account>();
        Map<Id, Account> mapUpdateAccounts = new Map<Id, Account>();
        Map<Id, List<String>> mapTeams = new Map<Id, List<String>>();
        List<Messaging.singleEmailMessage> lstEmails = new List<Messaging.singleEmailMessage>();
        
        // Determine Email Settings 
        if(!bolEmailSettings(strSettingName)) {
            Util.notifyProfileOfError('System Administrator', 'Mobile Truck and Account Expiration Job Failure', 'The automated job that notifies ' +
                 'Mobile Trucks was not able to find an active Custom Setting record for *' + strSettingName + '*.  Please check the Custom Setting!');
            return;
        }
        
        System.Debug(LOGGINGLEVEL.ERROR, 'RUNNING SETTING = ' + strSettingName); 
        
        // Assign CS values to variables
        String strEmailTemplateId = csEmailSettings.Email_Template_ID__c;
        Integer intTimeframe = Integer.valueOf(csEmailSettings.Timeframe__c);
        String strTimeframeCriteria = csEmailSettings.Timeframe_Criteria__c;
        String strRoleList = csEmailSettings.Team_Member_Roles__c;
        Boolean bolExpirationSent = csEmailSettings.Expiration_Sent__c;
        String strOrgWideEmailId = csEmailSettings.OrgWide_Email_Id__c;
        String strStoreTypes = csEmailSettings.Account_Types__c;
        String strExpirationSentField = csEmailSettings.Expiration_Sent_API_Name__c;
        String strExpirationDateField = csEmailSettings.Expiration_Field_API_Name__c;

        
        // Parse Store (Account) Types
        Set<String> setStoreTypes = new Set<String>();
        for(String strType : strStoreTypes.split('\\|')) {
            setStoreTypes.add(strType);
        }
        
        // Parse Date
        String strYear = string.ValueOf(System.Today().addDays(intTimeframe).Year());
        String strMonth = string.ValueOf(System.Today().addDays(intTimeframe).Month());
        String strDay = string.ValueOf(System.Today().addDays(intTimeframe).Day());
        if(strMonth.length()==1){ strMonth = '0' + strMonth; }
        if(strDay.length()==1){ strDay = '0' + strDay; }
        String strDate = strYear + '-' + strMonth + '-' + strDay;
        
        // Pull all Users into a MAP
        Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Email FROM User WHERE IsActive = true]);
        
        // Create query to pull Expiring Trucks
        String strQuerySELECT = 'SELECT Store__c, Store__r.Name, Truck__c ';
        if(strExpirationSentField != null) { strQuerySelect += ', ' + strExpirationSentField + ' '; }
        if(strExpirationDateField != null) { strQuerySelect += ', ' + strExpirationDateField + ' '; }
        String strQueryFROM = 'FROM Truck_for_Store__c ';
        String strQueryWHERE = 'WHERE ' + strExpirationDateField + ' ' + strTimeframeCriteria + ' ' + strDate +
                                ' AND Store__r.Store_Ownership_Type__c IN :setStoreTypes ' +
                                ' AND ' + strExpirationSentField + ' = ' + bolExpirationSent;
                                
        String strQuery = strQuerySELECT + strQueryFROM + strQueryWHERE;
        
        System.Debug(LOGGINGLEVEL.ERROR, '***** - ' + strQuery);
        
        List<Truck_for_Store__c> lstScope = Database.Query(strQuery);
        
        // Get unique Account Teams and create list of Roles
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setTeamMemberRoles = new Set<String>();
        
        // Unique Stores (Accounts)
        for(Truck_for_Store__c tfsRecord : lstScope) {
            setAccountIds.add(tfsRecord.Store__c);
        }
        
        // Unique Account Team Roles
        for(String strRole : strRoleList.split('\\|')) {
            setTeamMemberRoles.add(strRole);
        }
        
        System.Debug(LOGGINGLEVEL.ERROR,'TEAM ROLES = ' + setTeamMemberRoles);

        
        
        // Create Map for Account Emails based on Account Team Role
        List<String> lstLoopEmails = new List<String>();
        Id idAccountLoop; Integer intCountLoop = 1;
        
        List<AccountTeamMember> lstTeamMembers = [SELECT AccountId, User.Email FROM AccountTeamMember WHERE AccountId IN :setAccountIds AND TeamMemberRole IN :setTeamMemberRoles ORDER BY AccountId]; 
        for(AccountTeamMember atmRecord : lstTeamMembers) {

            if(idAccountLoop == null) { idAccountLoop = atmRecord.AccountId; }

            // Account Id Change Management
            if(idAccountLoop != null && idAccountLoop != atmRecord.AccountId) {
            	System.Debug(LOGGINGLEVEL.ERROR, 'SAVING LIST - ' + lstLoopEmails + ' TO AccountId ' + idAccountLoop);
                mapTeams.put(idAccountLoop, lstLoopEmails);             
                lstLoopEmails = new List<String>();
                idAccountLoop = atmRecord.AccountId;
            }
            
            // Add Email to List
            System.Debug(LOGGINGLEVEL.ERROR, 'ADDING CC - ' + atmRecord.User.Email + ' TO LIST');
            lstLoopEmails.add(atmRecord.User.Email);
            
            // Handle last record in list
            if(intCountLoop == lstTeamMembers.size()) {
                mapTeams.put(idAccountLoop, lstLoopEmails);
            }
            
            // Loop
            intCountLoop++;
            
        }
        
        System.Debug(LOGGINGLEVEL.ERROR,'EMAIL ADDRESSES = ' + lstLoopEmails);
        
        // Create "fake" contact to enable mailing with templates
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'no-reply@redwingshoes.com';
        insert con;
            
        // Loop through all records and add to email list
        for(Truck_for_Store__c tfsRecord : lstScope) {
            
            System.Debug(LOGGINGLEVEL.ERROR, '**** - TESTING ' + tfsRecord.Store__c);
            
            if(mapTeams.get(tfsRecord.Store__c) != null) {
                
                System.Debug(LOGGINGLEVEL.ERROR, '**** - PROCESSING ' + tfsRecord);
                System.Debug(LOGGINGLEVEL.ERROR, '**** - CC LIST ' + mapTeams.get(tfsRecord.Store__c));
                
                Messaging.singleEmailMessage msg = new Messaging.singleEmailMessage();
                msg.setTemplateId(strEmailTemplateId);
                msg.setCcAddresses(mapTeams.get(tfsRecord.Store__c));
                if(strOrgWideEmailId != null) { msg.setOrgWideEmailAddressId(strOrgWideEmailId); }
                msg.setTargetObjectId(con.Id);
                msg.setWhatId(tfsRecord.Id);
                msg.setSaveAsActivity(false);
                
                // Add Email to Bulk List
                lstEmails.add(msg);
                
                // Update Status Checkbox Field
                if(strExpirationSentField == 'Truck__r.IsExpirationEmailSent__c') {
                    if(!tfsRecord.Truck__r.IsExpirationEmailSent__c) {
                        //lstUpdateTrucks.add(new Truck__c(Id=tfsRecord.Truck__c,IsExpirationEmailSent__c=true));
                        mapUpdateTrucks.put(tfsRecord.Truck__c, new Truck__c(Id=tfsRecord.Truck__c,IsExpirationEmailSent__c=true));
                    }
                }
                
                if(strExpirationSentField == 'Store__r.IsDealerExpirationEmailSent__c') {
                    if(!tfsRecord.Store__r.IsDealerExpirationEmailSent__c) {
                        //lstUpdateAccounts.add(new Account(Id=tfsRecord.Store__c,IsDealerExpirationEmailSent__c=true));
                        mapUpdateAccounts.put(tfsRecord.Store__c, new Account(Id=tfsRecord.Store__c,IsDealerExpirationEmailSent__c=true));
                    }
                }
            }
            
        }

        // Send All Emails
        if(lstEmails.size() > 0) {
            Messaging.sendEmail(lstEmails);
        }
        
        // Update all Trucks
        if(mapUpdateTrucks.size() > 0) {
            update mapUpdateTrucks.values();
        }
        
        // Update All Accounts
        if(mapUpdateAccounts.size() > 0) {
            update mapUpdateAccounts.values();
        }
        
        // Clean up Contact!
        delete con;
        
    }
    
    public static void scheduleJobs() {

        schedule_ContractExpiration clsCRON = new schedule_ContractExpiration();
        String strSchedule ='0 0 6 * * ?';
        system.schedule('Account and Truck Contract Expiration Emails',strSchedule, clsCRON);
        
    }

}