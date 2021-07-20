({
	init : function(component, event, helper) {
		var action = component.get('c.getTasksForContact');
        
        action.setStorable(true);
        
        action.setCallback(this, function(result) {
            var status = result.getState();
            if (status == 'SUCCESS') {
                
                var tasks = result.getReturnValue();
                
                if (tasks) {
                    console.log('Tasks Result', tasks);
                    tasks = tasks.map(function(task, i) {
                        return Object.assign(task, {
                            Seq: i + 1,
                            Status : task.Ptnr_Onbd_Fmwk__Computed_Status__c.replace(/\s+/g, '') 
                        });
                    });
                    
                    component.set('v.tasks', tasks);  
                }
                
                //console.log('Tasks Result', tasks);
            } else {
                console.error(response.getError());
            }
        });
        
        $A.enqueueAction(action);
	},
    
    taskCompleted: function(component, event, helper) {
        if (event.getParam('value')) {
            var tasks = component.get('v.tasks');
            component.set('v.tasks', tasks.map(function(task) {
                if (task.Id == event.getParam('value')) {
                    task.Status = 'Completed';
                    task.Ptnr_Onbd_Fmwk__Computed_Status__c = 'Completed';
                }
                
                return task;
            }));  
        }
    }
})