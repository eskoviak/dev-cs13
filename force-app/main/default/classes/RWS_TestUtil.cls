/********************************************************************************
*   PURPOSE : Utility class. Used to generate data for test classes
*
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   12/01/2016  Usman Aslam/M360        Initial version
*	03/08/18	Brandon Willard(M360)   Modified to support testing for RWCP-3449
*	09/17/2019	Rajani Cheruku (RW)		Added RWBAA testing for US-62940
********************************************************************************/
public with sharing class RWS_TestUtil {

    // get record type id
    public static Id getRecordTypeIdByDeveloperName(String developerName, String sObjectType) {
        return [select Id from RecordType 
                where DeveloperName = :developerName 
                and SObjectType = :sObjectType].Id;
    }

    public static Dealer__c createDealer(Boolean insertRecord) {
        Dealer__c d = new Dealer__c(Name = 'Test Dealer', IsActive__c = true);

        if(insertRecord) {
            insert d;
        }

        return d;
    }
    

    // create account
    public static Account createAccount(Id recordTypeId, Boolean insertRecord) {
        Account acc = new Account(Name = 'Test ' + Datetime.now().getTime(), 
                                  RecordTypeId = recordTypeId,
                                  Type = 'Customer',
                                  Status__c = 'Current Customer',
                                  IA_Account_Category__c = 'National Account',
                                  Publish_Status__c = 'Published',
                                  Active__c = true,
                                  Credit_Status__c = 'Approved/Active'
                                  ,IA_Physical_Location_Address_Line_1__c = '24-A',
                                  IA_Physical_Location_Country__c = 'US',
                                  RWfB_same_as_Physical_Address__c = false,
                                  Primary_Contact_Email__c = 'Test' + Datetime.now().getTime() + '@noemail.com',
                                  Primary_Contact_Last_Name__c = 'First' + Datetime.now().getTime(),
                                  Primary_Contact_First_Name__c = 'Last' + Datetime.now().getTime(),
                                  Primary_Contact_Mailing_Street__c = '24-A' + Datetime.now().getTime(),
                                  Primary_Contact_Mailing_State_Province__c = 'MN',
                                  Primary_Contact_Mailing_Country__c  = 'US',
                                  Primary_Contact_Mailing_Zip_Postal_Code__c = '55213',
                                  HasActiveProgram__c = true,
                                  Requires_Invoicing__c = 'No' );
        
        if(insertRecord)
            insert acc;
        
        return acc;
    }
    
    // create contact
    public static Contact createContact(Id accountId, Integer counter, Boolean insertRecord) {
        Id rtId = getRecordTypeIdByDeveloperName('Business_Partner', 'Contact');

        //03.19.2019 - For validation rule - need correct phone number
        //I just want 7 random digits as the last part of the number; then we don't have to worry about duplicate rules.
        String randNo = String.valueOf(Crypto.getRandomInteger());
        String phone3 = randNo.right(3).rightPad(3, '0');
        String phone4 = randNo.right(4).rightPad(4, '0');
        String fullPhone = '(' + phone3 + ') ' + phone3 + '-' + phone4;

        Contact acc = new Contact(LastName = counter + 'Test' + Datetime.now().getTime(), 
        						  FirstName = counter + 'FNTest' + Datetime.now().getTime(),
                                  AccountId = accountId,
                                  Email = counter + 'Test' + Datetime.now().getTime() + '@noemail.com',
                                  //Phone = counter + '' + Datetime.now().getTime(),
                                  Phone = fullPhone,
                                  RecordTypeId = rtId);
        
        if(insertRecord)
            insert acc;
        
        return acc;
    }
    
    // create program
    public static Program__c createProgram(Id accountId, Boolean insertRecord) {
        Program__c pr = new Program__c();
        pr.Account__c = accountId;
        pr.Name = 'Test ' + Datetime.now().getTime();
        pr.Active__c = true;
        pr.Type__c = 'CashandCarry';
        pr.Auto_Update_Price__c = true;
        pr.Activation_Date__c = Date.today().addDays(-1);
        pr.Expiration_Date__c = Date.today().addDays(5);
        pr.Eligibility_Option__c = 'False';
        pr.Subsidy_Tax__c = 'SubsidyTaxed';
        pr.HasPricebook__c = true;
        pr.Require_Upload_of_Company_Voucher__c = 'No';
        
        if(insertRecord)
            insert pr;
        
        return pr;
    }
    
   //create RWBAA Data for AccountAlerts [AR,CH,CL]
    public static RWBAA_AR_Data__c createRwbaa(Id accountId, Boolean insertRecord){
    	RWBAA_AR_Data__c rwbaa = new RWBAA_AR_Data__c(
    		Account__c = accountId,
    		MSTS_Available_Credit__c = 20000,
    		MSTS_Credit_Limit__c = 5000,
        	MSTS_AR_61_to_90__c = 0,
        	MSTS_AR_91_to_120__c = 0,
        	MSTS_AR_121_to_150__c = 0,
        	MSTS_AR_Over_150__c = 10);
    	
    	if(insertRecord){
    		insert rwbaa;
    	}
    	return rwbaa;
    }
    
    //create RWBAA Contact Data
    public static RWBAA_Contacts__c createRwbaaContact(Id accountId, Boolean insertRecord){
    	RWBAA_Contacts__c rwbaaCont = new RWBAA_Contacts__c(
    		Account_Safe_ID__c = accountId,
    		RWBAA_First_Name__c = 'Test' + Datetime.now().getTime(),
    		RWBAA_Last_Name__c = 'Test' + Datetime.now().getTime(),
    		RWfB_Account__c = accountId
    		);
    	
    	if(insertRecord){
    		insert rwbaaCont;
    	}
    	return rwbaaCont;
    }
    

    public static Servicing_Store__c createServicingStore(Id accountId, Id programId, Boolean insertRecord) {
        Servicing_Store__c pr = new Servicing_Store__c();
        pr.Account__c = accountId;
        pr.Program__c = programId;
        pr.Servicing_Status__c = 'Active';
        
        if(insertRecord)
            insert pr;
        
        return pr;
    }
    
    // create product
    public static Product2 createProduct(String uid, Boolean insertRecord) {
        Product2 prod = new Product2(Name = 'Laptop X200' + uid, 
                                     Family = 'Hardware',
                                     IsActive = true,
                                     Category__c = 'Footwear',
                                     Style_Number_Unique_Id__c = '00110' + uid,
                                     Item_Status__c = 'Active' ,
                                     Item_Status_Code__c = '20',
                                     ProductCode = 'PC00110' + uid);
        
        if(insertRecord)
            insert prod;
        
        return prod;
    }
    
    // create product
    public static Product2 createProduct(Boolean insertRecord) {
        return createProduct('1', insertRecord);
    }
    
    // create pricebook entry
    public static PricebookEntry createPricebookEntry(Id pricebookId, Id productId, Boolean insertRecord) {
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, 
            Product2Id = productId,
            UnitPrice = 100, 
            IsActive = true,
            MSRP_Effective_Date__c = Date.today());
        
        if(insertRecord)
            insert standardPrice;
        
        return standardPrice;
    }
    
    // create publish pricebook entry - added by BW
    public static Publish_PriceBook_Entry__c createPublishPricebookEntry(Id pricebookId, Id productId, Boolean insertRecord) {
        Publish_PriceBook_Entry__c customPrice = new Publish_PriceBook_Entry__c(
            Publish_PriceBook__c = pricebookId, 
            Product_ID__c = productId,
            List_Price__c = 100, 
            Active__c = true,
            CurrencyIsoCode ='USD',
            Filter_Number__c = 0,
            MSRP_Effective_Date__c = Date.today());
        
        if(insertRecord)
            insert customPrice;
        
        return customPrice;
    }
    
    // create pricebook
    public static Pricebook2 createCustomPricebook(Id programId, Boolean insertRecord) {
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true, Program__c = programId);
        
        if(insertRecord)
            insert customPB;
        
        return customPB;
    }
    
    // create custom pricebook(ppb) - added by BW
    public static Publish_PriceBook__c createCustomPublishPricebook(Id programId, Boolean insertRecord) {
        Publish_PriceBook__c customPPB = new Publish_PriceBook__c(Name='Custom Pricebook', IsActive__c=true, Program__c = programId);
        
        if(insertRecord)
            insert customPPB;
        
        return customPPB;
    }

    // create future price
    public static Future_Price__c createFuturePrice(Id productId, Boolean insertRecord) {
        Future_Price__c customPB 
            = new Future_Price__c(  Active__c = true, 
                                    Product__c = productId,
                                    Effective_Date__c = Date.today(),
                                    MSRP__c = 1000);
        
        if(insertRecord)
            insert customPB;
        
        return customPB;
    }

    
    // get profile name
    public static Id getProfileIdByName(String profileName) {
        return [select Id from Profile where name = :profileName].Id;
    }
    
    // create community user
    public static User createCommunityUser(Id contactId, Id profileId, Boolean insertRecord) {
        User user = new User(
            alias = 't' + String.valueOf(contactId).right(7), 
            email = 'test' + contactId + '@noemail.com',
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing', 
            languagelocalekey ='en_US',
            localesidkey ='en_US', 
            profileid = profileId, 
            country ='United States',
            IsActive = true,
            ContactId = contactId,
            timezonesidkey = 'America/Los_Angeles', 
            username = 'test' + contactId + '@noemail.com');
        
        if(insertRecord)
            insert user;
        
        return user;
    }

    public static User createUser(String randomString, Id profileId, Boolean insertRecord) {
        User user = new User(
            alias = 't' + randomString, 
            email = 'test' + randomString + '@noemail.com',
            emailencodingkey = 'UTF-8', 
            lastname = 'Testing', 
            languagelocalekey ='en_US',
            localesidkey ='en_US', 
            profileid = profileId, 
            country ='United States',
            IsActive = true,
            timezonesidkey = 'America/Los_Angeles', 
            username = 'test' + randomString + '@noemail.com');
        
        if(insertRecord)
            insert user;
        
        return user;
    }
    
    // create IA Feature
    public static IA_Feature__c createIAFeature( String Name , ID parentIAfeature, String Category, Boolean Selectable, Boolean a_insert )
    {
        IA_Feature__c  l_IA_feature = new IA_Feature__c();
        l_IA_feature.Name = Name;
        l_IA_feature.Parent_IA_Feature__c = parentIAfeature;
        l_IA_feature.Category__c = Category;
        l_IA_feature.Selectable__c = selectable;
        l_IA_feature.Feature_Name__c = Name;

        if(a_insert) {
            insert l_IA_feature;
        }
        return l_IA_feature;              
    }
    
    // create Feature
    public static Features__c createFeature( String Name , ID IAfeatureId, Boolean a_insert )
    {
        Features__c  l_feature = new Features__c();
        l_feature.Name = Name;
        l_feature.IA_Feature__c = IAfeatureId;
        l_feature.Feature_Name__c = Name;

        if( a_insert )
        {
            insert l_feature;
        }
        return l_feature;              
    }
    
    // create product
    public static Product2 createProductwithDetail(String Name, String Category,Boolean insertRecord) {
        Product2 prod = new Product2(Name = Name, 
                                     Category__c = Category,
                                     IsActive = true,
                                     Item_Status__c = 'Active',
                                     Item_Status_Code__c = '20');
        
        if(insertRecord)
            insert prod;
        
        return prod; 
    }

    // create product feature
    public static Product_Style_Features__c createProductFeature(Id FeatureID, Id ProductID, Boolean a_insert) {
        Product_Style_Features__c  l_prod_ftr = new Product_Style_Features__c();
        l_prod_ftr.Feature__c = FeatureID;
        l_prod_ftr.Product_Style__c = ProductID;

        if( a_insert ) {
            insert l_prod_ftr;
        }
        return l_prod_ftr; 
    }

    // create filter criteria
    public static Filter_Criteria__c createFilterCriteria(Id programId, Id iaFeatureId, Boolean insertRecord) {
        Filter_Criteria__c  fc = new Filter_Criteria__c();
        fc.Program__c = programId;
        fc.IA_Feature__c = iaFeatureId;
        fc.Filter_Number__c = 1;
        fc.Discount__c = 10;

        if( insertRecord ) {
            insert fc;
        }
        return fc; 
    }
}