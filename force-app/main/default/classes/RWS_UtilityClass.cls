public without sharing class RWS_UtilityClass {    
    /**********************************
     *** Program related pick Lists ***
     **********************************/
   
    //Fetch Sales Contract pick list values
    public static List<SelectOption> getSalesContract()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Sales_Contract__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@Typeoptions' +options);     
        return options; 
    }
    

    //Fetch PCard pick list values
    public static List<SelectOption> getPCard()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Alternative_Payment__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
              if (f.getLabel() == 'Yes') {
            options.add(new SelectOption(f.getValue(), 'Allowed'));
            } else {
            options.add(new SelectOption(f.getValue(), 'Not Allowed'));
            }
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    
    //Fetch Program Type Pick List
    public static List<SelectOption> getType()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@Typeoptions' +options);     
        return options; 
    }

    public static Boolean getUserRecordEditAccess(Id recordId) {
        List<UserRecordAccess> access = [select RecordId, HasEditAccess from UserRecordAccess 
                        where UserId = :UserInfo.getUserId()
                        And RecordId = :recordId];

        return access.size() > 0 ? access[0].HasEditAccess : false;
    }

    public static Boolean getUserRecordAccess(Id recordId) {
        List<UserRecordAccess> access = [select RecordId, HasEditAccess, HasReadAccess from UserRecordAccess 
                        where UserId = :UserInfo.getUserId()
                        And RecordId = :recordId];

        return access.size() > 0 ? access[0].HasReadAccess || access[0].HasEditAccess : false;
    }
    
    //Fetch Program SubsidyType Pick List
    public static List<SelectOption> getsubsidyType()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Subsidy_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@SubsidyTypeeoptions' +options);     
        return options; 
    }
    
    //Fetch Program Subsidy Frequency Pick List
    public static List<SelectOption> getsubsidyFrequency()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Subsidy_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@SubsidyFrequencyeeoptions' +options);     
        return options; 
    }
    
    //Fetch Program AccessoriesAllowedSubsidy Pick List
    public static List<SelectOption> getaccessoriesAllowedSubsidy()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = Program__c.Accessories_Allowed_on_Subsidy__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  */
        options.add(new SelectOption('Allowed', 'Allowed'));    
        options.add(new SelectOption('Not Allowed', 'Not Allowed')); 
        system.debug ('@@accessoriesAllowedSubsidoptions' +options);     
        return options; 
    }
    
    //Fetch Program EligibilityOptionoptions Pick List
    public static List<SelectOption> geteligibilityOption()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Eligibility_Option__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@EligibilityOptionoptions' +options);     
        return options; 
    }
    
    //Fetch Program RollingBalanceoptions Pick List
    public static List<SelectOption> getRollingBalanceOption() 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Rolling_Balance__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@RollingBalanceoptions' +options);     
        return options; 
    }
    
    //Fetch Program VoucherDistributionOption Pick List
    public static List<SelectOption> getVoucherDistributionOption()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Voucher_Distribution__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@VoucherDistributionOption' +options);     
        return options; 
    }
    
    //Fetch Program AnnualResetorRolloverOption Pick List
    public static List<SelectOption> getAnnualResetorRolloverOption()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Single-use', 'Single-use'));  
        //options.add(new SelectOption('Multi-use', 'Multi-use'));   
        system.debug ('@@AnnualResetorRolloverOption' +options);     
        return options; 
    }
    
    
    //Fetch Program RequireUpload Pick List
    public static List<SelectOption> getRequireUpload()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Require_Upload_of_Company_Voucher__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@RequireUpload' +options);     
        return options; 
    }
    
    
    //Fetch Program MandatoryOption Pick List
    public static List<SelectOption> getMandatoryOption() 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = Program__c.Mandatory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  */
        options.add(new SelectOption('Yes', 'Mandatory'));    
        options.add(new SelectOption('No', 'Not Mandatory')); 
        system.debug ('@@MandatoryOption' +options);     
        return options; 
    }
    
    //Fetch Program AccessoriesAllowPayrollDeduction Pick List
    public static List<SelectOption> getAccessoriesAllowPayrollDeduction()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        /*Schema.DescribeFieldResult fieldResult = Program__c.Accessories_Allowed_on_Payroll_Deduction__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        } */
        options.add(new SelectOption('Yes', 'Allowed'));    
        options.add(new SelectOption('No', 'Not Allowed'));  
        system.debug ('@@AccessoriesAllowPayrollDeduction' +options);     
        return options; 
    }
    /*
    //Fetch Program AutoAddProducts Pick List
    public static List<SelectOption> getAutoAddProducts()  
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Auto_Add_Products__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@AutoAddProducts' +options);     
        return options; 
    }
    */
    //Fetch Program Fixed Pick List
    public static List<SelectOption> getFixed()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Fixed__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@Fixed' +options);     
        return options; 
    }
    
    
    
    
    
    
    
    
    
    
    
    /***********************************************************
     *** Account methods***
     **********************************************************/
     
     //Fetch Account Organization Type Pick List
    public static List<SelectOption> getorganizationTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Organization_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@typeoptions' +options);     
        return options; 
    }
    
    //Fetch Account Category Pick List
    public static List<SelectOption> getaccountCategorys()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Account_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@categoryoptions' +options);     
        return options; 
    }    
    
    //Fetch Company Type Pick List
    public static List<SelectOption> getaccountTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Company_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@categoryoptions' +options);     
        return options; 
    } 
    
    //Fetch Company Service Method Pick List
    public static List<SelectOption> getaccountserviceMethods()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.NA_Distribution_Method__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@servicemethodoptions' +options);     
        return options; 
    }
    
    //Fetch Company Shoe Mobile Frequency Pick List
    public static List<SelectOption> getshoemobileceFrequency()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.NA_Shoemobile_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@shoemobilefreqoptions' +options);     
        return options; 
    }
    
    
    //Fetch ContactPreference Pick List
    public static List<SelectOption> getTaxIdType()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Tax_Id_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Account Tax Exempt Pick List
    public static List<SelectOption> getTaxExempts()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Tax_Exempt__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('--None--', '--None--'));     
        /*for( Schema.PicklistEntry f : ple)
{
options.add(new SelectOption(f.getValue(), f.getLabel()));
} */
        
        options.add(new SelectOption('Yes', 'Exempt'));  
        options.add(new SelectOption('No', 'Not Exempt'));      
        
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch ContactRoles Pick List
    public static List<SelectOption> getcontactRoles()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() != 'Billing Contact')
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@roleoptions' +options);     
        return options; 
    }

        //Fetch ContactRoles Pick List
    public static List<SelectOption> getPrimaryContactRole()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.BPR_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() == 'Primary Contact')
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@primaryContactRoleOptions' +options);     
        return options; 
    }
            //Fetch ContactRoles Pick List
    public static List<SelectOption> getBillingContactRole()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.BPR_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() == 'Billing Contact')
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@primaryContactRoleOptions' +options);     
        return options; 
    }
    //Fetch credit status Pick List
    public static List<SelectOption> getcreditStatus()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Credit_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@roleoptions' +options);     
        return options; 
    }
    
    //Fetch BillingFrequency Pick List
    public static List<SelectOption> getBillingFrequency()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Billing_Frequency__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--Select--', '--Select--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@getBillingFrequency' +options);     
        return options; 
    }
    
    //Fetch Program RequireUpload Pick List Without 'Yes'
    public static List<SelectOption> getRequireUploadWithoutYes()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Require_Upload_of_Company_Voucher__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getValue() != 'Yes')
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@RequireUpload' +options);
        return options; 
    }

    
    //Fetch BPCPaymentTerms Pick List with 90 and 120 filtered out - Needs to be moved to RWSUtility
    public static List<SelectOption> getPaymentTermsFiltered()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.BPC_Payment_Terms__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            if (f.getValue() != '90' && f.getValue() != '120'){
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
        }  
        return options; 
    }
    
    //Fetch BPCPaymentTerms Pick List
    public static List<SelectOption> getBPCPaymentTerms()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.BPC_Payment_Terms__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@getBPCPaymentTerms' +options);     
        return options; 
    }
    
    //Fetch InvoiceDeliveryMethod  Pick List

    public static List<SelectOption> getInvoiceDeliveryMethod()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Invoice_Delivery_Method__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        
        /*//United States
        options.add(new SelectOption('Email with CSV file', 'Email with CSV file'));
        options.add(new SelectOption('Email with PDF file', 'Email with PDF file'));
        options.add(new SelectOption('Special Invoice Handling', 'Special Invoice Handling'));
        system.debug ('@@getInvoiceDeliveryMethod' +options);     
        */
        return options; 

    }

    //Fetch InvoiceAttributesRequired Pick List
    public static List<SelectOption> getInvoiceAttributesRequired()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Invoice_Atributes_Required__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            if(f.getLabel() != 'UDF')
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@getInvoiceAttributesRequired' +options);     
        return options; 
    }
    
    //Fetch PreferredPaymentMethod Pick List
    public static List<SelectOption> getPreferredPaymentMethod()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Preferred_Payment_Method__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@getPreferredPaymentMethod' +options);     
        return options; 
    }
    
    //Fetch ContactPreference Pick List
    public static List<SelectOption> getcontactPreference()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Preference__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    
    
     //Industrial Account Pick List
    public static List<SelectOption> getIndustrialAccountOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Allowed', 'Allowed'));    
        options.add(new SelectOption('NotAllowed', 'Not Allowed')); 
        
        return options; 
    }
    
    //National Account Pick List
    public static List<SelectOption> getNationalAccountOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Allowed', 'Allowed'));    
        options.add(new SelectOption('NotAllowed', 'Not Allowed')); 
        
        return options; 
    }
    
    //City Exempt Pick List
    public static List<SelectOption> getCityExemptOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Exempt', 'Exempt'));    
        options.add(new SelectOption('NotExempt', 'Not Exempt')); 
        
        return options; 
    }
    
    
    //State Exempt Pick List
    public static List<SelectOption> getStateExemptOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Exempt', 'Exempt'));    
        options.add(new SelectOption('NotExempt', 'Not Exempt'));
        
        return options; 
    }
    
    //County Exempt Pick List
    public static List<SelectOption> getCountyExemptOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Exempt', 'Exempt'));    
        options.add(new SelectOption('NotExempt', 'Not Exempt')); 
        
        return options; 
    }
    
    //Country Exempt Pick List
    public static List<SelectOption> getCountryExemptOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Exempt', 'Exempt'));    
        options.add(new SelectOption('NotExempt', 'Not Exempt')); 
        
        return options; 
    }
    
   
    
    //Fetch Contact address same as account Pick List
    public static List<SelectOption> getAddressPreference()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Address_same_as_Accounts__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            if (f.getLabel() == 'Same as Physical') {
            options.add(new SelectOption(f.getValue(), 'Same as Company'));
            } else {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Billing Contact same as Primary Contact Pick List
    public static List<SelectOption> getcontactAddressPrimary()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Contact_Same_as_Primary__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Billing Contact Address Options Pick List
    public static List<SelectOption> getcontactAddressBilling()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.Billing_Address_Options__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Billing Contact Address Options Pick List
    public static List<SelectOption> getSubsidyTaxMethods()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Subsidy_Tax__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Requires Invoicing Account Pick List
    public static List<SelectOption> getrequiresInvoicing()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Requires_Invoicing__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //options.add(new SelectOption('all', 'all'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }
    
    //Fetch Requested Credit Limit Account Pick List
    public static List<SelectOption> getRequestedCreditLimit()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Account.Requested_Credit_Limi__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--Select--', '--Select--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@preferenceoptions' +options);     
        return options; 
    }

    //Fetch IA Physical Addr State Pick List
    public static List<SelectOption> getStates()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Account.IA_Physical_Location_State_Province__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        return options; 
    }

    //Fetch Program ServiceLevel Pick List
    public static List<SelectOption> getServicingLevel()
    {
        String accountType = [select Contact.Account.Store_Ownership_Type__c from User where Id = :UserInfo.getUserId() limit 1].Contact.Account.Store_Ownership_Type__c;
        
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Program__c.Servicing_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        /*
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        */ 

        for( Schema.PicklistEntry f : ple) {
            if(accountType == 'Dealer' && (f.getValue() == 'DealerOnly' || f.getValue() == 'DealerMarketAreaProgram')) 
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            
            if((accountType == null || accountType == 'Corporate') && f.getValue() == 'RWSS')
                options.add(new SelectOption(f.getValue(), f.getLabel()));

            if(accountType == null && f.getValue() == 'RWSSPlus')
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        system.debug ('@@ServicingLevelOptions' +options);     
        return options; 
    }

    //Fetch IA Physical Addr Countries Pick List
    public static List<SelectOption> getCountries()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =  Account.IA_Physical_Location_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        return options; 
    }

    //Fetch Contact Countries Pick List
    public static List<SelectOption> getContactCountries()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('US', 'United States'));
        options.add(new SelectOption('CA', 'Canada'));
        return options; 
    }
    
    //Fetch Attachment Type Pick List
    public static List<SelectOption> getAttachType()
    {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = RWfB_Attachment__c.Type__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               options.add(new SelectOption(f.getLabel(), f.getValue()));
       }     
       return options;
    }
    
    
    //Fetch Contact Countries Pick List
    public static List<SelectOption> getContactStates()
    {

        /*
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =  Account.IA_Physical_Location_State_Province__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
        } 
        */ 

        List<SelectOption> options = new List<SelectOption>();
        
        //United States
        options.add(new SelectOption('--Select--', '--Select--'));
        options.add(new SelectOption('AL', 'Alabama'));
        options.add(new SelectOption('AK', 'Alaska'));
        options.add(new SelectOption('AZ', 'Arizona'));
        options.add(new SelectOption('AR', 'Arkansas'));
        options.add(new SelectOption('CA', 'California'));
        options.add(new SelectOption('CO', 'Colorado'));
        options.add(new SelectOption('CT', 'Connecticut'));
        options.add(new SelectOption('DE', 'Delaware'));
        options.add(new SelectOption('FL', 'Florida'));
        options.add(new SelectOption('GA', 'Georgia'));
        options.add(new SelectOption('HI', 'Hawaii'));
        options.add(new SelectOption('ID', 'Idaho'));
        options.add(new SelectOption('IL', 'Illinois'));
        options.add(new SelectOption('IN', 'Indiana'));
        options.add(new SelectOption('IA', 'Iowa'));
        options.add(new SelectOption('KS', 'Kansas'));
        options.add(new SelectOption('KY', 'Kentucky'));
        options.add(new SelectOption('LA', 'Louisiana'));
        options.add(new SelectOption('ME', 'Maine'));
        options.add(new SelectOption('MD', 'Maryland'));
        options.add(new SelectOption('MA', 'Massachusetts'));
        options.add(new SelectOption('MI', 'Michigan'));
        options.add(new SelectOption('MN', 'Minnesota'));
        options.add(new SelectOption('MS', 'Mississippi'));
        options.add(new SelectOption('MO', 'Missouri'));
        options.add(new SelectOption('MT', 'Montana'));
        options.add(new SelectOption('NE', 'Nebraska'));
        options.add(new SelectOption('NV', 'Nevada'));
        options.add(new SelectOption('NH', 'New Hampshire'));
        options.add(new SelectOption('NJ', 'New Jersey'));
        options.add(new SelectOption('NM', 'New Mexico'));
        options.add(new SelectOption('NY', 'New York'));
        options.add(new SelectOption('NC', 'North Carolina'));
        options.add(new SelectOption('ND', 'North Dakota'));
        options.add(new SelectOption('OH', 'Ohio'));
        options.add(new SelectOption('OK', 'Oklahoma'));
        options.add(new SelectOption('OR', 'Oregon'));
        options.add(new SelectOption('PA', 'Pennsylvania'));
        options.add(new SelectOption('RI', 'Rhode Island'));
        options.add(new SelectOption('SC', 'South Carolina'));
        options.add(new SelectOption('SD', 'South Dakota'));
        options.add(new SelectOption('TN', 'Tennessee'));
        options.add(new SelectOption('TX', 'Texas'));
        options.add(new SelectOption('UT', 'Utah'));
        options.add(new SelectOption('VT', 'Vermont'));
        options.add(new SelectOption('VA', 'Virginia'));
        options.add(new SelectOption('WA', 'Washington'));
        options.add(new SelectOption('DC', 'Washington DC'));
        options.add(new SelectOption('WV', 'West Virginia'));
        options.add(new SelectOption('WI', 'Wisconsin'));
        options.add(new SelectOption('WY', 'Wyoming'));
        
        //Canada 
        options.add(new SelectOption('AB', 'Alberta'));
        options.add(new SelectOption('BC', 'British Columbia'));
        options.add(new SelectOption('MB', 'Manitoba'));
        options.add(new SelectOption('NB', 'New Brunswick'));
        options.add(new SelectOption('NL', 'Newfoundland and Labrador'));
        options.add(new SelectOption('NT', 'Northwest Territories'));
        options.add(new SelectOption('NS', 'Nova Scotia'));
        options.add(new SelectOption('NU', 'Nunavut'));
        options.add(new SelectOption('ON', 'Ontario'));
        options.add(new SelectOption('PE', 'Prince Edward Island'));
        options.add(new SelectOption('QC', 'Quebec'));
        options.add(new SelectOption('SK', 'Saskatchewan'));
        options.add(new SelectOption('YT', 'Yukon Territory'));

        return options; 
    }
    
    //Fetch RWBAA UserType Pick List
    public static List<SelectOption> getContactUserType()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.RWBAA_User_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--None--'));     
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }  
        system.debug ('@@userttypeoptions' +options);     
        return options; 
    }
    
    
    
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole : [select Id from UserRole where ParentRoleId
                                IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;

    }
    
    public static Map<Id, Group> grMap;

    private static void populateGroupMap() {
        if(grMap == null)
            grMap = new Map<Id, Group>([select Id, Name, Type, RelatedId from Group limit 5000]);
    }
    
    public static set<id> GetUserIdsFromGroups(set<id> groupids){

        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        String roleType = Schema.SObjectType.UserRole.getKeyPrefix();
        Set<Id> groupIdProxys = new Set<Id>();
        // Loop through all group members in a group
        Set <Id> groupWithRole = new Set<Id>();
        set<Id> groupWithRoleNSub = new set<Id>();
        id firstelement = null;

        populateGroupMap();
 
        for(Id i: groupids){
            firstelement = i;
            break;
        }

        if(String.valueOf(firstelement.getSObjectType()) == 'Group'){
            for(GroupMember m : [Select Id, UserOrGroupId,GroupId,Group.type From GroupMember Where GroupId in :groupIds]) {
                // If the user or group id is a user
                if(((String)m.UserOrGroupId).startsWith(userType)) {
                    result.add(m.UserOrGroupId);
                } else if(grMap.get(m.UserOrGroupId) !=null && ( grMap.get(m.UserOrGroupId).relatedid !=null && ((String)grMap.get(m.UserOrGroupId).relatedid).startsWith(roleType) )){
                   
                   
                    if(grMap.get(m.UserOrGroupId).type == 'Role')    
                        groupWithRole.add(grMap.get(m.UserOrGroupId).relatedid);
                    else if(grMap.get(m.UserOrGroupId).type == 'RoleAndSubordinatesInternal') 
                        groupWithRoleNSub.add(grMap.get(m.UserOrGroupId).relatedid);     
                }
                // If the user or group id is a group
                // Note: there may be a problem with governor limits if this is called too many times
                else if (((String)m.UserOrGroupId).startsWith(groupType)) {                   
                    // Call this function again but pass in the group found within this group
                    groupIdProxys.add(m.UserOrGroupId);
                }
            }
            
            if(groupWithRoleNSub.size() > 0){
                groupWithRoleNSub.addALL(getAllSubRoleIds(groupWithRoleNSub));
                Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :groupWithRoleNSub AND isActive =: true]);
                result.addALL(users.keyset());   
            }
            else if(groupWithRole.size()>0){
                Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :groupWithRole AND isActive =: true]);
                result.addALL(users.keyset());
            }
           
            if(groupIdProxys.size() > 0)
            {
                result.addAll(GetUserIdsFromGroups(groupIdProxys));
            }
        }else if(String.valueOf(firstelement.getSObjectType()) == 'CollaborationGroup'){
            for (CollaborationGroupMember m : [select  id, CollaborationGroupId,MemberId from CollaborationGroupMember
                                               where CollaborationGroupId IN :groupIds]){
                
                // If the user or group id is a user
                if (((String)m.MemberId).startsWith(userType)){
                    result.add(m.MemberId);
                }             
            }
        }
        return result; 
    }

    public static List<Set<Id>> getIsmAndNamUser() {
        Set<Id> ismUserIds = new Set<Id>();
        Set<Id> namUserIds = new Set<Id>();
        List<Set<Id>> allInternalUserIds = new List<Set<Id>>();

        for(Group g : [select Id, DeveloperName from Group
                                where DeveloperName in ('National_Accounts', 
                                        'ISM_Industrial_Sales_Managers')]) {

            if(g.DeveloperName == 'ISM_Industrial_Sales_Managers') ismUserIds.addAll(RWS_UtilityClass.GetUserIdsFromGroups(new Set<Id>{g.Id}) );
            if(g.DeveloperName == 'National_Accounts') namUserIds.addAll(RWS_UtilityClass.GetUserIdsFromGroups(new Set<Id>{g.Id}) );

            
        }

        for(User u : [select Id, Profile.Name

                                from User
                                where Profile.Name in ('RWS Industrial Sales Manager', 
                                        'RWS National Account Manager')]) {

            if(u.Profile.Name == 'RWS Industrial Sales Manager') ismUserIds.add(u.Id);
            if(u.Profile.Name == 'RWS National Account Manager') namUserIds.add(u.Id);
        }

        allInternalUserIds.add(ismUserIds);
        allInternalUserIds.add(namUserIds);


        return allInternalUserIds;
    }


    
    public static Account getParentAccountConstructor(Id parentAccountId) {
        return [SELECT Id,Billing_Frequency__c, IA_Federal_ID_Nbr__c, BPC_Payment_Terms__c,
                    Federal_ID__c,Invoice_Delivery_Method__c,
                    Credit_Limit__c, Legal_Name__c, Name 
                FROM Account WHERE ID = :parentAccountId];
    }

    public static Account getParentAccountInvoiceInfo(Id parentAccountId) {
        return [SELECT Id, Name, FirstName, LastName, PersonEmail, Phone, Billing_Frequency__c, Federal_ID__c, Payment_Terms__c, 
                                        Legal_Name__c, Invoice_Delivery_Method__c, Credit_Limit__c, Invoice_Parent_Account__c, IA_Federal_ID_Nbr__c, BPC_Payment_Terms__c, Invoice_Atributes_Required__c, Requested_Credit_Limi__c,Email_Application_To__c,
                                    (select Id from Contacts where Contact_Identifier__c IN ('Primary & Billing', 'Billing') order by Contact_Identifier__c desc )
                                FROM Account WHERE Id = :parentAccountId ];
    }

    public static Account getParentAccountForComponent(Id parentAccountId) {
        return [SELECT Id,Name,CreatedDate,Account_Number_BPC__c,Owner.Name,IA_Physical_Location_Address_Line_1__c,Phone,IA_Physical_Location_Address_Line_2__c,IA_Physical_Location_Address_Line_3__c,
                            IA_Physical_Location_City__c,
                           IA_Physical_Location_State_Province__c, IA_Physical_Location_ZIP_Postal_Code__c,IA_Physical_Location_Country__c,RWfB_Billing_Address_Line_1__c, RWfB_Billing_Address_Line_2__c,
                           RWfB_Billing_Address_Line_3__c,RWfB_Billing_Address_City__c, RWfB_Billing_Address_State_Province__c,RWfB_Billing_Address_ZIP_Postal_Code__c,RWfB_Billing_Address_Country__c,
                           Organization_Type__c,Account_Category__c,Company_Type__c,NA_Distribution_Method__c,DunsNumber,NA_Shoemobile_Frequency__c,
                           Tax_Exemption_Reason__c,Tax_Exemption_Reason__r.Name,Tax_Id_Type__c,Tax_Id_Number__c,Tax_Exempt__c,IA_Tax_Exempt_Certificate_Nbr__c,
                           Tax_Exempt_Expiration_Date__c,Open_Date__c,Credit_Status__c,Requested_Credit_Limi__c,Credit_Limit__C,Billing_Frequency__c,
                           BPC_Payment_Terms__c,Invoice_Delivery_Method__c,Preferred_Payment_Method__c,Email_Application_To__c,MSTS_ID__c,
                           MultiService_Credit_Application_ID__c,Credit_Application_Sent_Date__c,Credit_Application_Approval_Date__c,Active__c,
                           Requires_Invoicing__c,Send_Application__c,IA_Federal_ID_Nbr__c,RWfB_same_as_Physical_Address__c, ParentId, Parent.Name
                   FROM Account WHERE ID =: parentAccountId];
    }
    
    //check if current user is full access user
    //based on the custom setting
    public static Boolean isFullAccessUser() {
        Boolean returnMe = true;
        Id pId = UserInfo.getProfileId();
        String limitedProfileName = RWfB_Community__c.getOrgDefaults().Limited_Use__c;
        String pName = [Select Name from Profile where Id =: pId limit 1].Name;
        if(!String.isBlank(limitedProfileName)){
            returnMe = !limitedProfileName.contains(pName);
        }
        return returnMe;
    }
    
    //get values of account summary accordion custom settings
    public static Boolean isCollapsedAccInfo() {               
        return RWfB_Community__c.getOrgDefaults().Collapse_Account_Information__c;         
    }
    
    public static Boolean isCollapsedContact() {               
        return RWfB_Community__c.getInstance().Collapse_Contact_Information__c;        
    }
    
    public static Boolean isCollapsedBilling() {               
        return RWfB_Community__c.getInstance().Collapse_Credit_and_Billing__c;        
    }
    
    public static Boolean isCollapsedChildAcc() {               
        return RWfB_Community__c.getInstance().Collapse_Child_Accounts__c;      
    }
    
    public static Boolean isCollapsedPrograms() {               
        return RWfB_Community__c.getInstance().Collapse_Programs__c;   
    }
    
    public static Boolean isCollapsedAttachments() {               
        return RWfB_Community__c.getInstance().Collapse_Attachments__c;
    }
    
    
    
   
    
}