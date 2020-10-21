global class batchAccountUpdate_schedule implements Schedulable {
    
    global void execute(SchedulableContext scMain) {

    	batchAccountUpdate clsBatchAccountUpdate = new batchAccountUpdate();
		ID idBatch = Database.executeBatch(clsBatchAccountUpdate, 200);
	}
}