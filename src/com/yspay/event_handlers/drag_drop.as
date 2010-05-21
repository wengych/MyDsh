// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.EventCache;
    import com.yspay.YsControls.*;
    import com.yspay.events.EventButtonAddAction;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventDragToDatagrid;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.DBTableQueryEvent;
    import com.yspay.pool.Query;

    import flash.events.Event;

    import mx.controls.listClasses.ListBase;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.DragEvent;

    public function drag_drop(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var get_dts_func:Function = function(event:DBTableQueryEvent):void
            {
                var dts:DBTable = Application.application._pool.dts as DBTable;
                ui_comp.removeEventListener(dts.select_event_name, get_dts_func);

                var dts_xml:String = dts[event.query_name][dts.arg_select];

                // addFormItem(arg);
                ui_comp.addEventListener(EventCacheComplete.EVENT_NAME, cache_xml_func);
                var event_cache:EventCache = new EventCache(Application.application._pool);
                event_cache.DoCache(dts_xml, ui_comp);
            };

        var cache_xml_func:Function = function(event:EventCacheComplete):void
            {
                ui_comp.removeEventListener(EventCacheComplete.EVENT_NAME, cache_xml_func);

                // var event:Event = YsMaps.ys_event_map[];
                var new_event:Event;
                if (ui_comp is YsPod)
                    new_event = new EventPodShowXml(event.cache_xml);
                else if (ui_comp is YsTitleWindow)
                    new_event = new EventWindowShowXml(event.cache_xml);
                else if (ui_comp is YsButton)
                    new_event = new EventButtonAddAction(event.cache_xml, o);
                else if (ui_comp is YsDataGrid)
                    new_event = new EventDragToDatagrid(drag_object);
                ui_comp.dispatchEvent(new_event);
            }

        var drag_event:DragEvent = source_event as DragEvent;
        if (drag_event == null)
        {
            trace("事件类型不匹配");
            return;
        }

        var drag_object:Object = (drag_event.dragInitiator as ListBase).selectedItem;
        var dts:DBTable = Application.application._pool.dts as DBTable;

        dts.AddQuery(drag_object.DTS, Query, drag_object.DTS, ui_comp);
        ui_comp.addEventListener(dts.select_event_name, get_dts_func);
        dts.DoQuery(drag_object.DTS);
    }
}
