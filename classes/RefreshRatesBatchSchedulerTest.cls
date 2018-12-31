/********************************************************************************************************************
 * @ClassName       : RefreshRatesBatchSchedulerTest
 * @Description     : Test class of RefreshRatesBatchScheduler
********************************************************************************************************************/
@isTest(seeAllData=false)
private class RefreshRatesBatchSchedulerTest {
	
    @isTest
    private static void testRefreshRatesBatchScheduler(){
        Test.startTest();
        RefreshRatesBatchScheduler ratesScheduler = new RefreshRatesBatchScheduler();
        // This test runs a scheduled job at midnight Dec. 20th 2018
        Date today = System.today();
        String CRON_EXP = '0 0 0 * * ? *'; 
        String jobId = system.schedule('RefreshRatesBatchScheduler', CRON_EXP, ratesScheduler); 
        // Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
      	// Verify the expressions are the same
      	System.assertEquals(CRON_EXP, ct.CronExpression);
        Test.stopTest();
    }
}