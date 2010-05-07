// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.events.EventPodShowXml;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.DBTableQueryEvent;
    import com.yspay.pool.Query;

    import mx.controls.Button;
    import mx.controls.listClasses.ListBase;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.DragEvent;

    public function new_window(e:DragEvent, ui_comp:UIComponent):void
    {
        var func:Function = function(event:DBTableQueryEvent):void
            {
                var dts:DBTable = Application.application._pool.dts as DBTable;
                var temp:String = dts[event.query_name][dts.arg_select];
                ui_comp.removeEventListener(dts.select_event_name, func);

                // addFormItem(arg);

                var e:EventPodShowXml = new EventPodShowXml(new XML(temp));
                ui_comp.dispatchEvent(e);
            };

        var o:Object = (e.dragInitiator as ListBase).selectedItem;
        var dts:DBTable = Application.application._pool.dts as DBTable;


        dts.AddQuery(o.DTS, Query, o.DTS, ui_comp);
        ui_comp.addEventListener(dts.select_event_name, func);
        dts.DoQuery(o.DTS);
    }
}
