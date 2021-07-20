public class OnboardingPlanService {
    
    public static void createOnboardingTasks(Map<Id,Id> contactsIDswithTemplateIDs)
    {
        List<Planned_Onboarding_Tasks__c> contactTasks = new List<Planned_Onboarding_Tasks__c>();
        List<Onboarding_Tasks__c> tasksToInsert = [SELECT 
                                                                   Name,
                                                                   Category__c,
                                                                   Description__c,
                                                                   Duration_in_Days__c,
                                                                   Onboarding_Plan__c,
                                                                   Seq__c,
                                                                   Which_roles_is_this_task_for__c
                                                                   FROM Onboarding_Tasks__c
                                                                   WHERE Onboarding_Plan__r.Id IN:contactsIDswithTemplateIDs.values()];
        
        List<Contact> ContactsToUpdate = [SELECT Name,
                                          Onboarding_Plan__c,
                                          Account.Onboarding_Plan__c,
                                          Role_Function__c,
                                          Id
                                          FROM CONTACT
                                          WHERE ID IN :contactsIDswithTemplateIDs.keySet()];
        
        
        for(Contact con : ContactsToUpdate){
            
            if (Schema.sObjectType.Contact.fields.Onboarding_Plan__c.isUpdateable()) {
            	con.Onboarding_Plan__c = con.account.Onboarding_Plan__c;
            }
            
            for(Onboarding_Tasks__c t : tasksToInsert) {
                 
                String role = con.Role_Function__c;
                System.debug('************ROLE IS***********'+role);
                
                if(con.Role_Function__c == null 
                   || t.Which_roles_is_this_task_for__c.contains(role)
                   || t.Which_roles_is_this_task_for__c.contains('All')){
                       Planned_Onboarding_Tasks__c pt = new Planned_Onboarding_Tasks__c();
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Assigned_To__c.isUpdateable()) {
                       		pt.Assigned_To__c = con.Id;    
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Category__c.isUpdateable()) {
                           pt.Category__c = t.Category__c;
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Description__c.isUpdateable()) {
                           pt.Description__c = t.Description__c;
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Duration_in_Days__c.isUpdateable()) {
                           pt.Duration_in_Days__c = t.Duration_in_Days__c;
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.TemplateTask__c.isUpdateable()) {
                           pt.TemplateTask__c = t.Id;
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.fields.Seq__c.isUpdateable()) {
                           pt.Seq__c = t.Seq__c;                             
                       }
                       
                       if (Schema.sObjectType.Planned_Onboarding_Tasks__c.isCreateable()) {
                       	   contactTasks.add(pt);
                       }
                   }                
            }
        }
        
        if (Schema.sObjectType.Planned_Onboarding_Tasks__c.isCreateable()) {
        	if (contactTasks.size() > 0) {
            	insert contactTasks;        
            }
        }
    }
    
    public static void updateContactsWithOndbPlan(Map<Id,Id> accountWithTemplateIDs)
    {
        
        List<Contact> AccountContacts = [SELECT Name,
                                         Onboarding_Plan__c,
                                         Account.Onboarding_Plan__c,
                                         Id
                                         FROM CONTACT
                                         WHERE AccountID IN :accountWithTemplateIDs.keySet()];
        
        
        for(Contact con : AccountContacts){
            con.Onboarding_Plan__c = con.account.Onboarding_Plan__c;
            con.Onboarding_Status__c = 'Not Started';
        }
        
        if (Schema.sObjectType.Contact.isUpdateable()) {
        	update AccountContacts;    
        }
    }      
}