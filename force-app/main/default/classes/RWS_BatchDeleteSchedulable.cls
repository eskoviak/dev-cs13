/************************************************************************
* Schedulable Class - Schedules RWS_ServicingStoreDeleteBatch & RWS_PPBEDeleteBatch classes concurrently
*
* @Author: Brandon Willard
* @Date: 10/22/18
************************************************************************/ 
global class RWS_BatchDeleteSchedulable implements Schedulable {
	
    //Set Cron Expression (how often to run): Every Sunday at 12am
    public static final String CRON_EXPR = '0 0 0 ? * SUN *';
    
    //Method to call in anonymous apex to schedule using cron expression from above
    global static String scheduleDeleteBatchJob(){
        RWS_BatchDeleteSchedulable job = new RWS_BatchDeleteSchedulable();
        return System.schedule('PPBE & Servicing Store Delete Batch Jobs', CRON_EXPR, job);
    }
    
    //Execute batch jobs
    global void execute(SchedulableContext sc){
        try{
            //Instantiate and execute Servicing Store Delete Batch Job
            RWS_ServicingStoreDeleteBatch batchJobSS = new RWS_ServicingStoreDeleteBatch();
            Database.executeBatch(batchJobSS);
        } catch (Exception e){
            System.debug('Exception caught when executing SS batch job: '+e);
        }
        
        try{
            //Instantiate and execute PPBE Delete Batch Job        
            RWS_PPBEDeleteBatch batchJobPPBE = new RWS_PPBEDeleteBatch();
            Database.executeBatch(batchJobPPBE);
        } catch (Exception e){
            System.debug('Exception caught when executing PPBE batch job: '+e);
        }
    }
    
}