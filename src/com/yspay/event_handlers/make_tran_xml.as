// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.events.YsEvent;
    import com.yspay.util.DateUtil;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.Container;
    import mx.core.UIComponent;

    public function make_tran_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        trace('event_make_tran_xml');
        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container, YsPod) as YsPod;
        var xml:XML = <L TYPE="TRAN" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing">
                <L KEY="pod" KEYNAME="tran">
                    <A KEY="title" KEYNAME="title"/>
                </L>
            </L>;
        var child_wnd:Object;
        var P_data:Object = ys_pod._M_data.TRAN[ys_pod.P_cont];
        var ename:Object = P_data._data["__W_ENAME"][0]; // wnd.main_bus.GetFirst("__W_ENAME");
        var cname:Object = P_data._data["__W_CNAME"][0]; // wnd.main_bus.GetFirst("__W_CNAME");
        var date:Date = new Date;
        xml.@NAME = ename;
        xml.L.@VALUE = ename;
        xml.L.A.@VALUE = cname;
        xml.@MEMO = cname;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in ys_pod.getChildren())
        {
            var new_YsTitleWindow:YsTitleWindow = child_wnd as YsTitleWindow;
            if (new_YsTitleWindow != null)
            {
                var win_per:String = "WINDOWS://";
                var win_xml:XML = <L KEY="windows" KEYNAME="windows"/>;
                win_xml.@VALUE = win_per + new_YsTitleWindow.name;
                xml.L.appendChild(win_xml);
                continue;
            }
            var new_YsDict:YsDict = child_wnd as YsDict;
            if (new_YsDict != null)
            {
                var dict_inxml:XML = new_YsDict.GetXml();
                var dict_xml:XML = <L KEY="DICT" KEYNAME="DICT" VALUE="" >
                        <L KEY="From" KEYNAME="From" VALUE="pod"/>
                        <L KEY="To" KEYNAME="To" VALUE="pod"/>
                    </L>;
                dict_xml.@VALUE = "DICT://" + dict_inxml.text().toString();
                dict_xml.@KEYNAME = dict_inxml.services.@DESCRIPT;
                xml.L.appendChild(dict_xml);
                continue;
            }
            var new_button:YsButton = child_wnd as YsButton;
            if (new_button != null)
            {
                xml.L.appendChild(new_button.GetXml());
                continue;
            }
            var new_YsDataGrid:YsDataGrid = child_wnd as YsDataGrid;
            if (new_YsDataGrid != null)
            {
                continue;
            }
            var new_YsEvent:YsEvent = child_wnd as YsEvent;
            if (new_YsEvent != null)
            {
                continue;
            }
            var new_YsHBox:YsHBox = child_wnd as YsHBox;
            if (new_YsHBox != null)
            {
                continue;
            }
        }
        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (ys_pod.main_bus.GetVarArray('__DICT_XML') != null)
        {
            ys_pod.main_bus.RemoveByKey('__DICT_XML');
        }
        ys_pod.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
    }
}