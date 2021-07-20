trigger AccountTrigger on Account (after insert, after update) {
    
    public List<Account> updatedAccounts = Trigger.new;
    if(trigger.isAfter){
        Map<Id,Account> mapOfOldValues = trigger.oldMap;
        Map<Id,Id> accountWithOnboardingTemplateIDs = new Map<Id,Id>();
        for(Account updated_Account : updatedAccounts) {
            if(updated_Account.Onboarding_Plan__c != null)
            {
                if(mapOfOldValues == null){
                    accountWithOnboardingTemplateIDs.put(updated_Account.Id, updated_Account.Onboarding_Plan__c);
                } else {
                    if(updated_Account.Onboarding_Plan__c != mapOfOldValues.get(updated_Account.Id).Onboarding_Plan__c)
                        accountWithOnboardingTemplateIDs.put(updated_Account.Id, updated_Account.Onboarding_Plan__c);
                }
            }
        } //End For
        
        if(accountWithOnboardingTemplateIDs.size() > 0){
            OnboardingPlanService.updateContactsWithOndbPlan(accountWithOnboardingTemplateIDs);
        }
    }

}