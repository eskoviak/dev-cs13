public with sharing class TruckController
{
    private List<Account> AccountTemp;
	private List<Truck_for_Store__c> TruckTemp;
	private List<User> UserTemp;
	private List<Account> Locations;
    private Account ParentAccount;
    //public Truck_for_Store__c SelectedTruck;
    public List<Account> ServicedAccounts {get; set;}
    public Id SelectedAccountId {get; set;}
    public Id SelectedTruckId {get; set;}
    public boolean MapVisible;
    public boolean IgnoreServicedByTruck {get; set;}
    public String BaseUrl {get; set;}

    public TruckController()
    {
        BaseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '';
        MapVisible = false;
        IgnoreServicedByTruck = false;
        AccountTemp = new List<Account>();
        TruckTemp = new List<Truck_for_Store__c>();
        UserTemp = new List<User>();
        Locations = new List<Account>();
        ServicedAccounts = new List<Account>();
    }
    
    public Integer getServicedAccountsLength()
    {
        return ServicedAccounts.size();
    }
    
    public Account getServicedAccount(Integer index)
    {
        if(index >= getServicedAccountsLength())
        {
            //error            
        }
        return ServicedAccounts.get(index);
    }
    
    public boolean getMapVisible()
    {
        return MapVisible;
    }    
    
    public Account getParentAccount() 
    {
        return ParentAccount;
    }
     
    public List<SelectOption> getAccounts()
    {
        AccountTemp = [Select a.Store_Number__c, a.Id, a.Truck_Qty__c, a.ParentId From Account a Where a.Truck_Qty__c > 0];
        List<SelectOption> accounts = new List<SelectOption>();
        accounts.add(new SelectOption('','-Select-'));
        for(Account temp : AccountTemp)
        {
            accounts.add(new SelectOption(temp.Id, temp.Store_Number__c));
        }
        return accounts;
    }
	
	public List<SelectOption> TruckList
    {
        get
        {
            List<Truck_for_Store__c> TruckTemp = [Select t.Store__r.Id, t.Truck__r.Id, t.Truck_Unit_Nbr__c, t.Truck_Description__c  From Truck_for_Store__c t Where t.Truck_Is_Active__c = true];
            TruckList = new List<SelectOption>();
            TruckList.add(new SelectOption('','-Select-'));
            for(Truck_for_Store__c temp : TruckTemp)
            {
                String truckInfo = temp.Truck_Unit_Nbr__c + ' ' + temp.Truck_Description__c;
                TruckList.add(new SelectOption(temp.Store__r.Id, truckInfo));
            }
            return TruckList;
        }
        set;
    }
	
	/*public List<SelectOption> UserList
	{
		get
		{
			//correct role name? driver?
			List<User> UserTemp = [Select u.Id, u.Name, u.UserRole From User u Where u.IsActive = true AND u.UserRole.Name = 'Industrial_Store_Truck'];
			UserList = new List<SelectOption>();
			for(User temp : UserTemp)
			{
				UserList.add(new SelectOption(temp.Id, temp.Name);
			}
			return UserList;
		}
		set;
	}*/
    
    public void PopulateMapForAccount() 
    {
        List<Account> selectAccount = [Select Name, Latitude__c, Longitude__c From Account Where Id = :SelectedAccountId];
        if(selectAccount.size() > 0)
        {
            ParentAccount = selectAccount.get(0);
            PopulateIndustrialAccounts(ParentAccount.Id);
        	MapVisible = true;
        }
        else
        {
            MapVisible = false;
        }        
    }
    
    public void ToggleIgnoreNonTruck()
    {
        IgnoreServicedByTruck = !IgnoreServicedByTruck;
    }
    
    public void PopulateMapForTruck() 
    {
        List<Account> selectAccount = [Select Name, Latitude__c, Longitude__c From Account Where Id = :SelectedTruckId];
        if(selectAccount.size() > 0)
        {
            ParentAccount = selectAccount.get(0);
            PopulateIndustrialAccounts(ParentAccount.Id);
        	MapVisible = true;
        }
        else
        {
            MapVisible = false;
        }        
    }
    
    private void PopulateIndustrialAccounts(Id selectedId)
    {
        ServicedAccounts = [Select Id, Name, Latitude__c, Longitude__c, IA_Service_Method__c, Last_Truck_Run__c, Days_Since_Last_Truck_Run__c
                            FROM Account 
                            WHERE Id != :selectedId];
    }
    
    public PageReference openCal()
    {
        PageReference pageRef= new PageReference('/apex/TruckControllerCal');
        pageRef.setredirect(true);       
        pageRef.getParameters().put('storeId', ParentAccount.Id);
        return pageRef;
    }
}