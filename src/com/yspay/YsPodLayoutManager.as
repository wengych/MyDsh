package com.yspay
{

    import com.esria.samples.dashboard.managers.PodLayoutManager;
    import com.esria.samples.dashboard.view.*;
    import com.yspay.events.EventNewPod;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.pool.Pool;

    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import mx.controls.Alert;
    import mx.events.FlexEvent;

    public class YsPodLayoutManager extends PodLayoutManager
    {
        public var _pool:Pool;
        private var newwindow_xml_str:String = '<pod title="new windows">\
<HBox line="top">\
<DICT>\
  DICT://__W_CNAME\
</DICT>\
<DICT>\
  DICT://__W_ENAME\
</DICT>\
<BUTTON LABEL="保存">\
 <ACTION>event_make_windows_xml</ACTION>\
 <SERVICES>\
  SERVICES://YSDBSDTSObjectConfigInsert\
</SERVICES>\
</BUTTON>\
<BUTTON LABEL="清空">\
 <ACTION>event_clean_text</ACTION>\
</BUTTON>\
<BUTTON LABEL="显示xml">\
<ACTION>event_show_xml</ACTION>\
</BUTTON>\
</HBox>\
<HBox>\
<DICT>\
  DICT://__DICT_USER_RTN\
</DICT>\
<DICT>\
  DICT://__DICT_USER_RTNMSG\
</DICT>\
<DICT>\
  DICT://__DICT_OUT\
</DICT>\
<BUTTON LABEL="清空">\
 <ACTION>event_clean_text</ACTION>\
</BUTTON>\
</HBox>\
<windows title="new">\
new\
</windows>\
</pod>';
        private var newtran_xml_str:String = '<pod title="new tran"> \
<HBox line="top">\
<DICT>\
  DICT://__W_CNAME\
</DICT>\
<DICT>\
  DICT://__W_ENAME\
</DICT>\
<BUTTON LABEL="保存">\
 <ACTION>event_make_tran_xml</ACTION>\
 <SERVICES>\
  SERVICES://YSDBSDTSObjectConfigInsert\
</SERVICES>\
 <ACTION>\
    event_bus2window\
 </ACTION>\</BUTTON>\
<BUTTON LABEL="清空">\
 <ACTION>event_clean_text</ACTION>\
</BUTTON>\
</HBox>\
<HBox line="top">\
<DICT>\
  DICT://__DICT_USER_RTN\
</DICT>\
<DICT>\
  DICT://__DICT_USER_RTNMSG\
</DICT>\
<DICT>\
  DICT://__DICT_OUT\
</DICT>\
</HBox>\
<event>\
 dragDrop\
 <ACTION>new_window</ACTION>\
</event> \
</pod>';
        private var show_save_xml_str:String = '<pod tilte="show xml">\
<DATAGRID dragEnabled="true" editable="true" >\
<DICT>DICT://__W_CNAME</DICT>\
<DICT>DICT://__W_ENAME</DICT>\
<BUTTON LABEL="保存">\
 <ACTION>event_make_windows_xml</ACTION>\
 <SERVICES>\
  SERVICES://YSDBSDTSObjectConfigInsert\
</SERVICES>\
</BUTTON>\
<BUTTON LABEL="删除行">\
 <ACTION>_delete_line</ACTION>\
</BUTTON>\
<BUTTON LABEL="增加行">\
 <ACTION>_add_line</ACTION>\
</BUTTON>\
</DATAGRID>\
<windows>\
  new window\
 <event>\
   dragDrop\
  <ACTION>show_aa</ACTION>\
 </event> \
</windows>\
<windows>\
  xml window\
</windows>\
</pod>';
        private var showtran_xml_str:String = '<POD title="show tran"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragEnabled="true" editable="true" >\
<POOL> POOL\
  <object> INFO\
    <object att="array"> TRAN \
        <object id="中文名字"> MEMO</object>\
        <object id="英文名字"> NAME</object>\
        <object id="DTS"> DTS</object>\
        <object id="版本号"> VER</object>\
   </object>\
  </object>\
</POOL>\
</DATAGRID>\
</POD>';
        private var showdict_xml_str:String = '<POD title="show dict"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragEnabled="true" editable="true" >\
<POOL> POOL\
  <object> INFO\
    <object att="array"> DICT \
        <object id="中文名字"> MEMO</object>\
        <object id="英文名字"> NAME</object>\
        <object id="DTS">      DTS</object>\
        <object id="版本号">      VER</object>\
   </object>\
  </object>\
</POOL>\
</DATAGRID>\
</POD>';
        private var showservices_xml_str:String = '<POD title="show services"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragEnabled="true" editable="true" >\
<POOL> POOL\
  <object> INFO\
    <object att="array"> SERVICES \
        <object id="中文名字"> MEMO</object>\
        <object id="英文名字"> NAME</object>\
        <object id="DTS">      DTS</object>\
        <object id="版本号">      VER</object>\
   </object>\
  </object>\
</POOL>\
</DATAGRID>\
</POD>';
        private var showwindows_xml_str:String = '<POD title="show window"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragEnabled="true" editable="true" >\
<POOL> POOL\
  <object> INFO\
    <object att="array"> WINDOWS \
        <object id="中文名字"> MEMO</object>\
        <object id="英文名字"> NAME</object>\
        <object id="DTS">  DTS</object>\
        <object id="版本号">  VER</object>\
        <object id="建立日期">CDATE</object>\
   </object>\
  </object>\
</POOL>\
</DATAGRID>\
</POD>';
        private var showhbox_xml_str:String = '<POD title="show hbox"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragEnabled="true" editable="true" >\
<POOL> POOL\
  <object> INFO\
    <object att="array"> HBOX \
        <object id="中文名字"> MEMO</object>\
        <object id="英文名字"> NAME</object>\
        <object id="DTS">  DTS</object>\
        <object id="版本号">  VER</object>\
        <object id="建立日期">CDATE</object>\
   </object>\
  </object>\
</POOL>\
</DATAGRID>\
</POD>';

        public function YsPodLayoutManager(pool:Pool)
        {
            super();
            _pool = pool;
            this.addEventListener(EventNewPod.EVENT_NAME, OnNewPod);
        }

        //相当于入口
        public function OnNewPod(event:EventNewPod):void
        {
            var windows_pre_string:String = 'windows://';
            var type_obj:Object = {'new service': {'title': 'newService', 'type': NewService},
                    'show memory bus': {'title': 'memory bus', 'type': MemoryBusContent}};

            if (type_obj.hasOwnProperty(event.windows_type))
            {
                DoNewPod(new type_obj[event.windows_type].type,
                         type_obj[event.windows_type].title);
            }
            else if (event.windows_type == 'new window')
            {
                DoNewYsPod(new XML(newwindow_xml_str));
            }
            else if (event.windows_type == 'new tran')
            {
                DoNewYsPod(new XML(newtran_xml_str));
            }
            else if (event.windows_type == 'show tran')
            {
                DoNewYsPod(new XML(showtran_xml_str));
            }
            else if (event.windows_type == 'show xml')
            {
                DoNewYsPod(new XML(show_save_xml_str));
            }
            else if (event.windows_type == 'show dict')
            {
                DoNewYsPod(new XML(showdict_xml_str));
            }
            else if (event.windows_type == 'show service')
            {
                DoNewYsPod(new XML(showservices_xml_str));
            }
            else if (event.windows_type == 'show window')
            {
                DoNewYsPod(new XML(showwindows_xml_str));
            }
            else if (event.windows_type == 'show hbox')
            {
                DoNewYsPod(new XML(showhbox_xml_str));
            }

            else if (event.windows_type.toLocaleLowerCase().search(windows_pre_string) >= 0)
            {
                // 'WINDOWS://testop'
                var windows_name:String = event.windows_type.substr(windows_pre_string.length);
                if (_pool.info.WINDOWS[windows_name] == null)
                {
                    Alert.show("无此窗口!!");
                    return;
                }
                var podxml:XML = <pod>
                        <windows/>
                    </pod>;
                podxml.@title = windows_name;
                podxml.windows = event.windows_type;
//                <pod title="TT5">
//                      <windows>
//                            windows://TT5
//                      </windows>
//                </pod>
                DoNewYsPod(podxml);
            }
            else
            {
                var tran_name:String = event.windows_type;
                var pod_xml:XML = <pod>
                    </pod>;
                if (_pool.info.TRAN[tran_name] == null)
                {
                    Alert.show("无此交易!!");
                    return;
                }
                pod_xml.appendChild("tran://" + tran_name);
                //pod_xml:
                // <pod>
                //      tran://12
                //</pod>
                DoNewYsPod(pod_xml);
            }
        }

        private function DoNewYsPod(pod_xml:XML):void
        {
            var pod:YsPod = new YsPod(_pool);
            pod.title = pod_xml.@title;
            if (this.maximizedPod == null)
                this.addItemAt(pod, this.items.length + 1, false);
            else
            {
                this.maximizedPod.maximizeRestoreButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                this.addItemAt(pod, this.items.length + 1, true);
            }
            pod.addEventListener(FlexEvent.UPDATE_COMPLETE, onCreationCompletePod);
            var evt:EventPodShowXml = new EventPodShowXml(pod_xml);
            pod.dispatchEvent(evt);
        }

        private function DoNewPod(setupContent:DisplayObject, title:String):void
        {
            if (setupContent != null)
            {
                var pod:Pod = new Pod;
                pod.title = title;
                pod.addChild(setupContent);
                if (this.maximizedPod == null)
                    this.addItemAt(pod, this.items.length + 1, false);
                else
                {
                    this.maximizedPod.maximizeRestoreButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                    this.addItemAt(pod, this.items.length + 1, true);
                }
                pod.addEventListener(FlexEvent.UPDATE_COMPLETE, onCreationCompletePod);
                return;
            }
        }

        // Pod has been created so update the respective PodLayoutManager.
        private function onCreationCompletePod(e:FlexEvent):void
        {
            e.currentTarget.removeEventListener(FlexEvent.UPDATE_COMPLETE, onCreationCompletePod);
            this.removeNullItems();
            this.updateLayout(true);
        }
    }
}