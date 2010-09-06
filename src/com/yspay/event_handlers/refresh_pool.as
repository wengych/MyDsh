// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.*;
    import com.yspay.YsControls.*;
    import com.yspay.YsData.MData;
    import com.yspay.pool.*;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import mx.collections.ArrayCollection;
    import mx.core.FlexGlobals;
    import mx.core.Container;
    import mx.core.UIComponent;
    import mx.managers.CursorManager;

    public function refresh_pool(ui_comp:UIComponent,
                                 source_event:Event,
                                 action_info:XML):Boolean
    {
        var func:Function = function(event:DBTableQueryEvent):void
            {
                var M_data:MData = FlexGlobals.topLevelApplication.M_data;
                // TODO 修正刷新pool的问题
                CursorManager.removeBusyCursor();
                if (M_data.POOL.INFO[event.query_name] != null)
                    M_data.POOL.INFO[event.query_name].removeAll();

                M_data.POOL.INFO[event.query_name] = new ArrayCollection;
                var info:DBTable = _pool.info as DBTable;
                for each (var dict_obj:QueryObject in info[event.query_name])
                {
                    var ys_var:YsVarStruct = dict_obj.Get();
                    var o:Object = new Object;
                    o["APPNAME"] = ys_var.APPNAME.getValue();
                    o["CDATE"] = ys_var.CDATE.getValue();
                    o["CUSER"] = ys_var.CUSER.getValue();
                    o["DTS"] = ys_var.DTS.getValue();
                    o["ISUSED"] = ys_var.ISUSED.getValue();
                    o["MDATE"] = ys_var.MDATE.getValue();
                    o["MEMO"] = ys_var.MEMO.getValue();
                    o["MUSER"] = ys_var.MUSER.getValue();
                    o["NAME"] = ys_var.NAME.getValue();
                    o["TYPE"] = ys_var.TYPE.getValue();
                    o["VALUE"] = ys_var.VALUE.getValue();
                    o["VER"] = ys_var.VER.getValue();
                    M_data.POOL.INFO[event.query_name].addItem(o);
                }

                M_data.POOL.INFO[event.query_name].refresh();

                return;
            };

        var event_disp:EventDispatcher = new EventDispatcher;

        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container,
                                                    YsPod) as YsPod;
        var _pool:Pool = FlexGlobals.topLevelApplication._pool;

        var info:DBTable = _pool.info as DBTable;
        var arr:Array = ['DICT', 'WINDOWS', 'BUTTON', 'SERVICES', 'TRAN', 'ACTION',
                         'HBOX', 'EVENT', 'DATAGRID', 'SCRIPT'];

        ys_pod.addEventListener(info.select_event_name, ys_pod._YsInfoQueryComplete);
        CursorManager.setBusyCursor();

        for each (var str:String in arr)
        {
            var info_query_dict:String = str;
            var info_query_cond:String = "type='" + str + "' and appname='MapServer'";
            event_disp.addEventListener(info.select_event_name, func);
            info.AddQuery(info_query_dict, QueryWithIndex, info_query_cond, event_disp);
            info.DoQuery(info_query_dict, false, 'NAME', 'VER');
        }
        trace("refresh_pool ok!");

        return true;
    }
}
