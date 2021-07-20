({
	init : function(component, event, helper) {
		helper.getChannelMgrDetails(component, helper);
	},
    
    close: function(component, event, helper) {
        component.getEvent('onClose').fire();
    }
})