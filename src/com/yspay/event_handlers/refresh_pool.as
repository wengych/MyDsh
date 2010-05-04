// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.*;
    import com.yspay.pool.*;

    import flash.events.EventDispatcher;

    import mx.core.Application;
    import mx.core.Container;
    import mx.managers.CursorManager;

    public function refresh_pool(wnd:Object, event_container:Container):void
    {
        var _pool:Pool = Application.application._pool;

        var info:DBTable = _pool.info as DBTable;
        var arr:Array = ['DICT', 'WINDOWS', 'BUTTON', 'SERVICES', 'TRAN', 'ACTION', 'HBOX', 'EVENT'];
        wnd.addEventListener(info.select_event_name, wnd._YsInfoQueryComplete);
        CursorManager.setBusyCursor();

        for each (var str:String in arr)
        {
            var info_query_dict:String = str;
            var info_query_cond:String = "type='" + str + "' and appname='MapServer'";
            info.AddQuery(info_query_dict, QueryWithIndex, info_query_cond, wnd as EventDispatcher);
            info.DoQuery(info_query_dict, false, 'NAME', 'VER');
        }
        trace("refresh_pool ok!");
    }
}