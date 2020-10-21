/**
 * LeadAssignmentHandler
 * Utility / Helper class for dealing with lead assignment, particular using the Zip Code Assignment table for providing
 * zip code territories and Sales representative roles.
 * @author Demand Chain Systems
 * @Date  11/15/2015
 *
 */

//TODO: Add Lead assignment helper on/off custom setting
//Todo: default owner RD -field
public with sharing class LeadAssignmentHelper {
    
    public static boolean hasAlreadyRun = false;

	//This method will loop through records on before * triggers, and attempt to map the state to its
	//2-char code.  This is to address the fact that some reps (not all) enter the state in the full-name versus 
	//the 2char abbreviation.
	public static void fixLeadStates(List<Lead> leadsToFix){
		//Grab the custom metadata mapping and create an Apex map.
		//Im also using toLowerCase, so there's no funky misses on capitilization weirdness.
		Map<String,String> stateMapping = new Map<String,String>();
		for(State_Mapping__mdt sm : [SELECT MasterLabel,Abbreviation__c FROM State_Mapping__mdt]){
			stateMapping.put(sm.MasterLabel.toLowerCase(),sm.Abbreviation__c);
		}

		for(Lead l : leadsToFix){
			if(!String.isEmpty(l.State)){
				String state = stateMapping.get(l.State.toLowerCase());
				//State may be null if it's aready the 2 char version or no match is found.
				if(state != null){
					l.State = state;
				}
			}
		}
	}

	public static void assignLeadsByZipcode(List<Lead> leadsToAssign){
		APEX_Trigger_Settings__c triggerSetting = APEX_Trigger_Settings__c.getValues('LeadAssignmentHelper');
		if(triggerSetting == null || triggerSetting.IsActive__c){
			//Get a list of the available roles by priority (stored in the Lead Assignment Role list custom setting).
			Map<String,Lead_Assignment_Role__c> roleMap = Lead_Assignment_Role__c.getAll();

			//Construct a map of zip codes to the leads that are connected with those zip codes.
			Set<String> zipcodes = new Set<String>();
			for(Lead l : leadsToAssign){
				String zipcodeOrCountryCode = getZipcodeOrCountryCode(l);
				if(!String.isEmpty(zipcodeOrCountryCode)){
					zipcodes.add(zipcodeOrCountryCode);
				}
			}

			System.debug('JWL: zipcodes: ' + zipcodes);

			List<Zip_Code_Area_Assignment__c> zipAssignments =
				[Select
					Account_Owner__r.Name
					,Role__c
					,Zipcode__c
					,State_Name__c
				 From
				 	Zip_Code_Area_Assignment__c
				 Where
				 	IsActive__c = true
				 	And Zipcode__c in :zipcodes];

			System.debug('JWL: zipAssignments: ' + zipAssignments);


			Map<String,String> stateMapping = new Map<String,String>();
			for(State_Mapping__mdt sm : [SELECT MasterLabel,Abbreviation__c FROM State_Mapping__mdt]){
				stateMapping.put(sm.MasterLabel.toLowerCase(),sm.Abbreviation__c);
			}
			System.debug('JWL: stateMapping: ' + stateMapping);

			//Query for any zip codes that pertain to leads in this scope.
			//Then loop through the zip codes and roles to determine which lead gets assigned to which sales rep.
			for(sObject l : leadsToAssign){
				String zipOrCountry = getZipcodeOrCountryCode((Lead)l);
				System.debug('JWL: zipOrCountry: ' + zipOrCountry);
				for(Zip_Code_Area_Assignment__c zcaa : zipAssignments){
					if(zcaa.Role__c != null && zcaa.Account_Owner__r != null && zcaa.Zipcode__c == zipOrCountry){
						System.debug('JWL: zcaa: ' + zcaa);
						Lead_Assignment_Role__c assignmentRole = roleMap.get(zcaa.Role__c);
						l.put(assignmentRole.Lead_Role_Field__c,zcaa.Account_Owner__r.Name);

						if(!String.isEmpty(zcaa.State_Name__c)){
							String state = stateMapping.get(zcaa.State_Name__c.toLowerCase());
							if(state != null){
								l.put('State',state);
							}
						}
					}
				}
				System.debug('JWL: lead after: ' + l);
			}
		}
	}

	private static String getZipcodeOrCountryCode(Lead l){
		String zip = (String.isEmpty(l.postalCode) || l.PostalCode.length() <= 5) ? l.PostalCode : l.PostalCode.substring(0,5);
		return (String.isEmpty(l.Country) || l.Country == 'US' || l.Country == 'USA') ? zip : l.Country;
	}
}