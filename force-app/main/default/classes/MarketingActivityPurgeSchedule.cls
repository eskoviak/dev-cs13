global class MarketingActivityPurgeSchedule Implements Schedulable{
    global void execute(SchedulableContext sc){
        MarketingActivityPurgeBatch b = new MarketingActivityPurgeBatch();
        database.executeBatch(b);
    }
}