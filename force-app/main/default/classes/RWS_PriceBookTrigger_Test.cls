@isTest
private class RWS_PriceBookTrigger_Test {
    static testMethod void testTrigger() {
        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

    	Account acc = RWS_TestUtil.createAccount(rtId, true);

    	Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);
        pr.Active__c = false;
        insert pr;

    	Product2 prod = RWS_TestUtil.createProduct(true);

		Pricebook2 priceBook = RWS_TestUtil.createCustomPricebook(pr.Id, false);
		priceBook.Discount__c = 20;
		insert priceBook;

        /*
        System.assertEquals([select Id, Price_Book_ID__c from Program__c where Id = :pr.Id].Price_Book_ID__c, 
                            priceBook.Id);

		List<Publish_PriceBook__c> ppbs = [
    		select Id, Discount__c, Publish_Status__c, Name
    		from Publish_PriceBook__c 
    		where Price_Book__c = :customPB.Id
    	];*/

		//System.assertEquals(1, ppbs.size(), 'Issue with public price book');
		//System.assertEquals(customPB.Discount__c, ppbs[0].Discount__c, 'Incorrect discount');
		System.assertEquals(priceBook.Name.length() < 80, true, 'Incorrect Name');
        
        priceBook.Discount__c = 10;
		update priceBook;

        delete priceBook;

        undelete priceBook;

        priceBook.IsActive = false;

        update priceBook;
    }
}