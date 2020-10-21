global class TaskSurveyRollup implements ITriggers.HandlerInterface {

	Task[] newCollection = trigger.new;
	Task[] oldCollection = trigger.old;
	Boolean isDelete = trigger.isDelete;
	
	global void handle() {
		List<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = new List<RollUpSummaryUtility.fieldDefinition>();
		
		fieldDefinitions.add(new RollUpSummaryUtility.fieldDefinition('COUNT', 'Id', 'Survey_Count__c'));

		if(!isDelete) {
			RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, newCollection, 'Task', 'WhoId', 'Contact', 'and Subject LIKE \'Email: Red Wing Shoes Survey%\' and Status = \'Completed\' and CreatedDate = LAST_N_DAYS:365');
		}
		else {
			RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, oldCollection, 'Task', 'WhoId', 'Contact', 'and Subject LIKE \'Email: Red Wing Shoes Survey%\' and Status = \'Completed\' and CreatedDate = LAST_N_DAYS:365');			
		}
	}
}