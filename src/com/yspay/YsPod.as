package com.yspay
{
    import com.esria.samples.dashboard.view.NewWindow;
    import com.esria.samples.dashboard.view.Pod;
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Pool;
    import com.yspay.pool.QueryObject;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.StackUtil;

    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;
    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.DataGrid;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.Application;
    import mx.core.Container;
    import mx.events.DragEvent;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.DragManager;
    import mx.managers.PopUpManager;
    import mx.utils.ObjectProxy; //xingj

    public class YsPod extends Pod
    {
        public var _M_data:Object = Application.application.M_data; //xingj
        protected var _pool:Pool;
        protected var _cache:EventCache;
        protected var _bus_ctrl_arr:Array = new Array;
        protected var P_data:Object = new Object; //xingj
        public var P_cont:int = _M_data.TRAN.cont;

        [Bindable]
        public var main_bus:UserBus;

        public function YsPod(pool:Pool)
        {
            super();
            _pool = pool;
            this.addEventListener(EventPodShowXml.EVENT_NAME, OnShowXml);
            this.addEventListener(EventCacheComplete.EVENT_NAME, OnEventCacheComplete);
            this.addEventListener(DragEvent.DRAG_ENTER, OnDragEnter);
            _cache = new EventCache(_pool);
            var dts:DBTable = _pool.dts as DBTable;
            main_bus = _pool.MAIN_BUS as UserBus;
        }

        protected function OnDragEnter(event:DragEvent):void
        {
            if (this == event.currentTarget)
                DragManager.acceptDragDrop(this);
        }

        public function onDragDropHandler(e:DragEvent, action:String):void
        {
            var xml:XML = <windows />
            trace(e.dragInitiator)
            var str:String = 'windows://' + (e.dragInitiator as DataGrid).selectedItem.name;
            xml.appendChild(str);
            _cache.DoCache(xml.toXMLString(), this);
        }

        private function OnShowXml(event:EventPodShowXml):void
        {
            _cache.DoCache(event.xml.toXMLString(), this);
        }

        private function OnEventCacheComplete(event:EventCacheComplete):void
        {
            ShowWindow(event.cache_xml);
        }

        //相当于入�
        private function ShowWindow(xml:XML):void
        {
            var search_str:String = '://';
            var url:String = xml.text();
            var idx:int = url.search(search_str);
            var dxml:XML;
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                var dts_no:String = _pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;
                dxml = new XML(dts[dts_no].__DICT_XML);
            }
            else
                dxml = xml;

            if ((dxml.localName().toString().toLocaleLowerCase()) == 'pod')
            {
                //xingj

                _M_data.TRAN.cont++;
                _M_data.TRAN[P_cont] = P_data;

                P_data.XML = dxml;
                P_data.cont = 1000;
                P_data.obj = this;
                P_data.data = new ArrayCollection;
                //xingj ..
//??????? P_data中如果某个数据字典不止一项，那么他的TEXTINPUT是不是只有一项？还是所有的输入域都是数�
                if (P_data.data.length == 0)
                    P_data.data.addItem(new Object);
//???Proxy 被定义在某个下标(P_data.data[0])，所以如果需要通过事件改变其他下标的值，需要多个事件，目前TEXTINPUT不存在这个问题。DATAGRID是一个问�
                var proxy:ObjectProxy = new ObjectProxy;
                proxy = new ObjectProxy(P_data.data[0]);
                proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                                       updateChange);
                P_data.proxy = new ArrayCollection;
                P_data.proxy.addItem(new Object);
                P_data.proxy[0].env = proxy;

//??..
                P_data.ti = new ArrayCollection;
                P_data.ti.addItem(new Object);

                for each (var child:XML in dxml.elements())
                {

                    child_name = child.name().toString().toLowerCase();
                    if (child_name == 'windows' || child_name == 'hbox' || child_name == 'datagrid')
                    {
                        ShowWindow(child);
                    }
                    else if (child_name == 'dict')
                    {
                        ShowDict(titleWindow.form, child);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(titleWindow, child);
                    }
                    else if (child_name == 'event')
                    {
                        var fd:FunctionDelegate = new FunctionDelegate;
                        addEventListener(child.text().toString(), fd.create(onDragDropHandler, child.ACTION.text()));
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'windows')
            {
                var titleWindow:NewWindow = new NewWindow;
                var child_name:String;
                titleWindow.data = new Object;
                titleWindow.percentWidth = 100;
                titleWindow.title = dxml.text() + ":" + dxml.@TITLE;
                this.addChild(titleWindow);

                //xingj
                var W_cont:int = new int;
                W_cont = P_data.cont;
                P_data.cont++;
                P_data[W_cont] = new Object;
                var W_data:Object = P_data[W_cont];
                W_data.XML = dxml;
                W_data.obj = titleWindow;

                //xingj ..
                for each (var kid:XML in dxml.elements())
                {
                    child_name = kid.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(titleWindow.form, kid);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(titleWindow, kid);
                    }
//                    else if (child_name == 'event')
//                    {
//                        var fd:FunctionDelegate = new FunctionDelegate;
//                        addEventListener(child.text().toString(), fd.create(onDragDropHandler, child.ACTION.text()));
//                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'hbox')
            {
                var hbox:HBox = new HBox;
                hbox.data = {'xml': dxml};
                hbox.percentWidth = 100;
                hbox.setStyle('borderStyle', 'solid');
                hbox.setStyle('fontSize', '12');
                this.addChild(hbox);

                //xingj
                var W_cont:int = new int;
                W_cont = P_data.cont;
                P_data.cont++;
                P_data[W_cont] = new Object;
                var W_data:Object = P_data[W_cont];
                W_data.XML = dxml;
                W_data.obj = hbox;

                //xingj ..

                for each (var childs:XML in dxml.elements())
                {
                    child_name = childs.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(hbox, childs);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(hbox, childs);
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'datagrid')
            {
                var dg:DataGrid = new DataGrid;
                dg.data = {'xml': dxml};
                dg.percentWidth = 100;
                dg.percentHeight = 100;

                var dp:ArrayCollection = new ArrayCollection;

                dg.dataProvider = dp;

                dg.setStyle('borderStyle', 'solid');
                dg.setStyle('fontSize', '12');
                this.addChild(dg);


                //xingj
                var W_cont:int = new int;
                W_cont = P_data.cont;
                P_data.cont++;
                P_data[W_cont] = new Object;
                var W_data:Object = P_data[W_cont];
                W_data.XML = dxml;
                W_data.obj = dg;

                //xingj ..

                for each (var childs:XML in dxml.elements())
                {
                    child_name = childs.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(dg, childs);
                    }
                    else if (child_name == 'pool')
                    {
                        ShowPool(dg, childs);
                    }
                }
            }

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

                dxml = new XML(dts[dts_no].__DICT_XML);
            }
            else
                dxml = dict_xml;

            if (container is DataGrid)
            {

                var dg:DataGrid = container;

                var dgc:DataGridColumn =  new DataGridColumn;
                var obj_var:Object;
                var obj_name:String;
                var obj_title:String;

                var dp:ArrayCollection = container.dataProvider;

                var info:*;
                if (dxml.object.@att == "DBTABLE")
                {
                    info = _pool[dxml.object.text()] as DBTable;
                    if (dxml.object.object.@att == "array")
                    {
                        obj_var = info[dxml.object.object.text()];
                        obj_name = dxml.object.object.object.text();
                        obj_title = dxml.object.object.object.@id;

                    }

                }

                dgc.headerText = obj_title;
                dgc.dataField = obj_name;

                var i:int = 0;
                for each (var dict_obj:QueryObject in obj_var)
                {
                    var ys_var:YsVarStruct = dict_obj.Get();

                    if (dp.length <= i)
                    {
                        dp.addItem(new Object);
                    }

                    dp[i][obj_name] = ys_var[obj_name].getValue();
                    i++;
                }
                dg.columns = dg.columns.concat(dgc);
                dp.refresh();
            }
        }

        //ShowDict 用完整的链接显示一个DICT
        private function ShowDict(container:*, dict_xml:XML):void
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

                dxml = new XML(dts[dts_no].__DICT_XML);
            }
            else
                dxml = dict_xml;

            if (container is DataGrid)
            {

                var dg:DataGrid = container;

                var dgc:DataGridColumn =  new DataGridColumn;
                dgc.headerText = dxml.display.LABEL.@text;
                dgc.dataField = dxml.text();

                var dp:ArrayCollection = container.dataProvider;

                var data:Array = main_bus.GetVarArray(dxml.text());
                var datalen:int = data.length;

                for (var i:int = 0; i < datalen; i++)
                {
                    if (dp.length <= i)
                    {
                        dp.addItem(new Object);
                    }
                    dp[i][dxml.text()] = data[i].toString();

                }

                dg.columns = dg.columns.concat(dgc);
                dp.refresh();
            }
            else //if (container is NewWindow || container is HBox)
            {
                var label:Label = new Label;
                var ti:TextInput = new TextInput;

                label.text = dxml.display.LABEL.@text;
                var ti_name:String = dxml.services.@NAME;
                ti.text = '';
                ti.maxChars = int(dxml.services.@LEN);
                ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
                ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
                ti.data = {'name': ti_name, //'ys_var': main_bus.GetVarArray(ti_name),
                        'index': 0}; //arr[0];
                ti.addEventListener(Event.CHANGE, tichange);

                for (var i:int = 0; i <= P_data.ti.length; i++)
                {
                    if (i == P_data.ti.length)
                        P_data.ti.addItem(new Object);
                    if (P_data.ti[i][ti_name] == null)
                    {
                        P_data.ti[i][ti_name] = ti;
                        break;
                    }
                }
                if (!P_data.data[0].hasOwnProperty(ti_name))
                {
                    P_data.data[0][ti_name] = new String;
                    //Set DEFAULT VALUE
                    if (dxml.services.@DEFAULT == null)
                        P_data.proxy[0].env[ti_name] = '';
                    else
                    {
                        var str:String = dxml.services.@DEFAULT;
                        P_data.proxy[0].env[ti_name] = str;
                    }
                }
                else
                {
                    var str:String = P_data.data[0][ti_name];
                    ti.text = str;
                }
                var func_dele:FunctionDelegate = new FunctionDelegate;
                var ti_focus_out_func:Function = func_dele.create(OnTextInputFocusOut, ti_name);
                ti.addEventListener(FocusEvent.FOCUS_OUT, ti_focus_out_func);
                ti.addEventListener(FlexEvent.ENTER, enterHandler);
                if (container is HBox)
                {
                    container.addChild(label);
                    container.addChild(ti);
                }
                else
                {
                    var formitem:FormItem = new FormItem;
                    formitem.direction = "horizontal";
                    formitem.label = label.text;
                    formitem.addChild(ti);
                    container.addChild(formitem);
                    _bus_ctrl_arr.push({ti_name: ti});
                }
            }

        }

        private function tichange(evt:Event):void
        {
            trace(evt);
            //txtTitle = proxy.firstName + " " + proxy.lastName;  
            var tt:TextInput = evt.target as TextInput;
            P_data.proxy[tt.data.index].env[tt.data.name] = tt.text;
        }

        private function updateChange(evt:PropertyChangeEvent):void
        {
            var dictname:String = evt.property as String;
            var dictvalue:String = evt.newValue as String;
            for (var i:int = 0; i < P_data.ti.length; i++)
            {
                if (P_data.ti[i][dictname] == null)
                    break;

                P_data.ti[i][dictname].text = dictvalue;
            }
        }

        private function ShowButton(container:Container, button_xml:XML):void
        {
            var btn:Button = new Button;
            btn.label = button_xml.@LABEL;

            btn.data = button_xml;

            var func_delegate:FunctionDelegate = new FunctionDelegate;
            var func:Function = func_delegate.create(OnBtnClick, container);
            btn.addEventListener(MouseEvent.CLICK, func);
            var fd:FunctionDelegate = new FunctionDelegate;
            btn.addEventListener(StackSendXmlEvent.EVENT_STACK_SENDXML, fd.create(doBttonActions, container));
            btn.setStyle('fontWeight', 'normal');
            container.addChild(btn);
        }

        private function OnBtnClick(e:MouseEvent, container:Container):void
        {
            var btn:Button = e.target as Button;
            var stackUtil:StackUtil = new StackUtil;
            var arr:Array = new Array;
            var serviceNum:int = 0;
            for each (var kid:XML in btn.data.children())
            {
                var type:String = (kid.localName().toString().toLocaleLowerCase());
                if (type == 'services')
                    serviceNum++;
                arr.push(kid);
            }

            var event_bus2windowsXML:XML = <ACTION> event_bus2window </ACTION>;
            arr.push(event_bus2windowsXML);

            var fg:FunctionDelegate = new FunctionDelegate;
            stackUtil.addEventListener(StackUtil.EVENT_STACK_NEXT, fg.create(stackUtil.stack, btn, arr));
            //驱动�
            stackUtil.stack(new Event(StackUtil.EVENT_STACK_NEXT), btn, arr);
            trace(btn.label);
            // trace(btn.data.ACTION);
            trace(container.className);
        }

        //button一系列action services的最后一�

        private function doBttonActions(e:StackSendXmlEvent, container:Container):void
        {
            var action:XML = e.data as XML;
            var type:String = (action.localName().toString().toLocaleLowerCase());
            switch (type)
            {
                case 'action':
                {
                    //if (event_obj.hasOwnProperty(action))
                    {
                        var func:Function = EventHandlerFactory.get_handler(action);
                        func(this, container);
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
                    DoService(e, GetServiceXml(action));
                    break;
                }
            }

        }

        private function GetServiceXml(service_desc:XML):XML
        {
            var service_value:String = service_desc.toString();
            var link_head:String = 'services://';
            trace(service_value);

            if (service_value.substr(0, link_head.length).toLowerCase() == link_head.toLowerCase())
            {
                var service_name:String = service_value.substr(link_head.length);
                var dts_no:String = _pool.info.SERVICES[service_name].Get().DTS;
                var service_xml:String = _pool.dts[dts_no].__DICT_XML;
                return new XML(service_xml);
            }

            return service_desc;
        }


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
            for each (var var_name:String in bus_in_name_args)
            {
                // 参数从本地bus中获�?xingjun getfrist is err
                if (!P_data.data[0].hasOwnProperty(var_name))
                    bus.Add(var_name, main_bus.GetFirst(var_name));
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

        public function CallBack(bus:UserBus, service_info:XML, e:StackSendXmlEvent):void
        {
            trace('callback');
            trace(service_info.toXMLString());
            trace(bus);

            var dict_str:String
            var dict_search:String = 'dict://';
            var bus_out_name_args:Array = new Array;
            var dict_list:XMLList = service_info.RecvPKG.BODY.DICT;

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
                main_bus.RemoveByKey(var_name);
                var ys_var:YsVar = bus[var_name];
                main_bus.Add(var_name, ys_var);
            }

            for each (var key_name:String in bus.GetKeyArray())
            {
                trace(key_name);
                //var i:int = 0;
                //for each (var value:YsVar in bus[key_name])
                //{
                //    if (P_data.proxy.length >= i)
                //        break;
                //    P_data.proxy[i].env[key_name] = value;
                //}
                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
                    P_data.proxy[0].env[key_name] = bus[key_name][0].value.toString();
            }
            e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
        }

        public function OnNewWindowNameReady(name:String):void
        {
            var new_wnd:NewWindow = new NewWindow;
            new_wnd.title = name;
            this.addChild(new_wnd);
        }

        private function enterHandler(event:FlexEvent):void
        {
            var current:TextInput = event.target as TextInput;
            var o:Object = current.parent;
            var arr:Array = new Array;
            if (o is FormItem)
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
            else
                for each (var textinput:* in o.getChildren())
                {
                    if (textinput is TextInput)
                    {
                        arr.push(textinput);
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

        private function OnTextInputFocusOut(event:Event, key_name:String):void
        {
            //var main_bus:UserBus = _pool.MAIN_BUS as UserBus;
//            var ti:TextInput = event.target.owner as TextInput;
//            var ys_var:YsVarArray = main_bus[ti.data.key]
//            ys_var.value[ti.data.index].value = ti.text;
            //main_bus.RemoveByKey(key_name);
            //main_bus.Add(key_name, event.target.text);
        }
    }
}