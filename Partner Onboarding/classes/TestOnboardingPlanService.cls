@isTest
public class TestOnboardingPlanService {
    
    public static User createPartnerUser() {
        
        Account a = new Account(name = 'Partner Account');
        insert a;
        
        Contact c = new Contact(LastName = 'PartnerTest', AccountId = a.Id , Role_Function__c = 'All');
        insert c;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id,
            LastName = 'Test',
            Email = 'test@partneronboarding.com',
            Username = 'test@partneronboarding.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'ptobrd',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = c.Id
            
        );
        
        insert u;
        
        return u;
    } //End
    
    public static testmethod void updateContactsWithOndbPlan_whenObPlanAddedtoAccount() {
        User partneruser = createPartnerUser();
        
        // Test Setup
        Contact partnerCon = [SELECT NAME, ACCOUNTID FROM CONTACT WHERE ID =:partneruser.ContactId];
        Onboarding__c obplan = new Onboarding__c(Name = 'TEST PLAN', Status__c = 'Active');
        insert obplan;
        Account partnerAccount = [SELECT NAME, 
                                  Onboarding_Plan__c 
                                  FROM ACCOUNT
                                  WHERE ID = :partnerCon.AccountId];
        partnerAccount.Onboarding_Plan__c = obplan.id;
        update partnerAccount;
        
        Map<Id,Id> accountwithtemplateID = new Map<Id,Id>();
        accountwithtemplateID.put(partnerAccount.Id, obplan.id);
        
        //Run test
        Test.startTest();
        
        System.runAs(partneruser){
            OnboardingPlanService.updateContactsWithOndbPlan(accountwithtemplateID);
        }
        
        Test.stopTest();
        
        //Assert
        List<Contact> con = [SELECT Role_Function__c,
                             Onboarding_Plan__c, 
                             ID
                             FROM CONTACT 
                             WHERE ACCOUNTID =:PARTNERACCOUNT.ID];
        System.assertEquals(obplan.id, con[0].Onboarding_Plan__c);
    }
    
    public static testmethod void createOnboardingTasks_forContactsafterOBPlanAssociated(){
        User partneruser = createPartnerUser();
        //Test Setup
        Contact partnerCon = [SELECT NAME, Role_Function__c, ACCOUNTID FROM CONTACT WHERE ID =:partneruser.ContactId];
        
        Onboarding__c obplan = new Onboarding__c(Name = 'TEST PLAN', Status__c = 'Active');
        insert obplan;
        
        Onboarding_Tasks__c otask = new Onboarding_Tasks__c(Category__c = 'Category1',
                                                                                      Description__c = 'Test1',
                                                                                      Onboarding_Plan__c = obplan.Id,
                                                                                      Seq__c = 1);
        insert otask;
        
        Account partnerAccount = [SELECT NAME, 
                                  Onboarding_Plan__c 
                                  FROM ACCOUNT
                                  WHERE ID = :partnerCon.AccountId];
        partnerAccount.Onboarding_Plan__c = obplan.id;
        update partnerAccount;
        
        Map<Id,Id> accountwithtemplateID = new Map<Id,Id>();
        accountwithtemplateID.put(partnerAccount.Id, obplan.id);
 		
        Map<Id,Id> contactwithtemplateID = new Map<Id,Id>();
        contactwithtemplateID.put(partnercon.Id, obplan.id);
        
        // Run Test
        Test.startTest();
        OnboardingPlanService.createOnboardingTasks(contactwithtemplateID);
        Test.stopTest();
        
        // Assert
        List<Planned_Onboarding_Tasks__c> conTasks = [SELECT Category__c, Assigned_To__c
                                                                      FROM Planned_Onboarding_Tasks__c
                                                                      WHERE Assigned_To__c = :partnerCon.Id];
        
        System.assertEquals(2, conTasks.size());
        System.assertEquals('All', partnerCon.Role_Function__c);
       	
    }
    
    public static void defaultOnboardingStatus_WhenOnboardingPlanIsAttachedToNewContact_IsSetToNotStarted() {
        Account a = new Account(Name = 'Test');
        insert a;
        
        Onboarding__c obplan = new Onboarding__c(Name = 'TEST PLAN', Status__c = 'Active');
        insert obplan;
        
        Onboarding_Tasks__c otask = new Onboarding_Tasks__c(Category__c = 'Category1',
                                                                                      Description__c = 'Test1',
                                                                                      Onboarding_Plan__c = obplan.Id,
                                                                                      Seq__c = 1);
        insert otask;
        
        Test.startTest();
        
        Contact c = new Contact(LastName = 'Test', Onboarding_Plan__c = obplan.Id, Onboarding_Status__c = '');
        insert c;
        
        Test.stopTest();
        
        System.assertEquals('Not Started', c.Onboarding_Status__c);
    }
	
    public static void defaultOnboardingStatus_WhenOnboardingPlanIsAttachedToExistingContact_IsSetToNotStarted() {
        Account a = new Account(Name = 'Test');
        insert a;
        
        Onboarding__c obplan = new Onboarding__c(Name = 'TEST PLAN', Status__c = 'Active');
        insert obplan;
        
        Onboarding_Tasks__c otask = new Onboarding_Tasks__c(Category__c = 'Category1',
                                                                                            Description__c = 'Test1',
                                                                                            Onboarding_Plan__c = obplan.Id,
                                                                                            Seq__c = 1);
        
        Contact c = new Contact(LastName = 'Test', Onboarding_Status__c = '');
        insert c;
        
        insert otask;
        
        Test.startTest();
        
        c.Onboarding_Plan__c = obplan.Id;
        update c;
        
        Test.stopTest();
        
        System.assertEquals('Not Started', c.Onboarding_Status__c);
    } 
}