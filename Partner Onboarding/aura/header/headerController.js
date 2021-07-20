({
	init: function(component, event, helper) {
        helper.findUserDetails(component, helper);
		helper.calculateCompletion(component, helper);
    },
    
    showPopover: function(component, event, helper) {
        component.set('v.showPopover', !component.get('v.showPopover'))
    }
})