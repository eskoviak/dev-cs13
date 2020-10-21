public with sharing class CustomerSearch_Relate_Controller {

/**
*   {Purpose}  �  This class manages the CustomerSearch_Relate VF page
*
*   {Contact}   - support@demandchainsystems.com
*                 www.demandchainsystems.com
*                 612-424-0032                  
*/

/**
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   20140409    Andy Boettcher DCS      Created
*   =============================================================================
*/
    public hClsCriteria clsCriteria {get;set;}
    public List<hClsResult> lstResults {get;set;}
    public List<hClsTransHeader> lstTransactions {get;set;}
    public List<Account> lstAccounts {get;set;}
    public Id idSFDCIdUpdate {get;set;}
    //private static String strEndpoint = 'https://relateservices.tst.redwingshoes.com/soap/RWS/v1_0/CustomerServices';

    ///////////////////////////////////
    // Constructors
    ///////////////////////////////////
    public CustomerSearch_Relate_Controller() {
        clsCriteria = new hClsCriteria();
        lstResults = new List<hClsResult>();
        lstTransactions = new List<hClsTransHeader>();
        lstAccounts = new List<Account>();
        clsCriteria.strFirstName = ApexPages.currentPage().getParameters().get('fn');
        clsCriteria.strLastName = ApexPages.currentPage().getParameters().get('ln');
        clsCriteria.strTelephone = ApexPages.currentPage().getParameters().get('tel');
        clsCriteria.strEmail = ApexPages.currentPage().getParameters().get('eml');

        if(clsCriteria.strFirstName != '' || clsCriteria.strLastName != '' || clsCriteria.strTelephone != '' || clsCriteria.strEmail != '') {
            searchRelate();
        }

    }

    ///////////////////////////////////
    // GET SET
    ///////////////////////////////////
    public static String strEndpoint {
        get { 

            EndPoints__c csEndpoint = EndPoints__c.getInstance('RelateSearch');
            return csEndpoint.EndPoint__c; 

        }
    }

    ///////////////////////////////////
    // Action Methods
    ///////////////////////////////////
    private Account assignPAValues(Account pa) {

        hClsResult clsSource;

        // Find selected search result
        for(hClsResult clsResult : lstResults) {
            if(clsResult.strCustomerId == clsCriteria.strChosenCustomerId) {
                clsSource = clsResult;
                break;
            }
        }

        // Construct new PersonAccount
        if(clsSource != null) {
            pa.RecordTypeId = '012F0000000qw34';
            pa.FirstName = clsSource.strFirstName;
            pa.LastName = clsSource.strLastName;
            pa.PersonEmail = clsSource.strEmailAddress;
            pa.PersonMailingStreet = clsSource.strAddressLine1;
            pa.PersonMailingCity = clsSource.strCity;
            pa.PersonMailingState = clsSource.strTerritory;
            pa.PersonMailingPostalCode = clsSource.strPostalCode;
            pa.PersonMailingCountry = clsSource.strCountry;
            pa.Phone = clsSource.strTelephone;
            pa.Rel_Retail_Store_ID__c = clsSource.strRetailStoreId;
            pa.Data_Origin__c = 'RELATE';
            pa.Rel_Relate_ID__c = clsSource.strCustomerId;
            pa.Rel_Relate_Customer_Number__c = clsSource.strCustomerId;
            pa.Rel_Signup_Date__c = datetime.valueOfGmt(clsSource.strSignupDate + ' 05:00:00');
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                'There was an issue creating the Salesforce Person Account for this selection.  Please contact your system administrator!')); 
            return null;
        }

        return pa;
    }

    public PageReference updateExistingContact() {

        System.Debug(idSFDCIdUpdate);

        Account paUpdate = assignPAValues(new Account(Id=idSFDCIdUpdate));
        update paUpdate;

        updateRelateWithSFDCID(clsCriteria.strChosenCustomerId, paUpdate.Id);

        PageReference prRef = new PageReference('/' + paUpdate.Id);
        prRef.setRedirect(true);
        return prRef;
    }

    public PageReference createNewContact() {

        Account paNew = assignPAValues(new Account());
        insert paNew;

        updateRelateWithSFDCID(clsCriteria.strChosenCustomerId, paNew.Id);

        PageReference prRef = new PageReference('/' + paNew.Id);
        prRef.setRedirect(true);
        return prRef;
    }

    public void findSalesforceContacts() {

        lstAccounts = new List<Account>();
        lstAccounts = [
            SELECT Id, FirstName, LastName, PersonEmail 
                FROM Account 
                WHERE 
                    (FirstName = :clsCriteria.strChosenFN AND LastName = :clsCriteria.strChosenLN)
                    OR Rel_Relate_ID__c = :clsCriteria.strChosenCustomerId
                    
        ];

    }

    @Future(callout=true)
    private static void updateRelateWithSFDCID(String strCustomerId, String strAccountId) {

        Xmlstreamwriter writer = new Xmlstreamwriter();

        // Manually Generate XML because Salesforce cannot handle elements and attributes at the same time!  ARGH.
        String strXML = '';
        strXML+='<?xml version="1.0" encoding="UTF-8"?>';
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null,'env:Envelope', null);
                writer.writeAttribute(null, null, 'xmlns:env', 'http://schemas.xmlsoap.org/soap/envelope/');
                writer.writeAttribute(null, null, 'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
                writer.writeAttribute(null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
                writer.writeEmptyElement(null,'env:Header', null);
                writer.writeStartElement(null,'env:Body', null);
                    writer.writeStartElement(null,'v1:addOrUpdateCustomer', null);
                        writer.writeAttribute(null, null, 'xmlns:v1', 'http://v1_0.customer.webservices.csx.dtv.com/');
                        writer.writeStartElement(null,'customerData', null);
                            writer.writeStartElement(null,'customerId', null);
                                writer.writeCharacters(strCustomerId);
                            writer.writeEndElement();
                            writer.writeStartElement(null,'AlternateKey', null);
                                writer.writeAttribute(null, null, 'TypeCode', 'SFDC_ID');
                                writer.writeStartElement(null,'AlternateID', null);
                                    writer.writeCharacters(strAccountId);
                                writer.writeEndElement();
                            writer.writeEndElement();
                        writer.writeEndElement();
                    writer.writeEndElement();
                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();

        String xmlRequest = writer.getXMLString();
        writer.close();

        System.Debug(xmlRequest);

        // Assemble SOAP Request
        Http objHttp = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(strEndpoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type','text/xml;charset=UTF-8');
        httpReq.setTimeout(10000);
        httpReq.setBody(xmlRequest);
        if(!Test.isRunningTest()) { HttpResponse httpResp = objHttp.send(httpReq); }

    }

    public void retrieveCustomerTransactionHistory() {

        lstTransactions = new List<hClsTransHeader>();

        Xmlstreamwriter writer = new Xmlstreamwriter();

        // Manually Generate XML because Salesforce cannot handle elements and attributes at the same time!  ARGH.
        String strXML = '';
        strXML+='<?xml version="1.0" encoding="UTF-8"?>';
        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null,'env:Envelope', null);
                writer.writeAttribute(null, null, 'xmlns:env', 'http://schemas.xmlsoap.org/soap/envelope/');
                writer.writeAttribute(null, null, 'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
                writer.writeAttribute(null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
                writer.writeEmptyElement(null,'env:Header', null);
                writer.writeStartElement(null,'env:Body', null);
                    writer.writeStartElement(null,'v1:getTransactionHistory', null);
                        writer.writeAttribute(null, null, 'xmlns:v1', 'http://v1_0.customer.webservices.csx.dtv.com/');
                        writer.writeStartElement(null,'customerId', null);
                            writer.writeCharacters(clsCriteria.strChosenCustomerId);
                        writer.writeEndElement();
                    writer.writeEndElement();
                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();

        String xmlRequest = writer.getXMLString();
        writer.close();

        System.Debug(xmlRequest);

        // Assemble SOAP Request
        Http objHttp = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(strEndpoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type','text/xml;charset=UTF-8');
        httpReq.setTimeout(10000);
        httpReq.setBody(xmlRequest);
        HttpResponse httpResp;

        if(test.isRunningTest()) {
            httpResp = new HttpResponse();
            httpResp.setStatusCode(200);
            httpResp.setbody('<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:getTransactionHistoryResponse xmlns:ns2="http://v1_0.customer.webservices.csx.dtv.com/"><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>679</SequenceNumber><BusinessDayDate>2014-11-11-06:00</BusinessDayDate><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>701</SequenceNumber><BusinessDayDate>2014-11-11-06:00</BusinessDayDate><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Tender><Amount>128.250000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-11-11T00:00:00.000-06:00</BeginDateTime><EndDateTime>2014-11-11T00:00:00.000-06:00</EndDateTime><Tax><Amount>8.250000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">128.250000</Total><Total TotalType="TransactionTaxAmount">8.250000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>792</SequenceNumber><BusinessDayDate>2014-10-31-05:00</BusinessDayDate><BeginDateTime>2014-10-31T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-31T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-31T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-31T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-120</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-31T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-31T00:00:00.000-05:00</EndDateTime><Tender><Amount>129.990000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-31T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-31T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">129.990000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>674</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>125.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">125.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>675</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>120.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">120.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>676</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>125.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">125.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>680</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-120</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>134.990000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">134.990000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>681</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-120</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>134.990000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">134.990000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>682</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>125.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">125.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>683</SequenceNumber><BusinessDayDate>2014-10-23-05:00</BusinessDayDate><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tender><Amount>125.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-23T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-23T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">125.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>648</SequenceNumber><BusinessDayDate>2014-10-21-05:00</BusinessDayDate><BeginDateTime>2014-10-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-21T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>125.000000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">125.000000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>640</SequenceNumber><BusinessDayDate>2014-10-13-05:00</BusinessDayDate><BeginDateTime>2014-10-13T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-13T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-13T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-13T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-090</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-13T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-13T00:00:00.000-05:00</EndDateTime><Tender><Amount>134.990000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-13T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-13T00:00:00.000-05:00</EndDateTime><Tax><Amount>0.000000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">134.990000</Total><Total TotalType="TransactionTaxAmount">0.000000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>587</SequenceNumber><BusinessDayDate>2014-10-10-05:00</BusinessDayDate><BeginDateTime>2014-10-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-10T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-10T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>585</SequenceNumber><BusinessDayDate>2014-10-06-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-10T00:00:00.000-05:00</EndDateTime><Tender><Amount>-138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-10T00:00:00.000-05:00</EndDateTime><Tax><Amount>-8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-138.930000</Total><Total TotalType="TransactionTaxAmount">-8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>585</SequenceNumber><BusinessDayDate>2014-10-06-05:00</BusinessDayDate><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Tender><Amount>138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Tax><Amount>8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">138.930000</Total><Total TotalType="TransactionTaxAmount">8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>637</SequenceNumber><BusinessDayDate>2014-10-06-05:00</BusinessDayDate><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>457</SequenceNumber><BusinessDayDate>2014-07-07-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Tender><Amount>-139.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-06T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-06T00:00:00.000-05:00</EndDateTime><Tax><Amount>-9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-139.270000</Total><Total TotalType="TransactionTaxAmount">-9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>582</SequenceNumber><BusinessDayDate>2014-10-01-05:00</BusinessDayDate><BeginDateTime>2014-10-01T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-01T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-10-01T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-01T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>531</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-10-01T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-01T00:00:00.000-05:00</EndDateTime><Tender><Amount>-139.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-10-01T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-10-01T00:00:00.000-05:00</EndDateTime><Tax><Amount>-9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-139.270000</Total><Total TotalType="TransactionTaxAmount">-9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>632</SequenceNumber><BusinessDayDate>2014-09-25-05:00</BusinessDayDate><BeginDateTime>2014-09-25T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-25T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-25T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-25T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-25T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-25T00:00:00.000-05:00</EndDateTime><Tender><Amount>133.590000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-25T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-25T00:00:00.000-05:00</EndDateTime><Tax><Amount>8.590000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">120.000000</Total><Total TotalType="TransactionGrandAmount">133.590000</Total><Total TotalType="TransactionTaxAmount">8.590000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>572</SequenceNumber><BusinessDayDate>2014-09-22-05:00</BusinessDayDate><BeginDateTime>2014-09-22T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-22T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-22T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-22T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>485</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-22T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-22T00:00:00.000-05:00</EndDateTime><Tender><Amount>-139.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-22T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-22T00:00:00.000-05:00</EndDateTime><Tax><Amount>-9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-139.270000</Total><Total TotalType="TransactionTaxAmount">-9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>618</SequenceNumber><BusinessDayDate>2014-09-18-05:00</BusinessDayDate><BeginDateTime>2014-09-18T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-18T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-18T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-18T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-18T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-18T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-18T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-18T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>580</SequenceNumber><BusinessDayDate>2014-09-15-05:00</BusinessDayDate><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-090</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>581</SequenceNumber><BusinessDayDate>2014-09-15-05:00</BusinessDayDate><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-090</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>580</SequenceNumber><BusinessDayDate>2014-09-15-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Tender><Amount>-138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-15T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-15T00:00:00.000-05:00</EndDateTime><Tax><Amount>-8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-138.930000</Total><Total TotalType="TransactionTaxAmount">-8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>563</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tender><Amount>138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tax><Amount>8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">138.930000</Total><Total TotalType="TransactionTaxAmount">8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>564</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><OperatorID>BILFOOT</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>563</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tender><Amount>-138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tax><Amount>-8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-138.930000</Total><Total TotalType="TransactionTaxAmount">-8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>569</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>570</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-100</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>569</SequenceNumber><BusinessDayDate>2014-09-11-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tender><Amount>-138.930000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-11T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-11T00:00:00.000-05:00</EndDateTime><Tax><Amount>-8.940000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-138.930000</Total><Total TotalType="TransactionTaxAmount">-8.940000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>561</SequenceNumber><BusinessDayDate>2014-09-10-05:00</BusinessDayDate><BeginDateTime>2014-09-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-10T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-10T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>551</SequenceNumber><BusinessDayDate>2014-01-24-06:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-10T00:00:00.000-05:00</EndDateTime><Tender><Amount>-139.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-09-10T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-10T00:00:00.000-05:00</EndDateTime><Tax><Amount>-9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-129.990000</Total><Total TotalType="TransactionGrandAmount">-139.270000</Total><Total TotalType="TransactionTaxAmount">-9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>559</SequenceNumber><BusinessDayDate>2014-09-08-05:00</BusinessDayDate><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-110</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>2</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-090</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>60.000000</UnitCostPrice><RegularSalesUnitPrice>120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>120.000000</ActualSalesUnitPrice><ExtendedAmount>120.000000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>5</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Tender><Amount>406.110000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>6</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Tax><Amount>26.130000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">379.980000</Total><Total TotalType="TransactionGrandAmount">406.110000</Total><Total TotalType="TransactionTaxAmount">26.130000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>560</SequenceNumber><BusinessDayDate>2014-09-08-05:00</BusinessDayDate><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-110</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>559</SequenceNumber><BusinessDayDate>2014-09-08-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>2</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>02963-D-090</ItemID><UnitCostPrice>-129.990000</UnitCostPrice><RegularSalesUnitPrice>-129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>-129.990000</ActualSalesUnitPrice><ExtendedAmount>-129.990000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>559</SequenceNumber><BusinessDayDate>2014-09-08-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Return ItemType="Stock"><ItemID>97105</ItemID><UnitCostPrice>-60.000000</UnitCostPrice><RegularSalesUnitPrice>-120.000000</RegularSalesUnitPrice><ActualSalesUnitPrice>-120.000000</ActualSalesUnitPrice><ExtendedAmount>-120.000000</ExtendedAmount><Quantity>1.00</Quantity><TransactionLink><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>559</SequenceNumber><BusinessDayDate>2014-09-08-05:00</BusinessDayDate></TransactionLink><Reason>Return</Reason></Return></LineItem><LineItem VoidFlag="false"><SequenceNumber>5</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Tender><Amount>-406.110000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>6</SequenceNumber><BeginDateTime>2014-09-08T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-09-08T00:00:00.000-05:00</EndDateTime><Tax><Amount>-26.130000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">-379.980000</Total><Total TotalType="TransactionGrandAmount">-406.110000</Total><Total TotalType="TransactionTaxAmount">-26.130000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>560</SequenceNumber><BusinessDayDate>2014-08-07-05:00</BusinessDayDate><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-120</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>ISH</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>561</SequenceNumber><BusinessDayDate>2014-08-07-05:00</BusinessDayDate><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><OperatorID>TODHOLZ</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.270000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-08-07T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-08-07T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.280000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.270000</Total><Total TotalType="TransactionTaxAmount">9.280000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>CATALOG</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>ISH</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>481</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>482</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>483</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>484</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>485</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>486</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>487</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>488</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>489</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>490</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>491</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>492</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>493</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>494</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>495</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>496</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>497</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>498</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>499</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>500</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return><return CancelFlag="false"><RetailStoreID>999</RetailStoreID><WorkstationID>0</WorkstationID><SequenceNumber>501</SequenceNumber><BusinessDayDate>2014-07-21-05:00</BusinessDayDate><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><OperatorID>ORDERAPI</OperatorID><CurrencyCode>USD</CurrencyCode><RetailTransaction TypeCode="Transaction" TransactionStatus="Delivered"><LineItem VoidFlag="false"><SequenceNumber>1</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Sale ItemType="Stock"><ItemID>02963-D-095</ItemID><UnitCostPrice>129.990000</UnitCostPrice><RegularSalesUnitPrice>129.990000</RegularSalesUnitPrice><ActualSalesUnitPrice>129.990000</ActualSalesUnitPrice><ExtendedAmount>129.990000</ExtendedAmount><Quantity>1.00</Quantity></Sale></LineItem><LineItem VoidFlag="false"><SequenceNumber>3</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tender><Amount>144.610000</Amount></Tender></LineItem><LineItem VoidFlag="false"><SequenceNumber>4</SequenceNumber><BeginDateTime>2014-07-21T00:00:00.000-05:00</BeginDateTime><EndDateTime>2014-07-21T00:00:00.000-05:00</EndDateTime><Tax><Amount>9.620000</Amount></Tax></LineItem><Total TotalType="TransactionNetAmount">129.990000</Total><Total TotalType="TransactionGrandAmount">144.610000</Total><Total TotalType="TransactionTaxAmount">9.620000</Total></RetailTransaction><PosTransactionProperties><PosTransactionPropertyCode>Channel</PosTransactionPropertyCode><PosTransactionPropertyValue>ECOMM</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>order_type</PosTransactionPropertyCode><PosTransactionPropertyValue>W</PosTransactionPropertyValue></PosTransactionProperties><PosTransactionProperties><PosTransactionPropertyCode>source_code</PosTransactionPropertyCode><PosTransactionPropertyValue>HG</PosTransactionPropertyValue></PosTransactionProperties></return></ns2:getTransactionHistoryResponse></S:Body></S:Envelope>');
        } else {
            httpResp = objHttp.send(httpReq);
        }

        // Parse Response!
        if(httpResp.getStatusCode() != 200) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                'The Transaction History request returned an error, please try again!')); 
            return;
            System.Debug(httpResp.getBody());
        }

        // Deal with someone's great idea of using the same element name twice...
        String strResponse = httpResp.getBody();
        strResponse = strResponse.replace('<Return', '<LineReturn');
        strResponse = strResponse.replace('</Return', '</LineReturn');
        strResponse = strResponse.replace('</WorkstationID><SequenceNumber>', '</WorkstationID><SeqOrderNumber>');
        strResponse = strResponse.replace('</SequenceNumber><BusinessDayDate>', '</SeqOrderNumber><BusinessDayDate>');

        // Push good result to WS Response Object
        XmlStreamReader reader = new XmlStreamReader(strResponse);
        parseTransactionXMLResult(reader);

        //System.Debug(lstTransactions);
        
    }

    public void searchRelate() {

        lstResults = new List<hClsResult>();

        Xmlstreamwriter writer = new Xmlstreamwriter();

        // Manually Generate XML because Salesforce cannot handle elements and attributes at the same time!  ARGH.
        String strXML = '';
        strXML+='<?xml version="1.0" encoding="UTF-8"?>';

        writer.writeStartDocument('utf-8', '1.0');
            writer.writeStartElement(null,'env:Envelope', null);
                writer.writeAttribute(null, null, 'xmlns:env', 'http://schemas.xmlsoap.org/soap/envelope/');
                writer.writeAttribute(null, null, 'xmlns:xsd', 'http://www.w3.org/2001/XMLSchema');
                writer.writeAttribute(null, null, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance');
                writer.writeEmptyElement(null,'env:Header', null);
                writer.writeStartElement(null,'env:Body', null);
                    writer.writeStartElement(null,'v1:searchCustomers', null);
                        writer.writeAttribute(null, null, 'xmlns:v1', 'http://v1_0.customer.webservices.csx.dtv.com/');
                        writer.writeStartElement(null,'customerData', null);
                            writer.writeEmptyElement(null,'Instrument', null);
                            writer.writeEmptyElement(null,'CustomerID', null);
                            writer.writeStartElement(null,'EntityInformation', null);
                                writer.writeStartElement(null,'Individual', null);
                                    writer.writeStartElement(null,'Name', null);
                                        writer.writeStartElement(null,'Name', null);
                                            writer.writeAttribute(null, null, 'Location', 'First');
                                            writer.writeAttribute(null, null, 'SearchType', 'Contains');
                                            writer.writeCharacters(clsCriteria.strFirstName);
                                        writer.writeEndElement();
                                        writer.writeStartElement(null,'Name', null);
                                            writer.writeAttribute(null, null, 'Location', 'Last');
                                            writer.writeAttribute(null, null, 'SearchType', 'Contains');
                                            writer.writeCharacters(clsCriteria.strLastName);
                                        writer.writeEndElement();
                                    writer.writeEndElement();
                                    writer.writeStartElement(null,'ContactInformation', null);
                                        writer.writeStartElement(null,'Telephone', null);
                                            writer.writeAttribute(null, null, 'SequenceNumber', '');
                                            writer.writeAttribute(null, null, 'SearchType', 'Contains');
                                            writer.writeAttribute(null, null, 'TypeCode', 'Home');
                                            writer.writeStartElement(null,'PhoneNumber', null);
                                                writer.writeCharacters(clsCriteria.strTelephone);
                                            writer.writeEndElement();
                                            writer.writeEmptyElement(null,'Extension', null);
                                        writer.writeEndElement();
                                        writer.writeStartElement(null,'EMail', null);
                                            writer.writeAttribute(null, null, 'SearchType', 'Contains');
                                            writer.writeAttribute(null, null, 'TypeCode', '');
                                            writer.writeStartElement(null,'EMailAddress', null);
                                                writer.writeCharacters(clsCriteria.strEmail);
                                            writer.writeEndElement();
                                        writer.writeEndElement();
                                    writer.writeEndElement();
                                writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeEmptyElement(null,'SegmentID', null);
                        writer.writeEndElement();
                    writer.writeEndElement();
                writer.writeEndElement();
            writer.writeEndElement();
        writer.writeEndDocument();

        String xmlRequest = writer.getXMLString();
        writer.close();

        // Assemble SOAP Request
        Http objHttp = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(strEndpoint);
        httpReq.setMethod('POST');
        httpReq.setHeader('Content-Type','text/xml;charset=UTF-8');
        httpReq.setTimeout(10000);
        httpReq.setBody(xmlRequest);
        HttpResponse httpResp;

        if(test.isRunningTest()) {
            httpResp = new HttpResponse();
            httpResp.setStatusCode(200);
            httpResp.setbody('<?xml version="1.0" encoding="UTF-8"?><S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/"><S:Body><ns2:searchCustomersResponse xmlns:ns2="http://v1_0.customer.webservices.csx.dtv.com/"><return><DateTime>2014-11-17T15:42:35.000-06:00</DateTime><Customer ResponseCode="OK"><CustomerID>64725</CustomerID><SignupDate>2014-07-02-05:00</SignupDate><Validation ValidFlag="true" /><HouseholdKey /><EntityInformation><Individual><Name><Name Location="First">Willy</Name><Name Location="Middle" /><Name Location="Last">Wonka</Name></Name><ContactInformation><Address ContactPreferenceCode="N" PrimaryFlag="true" TypeCode="HOME" ValidFlag="true" SequenceNumber="1"><AddressLine1>120 MAIN DR</AddressLine1><City>RED WING</City><Country>US</Country><Territory>MN</Territory><PostalCode>55066</PostalCode></Address><EMail PrimaryFlag="true" TypeCode="HOME" ContactPreferenceCode="Y" SequenceNumber="1"><EMailAddress>willywonka@chocolatefactory.com</EMailAddress></EMail><Telephone PrimaryFlag="true" TypeCode="BUSINESS" ContactPreferenceCode="Y" SequenceNumber="1"><PhoneNumber>7631111111</PhoneNumber></Telephone><Telephone PrimaryFlag="false" TypeCode="HOME" ContactPreferenceCode="Y" SequenceNumber="2"><PhoneNumber>7631111111</PhoneNumber></Telephone></ContactInformation></Individual></EntityInformation><AlternateKey TypeCode="SERENADE_ID"><AlternateID>158</AlternateID></AlternateKey></Customer></return></ns2:searchCustomersResponse></S:Body></S:Envelope>');
        } else {
            httpResp = objHttp.send(httpReq);
        }

        // Parse Response!
        if(httpResp.getStatusCode() != 200) {
            System.debug(httpResp.getBody());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                'Either your criteria returned no results or too many results, please check your criteria and try again!')); 
            return;
        }

        // Push good result to WS Response Object
        XmlStreamReader reader = httpResp.getXmlStreamReader();
        parseSearchXMLResult(reader);

        System.Debug(lstResults);
    }

    ////////////////////////////////////////////
    // XML Parsers
    ////////////////////////////////////////////
    private void parseTransactionXMLResult(XmlStreamReader reader) {

        // NEW RESULT, CREATE NEW OBJECT
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if(reader.getEventType() == XmlTag.START_ELEMENT) {
                if(reader.getLocalName() == 'return') {
                    if(reader.getAttributeValue(null, 'CancelFlag') == 'false') {
                        lstTransactions.add(parseTransactionResult(reader));
                    }
                }
            }

            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
    }

    private void parseSearchXMLResult(XmlStreamReader reader) {

        // NEW RESULT, CREATE NEW OBJECT
        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if(reader.getLocalName() == 'Customer') {
                    if(reader.getAttributeValue(null, 'ResponseCode') == 'OK') {
                        lstResults.add(parseSearchCustomerResult(reader));
                    }
                }
            }

            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }

    }

    private hClsTransHeader parseTransactionResult(XmlStreamReader reader) {

        hClsTransHeader clsTransaction = new hClsTransHeader();
        clsTransaction.lstLineItems = new List<hClsTransLine>();
        hClsTransLine clsTransLine = new hClsTransLine();

        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {

            // Exit out
            if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'return') {
                System.Debug('EXITING OUT OF XML LOOP');
                break;
            }

            // Retail Store Id
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RetailStoreID') {
                reader.next();
                clsTransaction.strRetailStoreId = reader.getText();
            }

            // Sequence Number
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SeqOrderNumber') {
                reader.next();
                clsTransaction.strSequenceNumber = reader.getText();
            }

            // OperatorId
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OperatorId') {
                reader.next();
                clsTransaction.strOperatorId = reader.getText();
            }

            // Transaction Date
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'BeginDateTime') {
                reader.next();
                clsTransaction.strTransDate = reader.getText().substring(0,10); 
            }

            // Transaction Grand Amount
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Total') { 
                if(reader.getAttributeCount() > 0) { 
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getAttributeValue(null, 'TotalType') == 'TransactionGrandAmount') {
                        reader.next();
                        clsTransaction.decExtendedAmount = decimal.valueOf(reader.getText()); // Read ExtendedAmount
                    }
                }
            }

            // Channel
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PosTransactionPropertyCode') {
                reader.next();
                if(reader.getText() == 'Channel') {
                    reader.next();reader.next();reader.next();
                    clsTransaction.strChannel = reader.getText();
                }
                if(reader.getText() == 'order_type') {
                    reader.next();reader.next();reader.next();
                    clsTransaction.strOrderType = reader.getText();
                }
                if(reader.getText() == 'source_code') {
                    reader.next();reader.next();reader.next();
                    clsTransaction.strSourceCode = reader.getText();
                }
                
            }

            // Line Item - SALE START
            if(reader.getEventType() == XmlTag.START_ELEMENT && (reader.getLocalName() == 'Sale' || reader.getLocalName() == 'LineReturn')) {
                clsTransLine = new hClsTransLine();
            }

            // ItemId!
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ItemID') {
                reader.next();  // ItemId
                clsTransLine.strItemId = reader.getText(); // Read ItemID
            }

            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ExtendedAmount') {
                reader.next(); // ExtendedAmount
                clsTransLine.decExtendedAmount = decimal.valueOf(reader.getText()); // Read ExtendedAmount
            }

            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Quantity') {
                reader.next(); // Quantity
                clsTransLine.intQuantity = integer.valueOf(reader.getText()); // Read Quantity
            }

            // Line Item - SALE END
            if(reader.getEventType() == XmlTag.END_ELEMENT && (reader.getLocalName() == 'Sale' || reader.getLocalName() == 'LineReturn')) {
                clsTransaction.lstLineItems.add(clsTransLine);
                clsTransaction.strLineItemArray = JSON.serialize(clsTransaction.lstLineItems);
            }


            // Loop
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }


        }

        System.Debug('RETURNING TRANSACTION = ' + clsTransaction);
        return clsTransaction;

    }

    private hClsResult parseSearchCustomerResult(XmlStreamReader reader) {

        hClsResult clsResult = new hClsResult();

        boolean isSafeToGetNextXmlElement = true;
        while(isSafeToGetNextXmlElement) {

            System.debug('****EVENTTYPE ' + reader.getEventType() + ' | ' + reader.getLocalName());
            if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Customer') {
                break;
            } 

            // Customer ID
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CustomerID') {
                reader.next();
                clsResult.strCustomerId = reader.getText(); 
            }

            // Retail Store Id
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RetailStoreID') {
                reader.next();
                clsResult.strRetailStoreId = reader.getText(); 
            }

            // Signup Date
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SignupDate') {
                reader.next();
                clsResult.strSignupDate = reader.getText();

                if(clsResult.strSignupDate.length() > 0) {
                    clsResult.strSignupDate = clsResult.strSignupDate.substring(0,10);
                }
            }

            // First and Last Name
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Name') { 
                if(reader.getAttributeCount() > 0) { 
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getAttributeValue(null, 'Location') == 'First') {
                        reader.next();
                        clsResult.strFirstName = reader.getText();
                    }
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getAttributeValue(null, 'Location') == 'Last') {
                        reader.next();
                        clsResult.strLastName = reader.getText();
                    }
                }
            }

            // Telephone
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Telephone') {
                reader.next();reader.next();
                clsResult.strTelephone = formatphonenumber(reader.getText());
            }

            // Email 
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Email') {
                reader.next();reader.next();
                clsResult.strEmailAddress = reader.getText();
            }

            // RIMS Id
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'AlternateKey') { 
                if(reader.getAttributeCount() > 0) { 
                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getAttributeValue(null, 'TypeCode') == 'RIMSID') {
                        reader.next();reader.next();
                        clsResult.strRIMSId = reader.getText();
                    }
                }
            }

            // Address
            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Address') { 
                if(reader.getAttributeCount() > 0) { 
                    try {
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getAttributeValue(null, 'TypeCode') == 'HOME') {
                            reader.next();reader.next();clsResult.strAddressLine1 = reader.getText();
                            reader.next();reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'AddressLine2') {
                                reader.next();clsResult.strAddressLine2 = reader.getText();
                                reader.next();reader.next();reader.next();
                            } else {
                                reader.next();
                            }
                            clsResult.strCity = reader.getText();
                            reader.next();reader.next();reader.next();clsResult.strCountry = reader.getText();
                            reader.next();reader.next();reader.next();clsResult.strTerritory = reader.getText();
                            reader.next();reader.next();reader.next();clsResult.strPostalCode = reader.getText();
                        }
                    } catch (Exception ex) {
                        System.Debug('The XML returned from RELATE has an issue with the HOME address, bypassing.');
                    }
                }
            }

            // Loop
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }

        return clsResult;

    }

    public static String formatphonenumber(String cphone) {
        String fphone = cphone.replaceAll('\\D','');

        if (fphone.length() == 10) {
            fphone = formatphonenum(fphone);
            return fphone;
        }
        else {
            return cphone;
        }

    }

    static String formatphonenum (String s) {
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }

    ////////////////////////////////////////////////////////////////////////////////////////


    ///////////////////////////////////
    // Helper Classes
    ///////////////////////////////////
    public class hClsCriteria {

        public String strChosenFN {get;set;}
        public String strChosenLN {get;set;}
        public String strChosenCustomerId {get;set;}
        public String idChosenSFDCId {get;set;}
        public Boolean bolCreateNewContact {get;set;}

        public String strFirstName {
            get;
            set { if(value == null) { strFirstName = ''; } else { strFirstName = value; }}
        } 
        public String strLastName {
            get;
            set { if(value == null) { strLastName = ''; } else { strLastName = value; }}
        } 
        public String strTelephone {
            get;
            set { if(value == null) { strTelephone = ''; } else { strTelephone = value; }}
        }
        public String strEmail {
            get;
            set { if(value == null) { strEmail = ''; } else { strEmail = value; }}
        } 

        public hClsCriteria() { 
            strFirstName = '';
            strLastName = '';
            strTelephone = '';
            strEmail = '';
            idChosenSFDCId = '';
            bolCreateNewContact = false;
        }

    }

    public class hClsResult {

        public String strCustomerId {get;set;}
        public String strFirstName {get;set;}
        public String strLastName {get;set;}
        public String strTelephone {get;set;}
        public String strEmailAddress {get;set;}
        public String strRIMSId {get;set;}
        public String strRetailStoreId {get;set;}
        public String strSignupDate {get;set;}
        public String strAddressLine1 {get;set;}
        public String strAddressLine2 {get;set;}
        public String strCity {get;set;}
        public String strTerritory {get;set;}
        public String strPostalCode {get;set;}
        public String strCountry {get;set;}

        public hClsResult() { }

    }

    public class hClsTransHeader {

        public String strRetailStoreId {get;set;}
        public String strOperatorId {get;set;}
        public String strTransDate {get;set;}
        public String strChannel {get;set;}
        public String strOrderType {get;set;}
        public String strSourceCode {get;set;}
        public Decimal decExtendedAmount {get;set;}
        public String strSequenceNumber {get;set;}
        public String strLineItemArray {get;set;}
        public List<hClsTransLine> lstLineItems {get;set;}

    }

    public class hClsTransLine {
        public String strItemId {get;set;}
        public Integer intQuantity {get;set;}
        public Decimal decExtendedAmount {get;set;} 
    }
}