/**
 * Test class for LeadAssignmentHelper
 * @author  Demand Chain Systems
 * @date  11/15/2015
 */
@isTest
private class Test_LeadAssignmentHelper {

    static testmethod void testAssignLeads() {
        List<User> users = createUsers();
        createRoles();
        createAssignmentRecords(users);

        Test.startTest();
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 200; i++){
            String country = (Math.mod(i,3) == 1) ? 'US' : null;
            country = (Math.mod(i,3) == 2) ? 'USA' : country;
            leads.add(new Lead(Firstname='First',Lastname='Last',PostalCode='11111-111111',OwnerId=users.get(1).Id,Country=country));
        }
        insert leads;
        Test.stopTest();

        leads = [Select BTB_Sales_Rep__c,ISM_Sales_Rep__c,TSM_Sales_Rep__c,ROM_Sales_Rep__c From Lead];
        System.assertEquals(200,leads.size());
        for(Lead l : leads){
            System.assertEquals('Testy McTesterton',l.ISM_Sales_Rep__c);
            System.assertEquals('Testy McTesterton',l.TSM_Sales_Rep__c);
            System.assertEquals('Testy McTesterton',l.ROM_Sales_Rep__c);
        }
    }

    static testmethod void testAssignLeadsInternational() {
        List<User> users = createUsers();
        createRoles();
        createAssignmentRecords(users);

        Test.startTest();
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 200; i++){
            leads.add(new Lead(Firstname='First',Lastname='Last',OwnerId=users.get(1).Id,Country='CA'));
        }
        insert leads;
        Test.stopTest();

        leads = [Select BTB_Sales_Rep__c,ISM_Sales_Rep__c,TSM_Sales_Rep__c,ROM_Sales_Rep__c From Lead];
        System.assertEquals(200,leads.size());
        for(Lead l : leads){
            System.assertEquals('Testy McTesterton',l.BTB_Sales_Rep__c);
        }
    }

    static testmethod void testAssignLeadsWithInvalidZipcode() {
        List<User> users = createUsers();
        createRoles();
        createAssignmentRecords(users);

        Test.startTest();
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 200; i++){
            leads.add(new Lead(Firstname='First',Lastname='Last',PostalCode='22222'));
        }
        insert leads;
        Test.stopTest();

        leads = [Select BTB_Sales_Rep__c,ISM_Sales_Rep__c,TSM_Sales_Rep__c,ROM_Sales_Rep__c From Lead];
        System.assertEquals(200,leads.size());
        for(Lead l : leads){
            System.assertEquals(null,l.ISM_Sales_Rep__c);
            System.assertEquals(null,l.TSM_Sales_Rep__c);
            System.assertEquals(null,l.ROM_Sales_Rep__c);
            System.assertEquals(null,l.BTB_Sales_Rep__c);
        }
    }

    private static void createAssignmentRecords(List<User> users){
        List<Zip_Code_Area_Assignment__c> zaacs = new List<Zip_Code_Area_Assignment__c>{
            new Zip_Code_Area_Assignment__c(
                Account_Owner__c = users.get(0).Id
                ,Role__c = 'ISM'
                ,IsActive__c = true
                ,Zipcode__c = '11111'
            ),
            new Zip_Code_Area_Assignment__c(
                Account_Owner__c = users.get(1).Id
                ,Role__c = 'ROM'
                ,IsActive__c = true
                ,Zipcode__c = '11111'
            ),
            new Zip_Code_Area_Assignment__c(
                Account_Owner__c = users.get(2).Id
                ,Role__c = 'TSM'
                ,IsActive__c = true
                ,Zipcode__c = '11111'
            ),
            new Zip_Code_Area_Assignment__c(
                Account_Owner__c = users.get(3).Id
                ,Role__c = 'BTB'
                ,IsActive__c = true
                ,Zipcode__c = 'CA'
            )
        };
        insert zaacs;
    }

    private static void createRoles(){
        List<Lead_Assignment_Role__c> roles = new List<Lead_Assignment_Role__c>{
            new Lead_Assignment_Role__c(
                Name='ISM'
                ,Lead_Role_Field__c = 'ISM_Sales_Rep__c'
            ),
            new Lead_Assignment_Role__c(
                Name = 'TSM'
                ,Lead_Role_Field__c = 'TSM_Sales_Rep__c'
            ),
            new Lead_Assignment_Role__c(
                Name ='ROM'
                ,Lead_Role_Field__c = 'ROM_Sales_Rep__c'
            ),
            new Lead_Assignment_Role__c(
                Name = 'BTB'
                ,Lead_Role_Field__c = 'BTB_Sales_Rep__c'
            )
        };
        insert roles;
    }

    private static List<User> createUsers(){
        Id pId = [Select Id From Profile Where Name = 'System Administrator'].Id;

        List<User> users = new List<User>{
            new User(
                Email = 'testymctesterton1@redwingshoes.com'
                ,Username = 'testymctesterton1@redwingshoes.com'
                ,Alias = 'testy'
                ,LanguageLocaleKey = 'en_US'
                ,LocaleSidKey = 'en_US'
                ,TimezoneSidKey = 'America/Chicago'
                ,EmailEncodingKey = 'UTF-8'
                ,FirstName = 'Testy'
                ,LastName = 'McTesterton'
                ,ProfileId = pId
                ,Street = '123 1st Ave'
                ,City = 'Red Wing'
                ,State = 'MN'
                ,PostalCode = '11111'
                ,Country = 'US'
            ),
            new User(
                Email = 'testymctesterton2@redwingshoes.com'
                ,Username = 'testymctesterton2@redwingshoes.com'
                ,Alias = 'testy'
                ,LanguageLocaleKey = 'en_US'
                ,LocaleSidKey = 'en_US'
                ,TimezoneSidKey = 'America/Chicago'
                ,EmailEncodingKey = 'UTF-8'
                ,FirstName = 'Testy'
                ,LastName = 'McTesterton'
                ,ProfileId = pId
                ,Street = '123 1st Ave'
                ,City = 'Red Wing'
                ,State = 'MN'
                ,PostalCode = '11111'
                ,Country = 'US'
            ),
            new User(
                Email = 'testymctesterton3@redwingshoes.com'
                ,Username = 'testymctesterton3@redwingshoes.com'
                ,Alias = 'testy'
                ,LanguageLocaleKey = 'en_US'
                ,LocaleSidKey = 'en_US'
                ,TimezoneSidKey = 'America/Chicago'
                ,EmailEncodingKey = 'UTF-8'
                ,FirstName = 'Testy'
                ,LastName = 'McTesterton'
                ,ProfileId = pId
                ,Street = '123 1st Ave'
                ,City = 'Red Wing'
                ,State = 'MN'
                ,PostalCode = '11111'
                ,Country = 'US'
            ),
            new User(
                Email = 'testymctesterton4@redwingshoes.com'
                ,Username = 'testymctesterton4@redwingshoes.com'
                ,Alias = 'testy'
                ,LanguageLocaleKey = 'en_US'
                ,LocaleSidKey = 'en_US'
                ,TimezoneSidKey = 'America/Chicago'
                ,EmailEncodingKey = 'UTF-8'
                ,FirstName = 'Testy'
                ,LastName = 'McTesterton'
                ,ProfileId = pId
                ,Street = '123 1st Ave'
                ,City = 'Red Wing'
                ,State = 'MN'
                ,PostalCode = '11111'
                ,Country = 'US'
            )
        };

        insert users;
        return users;
    }

    static testmethod void testLeadStatesOnInsert(){
        List<User> users = createUsers();

        Test.startTest();
        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 200; i++){
            String country = (Math.mod(i,3) == 1) ? 'US' : null;
            country = (Math.mod(i,3) == 2) ? 'USA' : country;
            leads.add(new Lead(Firstname='First',Lastname='Last',PostalCode='11111-111111',OwnerId=users.get(1).Id,Country=country,State='Minnesota'));
        }
        insert leads;
        Test.stopTest();

        leads = [Select State From Lead];
        System.assertEquals(200,leads.size());
        for(Lead l : leads){
            System.assertEquals('MN',l.State);
        }
    }

    static testmethod void testLeadStatesOnUpdate(){
        List<User> users = createUsers();

        List<Lead> leads = new List<Lead>();
        for(Integer i=0; i < 200; i++){
            String country = (Math.mod(i,3) == 1) ? 'US' : null;
            country = (Math.mod(i,3) == 2) ? 'USA' : country;
            leads.add(new Lead(Firstname='First',Lastname='Last',PostalCode='11111-111111',OwnerId=users.get(1).Id,Country=country,State='Minnesota'));
        }
        insert leads;

        Test.startTest();
        for(Integer i=0; i < 200; i++){
            leads.get(i).State = 'minnesota';
        }
        update leads;
        Test.stopTest();

        leads = [Select State From Lead];
        System.assertEquals(200,leads.size());
        for(Lead l : leads){
            System.assertEquals('MN',l.State);
        }
    }
}