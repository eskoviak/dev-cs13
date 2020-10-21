/**
* Util class to find products styles related to filter criteria
* @DateCreated: 12/06/2017
* @Author: Usman Aslam (Magnet360)
*/
public with sharing class RWS_FilterCriteria_Util {

    // method that takes a fitler criteria and returns products styles related to that filter criteria
	public static Set<Id> getProductStylesForFilter(Filter_Criteria__c fc) {

        // map that holds where clause for the SOQL and 
        // AND/OR operator that needs be appliead between features selected in a filter criteria
        Map<String, String> whereClauseToOperator;
        Set<Id> iaFeatureId;
        Set<Id> allStyles = new Set<Id>();

        /*
            Overall Logic:
            =================================================
            Sample data from Filter_BE_Details__c
            {"( Name = '23194' AND Name = '23195') ":" AND ","( Name = 'RWBR') ":" AND "}SEPARATOR["a2VW00000005O37MAE","a2VW00000005O1QMAU"]

            whereClauseToOperator is filter by {"( Name = '23194'  AND Name = '23195') ":" AND ","( Name = 'RWBR') ":" AND "}

            and

            iaFeatureId is filled by ["a2VW00000005O37MAE","a2VW00000005O1QMAU"]

            after deserialization whereClauseToOperator will have two entries for the sample above

            whereClauseToOperator = {"( Name = '23194' AND Name = '23195') " => " AND ",
                                    "( Name = 'RWBR' ) " => " AND "}

            for each entry we'll run an SOQL, using the entry in map as the where clasue

            if there is an AND between entry, i.e ( Name = '23194' AND Name = '23195' )
            we'll change it to OR, i.e ( Name = '23194' OR Name = '23195' ) 
            because ( Name = '23194' AND Name = '23195' ) will never return data

            once all the styles are retrieved, we'll add them to a set and return back to the calling class
        */

        try {
            // populate map using details found on filter criteria
            whereClauseToOperator = (Map<String, String>) JSON.deserialize(fc.Filter_BE_Details__c.split('SEPARATOR')[0], Map<String, String>.class);

            // populate set with feature ids found on filter criteria
            iaFeatureId = (Set<Id>) JSON.deserialize(fc.Filter_BE_Details__c.split('SEPARATOR')[1], Set<Id>.class);
        } catch(Exception ex) {}
        

        // if details are not found on filter criteria, return empty set
        if(whereClauseToOperator == null || whereClauseToOperator.isEmpty()) return allStyles;

        // if feature ids are not found on filter criteria, return empty set
        if(iaFeatureId == null || iaFeatureId.isEmpty()) return allStyles;

        // get the tab category
        String tabCategory = [SELECT Category__c FROM IA_Feature__c where Id in :iaFeatureId limit 1].Category__c;
        
        // initialize variables
        List<Set<Id>> andStyles = new List<Set<Id>>();

        List<Set<Id>> orStyles = new List<Set<Id>>();

        // iteraate of where clause map
        for(String filter : whereClauseToOperator.keySet()) {

            List<Features__c> features;
            
            // flag to keep track that our code changed SOQL at run time
            Boolean filterChanged = false;

            // if there is AND between features selected, replace it with OR
            // because if we run a SOQL with 'where Name = 'RW' and Name = 'Wrox' 
            // it will always return no recors because a feature name cannot be both
            if(filter.indexOf('AND') >= 0) {
                // replaced AND with OR so the SOQL return the records
                String changedFilter = filter.replaceAll('AND', 'OR');

                // get feature records
                features = Database.query('select Id from Features__c where ' + changedFilter);

                // turn he flag on so we can apply further logic later for this scenario
                filterChanged = true;
            } else {

                // get feature records for OR'ed SOQLs
                features = Database.query('select Id from Features__c where ' + filter);
            }   

            // get the Operator (AND/OR) for the SOQL
            // AND means, all features in the SOQL must exist under the product style for getting qualified
            // OR means, if any feature in the SOQL exist under the product style, the product style qualifies
            String operator = whereClauseToOperator.get(filter);
            
            // initialize the vairable
            Set<Id> productStyles = new Set<Id>();


            if(filterChanged) { // if filter was changed at runtime above, run a aggregate SOQL

                // get number of features in the SOQL
                Integer filterCount = filter.split('AND').size();
                
                // find products styles having ALL of those feature
                for(AggregateResult p : [select Product_Style__c, count(Id)

                                            from Product_Style_Features__c 
                                            where Feature__c in :features
                                            and Product_Style__c != null
                                            and Product_Style__r.Category__c = :tabCategory
                                            group by Product_Style__c
                                            having count(Id) = :filterCount ]) {

                    productStyles.add((ID) p.get('Product_Style__c'));
                }                    
            } else {

                // find products styles having ANY of those feature
                for(Product_Style_Features__c p : [select Product_Style__c
                                                from Product_Style_Features__c 
                                                where Feature__c in :features
                                                and Product_Style__r.Category__c = :tabCategory
                                                and Product_Style__c != null]) {

                    productStyles.add(p.Product_Style__c);
                }
            }

            if(operator == ' AND ') { // if the Operator is AND, add the found styles to a separate set of set (Set<Set<Id>>)
                andStyles.add(productStyles);
            } else { // if the Operator is OR, add the found styles to a separate set
                orStyles.add(productStyles);
            }
        }


        // once all style are found the filter criteras
        if(andStyles.size() == 1 ) { 
            // check there was only one SOQL executed, consider it a everything that we were suppose find
            allStyles.addAll(andStyles[0]);

        } else if(andStyles.size() > 1) {
            // check there was more than one SOQL executed,
            // style should be there for all the SOQL executed
            Map<Id, Integer> styleToCountMap = new Map<Id, Integer>();
            

            // find the styles appeared (style found count) for number of SOQLs exectured
            for(Integer i = 0 ; i < andStyles.size(); i ++) {
                
                for(Id styleId : andStyles[i]) {
                    Integer count = styleToCountMap.get(styleId);
                    
                    if(count == null) 
                        count = 1;
                    else 
                        count ++;
                    
                    styleToCountMap.put(styleId, count);
                }
            }
            
            // total number of soqls executed
            Integer totalAndStyles = andStyles.size();
            

            for(Id styleId : styleToCountMap.keySet()) {
                Integer count = styleToCountMap.get(styleId);
                
                // if style found count is equivalent to total number of soqls executed
                // consider it qualified
                if(count == totalAndStyles) {
                    allStyles.add(styleId);
                }
            }
        }

        // other style that has a logic of OR, are going to be added straight aways
        for(Integer i = 0 ; i < orStyles.size(); i ++) {
            allStyles.addAll(orStyles[i]);
        }

        // return all styles
        return allStyles;
    }
}