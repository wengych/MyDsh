// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.EventCache;
    import com.yspay.YsControls.*;
    import com.yspay.events.EventButtonAddAction;
    import com.yspay.events.EventCacheComplete;
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

    public function drag_drop(ui_comp:UIComponent, source_event:Event, action_info:XML):Boolean
    {
        var get_dts_func:Function = function(event:DBTableQueryEvent):void
            {
                var dts:DBTable = Application.application._pool.dts as DBTable;
                if (--item_count <= 0)
                    ui_comp.removeEventListener(dts.select_event_name, get_dts_func);

                var dts_xml:String = dts[event.query_name][dts.arg_select];

                // addFormItem(arg);
                ui_comp.addEventListener(EventCacheComplete.EVENT_NAME, cache_xml_func);
                var event_cache:EventCache = new EventCache(Application.application._pool);
                event_cache.DoCache(dts_xml, ui_comp);
            };

        var cache_xml_func:Function = function(event:EventCacheComplete):void
            {
                var dts:DBTable = Application.application._pool.dts as DBTable;
                ui_comp.removeEventListener(EventCacheComplete.EVENT_NAME, cache_xml_func);

                // var obj:Object = drag_object;
                if (drag_item.TYPE == 'DICT' || drag_item.TYPE == 'SERVICES')
                {
                    var to_pod:XML =
                        <To>pod</To>
                        ;
                    var from_pod:XML =
                        <From>pod</From>
                        ;
                    event.cache_xml.appendChild(to_pod);
                    event.cache_xml.appendChild(from_pod);
                }

                if (drag_item.TYPE == 'WINDOWS')
                {
                    event.cache_xml.@showCloseButton = "true";
                }

                // var event:Event = YsMaps.ys_event_map[];
                var new_event:Event;
                if (ui_comp is YsPod)
                    new_event = new EventPodShowXml(event.cache_xml);
                else if (ui_comp is YsTitleWindow)
                    new_event = new EventWindowShowXml(event.cache_xml);
                else if (ui_comp is YsButton)
                    new_event = new EventButtonAddAction(event.cache_xml);

                ui_comp.dispatchEvent(new_event);
            }

        var drag_event:DragEvent = source_event as DragEvent;
        if (drag_event == null)
        {
            trace("事件类型不匹配");
            return false;
        }

        // var drag_object:Object = (drag_event.dragInitiator as ListBase).selectedItem;
        var drag_items:Array = (drag_event.dragInitiator as ListBase).selectedItems;
        var dts:DBTable = Application.application._pool.dts as DBTable;
        var drag_item:Object;
        var item_count:int = drag_items.length;

        ui_comp.addEventListener(dts.select_event_name, get_dts_func);
        for each (drag_item in drag_items)
        {
            dts.AddQuery(drag_item.DTS, Query, drag_item.DTS, ui_comp);
            dts.DoQuery(drag_item.DTS);
        }

        return true;
    }
}
