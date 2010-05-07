// ActionScript file

package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.view.NewWindow;
    import com.yspay.YsPod;
    import com.yspay.util.DateUtil;

    import mx.controls.Alert;
    import mx.core.Container;
    import mx.core.UIComponent;

    public function show_xml(ui_comp:UIComponent):void
    {
        var ys_pod:YsPod = EventHandlerFactory.GetParentYsPod(ui_comp.parent as Container);
        trace('show_xml');
        var xml:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing" MEMO=""></L>;
        var child_wnd:Container;
        var date:Date = new Date;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in ys_pod.getChildren())
        {
            var new_wnd:NewWindow = child_wnd as NewWindow
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