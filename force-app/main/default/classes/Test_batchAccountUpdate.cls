@IsTest 
public class Test_batchAccountUpdate {

    public static testMethod void testBatchAccountUpdate() {
    
       //PageReference pageRef = Page.AccountDocument; 
       //Test.setCurrentPageReference(pageRef);
       
        //Create Account
        Account newAccount = new Account (name='Unit Test Account');
        insert newAccount;

		batchAccountUpdate b = new batchAccountUpdate();
		database.executeBatch(b);
	}	

}