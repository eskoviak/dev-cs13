/**
*   {Purpose}  �  Supports the SafetyShoeSearch / National Acct Participant Store Locator VF page
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20141020    Andy Boettcher DCS      Created
*   20150224    Andy Boettcher DCS      Refactored for Account-first to allow for
*                                       single-line reporting of accounts and zips
*   20151120    James Loghry DCS        Added parameter to remote action  method and refactored a bit to support searching by city
*   20160325    James Loghry            Refactored controller and VF pages to better accomondate larger requests.  The controller now
*                                       kicks off a batch job that rights temporary records to an object, and then reads those records
*                                       once the batch job completes.
*    =============================================================================
*/
public without sharing class SafetyShoeSearchController {

    public Integer radius {get; set;}

    public SafetyShoeSearchController() {}

    @RemoteAction
    public static ZipCodeInfoWrapper getZipcodeInformation(List<String> criteria,String searchBy,Decimal distance){
        ZipCodeInfoWrapper ans = new ZipCodeInfoWrapper(distance);

        String zipQuery =
            'Select ' +
                'Id' +
                ',Name' +
                ',Location__c' +
                ',Location__Latitude__s' +
                ',Location__Longitude__s' +
                ',City__c' +
                ',State__c' +
                ',City_State__c ' +
            'From ' +
                'ZipCodeLatAndLong__c ' +
            'Where ';

        zipQuery += (searchBy == 'city') ? ' City_State__c in :criteria' : ' Name in :criteria';

        zipQuery += ' Order By Name Asc';

        for(ZipCodeLatAndLong__c zip : (List<ZipCodeLatAndLong__c>)Database.query(zipQuery)){
            ans.zipResults.add(zip);
        }

       for(Account a :
            [Select
                Id
                ,Longitude__c
                ,Latitude__c
                ,Name
                ,AccountNumber
                ,Mobile_Truck__c
                ,Store_Ownership_Type__c
                ,Store_Email__c
                ,M3_Location_Street__c
                ,M3_Location_City__c
                ,M3_Location_State_Province__c
                ,M3_Location_Zip_Postal_Code__c
                ,Phone
                ,Store_Number__c
            From
                Account
            Where
                Longitude__c != null
                And Latitude__c != null
                And Active_Store__c = true
                And National_Account_Participant__c = true
            Limit 40000]){
            ans.accountResults.add(a);
        }

        return ans;
    }

    public class ZipCodeInfoWrapper{
        public Decimal distance {get; private set;}
        public List<ZipCodeLatAndLong__c> zipResults {get; private set;}
        public List<Account> accountResults {get; private set;}
        public ZipCodeInfoWrapper(Decimal distance){
            this.distance = distance;
            this.zipResults = new List<ZipCodeLatAndLong__c>();
            this.accountResults = new List<Account>();
        }
    }
}