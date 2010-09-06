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
    import flash.events.ErrorEvent;
    import flash.events.MouseEvent;

    import mx.controls.Alert;
    import mx.core.FlexGlobals;
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
            _cache = new EventCache(this);
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
                _cache = new EventCache(this);
                _cache.DoCache(pod_xml);
            }
            else
            {
                var tran_name:String = event.windows_type;
                CheckPurview(tran_name);
            }
        }

        protected function CheckPurview(tran_name:String):void
        {
            var call_back:Function = function(new_bus:UserBus, error_event:ErrorEvent=null):void
                {
                    /*
                       if (new_bus == null ||
                       error_event != null)
                       {
                       Alert.show('权限检查失败');
                       return;
                       }

                       var user_rtn:int = new_bus.__DICT_USER_RTN.first;
                       if (user_rtn != 0)
                       {
                       Alert.show('权限检查失败');
                       return;
                       }
                     */
                    _cache = new EventCache(pod_mng);
                    _cache.DoCache(pod_xml.toXMLString());
                };

            var pool:Pool = FlexGlobals.topLevelApplication._pool;
            var pod_xml:XML = new XML('<pod></pod>');
            var pod_mng:YsPodLayoutManager = this;
            if (_pool.info.TRAN[tran_name] == null)
            {
                Alert.show("无此交易!!");
                return;
            }
            pod_xml.appendChild("tran://" + tran_name);

            var service_call:ServiceCall = new ServiceCall;
            var user_bus:UserBus = new UserBus;
            var scall_name:String = 'YSUserPurViewCheck';

            user_bus.Add(ServiceCall.SCALL_NAME, scall_name);
            user_bus.Add('USERID', pool.D_data.data.USERID[0]);
            user_bus.Add('SERVICE', tran_name);

            var ip:String = FlexGlobals.topLevelApplication.GetServiceIp(scall_name);
            var port:String = FlexGlobals.topLevelApplication.GetServicePort(scall_name);
            service_call.Send(user_bus, ip, port, call_back);
        }

        private function OnEventCacheComplete(event:EventCacheComplete):void
        {
            _cache = new EventCache(this);
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