({
    afterRender: function(component, helper) {
        this.superAfterRender();
        
        helper.setStatusColors(component);
    }
})