package com.yspay
{
    import com.esria.samples.dashboard.view.NewWindow;
    import com.esria.samples.dashboard.view.Pod;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.StackUtil;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.ComboBox;
    import mx.controls.DataGrid;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.Application;
    import mx.events.DragEvent;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.CursorManager;
    import mx.managers.DragManager;
    import mx.utils.ObjectProxy;

    public class YsPod extends Pod
    {

        public function YsPod(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            parent_container = parent;

            this.addEventListener(EventPodShowXml.EVENT_NAME, OnShow);
            this.addEventListener(EventCacheComplete.EVENT_NAME, OnEventCacheComplete);
            this.addEventListener(DragEvent.DRAG_ENTER, OnDragEnter);

            _cache = new EventCache(_pool);
            var dts:DBTable = _pool.dts as DBTable;
            main_bus = _pool.MAIN_BUS as UserBus;

            P_cont = _M_data.TRAN.cont;
            _M_data.TRAN.cont++;
            _M_data.TRAN[P_cont] = P_data;

            P_data.cont = 1000;
            P_data.obj = this;
            P_data.data = new ArrayCollection;
            P_data.proxy = new ArrayCollection;

            P_data.data.addItem(new Object);
            P_data.proxy.addItem(new Object);
            var proxy:ObjectProxy = new ObjectProxy(P_data.data[0]);
            proxy.DictNum = 0;
            proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                                   updateChange);
            P_data.proxy[0] = proxy;
            P_data.ti = new ArrayCollection;
            P_data.ti.addItem(new Object);
            P_data.DataGrid = new ArrayCollection;
            P_data.DataGrid.addItem(new Object);

        }

        public var P_cont:int; //xingj
        public var _M_data:Object = Application.application.M_data; //xingj
        public var main_bus:UserBus;
        protected var P_data:Object = new Object; //xingj
        protected var _bus_ctrl_arr:Array = new Array;
        protected var _cache:EventCache;
        protected var parent_container:DisplayObjectContainer;

        protected var _pool:Pool;

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
                        if (P_data.data.length <= i)
                        {
                            P_data.data.addItem(new Object);
                            P_data.proxy.addItem(new Object);
                            var proxy:ObjectProxy;
                            proxy = new ObjectProxy(P_data.data[i]);
                            proxy.DictNum = i;
                            proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                                                   updateChange);
                            P_data.proxy[i] = proxy;
                        }
                        P_data.proxy[i][key_name] = value.toString();
                        i++;
                    }
                }
