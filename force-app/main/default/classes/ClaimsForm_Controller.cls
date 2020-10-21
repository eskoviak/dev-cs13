public class ClaimsForm_Controller
{
    public ClaimsForm_Controller() 
    {
    }
	 
    public String FileName1 {get;set;}
    public Blob File1 {get;set;}
    public String FileName2 {get;set;}
    public Blob File2 {get;set;}
    public String FileName3 {get;set;}
    public Blob File3 {get;set;}
    public String AccountType {get;set;}
    public String Orders {get; set;}
    public String IssueDescription {get; set;}
    public String OrderNumber {get; set;}
    
    @TestVisible
    public PageReference InsertNewCase()
    {
        Case cs = new Case();
        String picId = '';
        Account a;
        try
        {
            Id contactId = [SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()].ContactId;
            Id accountId = [SELECT AccountId FROM Contact WHERE Id=:contactId].AccountId;
            a = [SELECT  Name, 
                         AccountNumber, 
                         M3_Location_Address__c, 
                         M3_Location_City__c, 
                         M3_Location_State_Province__c, 
                         M3_Location_ZIP_Postal_Code__c, 
                         M3_Location_Country__c, 
                         (SELECT UserId, TeamMemberRole FROM AccountTeamMembers WHERE IsDeleted = false)
                         FROM Account
                         WHERE Id=:accountId];
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'User record is not related to any Accounts.'));
            return null;
        }
        
        try
        {
            if(File1 != null)
            {
                picId = InsertPictureToDocuments(File1, FileName1);
                cs.Photo1__c = '<img src="/servlet/servlet.FileDownload?file=' + picId + '" width="768"></img>';
            }     
            if(File2 != null)
            {
                picId = InsertPictureToDocuments(File2, FileName2);
                cs.Photo2__c = '<img src="/servlet/servlet.FileDownload?file=' + picId + '" width="768"></img>';
            }
            if(File3 != null)
            {
                picId = InsertPictureToDocuments(File3, FileName3);
                cs.Photo3__c = '<img src="/servlet/servlet.FileDownload?file=' + picId + '" width="768"></img>';
            }
            
            cs.Account_Number__c = a.AccountNumber;
            cs.Account_Type__c = AccountType;
            cs.PO_and_Orginal_Invoice_Numbers__c = Orders.replaceAll(',', '\r\n');
            cs.Order__c = OrderNumber;
            cs.Type = 'DTI Claim';
            cs.Subject = 'Product Claim';
            cs.Claim_Address__c = a.M3_Location_Address__c;
            cs.Claim_City__c = a.M3_Location_City__c;
            cs.Claim_State__c = a.M3_Location_State_Province__c;
            cs.Claim_Postal_Code__c = a.M3_Location_ZIP_Postal_Code__c;
            cs.Claim_Country__c = a.M3_Location_Country__c;
            cs.Reason = 'Return Authorization (RA)';
            cs.Description = IssueDescription;
            cs.CreatedDate = System.Now();
            cs.Status = 'New';
            cs.Origin = 'Claim Form';
            cs.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'DTI Claim' LIMIT 1].Id;
            
            AccountTeamMember rom;
			AccountTeamMember salesRep;            
            AccountTeamMember regionDirector;
            
            for(AccountTeamMember atm : a.AccountTeamMembers)
            {
                if(atm.TeamMemberRole == 'Retail Operations Manager')
                {
                    rom = atm;
                }
                else if(atm.TeamMemberRole == 'Sales Rep')
                {
                    salesRep = atm;
                }
                else if(atm.TeamMemberRole == 'Region Director')
                {
                    regionDirector = atm;
                }
            }
            
            if(rom != null)
            {
                cs.OwnerId = rom.UserId;
                if(salesRep != null)
                {
                	cs.Sales_Rep__c = salesRep.UserId;
                }
                else if(regionDirector != null)
                {
                    cs.Sales_Rep__c = regionDirector.UserId;
                }
            }
            else if(salesRep != null)
            {
                cs.OwnerId = salesRep.UserId;
                cs.Sales_Rep__c = salesRep.UserId;
            }
            else if(regionDirector != null)
            {
                cs.OwnerId = regionDirector.UserId;
                cs.Sales_Rep__c = regionDirector.UserId;
            }
            else
            {
                cs.OwnerId = [SELECT Id FROM User WHERE FirstName = 'Chris' AND LastName = 'Doman' AND email = 'chris.doman@redwingshoes.com'].Id;
            }
            
            /*Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.emailHeader.triggerUserEmail = true;
            cs.setOptions(dmlOpts);*/
            
            insert cs;
            return new PageReference('/' + cs.Id);
        }
        catch(Exception e)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'ClaimsForm Process Failed.'));
            return null;
        }
    }  
    
    @TestVisible
    public String InsertPictureToDocuments(Blob file, String fileName)
    {
        Document d = new Document();
        d.name = fileName;
        d.body = file;
        d.folderid = UserInfo.getUserId(); //[SELECT Id FROM Folder WHERE Name = '' LIMIT 1][0].id; //folderid where the document will be stored insert
        insert d;
        return String.valueOf(d.Id).substring(0,15);
    }

}