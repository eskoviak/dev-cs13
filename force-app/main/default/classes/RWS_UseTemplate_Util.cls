/********************************************************************************
*   PURPOSE : Utility class to support program template selection/creation
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   			M360			        Initial version
*	03/08/18	Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
public with sharing class RWS_UseTemplate_Util {
	public static List<Filter_Criteria__c> newCriterias;
	public static Program_Scheduler__c scheduleProgram(Id programId, List<Filter_Criteria__c> criterias, List<Publish_PriceBook_Entry__c> ppbes, Boolean insertFCs) {

        Map<String, Decimal> customProductCodes = new Map<String, Decimal>();
        Set<String> customFPCs = new Set<String>();
        Map<Integer, Set<String>> productCodesMap = new Map<Integer, Set<String>>();
        Map<Integer, Set<String>> fpcsMap = new Map<Integer, Set<String>>();

        for(Publish_PriceBook_Entry__c ppbe : ppbes) {
          System.debug('ppbe: ' + ppbe);
          if(ppbe.Filter_Number__c == null) ppbe.Filter_Number__c = 0;

          if(ppbe.Discount__c == null) ppbe.Discount__c = 0;

          Integer filterNumber = ppbe.Filter_Number__c.intValue();

          if(filterNumber == 0) {
            customProductCodes.put(ppbe.Style_Number__c, ppbe.Discount__c);

            if(ppbe.Fixed_Price__c) customFPCs.add(ppbe.Style_Number__c);

          } else {
            Set<String> productCodes = productCodesMap.get(filterNumber);
            Set<String> fpcs = fpcsMap.get(filterNumber);

            if(productCodes == null) {
              productCodes = new Set<String>();
              fpcs = new Set<String>();

              productCodesMap.put(filterNumber, productCodes);
              fpcsMap.put(filterNumber, fpcs);
            }

            productCodes.add(ppbe.Style_Number__c);


            if(ppbe.Fixed_Price__c) fpcs.add(ppbe.Style_Number__c);
          }
        }

        newCriterias = new List<Filter_Criteria__c>();
        Boolean hasCustomList = !customProductCodes.isEmpty();
        Boolean foundCustomList = false;

        System.debug('productCodesMap: ' + productCodesMap);
        System.debug('fpcsMap: ' + fpcsMap);
        System.debug('customProductCodes: ' + customProductCodes);
        System.debug('customFPCs: ' + customFPCs);

        for(Filter_Criteria__c fc : criterias) {
        	System.debug('fc: ' + fc);
            if(fc.Filter_Number__c == null) fc.Filter_Number__c = 0;

            Integer filterNumber = fc.Filter_Number__c.intValue();

            if(fc.Filter_Number__c == 0) {
              foundCustomList = true;
              fc.Product_Code__c = JSON.serialize(customProductCodes) + '-FPC-' + JSON.serialize(customFPCs);
            } else {

              Set<String> productCodes = productCodesMap.get(filterNumber);
              Set<String> fpcs = fpcsMap.get(filterNumber);

              if(productCodes == null) {
                productCodes = new Set<String>();
                fpcs = new Set<String>();
              }
              fc.Product_Code__c = JSON.serialize(productCodes) + '-FPC-' + JSON.serialize(fpcs);
            }

            Filter_Criteria__c criteria = fc.clone(false, true);

            criteria.Program__c = programId;

            newCriterias.add(criteria);
        }

        System.debug(hasCustomList + ' - ' + foundCustomList);

        if(hasCustomList && !foundCustomList) {
          Filter_Criteria__c fc = new Filter_Criteria__c();

          fc.Program__c = programId;
          fc.Filter_Number__c = 0;
          fc.Filter_Display__c = 'CUSTOM LIST';
          fc.Product_Code__c = JSON.serialize(customProductCodes) + '-FPC-' + JSON.serialize(customFPCs);
          fc.Results_Count__c = customProductCodes.size();
          fc.Discount__c = 0;

          newCriterias.add(fc);
        }


		if(insertFCs) insert newCriterias;

        return new Program_Scheduler__c(Program__c = programId, 
          Program_Template_Name__c = null, 
          Processed__c = false);
	}
}