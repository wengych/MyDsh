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
            else if (event.windows_type == 'show xml')
            {
                DoNewYsPod(new XML(show_save_xml_str));
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
                pod_xml.@title = tran_name;
                //pod_xml:
                // <pod title="12">
                //      tran://12
                //</pod>
                DoNewYsPod(pod_xml);
            }
        }

        private function DoNewYsPod(pod_xml:XML):void
        {
            var pod:YsPod = new YsPod(container);
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