Public  with sharing class RWS_ProgramHomeController{

    public Program__c ProObj {get;set;}
    public List<Program__c> ProgramList {get;set;}
    public String jsonResult     {set;get;}
    public List<ProgramWrap> ProListWrap {get;set;}
    public Boolean isFullAccessUser {get; set;}
    
    
    /*public List<SelectOption> programViews
    {
        get
        {
            if(programViews == null )
            {
                programViews = new List<SelectOption>();
                programViews.add(new SelectOption('1', 'Program Templates'));
                programViews.add(new SelectOption('0', 'Account Templates'));
            }
            return programViews ;
        }
        set; 
    }
    public String selectedProgramViews {get; set; }*/

    public Set<Id> industrialAccountSet ;

    //Controller
    public RWS_ProgramHomeController(){
        isFullAccessUser = RWS_UtilityClass.isFullAccessUser();
        ProObj = new Program__c();
        ProgramList = new List<Program__c>();
        ProListWrap = new List<ProgramWrap>();
        //selectedProgramViews = '0';
        User storeUser = [Select Id,contactid,accountId from User where id =: Userinfo.getUserid()];
        List<Store_IA_Account__c> storeAccountList = [select Id,IA_Account__c,Store_Account__c from Store_IA_Account__c 
                            where Store_Account__c = :storeUser.accountId
                            and IA_Account__c != null];

        industrialAccountSet = new Set<Id>();
        if(!storeAccountList.isEmpty()){
            for(Store_IA_Account__c storeId: storeAccountList){
                industrialAccountSet.add(storeId.IA_Account__c);
            } 
        } 

        getPrograms();
    }
    
    public void getPrograms()
    {
        System.debug('UAC: industrialAccountSet ' + industrialAccountSet );
        proListWrap = new List<ProgramWrap>();
        jsonResult = '';
        //Boolean isTemplate = selectedProgramViews == '1' ? true : false ;
        //System.debug('UAC: isTemplate ' + isTemplate );

        programList =  [SELECT Id,Name,Active__c, Account__r.Name, Template__c, toLabel(Type__c), Program_Notes_Trimmed__c, Activation_Date__c, Expiration_Date__c  FROM Program__c 
                        WHERE //( Account__c IN :industrialAccountSet OR 
                         (Account__c = null AND OwnerId = :UserInfo.getUserId())  //) 
                        AND Template__c = TRUE ];
        
        System.debug('UAC: programList size ' + programList.size() );

        for(Program__c obj : programList)
        {
            ProgramWrap wrapObj = new ProgramWrap();
            
            wrapObj.URLEdit = 'RWS_NewProgramSetup?tab=program&task=clone&proid='+obj.Id;
            wrapObj.URLSummary = 'ProgramSummary?tab=program&proid='+obj.Id;
            wrapObj.ProObj = obj;
            System.debug(obj.Expiration_Date__c);
            if(obj.Active__c == false)
            {
                wrapObj.Status = 'InActive';
            }
            else
            {
                wrapObj.Status = 'Active';
            }
            
            proListWrap.add(wrapObj);
        }
        
        System.debug('UAC: programList ' + programList );
        jsonProgramList();
    }

    public String jsonProgramList(){
        jsonResult = JSON.serialize(proListWrap);
        jsonResult = String.escapeSingleQuotes(jsonResult);
        System.debug('jsonResult****'+jsonResult);
            return jsonResult; 
    }
    
    public PageReference RedirectToEdit(String Id){
    
        system.debug('-=-=- Need to redirect'+Id);
        return null;
    }

    public class ProgramWrap{
        String URLEdit {get;set;}
        String URLSummary {get;set;}
        String Status {get;set;}
        Program__c ProObj {get;set;}
        
    }
}