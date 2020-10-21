@IsTest
public class Test_PopulateAccountTeamOnAccountTrigger {/*
    	
    	// Test when there are no Account Team Members
        static testMethod void TestNoAccountTeamMembers() {
            
            //Create Account
            Account newAccount = new Account (name='Unit Test Account');
            insert newAccount;
                    
            //Get Profile Information
            Profile p = [select id from profile where name='System Administrator'];
            
            //Create Users
            User newUser01 = new User (FirstName='Test01',LastName='User01',Alias='tuser01',Email='test01@test.com',
                Username='edatest01@redwingshoes.com',CommunityNickname='test01',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser01;
            
            User newUser02 = new User (FirstName='Test02',LastName='User02',Alias='tuser02',Email='test02@test.com',
                Username='edatest02@redwingshoes.com',CommunityNickname='test02',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser02;
                
            //Test that Account Credit Analyst should be null
            System.assertEquals(null,newAccount.Account_Credit_Analyst__c);  
        }
  
    	// Test when there is a Credit Analyst Account Team Member
        static testMethod void TestCreditAnalystAccountTeamMember() {

            //Create Account
            Account newAccount = new Account (name='Unit Test Account');
            insert newAccount;
                    
            //Get Profile Information
            Profile p = [select id from profile where name='System Administrator'];
            
            //Create Users
            User newUser01 = new User (FirstName='Test01',LastName='User01',Alias='tuser01',Email='test01@test.com',
                Username='edatest01@redwingshoes.com',CommunityNickname='test01',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser01;
            
            User newUser02 = new User (FirstName='Test02',LastName='User02',Alias='tuser02',Email='test02@test.com',
                Username='edatest02@redwingshoes.com',CommunityNickname='test02',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser02;
            
            //Create Account Team
            AccountTeamMember atm01 = new AccountTeamMember (UserId=newUser01.id,AccountId=newAccount.id,TeamMemberRole='Credit Analyst');
            insert atm01;
           
            //AccountTeamMember atm02 = new AccountTeamMember (UserId=newUser02.id,AccountId=newAccount.id,TeamMemberRole='Industrial Sales Manager');
            //insert atm02;     
            
            //Update Account
            newAccount.Gift_Card_Participant__c = true;
            update newAccount;
            
            //Re-query the data
            Account checkAccount = new Account();
            checkAccount = [SELECT Id,Account_Credit_Analyst__c FROM Account WHERE Id= :newAccount.id];
           
            //Run Check
            System.assertEquals(newUser01.id,checkAccount.Account_Credit_Analyst__c);
        }       
    
    	// Test when there is a non Credit Analyst Account Team Member
        static testMethod void TestNonCreditAnalystAccountTeamMember() {

            //Create Account
            Account newAccount = new Account (name='Unit Test Account');
            insert newAccount;
                    
            //Get Profile Information
            Profile p = [select id from profile where name='System Administrator'];
            
            //Create Users
            User newUser01 = new User (FirstName='Test01',LastName='User01',Alias='tuser01',Email='test01@test.com',
                Username='edatest01@redwingshoes.com',CommunityNickname='test01',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser01;
            
            User newUser02 = new User (FirstName='Test02',LastName='User02',Alias='tuser02',Email='test02@test.com',
                Username='edatest02@redwingshoes.com',CommunityNickname='test02',profileid=p.Id,EmailEncodingKey='UTF-8',
                TimeZoneSidKey='America/Chicago',LocaleSidKey='en_US',
                LanguageLocaleKey='en_US');
            insert newUser02;
            
            //Create Account Team
            //AccountTeamMember atm01 = new AccountTeamMember (UserId=newUser01.id,AccountId=newAccount.id,TeamMemberRole='Credit Analyst');
            //insert atm01;
           
            AccountTeamMember atm02 = new AccountTeamMember (UserId=newUser02.id,AccountId=newAccount.id,TeamMemberRole='Industrial Sales Manager');
            insert atm02;     
            
            //Update Account
            newAccount.Gift_Card_Participant__c = true;
            update newAccount;
            
            //Re-query the data
            Account checkAccount = new Account();
            checkAccount = [SELECT Id,Account_Credit_Analyst__c FROM Account WHERE Id= :newAccount.id];
           
            //Run Check
            System.assertEquals(null,checkAccount.Account_Credit_Analyst__c);
        }       
    
*/}