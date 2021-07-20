public with sharing class OnboardingService {
	
    @AuraEnabled
    public static List<Planned_Onboarding_Tasks__c> replaceParams(List<Planned_Onboarding_Tasks__c> tasks, User u) {
        for (Planned_Onboarding_Tasks__c task : tasks) {
            if (task.TemplateTask__r != null) {
                if (task.TemplateTask__r.Action_Params__c != null) {
                    if (task.TemplateTask__r.Action_Params__c.contains('{! User.Id }')) {
                        task.TemplateTask__r.Action_Params__c = task.TemplateTask__r.Action_Params__c.replace('{! User.Id }', u.Id);
                    }   
                }    
            }
            
        }
        
        return tasks;
    }
    
    public static Boolean checkFieldAccessibility() {
        return (
            Schema.sObjectType.Planned_Onboarding_Tasks__c.isAccessible() &&
            Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.TemplateTask__c.isAccessible() &&
			Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Computed_Status__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Category__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Description__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Image_Name__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Button_Label__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Seq__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Action_Type__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Action_Params__c.isAccessible() &&
            Schema.sObjectType.Onboarding_Tasks__c.fields.Complete_Task_When_Action_clicked__c.isAccessible()
        );
    }
    
    @AuraEnabled
    public static List<Planned_Onboarding_Tasks__c> getTasksForContact() {
        
        List<Planned_Onboarding_Tasks__c> results 
            = new List<Planned_Onboarding_Tasks__c>();
        
        if (checkFieldAccessibility()) {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if (users.size() > 0) {
                results = [
                    SELECT 
                    Id, 
                    TemplateTask__r.Category__c, 
                    TemplateTask__r.Description__c,
                    Computed_Status__c,
                    TemplateTask__r.Image_Name__c,
                    TemplateTask__r.Button_Label__c,
                    TemplateTask__r.Seq__c,
                    TemplateTask__r.Action_Type__c,
                    TemplateTask__r.Action_Params__c,
                    TemplateTask__r.Complete_Task_When_Action_clicked__c
                    FROM 
                    Planned_Onboarding_Tasks__c
                    WHERE 
                    Assigned_To__c = :users.get(0).ContactId
                    ORDER BY Seq__c ASC ];
                
                results = replaceParams(results, users[0]);
            }    
        }
            
        return results;
    }
    
    @AuraEnabled
    public static void completeTask(Id taskId) {
        if (Schema.sObjectType.Planned_Onboarding_Tasks__c.isUpdateable()) {
            if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Status__c.isUpdateable()) {
                if (taskId != null) {
                    Planned_Onboarding_Tasks__c task = new Planned_Onboarding_Tasks__c(
                        Id = taskId, 
                        Status__c = 'Completed');
                    update task;    
                }   
            }
        }
    }
    
    /**
	  * Finds the Id of the channel manager of the curren user
		* returns null if the user is not a portal user
		* @return Id of channel manager
	*/
	@TestVisible
	private static Id getChannelManager() {
		User u = [
		SELECT Contact.Account.OwnerId
		FROM User
		WHERE Id = :UserInfo.getUserId()];

		if (u.Contact != null) {
			if (u.Contact.Account != null) {
				return u.Contact.Account.OwnerId;
			}
		}

		return null;
	}
    
    @AuraEnabled
    public static ConnectApi.UserProfile getUserProfile() {
        return ConnectApi.UserProfiles.getUserProfile(Network.getNetworkId(), getChannelManager());
    }
     
    @AuraEnabled
    public static String getUserDetails() {
        return UserInfo.getFirstName();
    }
}