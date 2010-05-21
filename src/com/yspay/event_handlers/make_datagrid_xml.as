// ActionScript file
// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.util.DateUtil;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.Container;
    import mx.core.UIComponent;

    public function make_datagrid_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container, YsPod) as YsPod;
        var P_data:Object = ys_pod._M_data.TRAN[ys_pod.P_cont];

        if (!P_data.data.hasOwnProperty('__W_ENAME') || !P_data.data.hasOwnProperty('__W_CNAME'))
            return;

        var ename:Object = P_data._data["__W_ENAME"][0]; // wnd.main_bus.GetFirst("__W_ENAME");
        var cname:Object = P_data._data["__W_CNAME"][0]; // wnd.main_bus.GetFirst("__W_CNAME");

        trace('event_make_windows_xml');
        var xml:XML = <L TYPE="DATAGRID" NAME="" VER="" ISUSED="0" APPNAME="MapServer" CUSER="xing" />
//                <L KEY="DATAGRID" KEYNAME="" />
//            </L>;
        var child_wnd:Object;
        var date:Date = new Date;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);

        for each (child_wnd in ys_pod.getChildren())
        {
            var dg:YsDataGrid = child_wnd as YsDataGrid;
            if (dg != null)
                break;
        }

        var dg_xml:XML = dg.GetSaveXml();

        dg_xml.@VALUE = ename;

        xml.appendChild(dg_xml);
        xml.@NAME = ename;
        xml.@MEMO = cname;

        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (ys_pod.main_bus.GetVarArray('__DICT_XML') != null)
        {
            ys_pod.main_bus.RemoveByKey('__DICT_XML');
        }
        ys_pod.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
    }
}