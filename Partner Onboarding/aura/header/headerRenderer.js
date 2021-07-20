({
    afterRender: function(component) {
        this.superAfterRender();
        
        var backgroundStyle = component.get('v.backgroundStyle');
        console.log('backgroundStyle', backgroundStyle, component.getElement());
        if (backgroundStyle) {
            component.getElement().style.background = backgroundStyle;
        }
    }
})