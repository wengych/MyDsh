// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.util.DateUtil;
    import mx.core.Container
    import mx.controls.Alert;

    import com.esria.samples.dashboard.view.NewWindow;

    public function show_xml(wnd:Object, event_container:Container):void
    {
        trace('show_xml');
        var xml:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing" MEMO=""></L>;
        var child_wnd:Container;
        var date:Date = new Date;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in wnd.getChildren())
        {
            var new_wnd:NewWindow = child_wnd as NewWindow
            if (new_wnd == null)
                continue;
            var new_xml:XML = new_wnd.save_windows_xml();
            xml.appendChild(new_xml);
            xml.@NAME = new_xml.@VALUE;
            xml.@MEMO = new_xml.A.(@KEYNAME == 'Title').@VALUE;
        }
        Alert.show(xml.toXMLString());
    }
}