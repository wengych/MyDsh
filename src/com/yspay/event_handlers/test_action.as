// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.EventCache;
    import com.yspay.YsControls.*;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.DBTableQueryEvent;
    import com.yspay.pool.Query;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.Application;
    import mx.core.UIComponent;

    public function test_action(ui_comp:UIComponent, event:Event, action_info:XML):void
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

                ui_comp.dispatchEvent(new_event);
            }

        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent, YsPod) as YsPod;

        var _xml:XML = action_info;

        var new_dict_xml:XML = new XML('<DICT>DICT://GENDERListTest</DICT>');

        var info:DBTable = Application.application._pool.info;
        var dts_no:String = info.DICT['GENDERListTest'].Get().DTS;
        var dts:DBTable = Application.application._pool.dts;

        dts.AddQuery(dts_no, Query, dts_no, ui_comp);
        ui_comp.addEventListener(dts.select_event_name, get_dts_func);
        dts.DoQuery(dts_no);
    }
}
