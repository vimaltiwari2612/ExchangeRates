/********************************************************************************************************************
 * @ClassName       : RefreshRatesBatchScheduler
 * @Description     : Scheduler class for Refresh Rates Batch
********************************************************************************************************************/
public class RefreshRatesBatchScheduler implements Schedulable{

    public void execute(SchedulableContext sc){
        RefreshRatesBatch ratesBatch = new RefreshRatesBatch();
        Database.executeBatch(ratesBatch, UtilClass.BATCH_SIZE);
    }
}