// ActionScript file
package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.view.NewWindow;
    import com.yspay.util.DateUtil;

    import mx.core.Container;

    public function make_tran_xml(wnd:Object, event_container:Container):void
    {
        var win_per:String = "WINDOWS://";
        trace('event_make_windows_xml');
        var xml:XML = <L TYPE="TRAN" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing">
                <L KEY="pod" KEYNAME="tran">
                    <A KEY="title" KEYNAME="title"/>
                </L>
            </L>;
        var child_wnd:Container;
        var P_data:Object = wnd._M_data.TRAN[wnd.P_cont];
        var ename:Object = P_data.data[0]["__W_ENAME"]; // wnd.main_bus.GetFirst("__W_ENAME");
        var cname:Object = P_data.data[0]["__W_CNAME"]; // wnd.main_bus.GetFirst("__W_CNAME");
        var date:Date = new Date;
        xml.@NAME = ename;
        xml.L.@VALUE = ename;
        xml.L.A.@VALUE = cname;
        xml.@MEMO = cname;
        xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
        for each (child_wnd in wnd.getChildren())
        {
            var new_wnd:NewWindow = child_wnd as NewWindow
            if (new_wnd == null)
                continue;
            var win_xml:XML = <L KEY="windows" KEYNAME="windows"/>;
            var postion:int = new_wnd.title.search(":");
            win_xml.@VALUE = (win_per + new_wnd.title.substr(0, postion));
            xml.L.appendChild(win_xml);
        }
        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (wnd.main_bus.GetVarArray('__DICT_XML') != null)
        {
            wnd.main_bus.RemoveByKey('__DICT_XML');
        }
        wnd.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
    }
}