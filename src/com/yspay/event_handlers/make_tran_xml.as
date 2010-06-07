// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.util.DateUtil;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.Container;
    import mx.core.UIComponent;

    public function make_tran_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        trace('event_make_tran_xml');
        var ys_pod:YsPod = UtilFunc.GetParentByType(ui_comp.parent as Container,
                                                    YsPod) as YsPod;
        var xml:XML =
            <L TYPE="TRAN" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing"/>
            ;
        var child_wnd:Object;
        var P_data:Object = ys_pod.D_data;
        var ename:String = '';
        var cname:String = '';
        var date:Date = new Date;

        if (P_data.data.hasOwnProperty('__W_ENAME'))
            ys_pod.ename = P_data.data['__W_ENAME'][0];
        if (P_data.data.hasOwnProperty('__W_CNAME'))
            ys_pod.cname = P_data.data['__W_CNAME'][0];

        xml.@NAME = ys_pod.ename;
        xml.@MEMO = ys_pod.cname;
        xml.@VER = date.fullYear +
            DateUtil.doubleString(date.month + 1) +
            DateUtil.doubleString(date.date) +
            DateUtil.doubleString(date.hours) +
            DateUtil.doubleString(date.minutes) +
            DateUtil.doubleString(date.seconds);
        var pod_xml:XML = ys_pod.GetSaveXml();
        if (pod_xml != null)
            xml.appendChild(pod_xml);

        var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
        if (ys_pod.main_bus.GetVarArray('__DICT_XML') != null)
        {
            ys_pod.main_bus.RemoveByKey('__DICT_XML');
        }
        ys_pod.main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
    }
}