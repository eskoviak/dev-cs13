public with sharing class TruckControllerWithCal
{
    private List<Account> AccountTemp;
	private List<Truck_for_Store__c> TruckTemp;
	private List<User> UserTemp;
	private List<Account> Locations;
    private Account ParentAccount;
    //public Truck_for_Store__c SelectedTruck;
    public Id SelectedAccountId {get; set;}
    public Id SelectedTruckId {get; set;}
    public boolean MapVisible;

    public TruckControllerWithCal()
    {
        MapVisible = false;
        AccountTemp = new List<Account>();
        TruckTemp = new List<Truck_for_Store__c>();
        UserTemp = new List<User>();
        Locations = new List<Account>();
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
    
    /*public void setAccount() 
    {
        SelectedAccount = a;
        SelectedTruck = null;
    }
    /*public List<SelectOption> accounts
    {
        get
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
        set
        {
            SelectedId = a;
        	SelectedTruck = null;
        }
    }*/
	
	public List<SelectOption> TruckList
    {
        get
        {
            List<Truck_for_Store__c> TruckTemp = [Select t.Store__r.Id, t.Truck__r.Id From Truck_for_Store__c t Where t.Truck_Is_Active__c = true];
            TruckList = new List<SelectOption>();
            TruckList.add(new SelectOption('','-Select-'));
            for(Truck_for_Store__c temp : TruckTemp)
            {
                TruckList.add(new SelectOption(temp.Store__r.Id, temp.Truck__r.Id));
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
        List<Account> selectAccount = [Select Latitude__c, Longitude__c From Account Where Id = :SelectedAccountId];
        if(selectAccount.size() > 0)
        {
            ParentAccount = selectAccount.get(0);
        	MapVisible = true;
        }
        else
        {
            MapVisible = false;
        }        
    }
    
    public void PopulateMapForTruck() 
    {
        List<Account> selectAccount = [Select Latitude__c, Longitude__c From Account Where Id = :SelectedTruckId];
        if(selectAccount.size() > 0)
        {
            ParentAccount = selectAccount.get(0);
        	MapVisible = true;
        }
        else
        {
            MapVisible = false;
        }        
    }
    
    public PageReference openCal()
    {
        PageReference pageRef= new PageReference('/apex/TruckControllerCal');
        pageRef.setredirect(true);       
        pageRef.getParameters().put('storeId', SelectedAccountId);
        system.debug('StoreId: ' + SelectedAccountId);
        return pageRef;
    }
}