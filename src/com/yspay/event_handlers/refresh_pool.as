// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.*;
    import com.yspay.pool.*;
    import com.yspay.util.GetParentByType;

    import flash.events.EventDispatcher;
    import flash.events.Event;

    import mx.core.Application;
    import mx.core.Container;
    import mx.core.UIComponent;
    import mx.managers.CursorManager;

    public function refresh_pool(ui_comp:UIComponent, source_event:Event):void
    {
        var ys_pod:YsPod = GetParentByType(ui_comp.parent as Container, YsPod) as YsPod;
        var _pool:Pool = Application.application._pool;

        var info:DBTable = _pool.info as DBTable;
        var arr:Array = ['DICT', 'WINDOWS', 'BUTTON', 'SERVICES', 'TRAN', 'ACTION', 'HBOX', 'EVENT'];
        ys_pod.addEventListener(info.select_event_name, ys_pod._YsInfoQueryComplete);
        CursorManager.setBusyCursor();

        for each (var str:String in arr)
        {
            var info_query_dict:String = str;
            var info_query_cond:String = "type='" + str + "' and appname='MapServer'";
            info.AddQuery(info_query_dict, QueryWithIndex, info_query_cond, ys_pod);
            info.DoQuery(info_query_dict, false, 'NAME', 'VER');
        }
        trace("refresh_pool ok!");
    }
}