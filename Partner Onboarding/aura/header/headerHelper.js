({
	calculateCompletion : function(component, helper) {
		var action = component.get('c.getTasksForContact');
        
        action.setStorable(true);
        
        action.setCallback(this, function(result) {
            var status = result.getState();
            if (status == 'SUCCESS') {
                
                var tasks = result.getReturnValue();
                if (tasks) {
                	var totalTasks = tasks.length;
                    var completedTasks = tasks.filter(function(task) {
                        return task.Ptnr_Onbd_Fmwk__Computed_Status__c == 'Completed';
                    }).length;
                    
                    var actualPercent = (completedTasks / totalTasks) * 100;
                    var total_time = 700;
                    var tickInterval = 30;
                    var deltaGain = (actualPercent / total_time) * tickInterval;
                    var timeElapsed = 0;
                    
                    function startCountdown() {
                        var clock = setTimeout($A.getCallback(function() {
                            timeElapsed += tickInterval;
                            var currentValue = parseInt(component.get('v.percent'));
                            if (timeElapsed > total_time) {
                                component.set('v.percent', parseInt(actualPercent));
                                clearInterval(clock);
                            } else {
                                component.set('v.percent', parseInt(currentValue + deltaGain));
                            	startCountdown(); 
                            }
                        }), tickInterval);
                    }
                    
                    startCountdown();
                }
                
                
            } else {
                console.error(response.getError());
            }
		});
     	
        $A.enqueueAction(action);
	},
    
    findUserDetails : function(component, helper) {
        var action = component.get('c.getUserDetails');
        
        action.setStorable(true);
        
        action.setCallback(this, function(result) {
            var status = result.getState();
            if (status == 'SUCCESS') {
                component.set('v.username', result.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})