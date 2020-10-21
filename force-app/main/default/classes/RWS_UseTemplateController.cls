/********************************************************************************
*   PURPOSE : Controller for template selection
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   			M360			        Initial version*
*	03/08/18	Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_UseTemplateController {
    Id programId;
    public RWS_UseTemplateController() {
        programId = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference createClone() {
        SavePoint sp = Database.setSavepoint();

        try {
            Program__c existingProgram = getProgram();

            if(existingProgram.Processing_Status__c != 'Completed') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please use this Program Template when its processing is completed.'));
                return null;
            }

            Id programRecordTypeId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Program', 'Program__c');

            Program__c newProgram = existingProgram.clone(false, true);

            newProgram.RecordTypeId = programRecordTypeId;
            newProgram.Template__c = false;
            newProgram.OwnerId = UserInfo.getUserId();
            newProgram.Processing_Status__c = 'Scheduled';

            insert newProgram;

            List<Publish_PriceBook__c> pbs = [SELECT Name, CurrencyIsoCode, IsActive__c, 
                                        //Description, 
                                        Program__c, //Type__c, 
                                        Discount__c//, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                        //Future_Pricebook__c, Effective_Date__c 
                                    FROM Publish_PriceBook__c where Program__c = :programId];

            if(!pbs.isEmpty()) {
                Publish_PriceBook__c newPb = pbs[0].clone(false, true);
                newPb.Program__c = newProgram.Id;

                insert newPb;

                List<Publish_PriceBook_Entry__c> pbes = [select Style_Number__c,
                                            Fixed_Price__c,
                                            Filter_Number__c,
                                            Discount__c 
                                        FROM Publish_PriceBook_Entry__c where Publish_PriceBook__c = :pbs[0].Id];

                List<Filter_Criteria__c> criterias = [SELECT OwnerId, CurrencyIsoCode, Program__c, 
                                            IA_Feature__c, Filter_Name__c, 
                                            Filter_BE_Details__c, Filter_Display__c, 
                                            Filter_Number__c, Discount__c, 
                                            Results_Count__c,
                                            Product_Code__c 
                                          FROM Filter_Criteria__c
                                          WHERE Program__c = :programId];

                System.debug(pbes.size() + ' pbes: ' + pbes);
                System.debug(criterias.size() + ' criterias: ' + criterias);

                insert RWS_UseTemplate_Util.scheduleProgram(newProgram.Id, criterias, pbes, true);
                           
            }

            return new PageReference('/' + newProgram.Id + '/e?retURL=%2F' + newProgram.Id );

        } catch(DmlException ex) {
            ApexPages.addMessages(ex);
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        if(ApexPages.hasMessages()) {
            Database.rollback(sp);
        } 

        return null;
    }

    private Program__c getProgram() {
        return [SELECT OwnerId, Name, CurrencyIsoCode, RecordTypeId, Account__c, 
              Accessories_Allowed_on_Subsidy__c,
              Accessories_Allowed_on_Payroll_Deduction__c, 
              Activation_Date__c,
              Active__c,
              Alternative_Payment__c,
              Annual_Reset_or_Rollover__c,
              Auto_Add_Products__c ,
              Auto_Update_Price__c,
              Description__c, 
              Eligibility_Option__c, 
              Exclusive__c,
              Expiration_Date__c,
              Fixed__c,
              Frequency__c,
              GSA_Pricing__c,
              HasPricebook__c,
              Mandatory__c, 
              Max_Amount__c,
              Number_of_Eligible_Employees__c,
              Number_of_Locations__c, 
              Number_of_Pairs_Allowed__c,
              Open_Subsidy__c, 
              Outbound_Message_Type__c,
              Proposal_Notes__c,
              Publish_Status__c,
              Published_Date__c, 
              Purchase_Program_Notes__c,
              Require_Upload_of_Company_Voucher__c,
              Rolling_Balance__c,
              Sales_Opportunity_Pairs__c,
              Sales_Contract__c,
              Sales_Contract_Reference__c,
              Servicing_Level__c,
              Subsidy_Amount__c,
              Subsidy_Frequency__c,
              Subsidy_Notes__c, 
              Subsidy_Percent__c,
              Subsidy_Tax__c,
              Subsidy_Type__c, 
              Template__c,
              TXMAS_Pricing__c,
              Type__c, 
              Voucher_Distribution__c,
              Processing_Status__c
            FROM Program__c where Id = :programId];
    }
}