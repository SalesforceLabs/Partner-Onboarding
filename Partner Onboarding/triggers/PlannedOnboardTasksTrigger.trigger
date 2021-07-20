trigger PlannedOnboardTasksTrigger on Planned_Onboarding_Tasks__c (after insert, after update) {
    
    Set<Id> contactIdsForWhichStatusShouldBeUpdatedToInProgress = new Set<Id>();
    Set<Id> contactIdsForWhichStatusShouldBeUpdatedToCompleted = new Set<Id>();
    
    for (Planned_Onboarding_Tasks__c task : Trigger.New) {
        if (task.Status__c == 'In Progress') {
            contactIdsForWhichStatusShouldBeUpdatedToInProgress.add(task.Assigned_To__c);
        } else if (task.Status__c == 'Completed') {
            contactIdsForWhichStatusShouldBeUpdatedToCompleted.add(task.Assigned_To__c);
        }
    }
    
    if (contactIdsForWhichStatusShouldBeUpdatedToInProgress.size() > 0) {
        List<Contact> contactsForWhichStatusShouldBeUpdatedToInProgress = new List<Contact>();
        for (Id contactId : contactIdsForWhichStatusShouldBeUpdatedToInProgress) {
            Contact c = new Contact(Id = contactId, Onboarding_Status__c = 'In Progress');
            contactsForWhichStatusShouldBeUpdatedToInProgress.add(c);
        }
        
        update contactsForWhichStatusShouldBeUpdatedToInProgress;
    }
    
    if (contactIdsForWhichStatusShouldBeUpdatedToCompleted.size() > 0) {
        List<Contact> contactsForWhichStatusShouldBeUpdatedToCompleted = new List<Contact>();
        
        List<Contact> contactWithInProgressOrNotStartedTasks = [
            Select 
            	Id, 
            	(Select 
                 	Id 
                 FROM 
                 	Planned_Onboarding_Tasks__r 
                 WHERE Status__c != 'Completed') 
            FROM 
            	Contact 
            WHERE Id IN :contactIdsForWhichStatusShouldBeUpdatedToCompleted];
        
        Set<Id> contactIdsForContactsWithInProgressTasks = new Set<Id>();
        for (Contact c : contactWithInProgressOrNotStartedTasks) {
            if (c.Planned_Onboarding_Tasks__r != null) {
                if (c.Planned_Onboarding_Tasks__r.size() > 0) {
                    contactIdsForContactsWithInProgressTasks.add(c.Id);
                }
            }
        }
        
        for (Id contactId : contactIdsForWhichStatusShouldBeUpdatedToCompleted) {
            Contact c;
            if (!contactIdsForContactsWithInProgressTasks.contains(contactId)) {
                c = new Contact(Id = contactId, Onboarding_Status__c = 'Completed');
            } else {
                c = new Contact(Id = contactId, Onboarding_Status__c = 'In Progress');
            }
            
			contactsForWhichStatusShouldBeUpdatedToCompleted.add(c);
        }
        
        if (contactsForWhichStatusShouldBeUpdatedToCompleted.size() > 0)
        	update contactsForWhichStatusShouldBeUpdatedToCompleted;
    }
}