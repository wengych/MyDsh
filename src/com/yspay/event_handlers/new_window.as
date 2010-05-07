// ActionScript file
package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.renderers.PopUpNamePanel;
    import com.yspay.YsPod;

    import mx.core.UIComponent;
    import mx.core.Container;
    import mx.managers.PopUpManager;

    public function new_window(ui_comp:UIComponent):void
    {
        var ys_pod:YsPod = EventHandlerFactory.GetParentYsPod(ui_comp.parent as Container);

        var new_popName:PopUpNamePanel = new PopUpNamePanel;
        new_popName.parentYsPod = ys_pod;

        PopUpManager.addPopUp(new_popName, ys_pod, true, null);
        PopUpManager.centerPopUp(new_popName);
    }
}