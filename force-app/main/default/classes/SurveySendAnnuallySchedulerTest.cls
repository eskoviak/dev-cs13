@isTest
private class SurveySendAnnuallySchedulerTest {

	static testMethod void testScheduler() {
		
		SurveySendAnnuallyScheduler scheduler = new SurveySendAnnuallyScheduler();
        string sch = '0 0 * * 1-12 ? *';
        
		Test.startTest();
			String jobId = system.schedule('Process Batch Job', sch, scheduler);
		Test.stopTest();
		
        String year = String.valueOf(system.now().year());
        String month = SurveySendAnnuallySchedulerTest.twoDigit(system.now().month());
        String day 	= SurveySendAnnuallySchedulerTest.twoDigit(system.now().day());
        String hour = SurveySendAnnuallySchedulerTest.twoDigit(system.now().addHours(1).hour());
        	
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        	
        system.assertEquals(sch, ct.CronExpression, 'The CronExpression does not match the time expression used for the scheduled job');
        system.assertEquals(0, ct.TimesTriggered, 'The batch job should only be scheduled and queued at this point');
        system.assertEquals(year + '-' + month + '-' + day + ' ' + hour + ':00:00', String.valueOf(ct.NextFireTime), 'The next scheduled time is incorrect');
        		
	}
	
    private static String twoDigit(integer raw) {
		if (raw < 10 && raw > 0) {
			return '0' + String.valueOf(raw);
		} else {
			return String.valueOf(raw);
		}
	}

}