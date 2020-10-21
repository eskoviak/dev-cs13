@IsTest 
public class Test_batchAccountUpdate_schedule {

    public static testMethod void testBatchAccountUpdate_schedule() {
    
       //PageReference pageRef = Page.AccountDocument; 
       //Test.setCurrentPageReference(pageRef);
       
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;

        //Create Batch
        batchAccountUpdate_schedule testSchedule = new batchAccountUpdate_schedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Batch Account Update', sch, testSchedule);

	}	

}