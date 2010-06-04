package com.yspay.YsControls
{
    import com.yspay.*;
    import com.yspay.YsData.PData;
    import com.yspay.events.StackEvent;
    import com.yspay.pool.*;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.ErrorEvent;
    import flash.events.Event;

    import mx.controls.Alert;
    import mx.core.Application;

    public class YsService extends YsAction
    {
        protected var _pool:Pool;
        //protected var _to:TargetList = new TargetList;
        //protected var _from:TargetList = new TargetList;
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
            _to.Init(this, xml.To);
            _from.Init(this, xml.From);
        }

        // 从_from中取得所有输入数据源，逐一查找对应key，找到后将值加入bus并返回true
        // 未找到对应key则返回false
        public function AddBusDataFromPData(bus:UserBus, key:String):Boolean
        {

            for each (var from_item:PData in _from.GetAllTarget())
            {
                if (from_item.data.hasOwnProperty(key))
                {
                    for each (var data_item:* in from_item.data[key])
                        bus.Add(key, data_item);
                    return true;
                }
            }

            return false;
        }

        // 调用ServiceCall
        public override function Do(stack_event:StackEvent, source_event:Event):void
        {
            var pod:YsPod = UtilFunc.GetParentByType(this._parent, YsPod) as YsPod;
            pod.enabled = false;

            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            var bus_in_const_args:Array = new Array;

            var scall_name:String = _xml.SendPKG.HEAD.@active;
            var dict_list:XMLList = _xml.SendPKG.BODY.DICT;

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

            // 向bus中添加const项
            for each (var const_item_xml:XML in _xml["CONST"])
            {
                var const_item_key:String = const_item_xml.text().toString();
                for each (var const_value_xml:XML in const_item_xml["VALUE"])
                {
                    var const_value:String = const_value_xml.text().toString();
                    bus.Add(const_item_key, const_value);
                }
            }

            //var_name=dict名字
            // 向bus中添加所有输入项
            for each (var var_name:String in bus_in_name_args) //从本地P_data中取得所需数据
            {
                if (bus[var_name] != null)
                    continue;

                if (AddBusDataFromPData(bus, var_name) == true)
                    continue;

                var ys_var:YsVar = main_bus[var_name];
                if (ys_var == null)
                    continue;

                bus.Add(var_name, ys_var);
            }

            var ip:String = Application.application.GetServiceIp(scall_name);
            var port:String = Application.application.GetServicePort(scall_name);

            var func:Function =
                function(new_bus:UserBus,
                         error_event:ErrorEvent=null):void
                {
                    ServiceCallBack(new_bus, stack_event, error_event);
                }
            //Alert.show(bus.toString());
            scall.Send(bus, ip, port, func);
        }

        protected var To_Map:Object = {'pod': YsPod, 'windows': YsTitleWindow,
                'dict': YsDict, 'event': YsXmlEvent};

        protected function GetDData(obj:Object):Object
        {
            if (obj.hasOwnProperty('D_data'))
                return obj.D_data;
            else
                return null;
        }

        protected function GetToObject(to_item_name:String):Object
        {
            if (To_Map.hasOwnProperty(to_item_name))
            {
                var ys_ctrl:Object;

                var parent_type:Class = To_Map[to_item_name];
                ys_ctrl = UtilFunc.GetParentByType(_parent, parent_type);

                return GetDData(ys_ctrl);
            }
            else if (to_item_name == 'MAINBUS')
            {
                return Application.application._pool.MAIN_BUS;
            }
            else if (to_item_name.search('parent') == 0)
            {
                return GetDData(_parent);
            }
            else
            {
                return null;
            }
        }

        protected function ServiceCallBack(bus:UserBus,
                                           event:StackEvent,
                                           error_event:ErrorEvent):void
        {
            var pod:YsPod = UtilFunc.GetParentByType(this._parent, YsPod) as YsPod;
            if (bus == null)
            {
                Alert.show('服务调用出错,bus为空' + '\n' +
                           '            服务名:' + action_name);
                _parent.dispatchEvent(event);
                pod.enabled = true;
                return;
            }

            var scall_rtn:int = -1;
            var user_rtn:int = -1;
            var user_rtn_msg:String = '';

            if (bus.hasOwnProperty('__DICT_SCALL_RTN'))
                scall_rtn = bus.__DICT_SCALL_RTN[0].value;

            if (bus.hasOwnProperty('__DICT_USER_RTN'))
            {
                user_rtn = bus.__DICT_USER_RTN[0].value;
                user_rtn_msg = bus.__DICT_USER_RTNMSG[0].value;
            }

            var pool:Pool = Application.application._pool;
            pool.SERVICE_RTN.SCALL_RTN = scall_rtn;
            pool.SERVICE_RTN.USER_RTN = user_rtn;
            pool.SERVICE_RTN.USER_RTN_MSG = user_rtn_msg;

            if (user_rtn != 0 || scall_rtn != 0)
            {
                _parent.dispatchEvent(event);
                pod.enabled = true;
                return;
            }


            // action_info
            //        <To>pod</To>
            //        <To>windows</To>
            //        <To>dict</To>
            //        <To>event</To>
            //        <To>parent</To>
            //        <To>parent.parent...</To>
            //        <To>MAINBUS</To>
            var to_arr:Array = new Array;
            var to_obj:Object = null;

            for each (var action_to_item:XML in _xml.To)
            {
                to_obj = GetToObject(action_to_item.text().toString());
                if (to_obj != null)
                    to_arr.push(to_obj);
            }

            for each (to_obj in to_arr)
            {
                if (to_obj is PData)
                    to_obj.Update(bus);
                else if (to_obj is UserBus)
                {
                    var bus_out_name_args:Array = GetBusArgs('dict://', _xml);
                    for each (var var_name:String in bus_out_name_args)
                    {
                        if (bus[var_name] == null)
                            continue;
                        main_bus.RemoveByKey(var_name);
                        main_bus.Add(var_name, bus[var_name]);
                    }
                }
            }

            pod.enabled = true;

            _parent.dispatchEvent(event);
        }


        private function GetBusArgs(search_str:String, xml:XML):Array
        {
            var dict_str:String;
            var arr:Array = new Array;
            var dict_search:String = search_str;
            var dict_list:XMLList = xml.RecvPKG.BODY.DICT;
            // 生成输出参数列表
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();
                var pre_link_str:String = dict_str.substr(0, dict_search.length);

                if (pre_link_str.toLowerCase() == dict_search)
                {
                    arr.push(dict_str.substr(dict_search.length));
                }
            }
            arr.push("__DICT_USER_RTNMSG");
            arr.push("__DICT_USER_RTN");
            arr.push("__YSAPP_SESSION_ATTRS");
            arr.push("__YSAPP_SESSION_SID");
            return arr;
        }
    }
}
