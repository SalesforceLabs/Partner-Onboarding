trigger ContactTrigger on Contact (before insert, before update, after insert,after update) {

    public List<Contact> updatedContacts = trigger.new;
    Map<Id,Contact> contactOldValues = trigger.oldMap;
    
    if(trigger.isAfter){
        Map<Id,Id> contactsIDswithTemplateIDs = new Map<Id,Id>();
        for(Contact c : updatedContacts) {
            if(c.Onboarding_Plan__c != null) {
                if(contactOldValues == null){
                    contactsIDswithTemplateIDs.put(c.Id, c.Onboarding_Plan__c);
                } else {
                    if(contactOldValues.get(c.Id).Onboarding_Plan__c == null) {
                        contactsIDswithTemplateIDs.put(c.Id, c.Onboarding_Plan__c);
                    }
                }
            }
        } //End for
        
        if(contactsIDswithTemplateIDs.size() > 0) {
            OnboardingPlanService.createOnboardingTasks(contactsIDswithTemplateIDs);
        }
    } else if(trigger.isBefore){
        
        for(Contact c : Trigger.New) {
            if(c.Onboarding_Plan__c != null) {
                if(contactOldValues == null){
                    c.Onboarding_Status__c = 'Not Started';
                } else {
                    if(contactOldValues.get(c.Id).Onboarding_Plan__c == null) {
                        c.Onboarding_Status__c = 'Not Started';
                    }
                }
            }
        }
    }
}