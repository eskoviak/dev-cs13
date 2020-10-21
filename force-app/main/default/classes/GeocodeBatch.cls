/**
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 2013-05-15    Mike Eaton      Added support for use of custom setting 
                                    email addresses by the notification routine   
* 2013-07-13    Mike Eaton      Added query LIMIT to prevent Google APU usage violation
* 2013-07-14    Mike Eaton      Added query WHERE M3_Location_Street__c != NULL     
* 2013-07-31    Mike Eaton      Updated QUERY_LIMIT to 500  
* 2013-07-31    Mike Eaton      Changed failedUpdates datatype from Double to Integer 
* 2020-07-10    Chris Mollet    Commentted out - DC Case 8433                             
* {Date}        {Changed By}    ({Ticket}) – {Change Description}
* =============================================================================
*/

global class GeocodeBatch /*implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts*/ {

    Public GeocodeBatch(){
    //Do Nothing
    }
/*   
    static string QUERY_LIMIT = '500';
    integer failedUpdates{get; set;}
    global string Query {get; set;}
 
    global GeocodeBatch(){ 
        failedUpdates = 0;
    }
    
    // 2013-06-30 [M.Eaton] - Updated to use new M3 related address fields
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('---ENTERING start---');
        if(Query == null)
            Query = 'SELECT id, M3_Location_Street__c, M3_Location_City__c, M3_Location_State_Province__c, M3_Location_ZIP_Postal_Code__c ' + 
                    'FROM Account WHERE M3_Location_Street__c != NULL AND Geocode_Status__c = \'Pending\' LIMIT ' + QUERY_LIMIT;
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> lScope){
        List<Account> lAccounts = (List<Account>)lScope;
        List<Account> lAccountsToUpdate = new List<Account>();
        List<Account> lFailedAccounts = new List<Account>();
        
        system.debug('---ENTERING execute---');
        
        for(Account oAccount : lAccounts){
            GoogleMapsHelper oGMH = new GoogleMapsHelper();
            
            String sLandmarkAddress = '';
            
            if(Util.NullCheck(oAccount.M3_Location_Street__c) != '')
                sLandmarkAddress += Util.NullCheck(oAccount.M3_Location_Street__c) + ', ';
            if(Util.NullCheck(oAccount.M3_Location_City__c) != '')
                sLandmarkAddress += Util.NullCheck(oAccount.M3_Location_City__c) + ', ';
            if(Util.NullCheck(oAccount.M3_Location_State_Province__c) != '')
                sLandmarkAddress += Util.NullCheck(oAccount.M3_Location_State_Province__c) + ', ';
            if(Util.NullCheck(oAccount.M3_Location_ZIP_Postal_Code__c) != '')
                sLandmarkAddress += Util.NullCheck(oAccount.M3_Location_ZIP_Postal_Code__c) + ', ';
            
            MapHelper.Landmark oLandmark = new MapHelper.Landmark();
            
            try{
                oLandmark = oGMH.geocodeLandmark(EncodingUtil.URLENCODE(sLandmarkAddress,'UTF-8'));
            }catch(Exception e){
                lFailedAccounts.add(new Account(id = oAccount.Id, Geocode_Status__c = 'Failed', Geocode_Message__c = e.getMessage()));
                failedUpdates++;
                continue;
            }
            
            if(oLandmark.longitude != null && oLandmark.latitude != null)
            {   
                oAccount.Latitude__c = oLandmark.latitude;
                oAccount.Longitude__c = oLandmark.longitude;
                oAccount.Geocode_Status__c = 'Success';
                oAccount.Geocode_Message__c = '';
                
                lAccountsToUpdate.add(oAccount);
            }else{
                lFailedAccounts.add(new Account(id = oAccount.Id, Geocode_Status__c = 'Failed'));
                failedUpdates++;
            }
        }

        List<Database.SaveResult> dsrs = Database.update(lAccountsToUpdate, false);
        for(Database.SaveResult dsr : dsrs){
            if(!dsr.isSuccess()){
                failedUpdates++;
                dsr.getId();
                
                lFailedAccounts.add(new Account(id = dsr.getId(), Geocode_Status__c = 'Failed'));
            }
        }
        
        try{
            update lFailedAccounts;
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    // 06-30-2013 [M.Eaton] - Updated to support customized NotificationSettings object
    global void finish(Database.BatchableContext BC){
    
    // TODO - Design Considerations:
    //    1 - What if no custom NotificationSetting record exists (ie. oSetting=NULL)? 
    //        a - Do not send OR send to Admin?
    //
        system.debug('---ENTERING finish---');
        try{
            
            AsyncApexJob a = [SELECT id, ApexClassId, 
                           JobItemsProcessed, TotalJobItems, 
                           NumberOfErrors, CreatedBy.Email 
                           FROM AsyncApexJob 
                           WHERE id = :BC.getJobId()];
            
            String emailMessage = 'Your batch job '
                 + 'Google Geocoding '
                 + 'has finished.  It executed ' 
                 + a.totalJobItems 
                 + ' batches.  Of which, ' + a.jobitemsprocessed 
                 + ' processed without any exceptions thrown and ' 
                 + a.numberOfErrors +
                 ' batches threw unhandled exceptions.'
                 + '  Of the batches that executed without error, ' 
                 + failedUpdates 
                 + ' records were not updated successfully.';
            
            //  Leverage new custom NotificationSettings object 
            NotificationUtils.SettingData oNS = NotificationUtils.getNotificationSettings('geocode');
            if( oNS != NULL ) {
                system.debug(oNS);
                if( oNS.isActive == true) {
                    //  send apex job notifications
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    //  2013-06-30 [M.Eaton] - Removed next line per business request
                    //String[] toAddresses = new String[] {a.createdBy.email};
                    
                    system.debug(oNS.listToEmail);
                    system.debug(oNS.replyToEmail);
                    system.debug(oNS.listCcEmail);
                    system.debug(emailMessage);
                    system.debug(oNS.listToEmail);
                    
                    mail.setToAddresses(oNS.listToEmail);
                    mail.setReplyTo(oNS.replyToEmail);
                    mail.setCcAddresses(oNS.listCcEmail);
                    mail.setSenderDisplayName('Geocode Batch Job Summary');
                    mail.setSubject('Geocode Batch job completed');
                    mail.setEmailPriority('High');
                    mail.setPlainTextBody(emailMessage);
                    mail.setHtmlBody(emailMessage);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                }
            }
        }
        catch (Exception ex){
            system.debug(ex.getMessage());
        }
    }*/
    
}