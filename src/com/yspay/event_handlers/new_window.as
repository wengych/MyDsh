// ActionScript file
package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.renderers.PopUpNamePanel;
    import com.yspay.YsPod;

    import mx.core.Container;
    import mx.managers.PopUpManager;

    public function new_window(wnd:Object, event_container:Container):void
    {
        var new_popName:PopUpNamePanel = new PopUpNamePanel;
        new_popName.parentYsPod = wnd as YsPod;

        PopUpManager.addPopUp(new_popName, wnd as YsPod, true, null);
        PopUpManager.centerPopUp(new_popName);
    }
}