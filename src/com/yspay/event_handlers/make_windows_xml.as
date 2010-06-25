// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.YsData.PData;
    import com.yspay.util.DateUtil;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.Container;
    import mx.core.UIComponent;

    public function make_windows_xml(ui_comp:UIComponent,
                                     source_event:Event,
                                     action_info:XML):Boolean
    {
        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container,
                                                    YsPod) as YsPod;

        var P_data:PData = ys_pod.D_data;
        var xml:XML =
            <L TYPE="WINDOWS" ISUSED="0" APPNAME="MapServer" CUSER="xing"></L>
            ;
        var child_wnd:Container;
        var date:Date = new Date;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in ys_pod.getChildren())
        {
            var new_wnd:YsTitleWindow = child_wnd as YsTitleWindow;
            if (new_wnd == null)
                continue;

            if (P_data.data.hasOwnProperty('__W_ENAME'))
                new_wnd.ename = P_data.data['__W_ENAME'][0];
            if (P_data.data.hasOwnProperty('__W_CNAME'))
                new_wnd.cname = P_data.data['__W_CNAME'][0];

            var new_xml:XML = new_wnd.GetSaveXml();
            if (new_xml == null)
                return true;

            xml.appendChild(new_xml);
            xml.@NAME = new_wnd.ename;
            xml.@MEMO = new_wnd.cname;

            break;
        }
        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (ys_pod.main_bus.GetVarArray('__DICT_XML') != null)
        {
            ys_pod.main_bus.RemoveByKey('__DICT_XML');
        }
        ys_pod.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());

        return true;
    }
}