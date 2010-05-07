package com.yspay
{
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.Pool;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.StackUtil;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.controls.Button;
    import mx.core.Application;

    public class YsButton extends Button implements YsControl
    {
        protected var _xml:XML;
        protected var _pool:Pool;

        public function YsButton()
        {
            super();
            _pool = Application.application.pool;
        }

        public function Init(xml:XML):void
        {
            this.label = xml.@LABEL;
            _xml = xml;
            var func_delegate:FunctionDelegate = new FunctionDelegate;
            this.addEventListener(MouseEvent.CLICK, OnBtnClick);
            var fd:FunctionDelegate = new FunctionDelegate;
            this.addEventListener(StackSendXmlEvent.EVENT_STACK_SENDXML, fd.create(DoActions, this));
            this.addEventListener(MouseEvent.CLICK, OnBtnClick);
            this.setStyle('fontWeight', 'normal');
        }

        protected function DoActions(e:StackSendXmlEvent):void
        {
            var type:String = (_xml.localName().toString().toLocaleLowerCase());
            switch (type)
            {
                case 'action':
                {
                    //if (event_obj.hasOwnProperty(action))
                    {
                        var func:Function = EventHandlerFactory.get_handler(_xml);
                        func(this);
                        e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
                    }
                    /*else
                       {
                       trace('no this function: ', action);
                     }*/
                    break;
                }
                case 'services':
                {
                    DoService(e, GetServiceXml(_xml));
                    break;
                }
            }
        }

        protected function OnBtnClick(event:MouseEvent):void
        {
            var stackUtil:StackUtil = new StackUtil;
            var arr:Array = new Array;
            var serviceNum:int = 0;
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

        private function CallBack(bus:UserBus):void
        {
            trace("service call callback");
        }

        private function DoService(e:StackSendXmlEvent, service:XML):void
        {
            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            var scall_name:String = service.SendPKG.HEAD.@active;
            var dict_list:XMLList = service.SendPKG.BODY.DICT;

            // service.@SENDBUS;
            // service.@RECVBUS;

            // 生成输入参数列表
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();

                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
                {
                    bus_in_name_args.push(dict_str.substr(dict_search.length));
                }
            }
            var scall:ServiceCall = new ServiceCall;
            var bus:UserBus = new UserBus;
            bus.Add(ServiceCall.SCALL_NAME, scall_name);
            //var_name=dict名字
            for each (var var_name:String in bus_in_name_args) //从本地P_data中取得所需数据
            {
                /*
                   if (!P_data.data[0].hasOwnProperty(var_name))
                   {
                   var ys_var:YsVar = main_bus[var_name];
                   bus.Add(var_name, ys_var);
                   }
                   else
                   {
                   for (var i:int = 0; i < P_data.data.length; i++)
                   {
                   if (P_data.data[i][var_name] == null)
                   break;
                   bus.Add(var_name, P_data.data[i][var_name]);
                   }
                 }*/
            }
            var ip:String = this.parentApplication.GetServiceIp(scall_name);
            var port:String = this.parentApplication.GetServicePort(scall_name);
            var func_dele:FunctionDelegate = new FunctionDelegate;
            //Alert.show(bus.toString());
            scall.Send(bus, ip, port, func_dele.create(CallBack, service, e));
        }
    }
}