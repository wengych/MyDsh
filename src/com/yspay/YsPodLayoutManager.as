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
        private var show_save_xml_str:String = '<pod tilte="show xml">\
<windows>\
  new window\
</windows>\
<windows>\
  xml window\
</windows>\
</pod>';
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
  YSDBSDTSObjectConfigInsert\
  <SendPKG>\
    <HEAD active="YSDBSDTSObjectConfigInsert"/>\
    <BODY>\
      <DICT>DICT://__DICT_XML</DICT>\
    </BODY>\
  </SendPKG>\
  <RecvPKG>\
     <BODY>\
      <DICT>DICT://__DICT_OUT</DICT>\
      <DICT>DICT://__DICT_USER_RTN</DICT>\
      <DICT>DICT://__DICT_USER_RTNMSG</DICT>\
    </BODY>\
  </RecvPKG>\
</SERVICES>\
 <ACTION>\
    event_bus2window\
 </ACTION>\
</BUTTON>\
<BUTTON LABEL="清空">\
 <ACTION>event_clean_text</ACTION>\
</BUTTON>\
<BUTTON LABEL="显示xml">\
<ACTION>event_show_xml</ACTION>\
</BUTTON>\
</HBox>\
<windows title="new">\
new\
</windows>\
</pod>';

//<action>event_save2bus</action>\
//<action>event_bus2window</action>\
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
  YSDBSDTSObjectConfigInsert\
  <SendPKG>\
    <HEAD active="YSDBSDTSObjectConfigInsert"/>\
    <BODY>\
      <DICT>DICT://__DICT_XML</DICT>\
    </BODY>\
  </SendPKG>\
  <RecvPKG>\
     <BODY>\
      <DICT>DICT://__DICT_OUT</DICT>\
      <DICT>DICT://__DICT_USER_RTN</DICT>\
      <DICT>DICT://__DICT_USER_RTNMSG</DICT>\
     </BODY>\
  </RecvPKG>\
</SERVICES>\
 <ACTION>\
    event_bus2window\
 </ACTION>\</BUTTON>\
<BUTTON LABEL="清空">\
 <ACTION>event_clean_text</ACTION>\
</BUTTON>\
</HBox>\
<event>\
 dragDrop\
 <ACTION>new_window</ACTION>\
</event> \
</pod>';

        private var showtran_xml_str:String = '<POD title="show tran"> \
<HBOX>\
<BUTTON LABEL="refresh">\
 <ACTION>event_refresh_pool</ACTION>\
</BUTTON>\
</HBOX>\
<DATAGRID dragenable="true">\
<POOL> _POOL\
  <object att="DBTABLE"> info\
    <object att="array"> TRAN\
    <object att="col" id="中文名字"> MEMO\
    </object>\
    </object>\
   </object>\
</POOL>\
<POOL>_POOL\
  <object att="DBTABLE">  info\
    <object att="array">    TRAN\
    <object att="col" id="英文名字"> NAME\
    </object>\
    </object>\
   </object>\
</POOL>\
<POOL>\
_POOL\
  <object att="DBTABLE">  info\
    <object att="array">    TRAN\
    <object att="col" id="DTS">      DTS\
    </object>\
    </object>\
   </object>\
</POOL>\
<POOL>\
_POOL\
  <object att="DBTABLE">  info\
    <object att="array">    TRAN\
    <object att="col" id="版本号">      VER\
    </object>\
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
                    'show window': {'title': 'window', 'type': WindowContent},
                    'show dict': {'title': 'dict', 'type': DictContent},
                    'show service': {'title': 'service', 'type': ServiceContent},
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
                DoNewYsPod(podxml);
            }
            else
            {
                var tran_name:String = event.windows_type;
//                if (_pool.info.TRAN[tran_name] == null)
//                {
//                    Alert.show("无此交易!!");
//                    return;
//                }
                var pod_xml:XML = <pod>
                    </pod>;
                pod_xml.appendChild("tran://" + tran_name);
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
//
//        private function OnQueryWindowsDTSComplete(event:DBTableQueryEvent):void
//        {
//            var dts:DBTable = _pool.dts as DBTable;
//            trace(event.query_name);
//
//            if (!dts.hasOwnProperty(event.query_name) || dts[event.query_name].__DICT_XML == null)
//            {
//                return;
//            }
//            var dispObj:DisplayObject = new DeployedWindow;
//            DoNewPod(dispObj, event.query_name);
//            var pod:Pod = dispObj.parent as Pod;
//            var dts_xml:XML = new XML(dts[event.query_name].__DICT_XML);
//            this.removeEventListener(dts.select_event_name, OnQueryWindowsDTSComplete);
//        }

//        private function OnDtsQueryComplete(event:DBTableQueryEvent, pod:YsPod):void
//        {
//            var dts:DBTable = _pool.dts as DBTable;
//            var contentXml:XML = new XML(StringUtil.trim(dts[event.query_name].__DICT_XML));
//            pod.dispatchEvent(new EventPodNewChild(contentXml));
//        }
//
//        private function onDragDropHandler(e:DragEvent, action:String):void
//        {
//            var object:Object = {'new window': ['cache window', 'new_window']}
//            var functionHepler:FunctionDelegate = new FunctionDelegate;
//            var search_str:String = '://';
//            var pod:YsPod = e.currentTarget as YsPod;
//            this.addEventListener(_pool.dts.select_event_name, functionHepler.create(OnDtsQueryComplete, pod));
//            var url:String = "WINDOWS://" + (e.dragInitiator as WindowContent).selectedItem.name;
//            var idx:int = url.search(search_str);
//            var query_key:String = url.substr(0, idx).toLocaleUpperCase();
//            var obj_key:String = url.substr(idx + search_str.length);
//            var dts_no:String = _pool.info[query_key][obj_key].Get().DTS;
//            var dts:DBTable = _pool.dts as DBTable;
//            dts.AddQuery(dts_no, Query, dts_no, this);
//            dts.DoQuery(dts_no);
//
//        }
    }
}