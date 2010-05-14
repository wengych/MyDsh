// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.util.DateUtil;
    import com.yspay.util.GetParentByType;

    import mx.controls.Alert;
    import mx.core.Container;
    import mx.core.UIComponent;
    import flash.events.Event;

    public function show_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var ys_pod:YsPod = GetParentByType(ui_comp.parent, YsPod) as YsPod;
        trace('show_xml');
        var xml:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing" MEMO=""></L>;
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
        }
        Alert.show(xml.toXMLString());
    }
}