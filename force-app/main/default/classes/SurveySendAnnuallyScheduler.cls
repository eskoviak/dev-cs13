global class SurveySendAnnuallyScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        SurveySendAnnuallyBatch batch = new SurveySendAnnuallyBatch();
        ID batchprocessid = Database.executeBatch(batch,200); 
    }
}