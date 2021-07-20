@isTest
public class TestOnboardingService {

		public static Id createUserRole() {
			UserRole ur = new UserRole(Name = 'CEO');
			insert ur;

			return ur.Id;
		}

		public static User createStandardUser(String profile) {
			User u = new User(
					ProfileId = [SELECT Id FROM Profile WHERE Name = :profile].Id,
					LastName = 'Test',
					Email = 'test@onboarding.com',
					Username = 'test@onboarding.com' + System.currentTimeMillis(),
					CompanyName = 'TEST',
					Title = 'title',
					Alias = 'alias',
					TimeZoneSidKey = 'America/Los_Angeles',
					EmailEncodingKey = 'UTF-8',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					UserRoleId = createUserRole()
			);

			return u;
		}

    public static User createPartnerCommunityUser() {
        Account a = new Account(name = 'Community Account');
        insert a;

        Contact c = new Contact(LastName = 'CommunityAccessTest', AccountId = a.Id);
        insert c;

        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner Community User'].Id,
            LastName = 'Test',
            Email = 'test@onboarding.com',
            Username = 'test@onboarding.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId = c.Id
        );

        insert u;
        
        return u;
    }
	
    public static void createPermissionSet(Id userId) {
        List<PermissionSet> permissions = [SELECT Id FROM PermissionSet WHERE Name = 'Onboarding_Access'];
        
        if (permissions.size() > 0) {
        	PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetId = permissions[0].Id,
            	AssigneeId = userId);
            insert assignment;
        }
    }
    
    @isTest
    public static void getTasksForContact_WhenNoTasksExist_ReturnsEmptyArray() {

        User u = createPartnerCommunityUser();
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
           createPermissionSet(u.Id);
        }
        
        List<Planned_Onboarding_Tasks__c> result;

        Test.startTest();

        System.runAs(u) {
            result = OnBoardingService.getTasksForContact();
        }

        Test.stopTest();

        System.assertEquals(0, result.size());
    }

    @isTest
    public static void getTasksForContact_WhenTasksExistForContact_ReturnsArrayOfTasks() {

        User u = createPartnerCommunityUser();
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
           createPermissionSet(u.Id);
        }
        
        Planned_Onboarding_Tasks__c task1 =
            new Planned_Onboarding_Tasks__c(Assigned_To__c = u.ContactId);
        insert task1;

        List<Planned_Onboarding_Tasks__c> result;

        Test.startTest();

        System.runAs(u) {
            result = OnBoardingService.getTasksForContact();
        }

        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    @isTest
    public static void getTasksForContact_WhenTaskIsCompleted_IncludeTask() {

        User u = createPartnerCommunityUser();
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
           createPermissionSet(u.Id);
        }
        
        Planned_Onboarding_Tasks__c task1 =
            new Planned_Onboarding_Tasks__c(
                Assigned_To__c = u.ContactId,
                Status__c = 'Completed');

        insert task1;

        List<Planned_Onboarding_Tasks__c> result;

        Test.startTest();

        System.runAs(u) {
            result = OnBoardingService.getTasksForContact();
        }

        Test.stopTest();

        System.assertEquals(1, result.size());
    }
    
    @isTest
    public static void completeTask_updateStatustoCompleted(){
        User u = createPartnerCommunityUser();
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
           createPermissionSet(u.Id);
        }
        
        Planned_Onboarding_Tasks__c task1 =
            new Planned_Onboarding_Tasks__c(
                Assigned_To__c = u.ContactId,
                Status__c = 'In Progress');

        insert task1;
        
        Test.startTest();

        System.runAs(u) {
            OnBoardingService.completeTask(task1.Id);
        }

        Test.stopTest();
        
        Planned_Onboarding_Tasks__c t = [SELECT Status__c, ID FROM 
                                                         Planned_Onboarding_Tasks__c
                                                         WHERE ID =:task1.Id];
        System.assertEquals('Completed', t.Status__c);
    }
}