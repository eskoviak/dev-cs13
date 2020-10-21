@isTest
private class RWS_PriceList_Summary_Controller_Test {
    static testMethod void testController() {
        Id profileId = RWS_TestUtil.getProfileIdByName('RWS Business Partner Community');

        Id rtId = RWS_TestUtil.getRecordTypeIdByDeveloperName('Business_Partner_Community', 'Account');

        Account acc = RWS_TestUtil.createAccount(rtId, true);

        acc.IsPartner = true;
        update acc;

        Contact con1 = RWS_TestUtil.createContact(acc.Id, 0, false);

        insert con1;

        Id roleId = [select Id from UserRole where Name = 'System Administrators' limit 1].Id;

        User u1 = RWS_TestUtil.createCommunityUser(con1.Id, profileId, false);

        System.runAs(new User(Id = UserInfo.getUserId())) {

            User user = new User(Id = UserInfo.getUserId(), UserRoleId = roleId);
            update user;

            insert u1;

            Id partnerRoleId = [select Name from UserRole where PortalAccountId = :acc.Id].Id;

            u1.UserRoleId = partnerRoleId;

            update u1;
        }

        Test.startTest();

        System.runAs(u1) {
            Program__c pr = RWS_TestUtil.createProgram(acc.Id, false);   
            pr.Processing_Status__c = 'Completed';
            insert pr;

            Product2 prod = RWS_TestUtil.createProduct(true);

            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry standardPrice = RWS_TestUtil.createPricebookEntry(pricebookId, prod.Id, true);

            Publish_PriceBook__c customPB = RWS_TestUtil.createCustomPublishPricebook(pr.Id, true);

            Publish_PriceBook_Entry__c customPrice = RWS_TestUtil.createPublishPricebookEntry(customPB.Id, prod.Id, true);
			System.debug('PPBE :'+customPrice);
            List<IA_Feature__c> Iafeature_lst1 = new List<IA_Feature__c>();
            Iafeature_lst1.add(RWS_TestUtil.createIAFeature('Brand',null, 'Footwear', false, false));
            insert Iafeature_lst1;

            List<IA_Feature__c> Iafeature_lst2 = new List<IA_Feature__c>();
            Iafeature_lst2.add(RWS_TestUtil.createIAFeature('Red wing',Iafeature_lst1[0].id, 'Footwear', true, false));
            insert Iafeature_lst2;

            List<Features__c> features_lst1 = new List<Features__c>();
            features_lst1.add(RWS_TestUtil.createFeature('Red wing',Iafeature_lst2[0].id, false));
            insert features_lst1;

            List<Product_Style__c> styles = [select Id from Product_Style__c];

            List<Product_Style_Features__c> Product_Features_lst = new List<Product_Style_Features__c>();
            Product_Features_lst.add(RWS_TestUtil.createProductFeature(features_lst1[0].id, styles[0].id, false));

            insert product_Features_lst;

            List<Filter_Criteria__c> filters = new List<Filter_Criteria__c>();
            Filter_Criteria__c fc = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[0].id, false);
            fc.IA_Feature__c = null;
            fc.Product_Code__c = JSON.serialize(new Set<String>{prod.ProductCode}) + '-FPC-' + JSON.serialize(new Set<String>() );
            fc.Filter_Display__c = 'AND( ABC )';

            Filter_Criteria__c fc2 = RWS_TestUtil.createFilterCriteria(pr.Id, Iafeature_lst2[0].id, false);
            fc2.Filter_Number__c = 0;
            fc2.IA_Feature__c = null;
            fc2.Product_Code__c = JSON.serialize(new Map<String, Decimal>{prod.ProductCode => 40}) + '-FPC-' + JSON.serialize(new Set<String>() );
            fc2.Filter_Display__c = 'Custom List';

            filters.add(fc);
            filters.add(fc2);

            insert filters;

            PageReference pg = Page.RWS_PriceList_Summary;
            pg.getParameters().put('id', customPB.Id);
            Test.setCurrentPageReference(pg);

            RWS_PriceList_Summary_Controller psc = new RWS_PriceList_Summary_Controller();
            psc.firstLoad = true;

            System.debug(psc.loadEntriesJSON);
            System.debug(psc.ProgramEffectiveDate);
            System.debug(psc.ExpirationDate);

            System.assert(psc.entries.size() == 1);

            psc.updateJson = JSON.serialize(psc.entries);

            psc.updateEntries();

            psc.program.Template__c = true;

            psc.updateProgram();

            psc.entryId = psc.entries[0].Id;

            //psc.removeEntry();

            psc.selectedFilter = '1';
            
            psc.removeAll();

            psc.searchTerm = prod.ProductCode;

            psc.searchProduct();
        }

        Test.stopTest();
    }
}