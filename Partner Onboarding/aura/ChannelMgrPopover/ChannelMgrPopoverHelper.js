({
	getChannelMgrDetails : function(component, helper) {
		var action = component.get('c.getUserProfile');
        
        action.setCallback(this, function(result) {
            if (result.getState() == 'SUCCESS') {
                console.log(result.getReturnValue());
                if (result.getReturnValue()) {
                    component.set('v.fullName', result.getReturnValue().userDetail.displayName);
                    component.set('v.email', result.getReturnValue().userDetail.email);
                    component.set('v.photoUrl', result.getReturnValue().userDetail.photo.largePhotoUrl);
                    component.set('v.profileURL', 'profile/' + result.getReturnValue().id)
                    
                    if (result.getReturnValue().userDetail.phoneNumbers) {
                        if (result.getReturnValue().userDetail.phoneNumbers.length > 0) {
                            component.set('v.phone', result.getReturnValue().userDetail.phoneNumbers[0].phoneNumber);
                        }
                    }
                }
            } else {
                console.error(result.getError());
            }
        });
        
        $A.enqueueAction(action);
	}
})