/********************************************************************************
*   PURPOSE : Controller for production selection component *
*
*   CHANGE  HISTORY
*   =============================================================================
*   Date        Name                    Description
*   			M360			        Initial version*
*	03/08/18	Brandon Willard(M360)   Modified for RWCP-3449
********************************************************************************/
Public Class RWS_Production_Selection_Controller{

    public Integer displayNum { get; set; }

    public String tableTab { get; set; }
    public Boolean chooseMoreFilters {get; set;}    
    //public List<featureWrapperClass> featureWrapperLst {get;set;}
    public List<featureWrapperClass> featureFWWrapperLst {get;set;}
    public List<featureWrapperClass> featureACWrapperLst {get;set;}
    public List<featureWrapperClass> featureWWWrapperLst {get;set;}
    public List<featureWrapperClass> featureOLWrapperLst {get;set;}
    private Map<String, List<PriceBookEntry>> relatedProducts;
    private Set<String> uniqueProducts;

    public string FWCheckbox {get;set;}
    public string ACCheckbox {get;set;}
    public string WWCheckbox {get;set;} 
    public string OLCheckbox {get;set;} 

    public String FWjsonResult     {get;set;}
    public String ACjsonResult     {get;set;}
    public String WWjsonResult     {get;set;}
    public String OLjsonResult     {get;set;}

    public String TabCategory {get;set;}
    public decimal discount {get; set;}
    public String resetVal {get; set;}
    private Id stdPriceBookId ;
    public boolean selectAllDisc{get;set;}

    public Publish_PriceBook__c createdPricebook {get;set;}
    public string ProgramId {get;set;}
    public string AccountId {get;set;}

    public Boolean updateProgram {get;set;}
    public Program__c createdProgram {get;set;}

    set<id> firstset = new set<id>();
    public String prdresult{get;set;}
    Map<string,Id> styleProductMap ;
    
    public Boolean sellOutsideLines {get; set;}
    public Boolean isTemplate = false ;
    public Boolean isWizard { get; set;}
    public Boolean isInternal { get; set;}
    public Boolean isProgramSetup { get; set;}
    private Integer recordsCount;


/********************************************************************************************************
                                        Constructor
********************************************************************************************************/
    public RWS_Production_Selection_Controller() {
        showPage = true;
        recordsCount = 0;
        system.debug('RWS_Production_Selection_Controller Constructor Begin ************');
        updateProgram = false;
        isWizard = false;
        isProgramSetup = false;
        isInternal = false;
        displayNum = 1000;
        ProgramId = ApexPages.currentPage().getParameters().get('proid');
        AccountId = ApexPages.currentPage().getParameters().get('AccountId');
        String pageURL = ApexPages.currentPage().getUrl();
        System.debug('UAC: pageURL ' + pageURL );

        if(pageURL != null) {
            // When user comes from AccountCreation Page
            if(pageURL.containsIgnoreCase('RWS_Account_CreationV2')) {
                isTemplate = false ;
                isWizard = true;
            }
            
            if(pageURL.containsIgnoreCase('RWS_NewProgramSetup')) {
                isProgramSetup = true;
            }
            
            // When user comes from ProgramSetup page to create new ProgramTemplate 
            if(pageURL.containsIgnoreCase('RWS_NewProgramSetup') && String.isBlank(ProgramId) ) {
                isTemplate = true;
            }
            
            if(pageURL.containsIgnoreCase('RWS_NewProgramSetup') && !String.isBlank(AccountId)){
                isTemplate = false;
            }
            
            if(pageURL.containsIgnoreCase('RWS_Product_Selection') ) 
            {
                isInternal = true;
                if(String.isBlank(programId)) programId = ApexPages.currentPage().getParameters().get('id');
                isTemplate = false ;
            }
        }

        
        try{
            List<User> contacts = [Select Id, Name, Contact.Account.Sells_Outside_Lines__c from user where id = :userinfo.getuserid()];
            if(contacts != null && contacts.size() > 0){
                sellOutsideLines = contacts[0].Contact.Account.Sells_Outside_Lines__c;
            }

            populateProgram();

        } catch(Exception e){ }


        discount = 20;
        resetVal = 'reset';
        FWCheckbox = 'false';
        ACCheckbox = 'false';
        WWCheckbox = 'false';
        OLCheckbox = 'false';
        selectAllValue = 'false';

        StandardPriceBookId();
        TabCategory = 'Workwear';
        FeaturesListbyCategory();
        
        TabCategory = 'Accessories Apparel and Gear';
        FeaturesListbyCategory();

        TabCategory = 'Outside Lines';
        FeaturesListbyCategory();
        
        TabCategory = 'Footwear';
        FeaturesListbyCategory();

        system.debug('RWS_Production_Selection_Controller Constructor END ************');

    }

    public void populateProgram() {
        if(!String.isBlank(programId)) {
            createdprogram = [select id, Name, Auto_Update_Price__c, Auto_Add_Products__c,
                                    Account__r.Sells_Outside_Lines__c 
                                FROM Program__c where Id = :ProgramId]; 
        }

        if (createdProgram != null) {
            List<Publish_PriceBook__c> ppbs = [select Id,Program__c//,IsStandard   
                                    from Publish_PriceBook__c	 
                                where Program__c = :createdProgram.Id /*and IsStandard = false*/ limit 1];

            if(null != ppbs && !ppbs.isEmpty())
                createdPricebook = ppbs[0];
        }
    }

    public Boolean showPage {get; set;}
    public void validateProgram() {
        try {
            update createdprogram;
        } catch(Exception dmex)  {
            ApexPages.addMessages(dmex);
            showPage = false;
        }
    }
    
         
/********************************************************************************************************
                    Wrapper Class to hold all IA features
********************************************************************************************************/
    Public class featureWrapperClass {
        public IA_Feature__c featureObj {get;set;}
        public String ParentFeature {get;set;}
        public String FilterDisplay {get; set;}
        public List<featurechildWrapperClass> childfeatureLst {get;set;} 
        public Integer displayNum {get; set;}
        featureWrapperClass(IA_Feature__c Obj, List<featurechildWrapperClass> ObjLst, String pf, String fd){
            ParentFeature = pf;
            FilterDisplay = fd;
            childfeatureLst = objLst;
            featureObj = obj;
            displayNum = featureObj.Display_Up_To__c == null ? 1000 : Integer.valueOf(featureObj.Display_Up_To__c);
        }
    }
/********************************************************************************************************
                Wrapper Class to hold child and grandchild IA features
********************************************************************************************************/
    Public class featurechildWrapperClass {
        public IA_Feature__c featureObj {get;set;}
        public Boolean Selected {get;set;}
        public List<featuregrandChildWrapperClass > grandchildfeaturelst {get;set;}
        public Integer displayNum {get; set;}
        featurechildWrapperClass (IA_Feature__c Obj, List<featuregrandChildWrapperClass > g) {
            featureObj = obj;
            Selected = False;
            grandchildfeaturelst =g;
            displayNum = featureObj.Display_Up_To__c == null ? 1000 : Integer.valueOf(featureObj.Display_Up_To__c);
        }
    }
/********************************************************************************************************
                    Wrapper Class to hold grandchild features
********************************************************************************************************/
    Public class featuregrandChildWrapperClass {
        public IA_Feature__c featureObj {get;set;}
        public Boolean Selected {get;set;}
        public Integer displayNum {get; set;}
        featuregrandChildWrapperClass (IA_Feature__c Obj) {
            featureObj = obj;
            Selected = False;
            displayNum = featureObj.Display_Up_To__c == null ? 1000 : Integer.valueOf(featureObj.Display_Up_To__c);
        }
    }
/********************************************************************************************************
                            Converts list to jsonString
********************************************************************************************************/
    public String jsonProductList(List<PriceBookEntry> productslst){
        String jsonResult = JSON.serialize(productslst);
        jsonResult = String.escapeSingleQuotes(jsonResult);
        
        return jsonResult; 
    }
    
     public String jsonProductList(List<Publish_PriceBook_Entry__c> productslst){
        String jsonResult = JSON.serialize(productslst);
        jsonResult = String.escapeSingleQuotes(jsonResult);
        
        return jsonResult; 
    }

    public String searchKeyword {get; set;}
    
    public void searchByKeyword() {
        isEditMode = false;

        String escapedTerm = String.escapeSingleQuotes(searchKeyword);

        if(String.isBlank(escapedTerm) ) initializeProductList(new List<PriceBookEntry>() );

        List<Product2> products = getUniqueProducts();

        Integer recordLimit = Integer.valueOf(Label.Default_Product_Records);

        String whereClause = '';
        for(String term : escapedTerm.split(',')) {
            if(term == '') continue;

            if(whereClause != '') whereClause += ' OR ';

            whereClause += ' Product2.Name like \'%' + term + '%\' OR ProductCode like \'%' + term + '%\' ';
        }

        

        String isoCode = UserInfo.getDefaultCurrency();
        String query = 'SELECT     UnitPrice, ' +
                                                'Product2.Category__c, ' +
                                                'Product2.Name,  ' +
                                                'ProductCode, ' +
                                                'Pricebook2Id, ' +
                                                'Fixed_Price__c,  ' +
                                                'Discount__c, ' +
                                                'RWS_Id__c ' +
                                'FROM PricebookEntry  ' +
                                'WHERE Pricebook2Id = :stdPriceBookId  ' +
                                'and product2.category__c = :TabCategory ' +
                                'AND Product2.IsActive = true ' +
                                'AND Product2Id in :products ' +
                                'AND CurrencyISOCode = :isoCode ' +
                                'AND ( ' + whereClause + ' ) ' +
                                'order by Product2.ProductCode ' +
                                'limit :recordLimit ';
        
        SYstem.debug('query: ' + query);
        List<PriceBookEntry> pbes = Database.query(query);

        for(PricebookEntry pbe : pbes) {
            pbe.Discount__c = 0;
        }
        
        initializeProductList(pbes);
    }

    public void reRenderAction() {}

    private String whereJson; 
    private String whereClauseForDisplay;

/**********************************************************************************************************************
             Method to validate that if a tandem filter is selected, a non-tandem filter must also be selected
             Added by BW : 8/18/17 
***********************************************************************************************************************/

    Public void validateFilters() {
        List<String> filterIds = new List<String>();
        List<IA_Feature__c> tandemFilters = new List<IA_Feature__c>();
        List<IA_Feature__c> nonTandemFilters = new List<IA_Feature__c>();
        List<String> checkedFilters = (List<String>)JSON.deserialize( Apexpages.currentPage().getParameters().get('checkedFiltersJSON'), List<string>.class);
        System.debug('checked filter list: ' + checkedFilters);
        for (String filter : checkedFilters) {
            filterIds.add(filter.substringAfterLast(' '));            
        }
        System.debug('filter Id list: ' + filterIds);
        for (IA_Feature__c filter : [SELECT Feature_Name__c, Tandem__c FROM IA_Feature__c WHERE Id =: filterIds]){
            System.debug('pulled filters: ' + filter + ' | ');

            if (filter.Tandem__c == true){
                tandemFilters.add(filter);              
            } else {
                nonTandemFilters.add(filter);               
            }
        }
        
        System.debug('tandem filter list: ' + tandemFilters);
        System.debug('non-tandem filter list: ' + nonTandemFilters);
        
        if ((tandemFilters.size() > 0) && (nonTandemFilters.size() == 0)){
            chooseMoreFilters = true;
                      
            } else {
                chooseMoreFilters = false;
                
            }
        
        System.debug('boolean value: ' + chooseMoreFilters);        
    }
    
    
     
/********************************************************************************************************
                    Method to get the Products List by selected Feature
********************************************************************************************************/   
    Public void productsListbyFeature() {
        isEditMode = false;
        whereJson = '';
        whereClauseForDisplay = '';

        List<featureWrapperClass> fetrWraplst = new List<featureWrapperClass>();
        if(TabCategory == 'Footwear') {
            fetrWraplst = featureFWWrapperLst;
        }
        else if(TabCategory == 'Accessories Apparel and Gear'){
            fetrWraplst = featureACWrapperLst;
        }
        else if(TabCategory == 'Outside Lines'){
            fetrWraplst = featureOLWrapperLst;
        }
        else {
            fetrWraplst = featureWWWrapperLst;
        }
        
        Set<String> featureId = new Set<String>();

        //Set<String> orFeatures = new Set<String>();
        //Set<String> andFeatures = new Set<String>();

        

        Map<String, String> whereClauseToOperator = new Map<String, String>();

        for(featureWrapperClass f : fetrWraplst) {


            String topLevelOperator = f.featureObj.Filter_Logic__c == null || f.featureObj.Filter_Logic__c == 'OR' ? ' OR ' : ' AND ';

            String levelOneWhereClasue = '';
            String levelOneOrFeatures = '';
            String levelOneOAndFeatures = '';

            String levelOneWhereClasueForDisplay = '';
            String levelOneOrFeaturesForDisplay = '';
            String levelOneOAndFeaturesForDisplay = '';

            for(featurechildWrapperClass c : f.childfeatureLst ) {
                    String levelTwoWhereClasue = '';

                    String levelTwoOrFeatures = '';
                    String levelTwoOAndFeatures = '';

                    String levelTwoWhereClasueForDisplay = '';

                    String levelTwoOrFeaturesForDisplay = '';
                    String levelTwoOAndFeaturesForDisplay = '';

                    String middleLevelOperator = c.featureObj.Filter_Logic__c == null || c.featureObj.Filter_Logic__c == 'OR' ? ' OR ' : ' AND ';

                    for(featuregrandChildWrapperClass g : c.grandchildfeaturelst ) {
                        
    
                        if(g.selected == true) {
                            System.debug('g.featureObj.name: ' + g.featureObj.name);
                            featureId.add(g.featureObj.name);

                            if(g.featureObj.Filter_Logic__c == null || g.featureObj.Filter_Logic__c == 'OR') {
                                if(levelTwoOrFeatures != '') levelTwoOrFeatures += ' OR ';
                                levelTwoOrFeatures += ' Name = \'' + g.featureObj.Name + '\'';

                                if(levelTwoOrFeaturesForDisplay != '') levelTwoOrFeaturesForDisplay += ' OR ';
                                levelTwoOrFeaturesForDisplay += ' ' + g.featureObj.Feature_Name__c + ' ';

                                //orFeatures.add(g.featureObj.Name);
                            }
                            else {
                                if(levelTwoOAndFeatures != '') levelTwoOAndFeatures += ' AND ';
                                levelTwoOAndFeatures += ' Name = \'' + g.featureObj.Name + '\'';


                                if(levelTwoOAndFeaturesForDisplay != '') levelTwoOAndFeaturesForDisplay += ' AND ';
                                levelTwoOAndFeaturesForDisplay += ' ' + g.featureObj.Feature_Name__c + ' ';
                                //andFeatures.add(g.featureObj.Name);
                            }
                        }

                        levelTwoWhereClasue = (levelTwoOrFeatures != '' ? '(' + levelTwoOrFeatures + ') ' : '') +
                                            (levelTwoOrFeatures != '' && levelTwoOAndFeatures != '' ? middleLevelOperator + ' ' : '') +
                                            (levelTwoOAndFeatures != '' ? '(' + levelTwoOAndFeatures + ') ' : '');

                        if(levelTwoOrFeatures != '' && levelTwoOAndFeatures != '') {
                            levelTwoWhereClasue = '(' + levelTwoWhereClasue + ')';
                        }
                        
                        levelTwoWhereClasueForDisplay = (levelTwoOrFeaturesForDisplay != '' ? '(' + levelTwoOrFeaturesForDisplay + ') ' : '') +
                                            (levelTwoOrFeaturesForDisplay != '' && levelTwoOAndFeaturesForDisplay != '' ? middleLevelOperator + ' ' : '') +
                                            (levelTwoOAndFeaturesForDisplay != '' ? '(' + levelTwoOAndFeaturesForDisplay + ') ' : '');
                        
                        if(levelTwoOrFeaturesForDisplay != '' && levelTwoOAndFeaturesForDisplay != '') {
                            levelTwoWhereClasueForDisplay = '(' + levelTwoWhereClasueForDisplay + ')';
                        }
                    }

                    //System.debug('levelTwoWhereClasue: ' + levelTwoWhereClasue);
                    if(levelTwoWhereClasue != '') {
                        
                        whereClauseToOperator.put(levelTwoWhereClasue, topLevelOperator);
                    
                        if(whereClauseForDisplay != '' ) whereClauseForDisplay += topLevelOperator;
                        
                        whereClauseForDisplay += levelTwoWhereClasueForDisplay;

                    } else {

                        if(c.selected == true) {

                            featureId.add(c.featureObj.name);

                            if(c.featureObj.Filter_Logic__c == null || c.featureObj.Filter_Logic__c == 'OR') {
                                if(levelOneOrFeatures != '') levelOneOrFeatures += ' OR ';
                                levelOneOrFeatures += ' Name = \'' + c.featureObj.Name + '\'';

                                if(levelOneOrFeaturesForDisplay != '') levelOneOrFeaturesForDisplay += ' OR ';
                                levelOneOrFeaturesForDisplay += ' ' + c.featureObj.Feature_Name__c + ' ';

                                //orFeatures.add(c.featureObj.Name);
                            }
                            else {
                                if(levelOneOAndFeatures != '') levelOneOAndFeatures += ' AND ';
                                levelOneOAndFeatures += ' Name = \'' + c.featureObj.Name + '\'';

                                if(levelOneOAndFeaturesForDisplay != '') levelOneOAndFeaturesForDisplay += ' AND ';
                                levelOneOAndFeaturesForDisplay += ' ' + c.featureObj.Feature_Name__c + ' ';

                                //andFeatures.add(c.featureObj.Name);
                            }

                            levelOneWhereClasue = (levelOneOrFeatures != '' ? '(' + levelOneOrFeatures + ') ' : '') +
                                                (levelOneOrFeatures != '' && levelOneOAndFeatures != '' ? topLevelOperator + ' ' : '') +
                                                (levelOneOAndFeatures != '' ? '(' + levelOneOAndFeatures + ') ' : '');
                            
                            if(levelOneOrFeatures != '' && levelOneOAndFeatures != '') {
                                levelOneWhereClasue = '(' + levelOneWhereClasue + ')';
                            }

                            levelOneWhereClasueForDisplay = (levelOneOrFeaturesForDisplay != '' ? '(' + levelOneOrFeaturesForDisplay + ') ' : '') +
                                            (levelOneOrFeaturesForDisplay != '' && levelOneOAndFeaturesForDisplay != '' ? topLevelOperator + ' ' : '') + 
                                                (levelOneOAndFeaturesForDisplay != '' ? '(' + levelOneOAndFeaturesForDisplay + ') ' : '');
                        
                            if(levelOneOrFeaturesForDisplay != '' && levelOneOAndFeaturesForDisplay != '') {
                                levelOneWhereClasueForDisplay = '(' + levelOneWhereClasueForDisplay + ')';
                            }

                        }
                    }
            }
                
            if(levelOneWhereClasue != '') {
                whereClauseToOperator.put(levelOneWhereClasue, topLevelOperator);
                
                if(whereClauseForDisplay != '' ) whereClauseForDisplay += topLevelOperator;
                
                whereClauseForDisplay += levelOneWhereClasueForDisplay;
            }

            

        }

        //System.debug(orFeatures);
        //System.debug(andFeatures);

        System.debug('featureId: ' + featureId);
        System.debug('tabCategory: ' + tabCategory); 
        if(featureId.isEmpty()) { 
            productsListByTabCategory();
        } else {

            System.debug('whereClauseForDisplay: ' + whereClauseForDisplay);
            System.debug('whereClauseToOperator: ' + whereClauseToOperator);

            whereJson = JSON.serialize(whereClauseToOperator);

            //System.debug('whereJson: ' + whereJson);

            List<Set<Id>> andStyles = new List<Set<Id>>();

            List<Set<Id>> orStyles = new List<Set<Id>>();

            for(String filter : whereClauseToOperator.keySet()) {

                List<Features__c> features;
                
                Boolean filterChanged = false;
                if(filter.indexOf('AND') >= 0) {
                    String changedFilter = filter.replaceAll('AND', 'OR');
                    System.debug('changedFilter: ' + changedFilter);
                    features = Database.query('select Id from Features__c where ' + changedFilter);
                    filterChanged = true;
                } else {
                    features = Database.query('select Id from Features__c where ' + filter);
                }   

                String operator = whereClauseToOperator.get(filter);
                
                Set<Id> productStyles = new Set<Id>();
                if(filterChanged) {
                    Integer filterCount = filter.split('AND').size();
                    
                    for(AggregateResult p : [select Product_Style__c, count(Id)

                                                from Product_Style_Features__c 
                                                where Feature__c in :features
                                                and Product_Style__c != null
                                                and Product_Style__r.Category__c = :TabCategory
                                                group by Product_Style__c
                                                having count(Id) = :filterCount ]) {

                        productStyles.add((ID) p.get('Product_Style__c'));
                    }                    
                } else {
                    for(Product_Style_Features__c p : [select Product_Style__c
                                                    from Product_Style_Features__c 
                                                    where Feature__c in :features
                                                    and Product_Style__c != null
                                                    and Product_Style__r.Category__c = :TabCategory]) {
    
                        productStyles.add(p.Product_Style__c);
                    }
                }

                if(operator == ' AND ') {
                    andStyles.add(productStyles);
                } else {
                    orStyles.add(productStyles);
                }
            }

            Set<Id> allStyles = new Set<Id>();

            if(andStyles.size() == 1 ) {

                allStyles.addAll(andStyles[0]);
            } else if(andStyles.size() > 1) {

                /*
                Set<Id> baseStyles;
                Integer index = 0;
                for(Integer i = 1 ; i < andStyles.size(); i ++) {
                    if(baseStyles == null) baseStyles = andStyles[i];
                    
                    if(baseStyles == null || (baseStyles != null && andStyles[i].size() < baseStyles.size()) ) {
                        baseStyles = andStyles[i];
                        index = i;
                    }
                }
                */
                
                Map<Id, Integer> styleToCountMap = new Map<Id, Integer>();
                

                for(Integer i = 0 ; i < andStyles.size(); i ++) {
                    
                    for(Id styleId : andStyles[i]) {
                        Integer count = styleToCountMap.get(styleId);
                        
                        if(count == null) 
                            count = 1;
                        else 
                            count ++;
                        
                        styleToCountMap.put(styleId, count);
                    }
                }
                
                Integer totalAndStyles = andStyles.size();
                
                for(Id styleId : styleToCountMap.keySet()) {
                    Integer count = styleToCountMap.get(styleId);
                    
                    if(count == totalAndStyles) {
                        allStyles.add(styleId);
                    }
                }
            }

            for(Integer i = 0 ; i < orStyles.size(); i ++) {
                allStyles.addAll(orStyles[i]);
            }

            System.debug('allStyles: ' + allStyles.size());

            if(!allStyles.isEmpty()) {
                productsList(allStyles);
            }
            else {
                recordsCount = 0;
                System.debug('1. recordsCount: ' + recordsCount);
                if(TabCategory == 'Footwear') {
                    FWjsonResult = '[]';
                }
                else if(TabCategory == 'Accessories Apparel and Gear'){
                    ACjsonResult = '[]';
                }
                else if(TabCategory == 'Outside Lines'){
                    OLjsonResult = '[]';
                }
                else {
                    WWjsonResult = '[]';
                }
            }
        } 
    }

    private List<Product2> getUniqueProducts() {
        List<Product_Style__c> styles = [select Id 
                                            from Product_Style__c
                                        where Category__c = :TabCategory];

        List<Product2> products = [select Id from Product2 
                                        where Product_Style__c in :styles];

        return products;
    }

    /********************************************************************************************************
        Method to get the Product List by sending Product Id's
    ********************************************************************************************************/
    Public void productsList(Set<Id> productStyleIds) {

        List<Product2> products = [select Id from Product2 
                                        where Product_Style__c in :productStyleIds 
                                        and IsActive = true
                                        and Category__c = :TabCategory];

        List<PriceBookEntry> productlst = [SELECT UnitPrice, product2.category__c,
                                                Product2.name,
                                                ProductCode, Pricebook2Id, 
                                                Fixed_Price__c,
                                                Discount__c,
                                                RWS_Id__c
                                            FROM PricebookEntry 
                                            WHERE Pricebook2Id = :stdPriceBookId 
                                            AND IsActive = true 
                                            AND product2Id in :products
                                            AND CurrencyISOCode = :UserInfo.getDefaultCurrency()
                                            order by Product2.ProductCode]; 
                                
        for(PricebookEntry pbe : productlst) {
            pbe.Discount__c = 0;
        }

        recordsCount = productlst.size();
        System.debug('2. recordsCount: ' + recordsCount);

        initializeProductList(productlst);
    }

    /********************************************************************************************************
        Method to get the Feature Wrapper List by Category
    ********************************************************************************************************/
    Public void FeaturesListbyCategory() {
        Boolean initialized = false;
        if(TabCategory  == 'Footwear') {
            if(featureFWWRapperLst == null) {
                featureFWWRapperLst = new List<featureWrapperClass>();
                featureFWWrapperLst = getTabFeatures();               
                initialized = true;  
            }
        }
        else if (TabCategory  == 'Accessories Apparel and Gear') {
            if(featureACWrapperLst == null) {
                featureACWrapperLst = new List<featureWrapperClass>();
                featureACWrapperLst = getTabFeatures();                 
                initialized = true;  
            }
        }
        else if (TabCategory  == 'Outside Lines') {
            if(featureOLWrapperLst == null) {
                featureOLWrapperLst = new List<featureWrapperClass>();
                featureOLWrapperLst = getTabFeatures();                
                initialized = true;  
            }
        }
        else {
            if(featureWWWrapperLst == null) {
                featureWWWrapperLst = new List<featureWrapperClass>(); 
                featureWWWrapperLst = getTabFeatures();                
                initialized = true;  
            }
        }

        // To get products
        if(initialized)
            productsListByTabCategory();
    }

    private List<featureWrapperClass> getTabFeatures() {
        Map<Id,IA_Feature__c> featureMap = new Map<Id,IA_Feature__c>([select Display_Up_To__c, Id, Name, Feature_Name__c, Filter_Logic__c, Filter_Display__c,
                                                                      (select Display_Up_To__c, Id, Name, Feature_Name__c, Filter_Logic__c from IA_Feature__r 
                                                                        where category__c = :TabCategory order by display_Order__c)
                                                                      from IA_Feature__c where selectable__c = false and category__c = :TabCategory 
                                                                      order by display_Order__c  ]);

        Map<Id,IA_Feature__c> featurechildMap = new Map<Id,IA_Feature__c> ([select Display_Up_To__c, id,name, Feature_Name__c, Filter_Logic__c,  
                                                                            (select Display_Up_To__c, id,name, Feature_Name__c, Filter_Logic__c from IA_Feature__r 
                                                                                where category__c = :TabCategory 
                                                                            order by display_Order__c nulls last) 
                                                                            from IA_Feature__c 
                                                                            where Parent_IA_Feature__c in :featureMap.keyset()
                                                                            and category__c = :TabCategory order by display_Order__c]);
        List<featureWrapperClass> featureWrapperLst = new List<featureWrapperClass>();
        for(IA_Feature__c ftr : featureMap.values()) {
            List<featurechildWrapperClass> featureChildWrapLst = new List<featurechildWrapperClass>();
            
            for(IA_Feature__c ftrchild : featureMap.get(ftr.id).IA_Feature__r) {
                List<featuregrandChildWrapperClass> featuregrandChildWrapLst = new List<featuregrandChildWrapperClass>();
                for(IA_Feature__c ftrgrandchild : featurechildMap.get(ftrchild.id).IA_Feature__r) {
                    featuregrandChildWrapLst.add(new featuregrandChildWrapperClass(ftrgrandchild));
                }
                featureChildWrapLst.add(new featurechildWrapperClass(ftrchild,featuregrandChildWrapLst));             
            }
            featureWrapperLst.add(new featureWrapperClass(ftr, featureChildWrapLst, ftr.Feature_Name__c, ftr.Filter_Display__c));
        }

        return featureWrapperLst;
    }
    /********************************************************************************************************
Method to get the Product List by Category
********************************************************************************************************/
    
    Public void productsListByTabCategory() {

        initializeProductList(new List<PriceBookEntry>());
        
    }
    public String selectedFilter {get; set;}
    public String selectedFilterDiscount {get; set;}
    public String featuresToSelect {get; set;}

    private boolean isEditMode = false;
    

    public void initializeSelectionView() {
        isEditMode = true;
        selectedFilterDiscount = '';
        featuresToSelect = '';
        
        if(String.isBlank(selectedFilter)) return;

        Integer filterNumber = getFilterNumber();

        List<Filter_Criteria__c> fcs = [SELECT OwnerId, CurrencyIsoCode, Discount__c, 
                    Filter_BE_Details__c, Filter_Display__c, 
                    Filter_Number__c, IA_Feature__c, 
                    Program__c, Results_Count__c,
                    Product_Code__c
                from Filter_Criteria__c
                where Program__c = :createdProgram.Id
                and IA_Feature__c = null
                and Filter_Number__c = :filterNumber];

        Filter_Criteria__c criteria;
        
        List<PriceBookEntry> productlst;
        if(!fcs.isEmpty()) {
            criteria = fcs[0];
        }

        if(criteria != null && !String.isBlank(criteria.Product_Code__c)) {

            if(criteria.Discount__c == null) criteria.Discount__c = 0;

            String codesSet = criteria.Product_Code__c.split('-FPC-')[0];
            String fpcSet = criteria.Product_Code__c.split('-FPC-')[1];

            Set<String> fpCodes =  (Set<String>) JSON.deserialize(fpcSet, Set<String>.class);

            Map<String, Decimal> productCodes = new Map<String, Decimal>();

            Boolean hasTabCategory = false;
            if(criteria.Filter_Number__c > 0 ) {
                Set<String> codes = (Set<String>) JSON.deserialize(codesSet, Set<String>.class);
                

                for(String code : codes) {
                    productCodes.put(code, criteria.Discount__c);
                }

                Set<Id> iaFeatureId;

                try {
                    iaFeatureId = (Set<Id>) JSON.deserialize(criteria.Filter_BE_Details__c.split('SEPARATOR')[1], Set<Id>.class);
                } catch(Exception ex) {}
        


                if(iaFeatureId != null && !iaFeatureId.isEmpty()) {
                    TabCategory = [SELECT Category__c FROM IA_Feature__c where Id in :iaFeatureId limit 1].Category__c;
                    hasTabCategory = true;
                }   

            } else {
                productCodes = (Map<String, Decimal>) JSON.deserialize(codesSet, Map<String, Decimal>.class);
            }

            productlst = new List<PricebookEntry>();
            List<PricebookEntry> spbes = [SELECT Id, Product2Id, 
                                            Discount__c, 
                                            ProductCode,
                                            UnitPrice, 
                                            RWS_Id__c,
                                            Product2.Category__c, 
                                            Product2.Product_Style__c,
                                            Product2.Name,
                                            Fixed_Price__c,
                                            Filter_Number__c
                                            FROM PricebookEntry 
                                            WHERE Pricebook2Id = :stdPriceBookId 
                                            AND IsActive = true 
                                            AND ProductCode in :productCodes.keySet()
                                            AND Product2.Product_Style__c != null
                                            AND Product2.IsActive = true
                                            AND CurrencyISOCode = :UserInfo.getDefaultCurrency()
                                            order by Product2.ProductCode];


            Map<Id, PriceBookEntry> pricebookentry_Map = new Map<Id,PriceBookEntry>();
            Set<Id> productIds = new Set<Id>();
            Set<String> productCodesProcessed = new Set<String>();

            for(PricebookEntry spbe : spbes) {
                if(fpCodes.contains(spbe.ProductCode)) spbe.Fixed_Price__c = true;
                Decimal discount = productCodes.get(spbe.ProductCode);

                if(productCodesProcessed.contains(spbe.ProductCode)) {
                    continue;
                } else {
                    productCodesProcessed.add(spbe.ProductCode);
                }

                if(discount == null) discount = 0;

                spbe.Discount__c = discount;

                spbe.Filter_Number__c = criteria.Filter_Number__c;

                if(hasTabCategory && spbe.Product2.Category__c != TabCategory) continue;

                productlst.add(spbe);
            }

            recordsCount = productlst.size();
            System.debug('2-A. recordsCount: ' + recordsCount);

        } else {
            
           /* Set<Id> productStyleIds = new Set<Id>();
            List<PricebookEntry> pbes = [select Id, Product2Id, 
                                            Discount__c, 
                                            ProductCode,
                                            UnitPrice, 
                                            RWS_Id__c,
                                            Product2.Category__c, 
                                            Product2.Product_Style__c,
                                            Product2.Name,
                                            Fixed_Price__c,
                                            Filter_Number__c
                                        FROM PricebookEntry 
                                        where Pricebook2.Program__c = :createdProgram.Id
                                        AND Filter_Number__c = :filterNumber
                                        AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()
                                        order by Product2.ProductCode];*/
        
            Set<Id> productStyleIds = new Set<Id>();
            List<Publish_PriceBook_Entry__c> ppbes = [select Id, Product_ID__c, 
                                            Discount__c, 
                                            Style_Number__c,
                                            List_Price__c, 
                                            //RWS_Id__c,
                                            //Product2.Category__c, 
                                            //Product2.Product_Style__c,
                                            //Product2.Name,
                                            Fixed_Price__c,
                                            Filter_Number__c
                                        FROM Publish_PriceBook_Entry__c 
                                        where Publish_PriceBook__r.Program__c = :createdProgram.Id
                                        AND Filter_Number__c = :filterNumber
                                        AND CurrencyIsoCode = :UserInfo.getDefaultCurrency()
                                        order by Style_Number__c];
            
            Set<Id> productIds = new Set<Id>();
            Map<Id, Product2> prodMap = new Map<Id, Product2>();
            
            for(Publish_PriceBook_Entry__c ppbe : ppbes) {
                productIds.add(ppbe.Product_Id__c);
            }
            
            Set<Id> prodIdSet = new Set<Id>();
            for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode, Product_Style__c FROM Product2 WHERE Id IN : productIds ORDER BY ProductCode]){
                prodIdSet.add(prod.Id);
                prodMap.put(prod.Id, prod);
            }           
           
            
            for(Integer i = 0; i < ppbes.size(); i++){
                if (!prodIdSet.contains(ppbes[i].Product_Id__c)){
                    ppbes.remove(i);    
                }              
            }
            


            Map<Id, Publish_PriceBook_Entry__c> priceList = new Map<Id, Publish_PriceBook_Entry__c>();
            Map <Id, Id> PpbeToProdIdMap = new Map<Id, Id>();

            for(Publish_PriceBook_Entry__c ppbe : ppbes) {
                PpbeToProdIdMap.put(ppbe.Id, ppbe.Product_Id__c);
                priceList.put(ppbe.Product_ID__c, ppbe);
            }

            recordsCount = ppbes.size();
            System.debug('3. recordsCount: ' + recordsCount);

            if(ppbes.isEmpty()) {
                initializeProductList(ppbes);
                return;
            }
            
            Id prodId = PpbeToProdIdMap.get(ppbes[0].Id);
            Product2 prod = prodMap.get(prodId);

            TabCategory =  prod.Category__c;

            productIds.clear();

            for(Publish_PriceBook_Entry__c ppbe : ppbes) {
                productIds.add(ppbe.Product_Id__c);
            }

            productlst = [SELECT Id, Product2Id, 
                            Discount__c, 
                            ProductCode,
                            UnitPrice, 
                            RWS_Id__c,
                            Product2.Category__c, 
                            Product2.Product_Style__c,
                            Product2.Name,
                            Fixed_Price__c,
                            Filter_Number__c
                        FROM PricebookEntry 
                        WHERE Pricebook2Id = :stdPriceBookId 
                        AND IsActive = true 
                        AND Product2Id in :productIds
                        AND Product2.Product_Style__c != null
                        AND CurrencyISOCode = :UserInfo.getDefaultCurrency()
                        AND Product2.Category__c = :TabCategory
                        order by Product2.ProductCode]; 

            recordsCount = productlst.size();
            System.debug('4. recordsCount: ' + recordsCount);
                                    
            for(PricebookEntry pbe : productlst) {

                Publish_PriceBook_Entry__c price = priceList.get(pbe.Product2Id);

                if(price == null) continue;

                pbe.Discount__c = price.Discount__c != null ? price.Discount__c : 0;
                pbe.Fixed_Price__c = price.Fixed_Price__c;
                pbe.Filter_Number__c = price.Filter_Number__c;

            }

            

        }

        initializeProductList(productlst); 

        //delete pbes;

        if(selectedFilter == '0') return;

        selectedFilterDiscount = criteria.Discount__c == null ? '0' : String.valueOf(criteria.Discount__c);
       
        Set<Id> IafeatureId = (Set<Id>) JSON.deserialize(criteria.Filter_BE_Details__c.split('SEPARATOR')[1], Set<Id>.class);

        whereClauseForDisplay = criteria.Filter_Display__c;
        whereJson = criteria.Filter_BE_Details__c;

        for(Id fId : IafeatureId) {
            if(featuresToSelect != '') featuresToSelect += ',';

            featuresToSelect += String.valueOf(fId).left(15);
        }

        

        /*
        for(Filter_Criteria__c fc : criterias) {
            IafeatureId.add(fc.IA_Feature__c);
        }
        */

        if(TabCategory == 'Footwear') {
            //featureFWWRapperLst =  getTabFeatures();  //Temp

            //initFilters(featureFWWrapperLst, iafeatureId);
            FWCheckbox = 'true';
        }
        else if (TabCategory == 'Accessories Apparel and Gear') {
            //initFilters(featureACWrapperLst, iafeatureId);
            AcCheckbox = 'true';
        }
        else if (TabCategory == 'Outside Lines') {
            //initFilters(featureOLWrapperLst, iafeatureId);
            OLCheckbox = 'true';
        }
        else {
            //initFilters(featureWWWrapperLst, iafeatureId);
            WWCheckbox = 'true';
        }


    }

    private void initializeProductList(List<PriceBookEntry> pbes) {
        //priceBookEntrylst = new List<PricebookEntry>(pbes); 
        
        String jsonValue = jsonProductList(pbes);
        if(TabCategory == 'Footwear') {
            FWjsonResult = '';
            FWjsonResult = jsonValue;
        }
        else if (TabCategory  == 'Accessories Apparel and Gear') {
            ACjsonResult = '';
            ACjsonResult = jsonValue;
        }
        else if (TabCategory  == 'Outside Lines') {
            OLjsonResult = '';
            OLjsonResult = jsonValue;
        }
        else {
            WWjsonResult = '';
            WWjsonResult = jsonValue;
        }

        System.debug('jsonValue: ' + jsonValue);
    }
    
     private void initializeProductList(List<Publish_PriceBook_Entry__c> ppbes) {
        //priceBookEntrylst = new List<PricebookEntry>(pbes); 
        
        String jsonValue = jsonProductList(ppbes);
        if(TabCategory == 'Footwear') {
            FWjsonResult = '';
            FWjsonResult = jsonValue;
        }
        else if (TabCategory  == 'Accessories Apparel and Gear') {
            ACjsonResult = '';
            ACjsonResult = jsonValue;
        }
        else if (TabCategory  == 'Outside Lines') {
            OLjsonResult = '';
            OLjsonResult = jsonValue;
        }
        else {
            WWjsonResult = '';
            WWjsonResult = jsonValue;
        }

        System.debug('jsonValue: ' + jsonValue);
    }

    /********************************************************************************************************
        Wrapper Class to hold Products List
    *********************************************************************************************************/
    Public class ProductWrapperClass {
        Public string discount {get;set;}
        Public string programprice {get;set;}
        Public string productcode {get;set;}
        Public String Name {get;set;}
        Public String MSRP {get;set;}
        Public string Prodid {get;set;}
        public Boolean fixedPrice {get; set;}
        public ProductWrapperClass (string productcode1,
                                    string name1,
                                    string msrp1, 
                                    string discount1, 
                                    string programprice1, 
                                    string productid1,
                                    Boolean fPrice)
        {
            productcode = productcode1;
            discount = discount1;
            programprice = programprice1;
            name = name1;
            msrp = msrp1;
            Prodid = productid1;
            fixedPrice = fPrice;

        }
    }
    
    public Decimal overallDiscount {get; set;}

    private void setSelectAll() {

        System.debug('selectAllValue: ' + selectAllValue);
        if(TabCategory == 'Footwear') {
            FWCheckbox = selectAllValue;
        }
        else if (TabCategory == 'Accessories Apparel and Gear') {
            AcCheckbox = selectAllValue;
        }
        else if (TabCategory == 'Outside Lines') {
            OLCheckbox = selectAllValue;
        }
        else {
            WWCheckbox = selectAllValue;
        }
    }
    
    private boolean isDiscountSame = true;
    Public void addProgram() {
        isDiscountSame = true;
        
        if(createdprogram == null) {
            createdprogram = [select id, Name, Auto_Update_Price__c, Auto_Add_Products__c 
                                FROM Program__c 
                                where createdbyid = :userinfo.getuserid() and Template__c = :isTemplate 
                                order by CreatedDate desc limit 1];
        }
        System.debug('Got into the add program function. ');
        if(createdProgram != null) {
            if(updateProgram == null) updateProgram = false;
            if(overallDiscount == null) overallDiscount = 0;
            System.debug('overallDiscount: ' + overallDiscount);

            if(updateProgram) {
                update createdprogram;
            }

            if(createdPricebook == null) {
                createdPriceBook = new Publish_PriceBook__c();
                createdPriceBook.Name = createdprogram.Name + ' Pricebook';
                createdPriceBook.Program__c = createdProgram.id;
                createdPriceBook.isactive__c = true;
                insert createdPriceBook ;
            }

            List<ProductWrapperClass> prodWrapper = new List<ProductWrapperClass>();
            prodWrapper = (List<ProductWrapperClass>) system.JSON.deserialize(prdresult, List<ProductWrapperClass>.class);


            Integer fNumber;
            if(isEditMode) {
                fNumber = getFilterNumber();
            }

            System.debug(prodWrapper.size() + ' - ' + recordsCount + ' - ' + fNumber + ' - ' + isEditMode);
            
            if(!prodWrapper.isEmpty()) {

                for(ProductWrapperClass pwc : prodWrapper) {
                    if(overallDiscount != Decimal.valueOf(pwc.discount)) {
                        overallDiscount = 0;
                        isDiscountSame = false;
                        break;
                    }
                }

                if(prodWrapper.size() != recordsCount) {
                    selectAllValue = 'false';                    

                    if(isEditMode) {
                        deleteFilterCriteria(fNumber);
                    }
                }

                setSelectAll();

                Decimal filterCounter = selectedFilterCriteria(prodWrapper);

                createPriceBookEntries(prodWrapper, createdPriceBook.id, filterCounter);
            } else {
                if(isEditMode) {

                    deleteFilterCriteria(fNumber);

                    removePricebookEntries(createdPriceBook.id, fNumber, new Set<Id>());
                }
            }

            if(isEditMode) {
                isEditMode = false;
            }
            
        }
    } 

    private void deleteFilterCriteria(Integer fNumber) {
            delete [select Id from Filter_Criteria__c 
                        where Filter_Number__c = :fNumber
                        and Program__c = :createdProgram.Id];
    }

    private Integer getFilterNumber() {
        return Integer.valueOf(selectedFilter);
    }

    Public Decimal selectedFilterCriteria(List<ProductWrapperClass> prodWrapper) {
        Set<Id> IafeatureId = new Set<Id>();
        List<featureWrapperClass> selectedWrapperClass = new List<featureWrapperClass>();

        if(TabCategory == 'Footwear') {
            selectedWrapperClass = featureFWWrapperLst;
        }
        else if (TabCategory == 'Accessories Apparel and Gear') {
            selectedWrapperClass = featureACWrapperLst;
        }
        else if (TabCategory == 'Outside Lines') {
            selectedWrapperClass = featureOLWrapperLst;
        }
        else {
            selectedWrapperClass = featureWWWrapperLst;
        }
        
        for(featureWrapperClass f :selectedWrapperClass) {
            for(featurechildWrapperClass c : f.childfeatureLst ) {
                if(c.selected == true) {
                    IafeatureId.add(c.featureObj.Id);
                }
                for(featuregrandChildWrapperClass g : c.grandchildfeaturelst ) {
                    if(g.selected == true) {
                        IafeatureId.add(g.featureObj.Id);
                    }
                }
            }
        }

        String selectAllCheckbox = 'false';
        if(TabCategory == 'Footwear') {
            selectAllCheckbox = FWCheckbox ;
        }
        else if (TabCategory == 'Accessories Apparel and Gear') {
            selectAllCheckbox = ACCheckbox ;
        }
        else if (TabCategory == 'Outside Lines') {
            selectAllCheckbox = OLCheckbox ;
        }
        else {
            selectAllCheckbox = WWCheckbox ;
        }

        if(selectAllCheckbox == 'true' &&  !IafeatureId.isEmpty() && isDiscountSame ) {
            return createfiltercriteira(prodWrapper, iafeatureId, createdProgram.Id, overallDiscount);
        } else {
            return createCustomListFilterCriteria(prodWrapper, createdProgram.Id);
        }
    }  

    public Decimal createCustomListFilterCriteria(List<ProductWrapperClass> prodWrapper, Id programId1) {
        //updateProgram(programId1);

        Map<String, Decimal> productCodes = new Map<String, Decimal>();
        Set<String> fixedProductCodes = new Set<String>();

        List<Filter_Criteria__c> fcs = [select Id, Discount__c, Product_Code__c from filter_criteria__c 
                                                            Where Program__c = :programId1 
                                                            AND Filter_Number__c = 0 limit 1];


        Filter_Criteria__c fc;
        if(!fcs.isEmpty()) {
            fc = fcs[0];

            if(!String.isBlank(fc.Product_Code__c)) {
                productCodes = (Map<String, Decimal>) JSON.deserialize(fc.Product_Code__c.split('-FPC-')[0], Map<String, Decimal>.class);
                fixedProductCodes = (Set<String>) JSON.deserialize(fc.Product_Code__c.split('-FPC-')[1], Set<String>.class);
            }

        }

        

        for(ProductWrapperClass p : prodWrapper) {

            if(String.isBlank(p.Prodid)) continue;

            productCodes.put(p.Productcode, Decimal.valueOf(p.discount));

            if(p.fixedPrice) fixedProductCodes.add(p.ProductCode);
        }

        if(fc == null) {
            fc = new Filter_Criteria__c();
        }

        fc.Program__c = programId1;
        fc.Filter_Number__c = 0;
        fc.Filter_Display__c = 'CUSTOM LIST';
        fc.Product_Code__c = JSON.serialize(productCodes) + '-FPC-' + JSON.serialize(fixedProductCodes);
        fc.Results_Count__c = prodWrapper.size();
        fc.Discount__c = 0;

        upsert fc;

        return 0;

        
    }
    
    //@future 
    public Decimal createfiltercriteira(List<ProductWrapperClass> prodWrapper, Set<Id> IafeatureId, Id programId1, Decimal od) {
        //updateProgram(programId1);
        
        Set<String> productCodes = new Set<String>();
        Set<String> fixedProductCodes = new Set<String>();

        for(ProductWrapperClass p : prodWrapper) {

            if(String.isBlank(p.Prodid)) continue;

            productCodes.add(p.ProductCode);

            if(p.fixedPrice) fixedProductCodes.add(p.ProductCode);
        }

        Decimal filtercounter = 0;
        Boolean insertFilter = true;
        List<Filter_Criteria__c> filtercriteria_lst = [select IA_feature__c,filter_number__c, Filter_Display__c from filter_criteria__c 
                                                            Where program__r.id = :programId1
                                                            order by filter_number__c 
                                                            ];

        AggregateResult[] maxValue =[select max(filter_number__c) 
                                        from filter_criteria__c where program__r.id = :programId1 
                                        and filter_number__c !=null];

        
        for(AggregateResult ar : maxValue) {
            filterCounter = (Decimal) ar.get('expr0');
        }
        
        if(filtercounter == null) {
            filtercounter = 1;
        }
        else {
            filtercounter = filtercounter +1;
        }

        Map<Decimal, String> filtercriteriaMap = new Map<Decimal, String>();

        for(Filter_Criteria__c fcl : filtercriteria_lst) {
            if(fcl.Filter_Display__c  == null) continue;

            filtercriteriaMap.put(fcl.filter_number__c, fcl.Filter_Display__c);
        }

        Decimal existingFilterNumber = 0;
        for(Decimal fn : filtercriteriaMap.keySet()) {
            String filterfeatureId = filterCriteriaMap.get(fn);

            whereClauseForDisplay = whereClauseForDisplay.trim();
            filterfeatureId = filterfeatureId.trim();

            if(filterfeatureId.equals(whereClauseForDisplay)){
                insertFilter = false;
                existingFilterNumber = fn;
                break;
            }
        }

        if(insertFilter) {

            List<Filter_Criteria__c> fc_lst = new List<Filter_Criteria__c>();

            if(!(String.isBlank(whereJson) || String.isBlank(whereClauseForDisplay)) ) {
                Filter_Criteria__c fc = new Filter_Criteria__c();
                fc.Program__c = programId1;
                fc.Filter_Number__c = filterCounter;
                fc.Discount__c = od;
                fc.Filter_Display__c = whereClauseForDisplay;
                fc.Filter_BE_Details__c = whereJson + 'SEPARATOR' + JSON.serialize(iaFeatureId);
                fc.Product_Code__c = JSON.serialize(productCodes) + '-FPC-' + JSON.serialize(fixedProductCodes);
                fc.Results_Count__c = prodWrapper.size();
                fc_lst.add(fc); 
            }
                
            
            if(!fc_lst.isEmpty()) {
                insert fc_lst;
            }

            return filterCounter;
        } else {


            if(!String.isBlank(selectedFilter)) {
                Integer fNumber = getFilterNumber();
                if(existingFilterNumber != fNumber) {
                    delete [select Id from Filter_Criteria__c 
                                where Filter_Number__c = :fNumber
                                and Program__c = :createdProgram.Id];
                }
            }

            filtercriteria_lst = [select Id, Discount__c, Product_Code__c from filter_criteria__c 
                                                            Where program__r.id = :programId1 
                                                            AND Filter_Number__c = :existingFilterNumber];

            Boolean isChanged = false;
            for(Filter_Criteria__c fc : filtercriteria_lst) {
                isChanged = true;

                if(fc.Discount__c != null && od != null /*&& od > fc.Discount__c*/) {
                    fc.Discount__c = od;
                    
                }

                if(!String.isBlank(fc.Product_Code__c)) {
                    productCodes.addAll((Set<String>) JSON.deserialize(fc.Product_Code__c.split('-FPC-')[0], Set<String>.class));
                    fixedProductCodes.addAll((Set<String>) JSON.deserialize(fc.Product_Code__c.split('-FPC-')[1], Set<String>.class));
                }

                fc.Product_Code__c = JSON.serialize(productCodes) + '-FPC-' + JSON.serialize(fixedProductCodes);
                fc.Results_Count__c = prodWrapper.size();
            } 

            if(isChanged) update filtercriteria_lst;
            
            return existingFilterNumber;
        }


    }

    private void updateProgram(Id prId) {
        Program__c pr = [select Id, Processing_Status__c from Program__c where Id = :prId limit 1];

        if(pr.Processing_Status__c == 'Scheduled') return;

        Program__c existingProgram = new Program__c(Id = prId,
            Processing_Status__c = 'Scheduled'
        ); 

        update existingProgram;
    }
    
    
    public void createPriceBookEntries(List<ProductWrapperClass> PBE_lst, Id pricebookId, Decimal filterNumber) {
        Set<Id> productIds = new Set<Id>();

        //List<PriceBookEntry> pricebookentry_lst = new List<PriceBookEntry>();
        for(ProductWrapperClass p : PBE_lst) {

            if(String.isBlank(p.ProdId)) continue;
        
            productIds.add((Id) p.ProdId);
        }

        if(!productIds.isEmpty()) {

            if(!String.isBlank(selectedFilter)) {
                
                Integer fNumber = getFilterNumber();

                if(!productIds.isEmpty()) removePricebookEntries(pricebookId, fNumber, productIds);

                if(filterNumber != fNumber) {
                    delete [select Id from Filter_Criteria__c 
                                where Filter_Number__c = :fNumber
                                and Program__c = :createdProgram.Id];
                }

                selectedFilter = '';
            }
        }
        
    }

    @testVisible
    private void removePricebookEntries(Id pricebookId, Integer fNumber, Set<Id> productIds) {

        List<Publish_PriceBook_Entry__c> priceBookEntries = 
                [select Id, Product_Id__c, List_Price__c, Fixed_Price__c, 
                        Discount__c, Active__c
                from Publish_PriceBook_Entry__c	 
                where Publish_PriceBook__c = :pricebookId 
                AND Filter_Number__c = :fNumber
                //AND Product2.IsActive = true
                //AND Product2Id not in :productIds
                AND CurrencyISOCode = :UserInfo.getDefaultCurrency()];
        
        Set<Id> prodIds = new Set<Id>();       
        for(Publish_PriceBook_Entry__c ppbe : priceBookEntries) {
        	prodIds.add(ppbe.Product_Id__c);
        }
        
        Set<Id> prodIdSet = new Set<Id>();
        for (Product2 prod : [SELECT Id, Name, Category__c, ProductCode FROM Product2 WHERE IsActive = true AND Id NOT IN : productIds AND Id IN : prodIds]){
            prodIdSet.add(prod.Id);            
        }
        
        for(Integer i = 0; i < priceBookEntries.size(); i++){
            if (!prodIdSet.contains(priceBookEntries[i].Product_Id__c)){
            	priceBookEntries.remove(i);
                i--;
            }
        }

        //RWS_PriceBookEntry_Util.deleteRecords(priceBookEntries);

        RWS_PriceBookEntry_Util.deactivatePublicPriceBookEntries(priceBookEntries);
    }
    
    public String selectAllValue {get; set;}
    
    private void StandardPriceBookId () {
        if(Test.isRunningTest()) {
            stdPriceBookId = Test.getStandardPricebookId();
        }
        else if (stdPriceBookId == null) 
            stdPriceBookId    = [select id, name from Pricebook2 where isStandard = true limit 1].id;
            
    }
}