public with sharing class RWS_ProgramTemplate_Queue  implements Queueable {
	private Id programId;
	private String programName;
	public RWS_ProgramTemplate_Queue(Id programId, String programName) {
		this.programId = programId;
		this.programName = programName;
    }

    public void execute(QueueableContext context) {
	    Program__c program = [SELECT Id, Name, Account__c, Account__r.Name, Owner.Name,
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
	              Servicing_Level__c,
	              Subsidy_Amount__c,
	              Subsidy_Frequency__c,
	              Subsidy_Notes__c, 
	              Subsidy_Percent__c,
	              Subsidy_Tax__c,
	              Subsidy_Type__c, 
	              Template__c,
	              TXMAS_Pricing__c,
	              toLabel(Type__c), 
	              Voucher_Distribution__c,
	              Processing_Status__c,
	              RecordTypeId
	            FROM Program__c where Id = :programId];

	    Id programRecordTypeId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Program_Template', 'Program__c');

        program.RecordTypeId = programRecordTypeId;

	    program.Account__c = null;
        program.Id = null;
        program.Active__c = false;
        program.Name = programName;

        for(SelectOption so : RWS_UtilityClass.getType() ) {
            if(so.getLabel() == program.Type__c) {
                program.Type__c = so.getValue();
                break;
            }
        }

        insert program;

        List<Filter_Criteria__c> fcs = [SELECT OwnerId, CurrencyIsoCode, Discount__c, 
                                    Filter_BE_Details__c, Filter_Display__c, 
                                    Filter_Number__c, IA_Feature__c, 
                                    Program__c, Results_Count__c,
                                    Product_Code__c
                                FROM Filter_Criteria__c 
                                where Program__c = :programId];

        List<Filter_Criteria__c> newFcs = new List<Filter_Criteria__c>();

        for(Filter_Criteria__c fc : fcs) {

            Filter_Criteria__c cloneFc = fc.clone(false, true);

            cloneFc.Program__c = program.Id;

            newFcs.add(cloneFc);
        }

        insert newFcs;


        List<Pricebook2> pbs = [SELECT Name, CurrencyIsoCode, IsActive, 
                                    Description, 
                                    Program__c, Type__c, 
                                    Discount__c, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                    Future_Pricebook__c, Effective_Date__c 
                                FROM Pricebook2 where Program__c = :programId];

        if(!pbs.isEmpty()) {

            Pricebook2 newPb = pbs[0].clone(false, true);
            newPb.Program__c = program.Id;

            insert newPb;

            List<PricebookEntry> pbes = [select Pricebook2Id, Product2Id, CurrencyIsoCode, 
                                        UnitPrice, IsActive, UseStandardPrice, 
                                        Discount__c, RWS_Last_Updated_Date__c, RWS_Id__c, 
                                        MSRP_Effective_Date__c, MSRP_Expiration_Date__c, 
                                        Fixed_Price__c, Filter_Number__c 
                                    FROM PricebookEntry where Pricebook2Id = :pbs[0].Id
                                    and CurrencyIsoCode = :UserInfo.getDefaultCurrency()];

            List<PricebookEntry> newPbes = new List<PricebookEntry>();

            Set<Id> productIds = new Set<Id>();

            for(PricebookEntry pb : pbes) {

                productIds.add(pb.Product2Id);

                PricebookEntry clonePbe = pb.clone(false, true);

                clonePbe.Pricebook2Id = newPb.Id;

                newPbes.add(clonePbe);

                if(newPbes.size() == 200) {
                	insert newPbes;

                	newPbes = new List<PricebookEntry>();
                }
            }
            
            if(!newPbes.isEmpty()) {
            	insert newPbes;
            }

            RWS_PriceBookEntry_Util.createPublishPriceBookEntries(newPb.Id, productIds);

        }

	}
}