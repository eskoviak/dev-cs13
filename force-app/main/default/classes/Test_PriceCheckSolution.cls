@isTest
private class Test_PriceCheckSolution {

    static testMethod void myUnitTest() {
        Account oAccount = new Account(name = 'Bootleggers', RWS_ID__c = '1256102');
        
       	insert oAccount;
       	
       	PageReference result = new PageReference('/apex/PriceCheck?id=' + oAccount.Id);

		Test.setCurrentPage(result);
        
        PriceCheckController oPriceCheckController = new PriceCheckController();

		PriceCheckController.ProductSearchResult oProductSearchResult = new PriceCheckController.ProductSearchResult();
        
        Price_Check__c oPriceCheck = oPriceCheckController.formatPriceCheck(false);
        oPriceCheck = oPriceCheckController.formatPriceCheck(true);
		Http oHttp = new Http();
		HttpRequest oRequest = oPriceCheckController.formatHttpRequest(oPriceCheck);

		HttpResponse oResponse = new HttpResponse();
		
		oResponse.setStatus('200');
		oResponse.setStatusCode(200);
		
		string sString = '<dog>';
		sString += '<h:GetSFDCPriceCheckDataResult xmlns:h="http://tempuri.org/"></h:GetSFDCPriceCheckDataResult>';
		sString += '<h:faultData xmlns:h="http://tempuri.org/"></h:faultData>';
		sString += '</dog>';
		
		oResponse.setBody(sString);
	    oPriceCheck = oPriceCheckController.handleResponse(oResponse, oPriceCheck);

		oPriceCheckController.insertPriceCheck(oPriceCheck);
		
		oPriceCheckController.sProductString = '1';
		oPriceCheckController.sProductBrand = 'Wrox';
		oPriceCheckController.searchProducts();
    }
}