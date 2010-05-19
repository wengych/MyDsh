// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.util.DateUtil;
    import com.yspay.util.UtilFunc;
    import com.yspay.YsControls.*;

    import mx.core.Container;
    import mx.core.UIComponent;
    import flash.events.Event;

    public function make_windows_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container, YsPod) as YsPod;

        trace('event_make_windows_xml');
        var xml:XML = <L TYPE="WINDOWS" ISUSED="0" APPNAME="MapServer" CUSER="xing"></L>;
        var child_wnd:Container;
        var date:Date = new Date;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in ys_pod.getChildren())
        {
            var new_wnd:YsTitleWindow = child_wnd as YsTitleWindow; 
            if (new_wnd == null)
                continue;
            var new_xml:XML = new_wnd.save_windows_xml(ys_pod.P_cont);
            xml.appendChild(new_xml);
            xml.@NAME = new_xml.@VALUE;
            xml.@MEMO = new_xml.A.(@KEYNAME == 'Title').@VALUE;

            break;
        }
        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (ys_pod.main_bus.GetVarArray('__DICT_XML') != null)
        {
            ys_pod.main_bus.RemoveByKey('__DICT_XML');
        }
        ys_pod.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
    }
}