//                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
//                    P_data.proxy[0][key_name] = bus[key_name][0].value.toString();
            }
            e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
        }

        public function OnEventCacheComplete(event:EventCacheComplete):void
        {
            P_data.XML = event.cache_xml;
            var dxml:XML = FullXml(event.cache_xml);

            ShowItem(dxml);
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

        public function onDragDropHandler(e:DragEvent, action:String):void
        {
            var xml:XML = <windows />
            var str:String = 'windows://' + (e.dragInitiator as DataGrid).selectedItem.NAME;
            xml.appendChild(str);
            _cache.DoCache(xml.toXMLString(), this);
        }

        protected function OnDragEnter(event:DragEvent):void
        {
            if (this == event.currentTarget)
                DragManager.acceptDragDrop(this);
        }

        // 调用ServiceCall
        private function DoService(e:StackSendXmlEvent, service:XML):void
        {
            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            var scall_name:String = service.SendPKG.HEAD.@active;
            var dict_list:XMLList = service.SendPKG.BODY.DICT;

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
                }
            }
            var ip:String = this.parentApplication.GetServiceIp(scall_name);
            var port:String = this.parentApplication.GetServicePort(scall_name);
            var func_dele:FunctionDelegate = new FunctionDelegate;
            Alert.show(bus.toString());
            scall.Send(bus, ip, port, func_dele.create(CallBack, service, e));
        }

        // 替换链接为完整xml
        private function FullXml(xml:XML):XML
        {
            var rtn:XML = xml;

            var search_str:String = '://';
            var url:String = xml.text();
            var idx:int = url.search(search_str);
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                if (_pool.info[query_key][obj_key] == undefined)
                {
                    Alert.show('error！');
                    return null;
                }
                var dts_no:String = _pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;
                rtn = new XML(xml);
                delete rtn.*;
                var temp:XML = new XML(dts[dts_no].__DICT_XML);
                rtn.appendChild(temp.children());
            }

            return rtn;
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
            _cache.DoCache(event.xml.toXMLString(), this);
        }


        private function ShowPool(container:*, dict_xml:XML):void
        {
            var search_str:String = '://';
            var url:String = dict_xml.text();
            var idx:int = url.search(search_str);
            var dxml:XML;
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                var query_obj:QueryObject = _pool.info[query_key][obj_key];

                if (query_obj == null)
                {
                    Alert.show('no this key in pool.info.' + query_key + '.' + obj_key);
                    return;
                }

                var dts_no:String = query_obj.Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;

                dxml = dict_xml;
                delete dxml.*;
                var temp:XML = new XML(dts[dts_no].__DICT_XML);
                dxml.appendChild(temp.children());
            }
            else
                dxml = dict_xml;

            if (container is DataGrid)
            {

                var dg:DataGrid = container;
                var arr_xml:XMLList = dxml.object.object.object;
                for each (var field_xml:XML in arr_xml)
                {
                    var dgc:DataGridColumn =  new DataGridColumn;
                    var obj_name:String = field_xml.text();
                    var obj_title:String = field_xml.@id;

                    dgc.headerText = obj_title;
                    dgc.dataField = obj_name;
                    dg.columns = dg.columns.concat(dgc);
                }
            }
        }

        //相当于入口�
        private function ShowItem(xml:XML):void
        {
            var dxml:XML = FullXml(xml);
            var node_name:String = dxml.localName().toString().toLocaleLowerCase();
//            <pod>
//              11
//              <windows>
//                 WINDOWS://290
//              </windows>
//            </pod>
            if (node_name == 'pod')
            {
                for each (var child:XML in dxml.elements())
                {
                    ShowItem(child);
                }
            }
            else
            {
                var child_ctrl:YsControl = new YsMaps.ys_type_map[node_name](this);

                child_ctrl.Init(dxml);
            }
        }

        private function comboboxchange(evt:Event):void
        {

            var tmpcobox:ComboBox = evt.target as ComboBox;

            var o:Object = (evt.target as ComboBox).selectedItem;
            if (o == null)
                return;
            var x:XML = tmpcobox.data.xml;
            P_data.proxy[tmpcobox.data.index][tmpcobox.data.name] = o[x.services.@NAME];

            P_data.data.refresh();
        }

        private function comboboxshowlabel(item:Object):String
        {
            var returnvalue:String = new String;
            if (item.hasOwnProperty("mx_internal_uid"))
                item.setPropertyIsEnumerable('mx_internal_uid', false);

            for (var o:Object in item)

                returnvalue += item[o].toString() + ' - ';

            return (returnvalue.substring(0, returnvalue.length - 3));
        }

        private function enterHandler(event:FlexEvent):void
        {
            var current:TextInput = event.target as TextInput;
            var o:Object = current.parent;
            var arr:Array = new Array;
            if (o is FormItem)
            {
                for each (var t:Object in o.parent.getChildren())
                {
                    for each (var textinput:* in t.getChildren())
                    {
                        if (textinput is TextInput)
                        {
                            arr.push(textinput);
                        }
                    }
                }
            }
            else
            {
                for each (var textinput1:* in o.getChildren())
                {
                    if (textinput1 is TextInput)
                    {
                        arr.push(textinput1);
                    }
                }
            }
            for (var i:int = 0; i < arr.length; i++)
            {
                if (arr[i] == current)
                {
                    if (i != arr.length - 1)
                        (arr[i + 1] as TextInput).setFocus();
                    else
                        (arr[0] as TextInput).setFocus();
                }
            }
        }

        private function tichange(evt:Event):void
        {
            var tt:TextInput = evt.target as TextInput;
            P_data.proxy[tt.data.index][tt.data.name] = tt.text;
            P_data.data.refresh();
        }

        private function updateChange(evt:PropertyChangeEvent):void //未考虑哪个proxy发送的请求xjxjxj
        {
            var dictname:String = evt.property as String;
            var dictNum:String = evt.source.DictNum;
            var dictvalue:String = evt.newValue as String;

            for (var i:int = 0; i < P_data.ti.length; i++)
            {
                if (P_data.ti[i][dictname] == null)
                    break;
                if (P_data.ti[i][dictname][dictNum] == null)
                    break;
                if (P_data.ti[i][dictname][dictNum] is TextInput)
                    P_data.ti[i][dictname][dictNum].text = dictvalue;
                else if (P_data.ti[i][dictname][dictNum] is ComboBox)
                {
                    for each (var O:Object in P_data.ti[i][dictname][dictNum].dataProvider)
                    {
//                        if (O[P_data.ti[i][dictname][dictNum].data.xml.text().toString()] == dictvalue)
//                            P_data.ti[i][dictname][dictNum].selectedItem = O;
                        if (O[dictname] == dictvalue)
                            P_data.ti[i][dictname][dictNum].selectedItem = O;
                    }
                }
            }
            for (var i:int = 0; i < P_data.DataGrid.length; i++)
            {
                if (P_data.DataGrid[i][dictname] == null)
                    break;

                var dataw:String = P_data.DataGrid[i][dictname]["W_data"];
                var datad:String = P_data.DataGrid[i][dictname]["D_data"];
                if (P_data[dataw] == undefined)
                    break;
                if (P_data[dataw][datad] == undefined)
                    break;
                if (P_data[dataw][datad][dictNum] == undefined)
                    break;
                if (P_data[dataw][datad][dictNum][dictname] == undefined)
                    break;
                P_data[dataw][datad][dictNum][dictname] = dictvalue;
            }
        }
    }
}
