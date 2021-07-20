({
	fireAction : function(component, event, helper) {
        
		var actionType = component.get('v.task').Ptnr_Onbd_Fmwk__TemplateTask__r.Ptnr_Onbd_Fmwk__Action_Type__c;
        var actionParams = component.get('v.task').Ptnr_Onbd_Fmwk__TemplateTask__r.Ptnr_Onbd_Fmwk__Action_Params__c;
        
        if (actionType) {
            if (actionType == 'Link') {
                var evt = $A.get("e.force:navigateToURL");
                evt.setParams({
                    url: actionParams
                });
                evt.fire();
            } else if (actionType == 'Navigate to Object') {
				var evt = $A.get("e.force:navigateToSObject");
                evt.setParams({
                    recordId: actionParams
                });
                evt.fire();                
            } else if (actionType == 'Create Record') {
                var evt = $A.get("e.force:createRecord");
                evt.setParams({
                    entityApiName: actionParams
                });
                evt.fire();
            } else if (actionType == 'Display Video') {
                // Set Allow Fullscreen
                var url = component.get('v.task').Ptnr_Onbd_Fmwk__TemplateTask__r.Ptnr_Onbd_Fmwk__Action_Params__c;
                if (url) {
                    component.set('v.displayVideo', true);
                    setTimeout(function() {
                        component.find('iFrame').getElement().setAttribute('src', helper.sanitizeUrl(url));
                        component.find('iFrame').getElement().setAttribute('allowFullscreen', 'allowFullscreen');
                    }, 0);   
                }
            }
        }
        
        if (component.get('v.task').Ptnr_Onbd_Fmwk__TemplateTask__r.Ptnr_Onbd_Fmwk__Complete_Task_When_Action_clicked__c) {
            var action = component.get('c.completeTask');
            action.setParams({ taskId: component.get('v.task').Id });
            
            action.setCallback(this, function(result) {
                var status = result.getState();
                if (status == 'SUCCESS') {
                    component.getEvent('onComplete').fire({
                        value: component.get('v.task').Id
                    });
                    setTimeout(function() {
                        helper.setStatusColors(component);
                    }, 100);
                } else {
                    console.error(response.getError())
                }
            })
            
            $A.enqueueAction(action);
        }
	},
    
    closeVideo: function(component, event, helper) {
		component.set('v.displayVideo', false);
    }
})