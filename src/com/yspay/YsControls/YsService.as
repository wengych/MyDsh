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
    import mx.core.FlexGlobals;

    public class YsService extends YsAction
    {
        protected var scall:ServiceCall;
        protected var _pool:Pool;
        public var prepareEmptyDict:Boolean;
        public var main_bus:UserBus;

        public function YsService(parent:DisplayObjectContainer)
        {
            super(parent);
            _pool = FlexGlobals.topLevelApplication._pool;
            main_bus = _pool.MAIN_BUS as UserBus;
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);
            _to.Init(this, xml.To);
            _from.Init(this, xml.From);

            UtilFunc.InitAttrbutes(YsMaps.service_attrs, this, _xml);
            UtilFunc.InitChild(this, _xml);
        }

        // 从_from中取得所有输入数据源，逐一查找对应key，找到后将值加入bus并返回true
        // 未找到对应key则返回false
        public function AddBusDataFromPData(bus:UserBus, key:String, type:String):Boolean
        {
            var from_targets:Array = _from.GetAllTarget();
            var from_target_names:Array = _from.GetAllTargetName();
            var data_item:Object;

            for (var idx:int = 0; idx < from_targets.length; ++idx)
            {
                var from_item:PData = from_targets[idx];
                var from_name:String = from_target_names[idx];
                if (from_item.data[key] == undefined)
                    continue;

                var dict_idx:int = UtilFunc.GetDataIndex(from_item, key, this);
                if (dict_idx >= 0)
                {
                    bus.RemoveByKey(key);
                    trace('YsService.AddBusDataFromPData:: ', key, 'dict_idx', dict_idx);
                    data_item = from_item.data[key];
                    if (data_item.length < dict_idx)
                        continue;
                    if (type == 'STRING')
                        bus.Add(key, from_item.data[key][dict_idx]);
                    else if (type == 'INT')
                        bus.Add(key, int(from_item.data[key][dict_idx]));
                }
                else
                {
                    trace('YsService.AddBusDataFromPData:: ', key);
                    for each (data_item in from_item.data[key])
                    {
                        if (type == 'STRING')
                            bus.Add(key, data_item.toString());
                        else if (type == 'INT')
                            bus.Add(key, int(data_item));
                    }
                    return true;
                }
            }

            return false;
        }

        // 取Service参数列表
        protected function SetBusArgs(dict_list:XMLList, names:Array, types:Array):void
        {
            var dict_str:String;
            var dict_name:String;
            var dict_type:String;
            var dict_search:String = 'dict://';
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();
                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
                {
                    dict_name = dict_str.substr(dict_search.length);
                }
                var pool:Pool = FlexGlobals.topLevelApplication._pool;

                if (!pool.info.DICT.hasOwnProperty(dict_name))
                    continue;
                var dts_no:String = pool.info.DICT[dict_name].Get().DTS;
                dict_xml = new XML(pool.dts[dts_no].__DICT_XML);
                dict_type = dict_xml.services.@TYPE;

                names.push(dict_name);
                types.push(dict_type);
            }
        }


        // 调用ServiceCall
        public override function Do(stack_event:StackEvent, source_event:Event):void
        {
            scall = new ServiceCall;
            var pod:YsPod = UtilFunc.GetParentByType(this._parent, YsPod) as YsPod;
            if (pod != null)
                pod.enabled = false;
            if ((this._parent as YsButton)._parent is YsDgListItem)
            {
                pod.enabled = true;
            }

            var bus_in_name_args:Array = new Array;
            var bus_in_type_args:Array = new Array;
            var bus_in_const_args:Array = new Array;

            var scall_name:String = _xml.SendPKG[0].HEAD[0].@active;
            var dict_in_list:XMLList = _xml.SendPKG.BODY.DICT;

            SetBusArgs(dict_in_list, bus_in_name_args, bus_in_type_args);


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
            for (var idx:int = 0; idx < bus_in_name_args.length; ++idx)
            {
                var var_name:String = bus_in_name_args[idx];
                var var_type:String = bus_in_type_args[idx];

                if (bus[var_name] != null)
                    continue;

                if (AddBusDataFromPData(bus, var_name, var_type) == true)
                    continue;

                var ys_var:YsVar = main_bus[var_name];
                if (ys_var == null)
                    continue;

                bus.Add(var_name, ys_var);
            }

            var ip:String = FlexGlobals.topLevelApplication.GetServiceIp(scall_name);
            var port:String = FlexGlobals.topLevelApplication.GetServicePort(scall_name);

            var func:Function = function(new_bus:UserBus, error_event:ErrorEvent=null):void
            {
                ServiceCallBack(new_bus, stack_event, error_event);
            }
            trace(bus.toString());
            scall.Send(bus, ip, port, func);
        }

        protected var To_Map:Object = {'pod': YsPod, 'windows': YsTitleWindow, 'dict': YsDict,
                'event': YsXmlEvent, 'hbox': YsHBox, 'vbox': YsVBox, 'dg_list': YsDgListItem,
                'datagrid': YsDataGrid};

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
                ys_ctrl = UtilFunc.YsGetParentByType(this._parent, parent_type);

                return GetDData(ys_ctrl);
            }
            else if (to_item_name == 'MAINBUS')
            {
                return FlexGlobals.topLevelApplication._pool.MAIN_BUS;
            }
            else if (to_item_name.search('parent') == 0)
            {
                return GetDData(this._parent);
            }
            else
            {
                return null;
            }
        }

        protected function ServiceCallBack(bus:UserBus, event:StackEvent, error_event:ErrorEvent):void
        {
            var pod:YsPod = UtilFunc.YsGetParentByType(this._parent, YsPod) as YsPod;
            var pool:Pool = FlexGlobals.topLevelApplication._pool;

            var bus_out_name_args:Array = GetBusArgs(_xml);
            if (bus == null)
            {
                pool.SERVICE_RTN.SCALL_RTN = '服务调用出错';
                Alert.show('服务调用出错,bus为空' + '\n' + '            服务名:' + action_name);
                event.result = false;
                this._parent.dispatchEvent(event);
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
                user_rtn_msg = bus.__DICT_USER_RTNMSG[0].value + ' (' + bus[ServiceCall.SCALL_NAME][0] + ')';
            }

            pool.SERVICE_RTN.SCALL_RTN = scall_rtn;
            pool.SERVICE_RTN.USER_RTN = user_rtn;
            pool.SERVICE_RTN.USER_RTN_MSG = user_rtn_msg;

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

            if (this.prepareEmptyDict == true)
            {
                for each (to_obj in to_arr)
                {
                    if (to_obj is PData)
                    {
                        for each (var dict_name:String in bus_out_name_args)
                            to_obj.ClearDict(dict_name);
                    }
                }
            }

            if (scall_rtn != 0)
            {
                event.result = false;
                this._parent.dispatchEvent(event);
                pod.enabled = true;
                return;
            }

            if (user_rtn != 0)
            {
                trace('Service: USER_RTN: ', user_rtn.toString());
                event.result = false;
                this._parent.dispatchEvent(event);
                pod.enabled = true;
                return;
            }

            for each (to_obj in to_arr)
            {
                if (to_obj is PData)
                    to_obj.Update(bus, bus_out_name_args);
                else if (to_obj is UserBus)
                {
                    for each (var var_name:String in bus_out_name_args)
                    {
                        if (bus[var_name] == null)
                            continue;
                        main_bus.RemoveByKey(var_name);
                        main_bus.Add(var_name, bus[var_name]);
                    }
                }
            }

            if (pod != null)
                pod.enabled = true;

            this._parent.dispatchEvent(event);
        }


        private function GetBusArgs(xml:XML):Array
        {
            var search_str:String = 'dict://';
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
            /*
               arr.push("__DICT_USER_RTNMSG");
               arr.push("__DICT_USER_RTN");
               arr.push("__YSAPP_SESSION_ATTRS");
               arr.push("__YSAPP_SESSION_SID");
             */
            return arr;
        }
    }
}
