// ActionScript file
package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.events.PodStateChangeEvent;
    import com.yspay.YsControls.YsPod;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.UIComponent;

    public function close_pod(ui_comp:UIComponent,
                              source_event:Event,
                              action_info:XML):Boolean
    {
        var ys_pod:YsPod = UtilFunc.YsGetParentByType(ui_comp, YsPod) as YsPod;

        if (ys_pod == null)
        {
            trace('取pod出错');
            return false;
        }

        ys_pod.dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.CLOSE));
        return true;
    }
}
