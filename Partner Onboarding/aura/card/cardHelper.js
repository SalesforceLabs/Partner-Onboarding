({
	setStatusColors : function(component) {
		// Set color
        var statusElement = component.getElement().querySelector('.status');
        var status = component.get('v.task').Status;

        if (statusElement) {
            if (status == 'InProgress') {
                statusElement.style.backgroundColor = component.get('v.inprogressColor');
            } else if (status == 'Completed') {
                statusElement.style.backgroundColor = component.get('v.completedColor');
            } else if (status == 'Due') {
                statusElement.style.backgroundColor = component.get('v.dueColor');
            } else if (status == 'Overdue') {
                statusElement.style.backgroundColor = component.get('v.overdueColor');
            }
        }
	},
    sanitizeUrl : function(url) {
        if (url.length > 5) {
            return url.substring(0, 5) == 'https' ? url : '/' + url;
        } else {
            return '/' + url;
        }
    }
})