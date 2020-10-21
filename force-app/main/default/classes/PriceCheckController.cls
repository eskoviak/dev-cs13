public with sharing class PriceCheckController {
	
	public final Account oAccount {get; set;}
	
	public List<SelectOption> lProductBrands {get; set;}
	public List<ProductSearchResult> lProductSearchResults {get; set;}
	public List<PriceCheckWrapper> lPriceCheckResults {get; set;}
	
	public String sProductString {get; set;}
	public String sProductBrand {get; set;}
	public String selectedProductCode {get; set;}
	public String selectedFacility {get; set;}
	public String SearchSuggestionText {get; set;}
	public String PriceCheckSuggestionText {get; set;}
	
	public Boolean RenderSearchResults {get; set;}
	public Boolean RenderPriceCheckResults {get; set;}
	public Boolean ScrollScreenToPriceCheck {get; set;}
	
	public class PriceCheckRequestException extends Exception {}
	
	public class ProductSearchResult{
		public Product2 Product {get; set;}
		public String Facility {get; set;}
		
		public ProductSearchResult(){
			Product = new Product2();
			Facility = '';
		}
	}

	public class PriceCheckWrapper{
		public Price_Check__c PriceCheck {get; set;}
		public String CustomerName {get; set;}
		public Boolean Error {get; set;}
		
		public PriceCheckWrapper(){
			Error = false;
		}
	}
	
	public PriceCheckController(){
		oAccount = [select id, name, site, RWS_ID__c from Account where id = :ApexPages.currentPage().getParameters().get('id')];
		
		lProductSearchResults = new List<ProductSearchResult>();
		RenderSearchResults = false;
		SearchSuggestionText = 'Submit a product query through the search criteria block above.';
		
		lPriceCheckResults = new List<PriceCheckWrapper>();
		RenderPriceCheckResults = false;
		PriceCheckSuggestionText = 'Select a product to get the latest price for this client.';
		
		ScrollScreenToPriceCheck = false;
		
		//Populate lProductBrands
		lProductBrands = new List<SelectOption>();
        lProductBrands.add(new SelectOption('--Search All--', '--Search All--'));  
        Schema.DescribeFieldResult oFieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> lFamilyEntries = oFieldResult.getPicklistValues();
        for( Schema.PicklistEntry oFamilyEntry : lFamilyEntries){
          lProductBrands.add(new SelectOption(oFamilyEntry.getLabel(), oFamilyEntry.getValue()));
        }
        
        
	} 
	
	public void doPriceCheck(){
		Price_Check__c oPriceCheck = formatPriceCheck(false);
		Http oHttp = new Http();
		HttpRequest oRequest = formatHttpRequest(oPriceCheck);
		
		HttpResponse oResponse = oHttp.send(oRequest);
	    oPriceCheck = handleResponse(oResponse, oPriceCheck);

		insertPriceCheck(oPriceCheck);
		
		return;
	}
	
	public void insertPriceCheck(Price_Check__c oPriceCheck){
		PriceCheckWrapper oPriceCheckWrapper = new PriceCheckWrapper();
        
        oPriceCheckWrapper.PriceCheck = oPriceCheck;
        oPriceCheckWrapper.CustomerName = oAccount.Name;

		if(oPriceCheck.Price__c != null){
			try{
				insert oPriceCheck;
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Price Check Failed to Insert! (Customer Number : ' + oPriceCheck.Customer_Number__c + ') (Product Code : ' + oPriceCheck.Style_Number__c + ') '));
				ScrollScreenToPriceCheck = false;
				return;
			}
		}else{
			oPriceCheckWrapper.Error = true;
		}

		lPriceCheckResults.add(oPriceCheckWrapper);

		if(lPriceCheckResults.size() > 0){
			RenderPriceCheckResults = true;
			ScrollScreenToPriceCheck = true;
		}
		
		return;
	}
	
	public Price_Check__c handleResponse(HttpResponse oResponse, Price_Check__c oPriceCheckRequest){
		String sStatus = oResponse.getStatus();
	    Integer sStatusCode = oResponse.getStatusCode();
	    
	    if (sStatus == null || sStatusCode < 200 || sStatusCode > 299) {
	      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Integration returned the status code (' + sStatusCode + ' : ' + sStatus + ')'));
	      return oPriceCheckRequest;
	    }
	    
	    System.Debug('************ PROCESS RESPONSE');
	    String sNamespace = 'http://tempuri.org/';
	    String sNamespaceSFDC = 'http://schemas.datacontract.org/2004/07/Retail.Service';
	    
	    Dom.Document xDocument = oResponse.getBodyDocument();
        Dom.XMLNode xPriceCheckResponse = xDocument.getRootElement();

		        
        Dom.XMLNode xPriceCheckResult = xPriceCheckResponse.getChildElement('GetSFDCPriceCheckDataResult', sNamespace);
        
        if(xPriceCheckResult != null){
        	if(xPriceCheckResult.getChildren().size() < 1){
	        	System.Debug('************ NO RESPONSE FOUND');
	        	//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: No Price Returned!'));
	        	for(Dom.XMLNode oNode : xPriceCheckResponse.getChildElement('faultData', sNamespace).getChildElements()){
	        		System.Debug('************ Error ( ' + oNode.getName() + ' - ' + oNode.getText() + ' - ' + oNode.getNamespace() + ' )');
	        		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error ( ' + oNode.getName() + ' - ' + oNode.getText() + ' - ' + oNode.getNamespace() + ' )'));
	        	}
	        	return oPriceCheckRequest;
        	}
        }

        Dom.XMLNode xPriceCheckData = xPriceCheckResult.getChildElement('SFDCPriceCheckData', sNamespaceSFDC);

        String DateToParse = xPriceCheckData.getChildElement('ContractExpDate', sNamespaceSFDC).getText();
        
        oPriceCheckRequest.Contract_Expiration_Date__c = Date.parse(DateToParse);
        oPriceCheckRequest.Price__c = decimal.valueOf(xPriceCheckData.getChildElement('Price', sNamespaceSFDC).getText());
        oPriceCheckRequest.CurrencyIsoCode = xPriceCheckData.getChildElement('CurrencyCode', sNamespaceSFDC).getText();
        oPriceCheckRequest.Price_List_Code__c = xPriceCheckData.getChildElement('PriceListCode', sNamespaceSFDC).getText();
		oPriceCheckRequest.Price_Check_Date__c = System.Now();
		
		return oPriceCheckRequest;
	}
	
	public Price_Check__c formatPriceCheck(boolean isTest){
		System.Debug('**********Begin Price Check');
		
		Price_Check__c oPriceCheck = new Price_Check__c();
        
        if(isTest){
        	oPriceCheck.Facility__c = 'FRW';
	        oPriceCheck.Customer_Number__c = '1979301';
	        oPriceCheck.Style_Number__c = '00875';
	        oPriceCheck.Customer_Name__r = new Account(RWS_ID__c = oPriceCheck.Customer_Number__c);
        }else{
	        oPriceCheck.Facility__c = selectedFacility;
	        oPriceCheck.Style_Number__c = selectedProductCode;
	        oPriceCheck.Customer_Number__c = oAccount.RWS_ID__c;
	        oPriceCheck.Customer_Name__r = new Account(RWS_ID__c = oAccount.RWS_ID__c);
        }
        
        if(oPriceCheck.Customer_Number__c == ''){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Customer Number is not set!'));
		}
		
		if(oPriceCheck.Style_Number__c == ''){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Style Number is not set!'));
		}
        
        return oPriceCheck;
	}
	
	public HttpRequest formatHttpRequest(Price_Check__c oPriceCheck){
		EndPoints__c oPriceCheckEndPoint = EndPoints__c.getInstance('PriceCheck');

		HttpRequest oRequest = new HttpRequest();
		
		if(oPriceCheckEndPoint == null){
			oRequest.setEndpoint('http://ci.redwingshoes.com/PriceCheckDev');
		}else{
			oRequest.setEndpoint(oPriceCheckEndPoint.EndPoint__c);
		}

	    oRequest.setMethod('POST'); // Set HTTPRequest Method
	    oRequest.setTimeout(30000); // timeout in 30 seconds
		
		String dt = System.now().format('yyyy-MM-dd\'T\'HH:mm:ssZ');
		String dt2 = dt.substring(0, dt.length()-2);
		String dt3   = dt2 + ':' + dt.substring(dt.length()-2, dt.length());
		
	    // construct requestBody XML string
	    String sRequestBody = '<?xml version="1.0" encoding="UTF-8" ?>\n';
	    sRequestBody += '<PriceCheck>\n';
	    
	    sRequestBody += '<CustomerNumber>'+oPriceCheck.Customer_Number__c+'</CustomerNumber>\n';
	    sRequestBody += '<StyleNumber>'+oPriceCheck.Style_Number__c+'</StyleNumber>\n';
	    sRequestBody += '<Facility>'+oPriceCheck.Facility__c+'</Facility>\n';
	    sRequestBody += '<OrderDate>'+dt3+'</OrderDate>\n';

	    sRequestBody += '</PriceCheck>';
	    oRequest.setBody(sRequestBody); 
	    
	    return oRequest;
	}
	
	public void searchProducts(){
		if(sProductString == '' && sProductBrand == '--Search All--'){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Please enter a search string and/or select a brand from the drop down menu.'));
			
			return;
		}
		
		lProductSearchResults = new List<ProductSearchResult>();
		
		String sQuery = 'SELECT Name, ProductCode, Family FROM Product2 WHERE';
		
		if(sProductString != '')
			sQuery += ' (Name LIKE \'%' + String.escapeSingleQuotes(sProductString) + '%\' or ProductCode LIKE \'%' + String.escapeSingleQuotes(sProductString) + '%\')';
		
		if(sProductString != '' && String.escapeSingleQuotes(sProductBrand) != '--Search All--')
			sQuery += ' and';
		
		if(sProductBrand != '--Search All--')
			sQuery += ' Family = \'' + String.escapeSingleQuotes(sProductBrand) + '\'';
		
		sQuery += ' ORDER BY ProductCode ASC';
		
		List<Product2> lProducts = database.query(sQuery);

		for(Product2 oProduct : lProducts){
			ProductSearchResult oProductSearchResult = new ProductSearchResult();
			
			oProductSearchResult.Product = oProduct;
			oProductSearchResult.Facility = 'FRW';
			
			lProductSearchResults.add(oProductSearchResult);
		}

		if(lProductSearchResults.size() > 0){
			RenderSearchResults = true;
		}else{
			RenderSearchResults = false;
			SearchSuggestionText = 'Product query has returned no results.';
		}
		
		return;
	}
	/*
	public void initiatePriceCheck(){
		System.Debug('**********Begin Price Check');
		
		Price_Check__c oPriceCheck = new Price_Check__c();
        
        oPriceCheck.Facility__c = selectedFacility;
        oPriceCheck.Style_Number__c = selectedProductCode;
        oPriceCheck.Customer_Number__c = oAccount.RWS_ID__c;
        oPriceCheck.Customer_Name__r = new Account(RWS_ID__c = oAccount.RWS_ID__c);
        
        oPriceCheck = requestPriceCheck(oPriceCheck);
        
        PriceCheckWrapper oPriceCheckWrapper = new PriceCheckWrapper();
        
        oPriceCheckWrapper.PriceCheck = oPriceCheck;
        oPriceCheckWrapper.CustomerName = oAccount.Name;

		if(oPriceCheck.Price__c != null){
			try{
				insert oPriceCheck;
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Price Check Failed to Insert! (Customer Number : ' + oPriceCheck.Customer_Number__c + ') (Product Code : ' + oPriceCheck.Style_Number__c + ') '));
				ScrollScreenToPriceCheck = false;
				return;
			}
		}else{
			oPriceCheckWrapper.Error = true;
		}

		lPriceCheckResults.add(oPriceCheckWrapper);

		if(lPriceCheckResults.size() > 0){
			RenderPriceCheckResults = true;
			ScrollScreenToPriceCheck = true;
		}else{
			RenderPriceCheckResults = false;
			ScrollScreenToPriceCheck = true;
			PriceCheckSuggestionText = 'Price Check has returned no results.';
		}
		
		return;
	}
	
	public Price_Check__c requestPriceCheck(Price_Check__c oPriceCheckRequest){
		if(oPriceCheckRequest.Customer_Number__c == ''){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Customer Number is not set!'));
			return oPriceCheckRequest;
		}
		
		if(oPriceCheckRequest.Style_Number__c == ''){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Style Number is not set!'));
			return oPriceCheckRequest;
		}
		
		EndPoints__c oPriceCheckEndPoint = EndPoints__c.getInstance('PriceCheck');
		
		Http oHttp = new Http();
		HttpRequest oRequest = new HttpRequest();
		
		if(oPriceCheckEndPoint == null){
			oRequest.setEndpoint('http://ci.redwingshoes.com/PriceCheckDev');
		}else{
			oRequest.setEndpoint(oPriceCheckEndPoint.EndPoint__c);
		}

	    oRequest.setMethod('POST'); // Set HTTPRequest Method
	    oRequest.setTimeout(30000); // timeout in 30 seconds
		
		String dt = System.now().format('yyyy-MM-dd\'T\'HH:mm:ssZ');
		String dt2 = dt.substring(0, dt.length()-2);
		String dt3   = dt2 + ':' + dt.substring(dt.length()-2, dt.length());
		
	    // construct requestBody XML string
	    String sRequestBody = '<?xml version="1.0" encoding="UTF-8" ?>\n';
	    sRequestBody += '<PriceCheck>\n';
	    
	    sRequestBody += '<CustomerNumber>'+oPriceCheckRequest.Customer_Number__c+'</CustomerNumber>\n';
	    sRequestBody += '<StyleNumber>'+oPriceCheckRequest.Style_Number__c+'</StyleNumber>\n';
	    sRequestBody += '<Facility>'+oPriceCheckRequest.Facility__c+'</Facility>\n';
	    sRequestBody += '<OrderDate>'+dt3+'</OrderDate>\n';

	    sRequestBody += '</PriceCheck>';
	    oRequest.setBody(sRequestBody); 
	    
	    HttpResponse oResponse = oHttp.send(oRequest);
	    
	    String sStatus = oResponse.getStatus();
	    Integer sStatusCode = oResponse.getStatusCode();
	    
	    if (sStatus == null || sStatusCode < 200 || sStatusCode > 299) {
	      ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: Integration returned the status code (' + sStatusCode + ' : ' + sStatus + ')'));
	      return oPriceCheckRequest;
	    }
	    
	    System.Debug('************ PROCESS RESPONSE');
	    String sNamespace = 'http://tempuri.org/';
	    String sNamespaceSFDC = 'http://schemas.datacontract.org/2004/07/Retail.Service';
	    
	    Dom.Document xDocument = oResponse.getBodyDocument();
        Dom.XMLNode xPriceCheckResponse = xDocument.getRootElement();

		        
        Dom.XMLNode xPriceCheckResult = xPriceCheckResponse.getChildElement('GetSFDCPriceCheckDataResult', sNamespace);
        
        if(xPriceCheckResult != null){
        	if(xPriceCheckResult.getChildren().size() < 1){
	        	System.Debug('************ NO RESPONSE FOUND');
	        	//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: No Price Returned!'));
	        	for(Dom.XMLNode oNode : xPriceCheckResponse.getChildElement('faultData', sNamespace).getChildElements()){
	        		System.Debug('************ Error ( ' + oNode.getName() + ' - ' + oNode.getText() + ' - ' + oNode.getNamespace() + ' )');
	        		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error ( ' + oNode.getName() + ' - ' + oNode.getText() + ' - ' + oNode.getNamespace() + ' )'));
	        	}
	        	return oPriceCheckRequest;
        	}
        }

        Dom.XMLNode xPriceCheckData = xPriceCheckResult.getChildElement('SFDCPriceCheckData', sNamespaceSFDC);

        String DateToParse = xPriceCheckData.getChildElement('ContractExpDate', sNamespaceSFDC).getText();
        
        oPriceCheckRequest.Contract_Expiration_Date__c = Date.parse(DateToParse);
        oPriceCheckRequest.Price__c = decimal.valueOf(xPriceCheckData.getChildElement('Price', sNamespaceSFDC).getText());
        oPriceCheckRequest.CurrencyIsoCode = xPriceCheckData.getChildElement('CurrencyCode', sNamespaceSFDC).getText();
        oPriceCheckRequest.Price_List_Code__c = xPriceCheckData.getChildElement('PriceListCode', sNamespaceSFDC).getText();
		oPriceCheckRequest.Price_Check_Date__c = System.Now();

	    return oPriceCheckRequest;
	}
	*/
}