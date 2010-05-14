package com.yspay.YsControls
{
    import com.esria.samples.dashboard.view.Pod;
    import com.yspay.UserBus;
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.YsVar;
    import com.yspay.YsVarStruct;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.pool.*;
    import com.yspay.util.UtilFunc;
    import flash.display.DisplayObjectContainer;
    import mx.core.Application;
    import mx.events.PropertyChangeEvent;
    import mx.managers.CursorManager;
    import mx.utils.object_proxy;

    use namespace object_proxy;

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

            D_data = P_data;
        }

        public var D_data:PData;
        public var P_cont:int; //xingj
        public var _M_data:MData = Application.application.M_data; //xingj
        public var main_bus:UserBus;
        protected var P_data:PData; // = new Object; //xingj
        protected var _bus_ctrl_arr:Array = new Array;
        // protected var _cache:EventCache;

        protected var _pool:Pool;
        protected var parent_container:DisplayObjectContainer;

        // TODO: CallBack的职责由YsService负责
        // ServiceCall回调函数
        public function CallBack(bus:UserBus, service_info:XML, Ysser:YsService):void
        {
            var _xml:XML = service_info;
            var _to_xml:XMLList = _xml.To;

            service_info = UtilFunc.FullXml(service_info);
            trace('callback');
            trace(service_info.toXMLString());
            trace(bus);
            if (bus == null)
                return; //?错误处理！

            var rtn:int = bus.__DICT_USER_RTN[0].value;

            if (rtn != 0)
                return;

            var bus_out_name_args:Array = GetBusArgs('dict://', service_info);
            var key_name:String;
            var ys_var:YsVar;

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
                ys_var = bus[var_name];
                main_bus.Add(var_name, ys_var);
            }

            for each (key_name in bus.GetKeyArray())
            {
                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
                {
                    var arr:Array = new Array;
                    for each (ys_var in bus.GetVarArray(key_name))
                    {
                        arr.push(ys_var.value);
                    }
                    P_data.data[key_name] = arr;
                }
            }
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

                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
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
    }
}
