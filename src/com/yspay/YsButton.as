package com.yspay
{
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.Pool;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.StackUtil;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Button;
    import mx.core.Application;

    public class YsButton extends Button implements YsControl
    {
        public function YsButton(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;

        }
        protected var _pool:Pool;
        protected var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public var service_list:Array = new Array;
        protected var curr_service:int = 0;

        public function Init(xml:XML):void
        {
            _parent.addChild(this);

            this.setStyle('fontWeight', 'normal');
            this.label = xml.@LABEL;
            _xml = xml;
            this.addEventListener(MouseEvent.CLICK, OnBtnClick);
            this.addEventListener(StackSendXmlEvent.EVENT_NAME, DoActions);


            var child_name:String;
            for each (var child:XML in xml.elements())
            {
                child_name = child.name().toString().toLowerCase();

                // 查表未发现匹配类型
                if (!YsMaps.ys_type_map.hasOwnProperty(child_name))
                    return;

                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }
        }

        protected function DoActions(e:StackSendXmlEvent):void
        {
            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var type:String = (e.data.localName().toString().toLocaleLowerCase());

            switch (type)
            {
                case 'action':
                {
                    var func:Function = EventHandlerFactory.get_handler(e.data.toString());
                    func(this);
                    e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
                    break;
                }
                case 'services':
                {
                    //ys_pod.DoService(e, GetServiceXml(_xml.SERVICES[0]));
                    var service:YsService = service_list[curr_service] as YsService;
                    service.DoService(e);

                    curr_service++;
                    break;
                }
            }
        }

        protected function OnBtnClick(event:MouseEvent):void
        {
            var stackUtil:StackUtil = new StackUtil;
            var arr:Array = new Array;
            var serviceNum:int = 0;

            // 初始化service列表的下标初值
            curr_service = 0;

            for each (var kid:XML in _xml.children())
            {
                var type:String = (kid.localName().toString().toLocaleLowerCase());
                if (type == 'services')
                    serviceNum++; //session?
                arr.push(kid);
            }

            var event_bus2windowsXML:XML = <ACTION> event_bus2window </ACTION>;
            arr.push(event_bus2windowsXML);

            var fg:FunctionDelegate = new FunctionDelegate;
            stackUtil.addEventListener(StackUtil.EVENT_STACK_NEXT, fg.create(stackUtil.stack, this, arr));
            //驱动�
            stackUtil.stack(new Event(StackUtil.EVENT_STACK_NEXT), this, arr);
        }

        private function GetServiceXml(service_desc:XML):XML
        {
            var service_value:String = service_desc.toString();
            var link_head:String = 'services://';
            if (service_value.substr(0, link_head.length).toLowerCase() == link_head.toLowerCase())
            {
                var service_name:String = service_value.substr(link_head.length);
                var dts_no:String = _pool.info.SERVICES[service_name].Get().DTS;
                var service_xml:String = _pool.dts[dts_no].__DICT_XML;
                return new XML(service_xml);
            }

            return service_desc;
        }
    }
}