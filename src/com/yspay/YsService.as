package com.yspay
{
    import com.yspay.YsData.PData;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;

    import mx.controls.Alert;
    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Application;
    import mx.core.Container;

    public class YsService implements YsControl
    {
        protected var _parent:DisplayObjectContainer;
        protected var service_info:XML;
        protected var _pool:Pool;
        public var main_bus:UserBus;

        public function YsService(parent:DisplayObjectContainer)
        {
            _parent = parent;
            _pool = Application.application._pool;
            main_bus = _pool.MAIN_BUS as UserBus;
        }

        public function Init(xml:XML):void
        {
            service_info = new XML(xml);
            (_parent as Object).service_list.push(this);
        }

        protected function AddDDataToBus(container:Object, var_name:String, bus:UserBus):Boolean
        {
            for each (var child:Object in container.getChildren())
            {
                if (child is TextArea || child is TextInput)
                {
                    if (child.data.From == "D_data" && child.data.To == "D_data") //纯私有数据
                        if (child.data.name == var_name)
                        {
                            bus.Add(child.data.name, child.text);
                            return true;
                        }
                }
                else if (child is Container)
                {
                    if (true == AddDDataToBus(child, var_name, bus))
                        return true;
                }
            }

            return false;
        }

        // 调用ServiceCall
        public function DoService(e:StackSendXmlEvent):void
        {
            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            service_info = UtilFunc.FullXml(service_info);
            var scall_name:String = service_info.SendPKG.HEAD.@active;
            var dict_list:XMLList = service_info.SendPKG.BODY.DICT;
            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];

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
                //首先从Textinput中的data.From是D_data，data.To也是D_data 中取得数据   ??????????????????

                var O:Object = this._parent;

                while (O != null)
                {
                    if (O is YsHBox || O is YsPod || O is YsTitleWindow)
                        break;
                    O = O.parent;
                }

                if (AddDDataToBus(O, var_name, bus) == true)
                    continue;

                if (!P_data._data[0].hasOwnProperty(var_name)) //如果P_data中没有改数据，从MAIN BUS中取得
                {
                    var ys_var:YsVar = main_bus[var_name];
                    bus.Add(var_name, ys_var);
                }
                else
                {
                    for (var i:int = 0; i < P_data._data.length; i++)
                    {
                        if (P_data._data[i][var_name] == null)
                            break;
                        bus.Add(var_name, P_data._data[i][var_name]);
                    }
                }
            }
            var ip:String = ys_pod.parentApplication.GetServiceIp(scall_name);
            var port:String = ys_pod.parentApplication.GetServicePort(scall_name);
            var func_dele:FunctionDelegate = new FunctionDelegate;
            Alert.show(bus.toString());
            scall.Send(bus, ip, port, func_dele.create(ys_pod.CallBack, service_info, e));
        }
    }
}
