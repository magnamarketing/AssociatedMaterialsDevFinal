/**
 * Created by SentientGrey on 2019-08-01.
 */
({
    doInit : function(component, event, helper)
    {
       /* var url = component.get('v.redirectUrl');
        var openInNewTab = false;
        //console.log('url: ' + url);
        if(url != null && url.length > 0 && url.startsWith('http'))
        {
            openInNewTab = true;
        }
        component.set('v.openInNewTab', openInNewTab);*/
        component.set('v.bgc', component.get('v.backgroundColor'));
    },
    setHover : function(component, event, helper)
    {
        var hover = component.get('v.hoverColor');
        if(hover != null && hover.length > 0)
        {
           component.set('v.bgc', hover);
        }
    },
    removeHover : function(component, event, helper)
    {
        component.set('v.bgc', component.get('v.backgroundColor'));
    },
    redirect : function(component, event, helper)
    {
        var navUrl = component.get('v.redirectUrl');
        var newTab = component.get('v.openInNewTab');
        if(navUrl != null && navUrl.length > 0)
        {
            if(newTab)
            {
                window.open(navUrl);
            }
            else
            {
                var nav = $A.get('e.force:navigateToURL');
                nav.setParams({
                    'url' : navUrl
                });
                nav.fire();
            }
        }
    },
});