package com.yspay
{
    import com.yspay.YsData.PData;
    import com.yspay.events.StackEvent;
    import com.yspay.pool.*;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.core.Application;
    import mx.core.Container;

    public class YsService extends YsAction
    {
        protected var _pool:Pool;
        public var main_bus:UserBus;

        public function YsService(parent:DisplayObjectContainer)
        {
            super(parent);
            _pool = Application.application._pool;
            main_bus = _pool.MAIN_BUS as UserBus;
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);
        }

        protected function AddDDataToBus(container:Object, var_name:String, bus:UserBus):Boolean
        {
            for each (var child:Object in container.getChildren())
            {
                //if (child is TextArea || child is TextInput)
                if (child is YsDict)
                {
                    if (child.dict.From == "D_data" && child.dict.To == "D_data") //纯私有数据
                        if (child.dict.name == var_name)
                        {
                            bus.Add(child.dict.name, child.text);
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
        public override function Do(stack_event:StackEvent, source_event:Event):void
        {
            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            var bus_in_const_args:Array = new Array;
            var full_xml:XML = UtilFunc.FullXml(action_info);
            if (full_xml == null)
            {
                _parent.dispatchEvent(source_event);
                return;
            }

            for each (var action_item:XML in action_info.elements())
            {
                full_xml.appendChild(action_item);
                    //bus_in_const_args.push(action_item.text().toString());
            }

            var scall_name:String = full_xml.SendPKG.HEAD.@active;
            var dict_list:XMLList = full_xml.SendPKG.BODY.DICT;
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

            for each (var const_item_xml:XML in full_xml["CONST"])
            {
                var const_item_key:String = const_item_xml.text().toString();
                for each (var const_value_xml:XML in const_item_xml["VALUE"])
                {
                    var const_value:String = const_value_xml.text().toString();
                    bus.Add(const_item_key, const_value);
                }
            }

            //var_name=dict名字
            for each (var var_name:String in bus_in_name_args) //从本地P_data中取得所需数据
            {
                if (bus[var_name] != null)
                    continue;

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
            var ip:String = Application.application.GetServiceIp(scall_name);
            var port:String = Application.application.GetServicePort(scall_name);

            var func:Function = function(new_bus:UserBus):void
                {
                    ServiceCallBack(new_bus, stack_event);
                }
            //Alert.show(bus.toString());
            scall.Send(bus, ip, port, func);
        }

        protected function ServiceCallBack(bus:UserBus, event:StackEvent):void
        {
            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            ys_pod.CallBack(bus, action_info);

            _parent.dispatchEvent(event);
        }
    }
}
