package com.yspay
{

    import com.esria.samples.dashboard.events.PodStateChangeEvent;
    import com.esria.samples.dashboard.managers.PodLayoutManager;
    import com.esria.samples.dashboard.view.*;
    import com.yspay.YsControls.YsPod;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventNewPod;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObject;
    import flash.events.MouseEvent;

    import mx.controls.Alert;
    import mx.events.FlexEvent;

    public class YsPodLayoutManager extends PodLayoutManager
    {
        public var _pool:Pool;
        protected var _cache:EventCache;

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
            _cache = new EventCache(_pool);
            this.addEventListener(EventNewPod.EVENT_NAME, OnNewPod);
            this.addEventListener(EventCacheComplete.EVENT_NAME, OnEventCacheComplete);
        }

        //相当于入口
        public function OnNewPod(event:EventNewPod):void
        {
            var windows_pre_string:String = 'windows://';
            var type_obj:Object = {'new service': {'title': 'newService', 'type': NewService},
                    'show memory bus': {'title': 'memory bus', 'type': MemoryBusContent}};
            var pod_xml:XML;
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
                pod_xml = new XML('<pod><windows/></pod>');
                pod_xml.@title = windows_name;
                pod_xml.windows = event.windows_type;
//                <pod title="TT5">
//                      <windows>
//                            windows://TT5
//                      </windows>
//                </pod>
                //DoNewYsPod(podxml);
                _cache.DoCache(pod_xml, this);
            }
            else
            {
                var tran_name:String = event.windows_type;
                pod_xml = new XML('<pod></pod>');
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
                _cache.DoCache(pod_xml.toXMLString(), this);
            }
        }

        private function OnEventCacheComplete(event:EventCacheComplete):void
        {
            DoNewYsPod(event.cache_xml);
        }

        private function DoNewYsPod(pod_xml:XML):void
        {
            pod_xml = UtilFunc.FullXml(pod_xml);
            var pod:YsPod = new YsPod(container);
            if (this.container.getChildren().length == 0)
            {
                this.addItemAt(pod, this.items.length + 1, true);
                pod.dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.MAXIMIZE));

            }
            else if (this.maximizedPod == null)
                this.addItemAt(pod, this.items.length + 1, false);
            else
            {
                this.maximizedPod.maximizeRestoreButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
                this.addItemAt(pod, this.items.length + 1, true);
            }
            pod.addEventListener(FlexEvent.UPDATE_COMPLETE, onCreationCompletePod);

            pod.Init(pod_xml);
        }

        private function DoNewPod(setupContent:DisplayObject, title:String):void
        {
            if (setupContent != null)
            {
                var pod:Pod = new Pod;
                pod.title = title;
                pod.addChild(setupContent);
                if (this.container.getChildren().length == 0)
                {
                    this.addItemAt(pod, this.items.length + 1, true);
                    pod.dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.MAXIMIZE));

                }
                else if (this.maximizedPod == null)
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