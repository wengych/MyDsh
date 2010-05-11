package com.yspay
{
    import com.esria.samples.dashboard.view.Pod;
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.*;
    import com.yspay.util.StackUtil;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.controls.ComboBox;
    import mx.controls.TextInput;
    import mx.core.Application;
    import mx.events.PropertyChangeEvent;
    import mx.managers.CursorManager;

    public class YsPod extends Pod
    {

        public function YsPod(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            parent_container = parent;
            this.addEventListener(EventPodShowXml.EVENT_NAME, OnShow);
            //this.addEventListener(EventCacheComplete.EVENT_NAME, OnEventCacheComplete);
            //this.addEventListener(DragEvent.DRAG_ENTER, OnDragEnter);

            // _cache = new EventCache(_pool);
            var dts:DBTable = _pool.dts as DBTable;
            main_bus = _pool.MAIN_BUS as UserBus;

            P_cont = _M_data.TRAN.CreatePData(this);
            P_data = _M_data.TRAN.getPData(P_cont);
        }

        public var P_cont:int; //xingj
        public var _M_data:MData = Application.application.M_data; //xingj
        public var main_bus:UserBus;
        protected var P_data:PData; // = new Object; //xingj
        protected var _bus_ctrl_arr:Array = new Array;
        // protected var _cache:EventCache;

        protected var _pool:Pool;
        protected var parent_container:DisplayObjectContainer;

        // ServiceCall回调函数
        public function CallBack(bus:UserBus, service_info:XML, e:StackSendXmlEvent):void
        {
            trace('callback');
            trace(service_info.toXMLString());
            trace(bus);

            var dict_str:String
            var dict_search:String = 'dict://';
            var bus_out_name_args:Array = new Array;
            var dict_list:XMLList = service_info.RecvPKG.BODY.DICT;
            var o:Object;

            if (bus == null)
                return; //?错误处理！

            // 生成输出参数列表
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();

                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
                {
                    bus_out_name_args.push(dict_str.substr(dict_search.length));
                }
            }
            bus_out_name_args.push("__DICT_USER_RTNMSG");
            bus_out_name_args.push("__DICT_USER_RTN");
            bus_out_name_args.push("__YSAPP_SESSION_ATTRS");
            bus_out_name_args.push("__YSAPP_SESSION_SID");
            /* xingjun add roolback
               if(bus.GetFirst("RTN") != "0" && bus.GetFirst("SESSION")!= Null)
               {
               //ROOLBACK
               /*
               bus.roolback()
               Session.Roolback()
               Session = Null;
               bus.rtn = -1;
               bus.rtmsg = "交易回退�

               }
             */
            //var main_bus:UserBus = _pool.MAIN_BUS as UserBus;
            for each (var var_name:String in bus_out_name_args)
            {
                if (bus[var_name] == null)
                    continue;
                main_bus.RemoveByKey(var_name);
                var ys_var:YsVar = bus[var_name];
                main_bus.Add(var_name, ys_var);
            }

            for each (var key_name:String in bus.GetKeyArray())
            {
                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
                {
                    var i:int = 0;
                    for each (var value:YsVar in bus[key_name].value)
                    {
                        P_data.CheckCount(i + 1);
                        P_data.data[i][key_name] = value.toString();

                        i++;
                    }
                    for (; i < P_data.data.length; i++)
                    {
                        if (P_data.data[i][key_name] == null)
                            break;
                        //P_data.data[i][key_name] = null;
                        delete P_data.data[i][key_name];
                    }

                    for (i = P_data.data.length; i >= 0; i--)
                    {

                        trace(o);
                            //delete P_data.data[i];

                    }
                }
//                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
//                    P_data.proxy[0][key_name] = bus[key_name][0].value.toString();
            }
            e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
        }

        public function _YsInfoQueryComplete(event:DBTableQueryEvent):void
        {
            CursorManager.removeBusyCursor();
            var info:DBTable = _pool.info as DBTable;
            if (_M_data.POOL.INFO[event.query_name] != null)
                _M_data.POOL.INFO[event.query_name].removeAll();

            //_M_data.POOL.INFO[event.query_name] = new ArrayCollection;

            for each (var dict_obj:QueryObject in info[event.query_name])
            {
                var ys_var:YsVarStruct = dict_obj.Get();
                var vare:Object = new Object;
                vare["APPNAME"] = ys_var.APPNAME.getValue();
                vare["CDATE"] = ys_var.CDATE.getValue();
                vare["CUSER"] = ys_var.CUSER.getValue();
                vare["DTS"] = ys_var.DTS.getValue();
                vare["ISUSED"] = ys_var.ISUSED.getValue();
                vare["MDATE"] = ys_var.MDATE.getValue();
                vare["MEMO"] = ys_var.MEMO.getValue();
                vare["MUSER"] = ys_var.MUSER.getValue();
                vare["NAME"] = ys_var.NAME.getValue();
                vare["TYPE"] = ys_var.TYPE.getValue();
                vare["VALUE"] = ys_var.VALUE.getValue();
                vare["VER"] = ys_var.VER.getValue();
                _M_data.POOL.INFO[event.query_name].addItem(vare);
            }
            _M_data.POOL.INFO[event.query_name].refresh();
            //xingj ..
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

        private function OnShow(event:EventPodShowXml):void
        {
            //_cache.DoCache(event.xml.toXMLString(), this);
            var node_name:String = event.xml.localName().toString().toLocaleLowerCase();

            // 查表未发现匹配类型
            if (!YsMaps.ys_type_map.hasOwnProperty(node_name))
                return;

            var child_xml:XML = UtilFunc.FullXml(event.xml);
            var child_ctrl:YsControl = new YsMaps.ys_type_map[node_name](this);
            child_ctrl.Init(child_xml);
        }

        public function updateChange(evt:PropertyChangeEvent):void //未考虑哪个proxy发送的请求xjxjxj
        {
            var dictname:String = evt.property as String;
            var dictNum:String = evt.source.DictNum;
            var dictvalue:String = evt.newValue as String;

            var i:int;
            var j:int;

            for (i = 0; i < P_data.ctrls_proxy.length; i++)
            {
                if (P_data.ctrls_proxy[i][dictname] == null)
                    break;
                if (P_data.ctrls_proxy[i][dictname][dictNum] == null)
                    break;
                if (P_data.ctrls_proxy[i][dictname][dictNum] is TextInput)
                    P_data.ctrls_proxy[i][dictname][dictNum].text = dictvalue;
                else if (P_data.ctrls_proxy[i][dictname][dictNum] is ComboBox)
                {
                    for each (var O:Object in P_data.ctrls_proxy[i][dictname][dictNum].dataProvider)
                    {
//                        if (O[P_data.ti[i][dictname][dictNum].data.xml.text().toString()] == dictvalue)
//                            P_data.ti[i][dictname][dictNum].selectedItem = O;
                        if (O[dictname] == dictvalue)
                            P_data.ctrls_proxy[i][dictname][dictNum].selectedItem = O;
                    }
                }
            }


            //copy(p_data[datad][*][dictname] = P_data._data[*][dictname]

            var datad:String;

            for (i = 0; i < P_data.data_grid.length; i++)
            {
                if (!P_data.data_grid[i].hasOwnProperty(dictname))
                    break;
                datad = P_data.data_grid[i][dictname];

                for (j = 0; j < P_data[datad].length; j++)
                    delete P_data[datad][j][dictname];

                for (j = 0; j < P_data._data.length; j++)
                {
                    if (P_data._data[j][dictname] == null)
                        break;

                    if (P_data[datad].length <= j)
                        P_data[datad].addItem(new Object);
                    P_data[datad][j][dictname] = P_data._data[j][dictname];
                }
                P_data[datad].refresh();
            }
        }
    }
}
