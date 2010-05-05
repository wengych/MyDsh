package com.yspay
{
    import com.esria.samples.dashboard.view.NewWindow;
    import com.esria.samples.dashboard.view.Pod;
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.StackUtil;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.collections.ArrayCollection;
    import mx.containers.Form;
    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.ComboBox;
    import mx.controls.DataGrid;
    import mx.controls.Label;
    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.Application;
    import mx.core.ClassFactory;
    import mx.core.Container;
    import mx.events.DataGridEvent;
    import mx.events.DragEvent;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.CursorManager;
    import mx.managers.DragManager;
    import mx.utils.ObjectProxy;

    public class YsPod extends Pod
    {
        public var _M_data:Object = Application.application.M_data; //xingj
        public var P_cont:int = _M_data.TRAN.cont; //xingj
        public var main_bus:UserBus;

        protected var _pool:Pool;
        protected var _cache:EventCache;
        protected var _bus_ctrl_arr:Array = new Array;
        protected var P_data:Object = new Object; //xingj


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
            var str:String = 'windows://' + (e.dragInitiator as DataGrid).selectedItem.NAME;
            xml.appendChild(str);
            _cache.DoCache(xml.toXMLString(), this);
        }

        private function OnShowXml(event:EventPodShowXml):void
        {
            _cache.DoCache(event.xml.toXMLString(), this);
        }

        private function OnEventCacheComplete(event:EventCacheComplete):void
        {
            ShowWindow(this, event.cache_xml);
        }

        //相当于入口�
        private function ShowWindow(container:*, xml:XML):void
        {
            var search_str:String = '://';
            var url:String = xml.text();
            var idx:int = url.search(search_str);
            var dxml:XML;
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                if (_pool.info[query_key][obj_key] == undefined)
                {
                    Alert.show('error！');
                    return;
                }
                var dts_no:String = _pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;
                dxml = xml;
                delete dxml.*;
                var temp:XML = new XML(dts[dts_no].__DICT_XML);
                dxml.appendChild(temp.children());
            }
            else
                dxml = xml;
//            <pod>
//              11
//              <windows>
//                 WINDOWS://290
//              </windows>
//            </pod>
            if ((dxml.localName().toString().toLocaleLowerCase()) == 'pod') //windows hbox datagrid
            {
                //xingj

                _M_data.TRAN.cont++;
                _M_data.TRAN[P_cont] = P_data;

                P_data.XML = dxml;
                P_data.cont = 1000;
                P_data.obj = container;
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

                for each (var child:XML in dxml.elements())
                {

                    child_name = child.name().toString().toLowerCase();
                    if (child_name == 'windows' || child_name == 'hbox' || child_name == 'datagrid')
                    {
                        ShowWindow(container, child);
                    }
                    else if (child_name == 'dict')
                    {
                        ShowDict(container, child);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(container, child);
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
                container.addChild(titleWindow);

                //xingj
                var W_cont:int = P_data.cont;
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
                        ShowButton(titleWindow.form, kid);
                    }
                    else if (child_name == 'hbox')
                    {
                        ShowWindow(titleWindow, kid);
                    }
                    else if (child_name == 'windows')
                    {
                        ShowWindow(titleWindow, kid);
                    }
                    else if (child_name == 'event')
                    {
                        var fhelper:FunctionDelegate = new FunctionDelegate;
                        addEventListener(kid.text().toString(), fhelper.create(onDragDropHandler, kid.ACTION.text()));
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'hbox')
            {
                var hbox:HBox = new HBox;
                hbox.data = {'xml': dxml};
                hbox.percentWidth = 100;
                hbox.setStyle('borderStyle', 'solid');
                hbox.setStyle('fontSize', '12');
                container.addChild(hbox);

                //xingj
                var W_cont1:int = P_data.cont;
                P_data.cont++;
                P_data[W_cont1] = new Object;
                var W_data1:Object = P_data[W_cont1];
                W_data1.XML = dxml;
                W_data1.obj = hbox;

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
                    else if (child_name == 'event')
                    {
                        var fd1:FunctionDelegate = new FunctionDelegate;
                        addEventListener(childs.text().toString(), fd1.create(onDragDropHandler, childs.ACTION.text()));
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'datagrid')
            {
                var dg:DataGrid = new DataGrid;
                dg.data = {'xml': dxml};
                dg.percentWidth = 100;
                dg.percentHeight = 100;
                for each (var kids:XML in dxml.attributes())
                {
                    if (kids.name() == "editable")
                        dg.editable = kids.toString();
                    if (kids.name() == "dragEnabled")
                        dg.dragEnabled = kids.toString();
                    if (kids.name() == "append")
                    {
                        dg.data["attrib"] = new Object;
                        dg.data["attrib"][kids.name().toString()] = kids.toString();
                    }
                    if (kids.name() == "itemEditEnd")
                    {
                        if (kids.toString() == "true")
                            dg.addEventListener("itemEditEnd", itemEditEndHandler);
                        else
                        {
                            if (dg.hasEventListener("itemEditEnd"))
                                dg.removeEventListener("itemEditEnd", itemEditEndHandler);
                        }
                    }
                }
                var arr:ArrayCollection;

                if (dxml.POOL != undefined)
                {
                    var ddxml:XMLList = dxml.POOL;

                    if (dxml.POOL == undefined)
                        return;
                    if (dxml.POOL.object == undefined)
                        return;
                    if (dxml.POOL.object.object == undefined)
                        return;
                    var p_xml:XML = dxml.POOL[0];
                    var info_xml:XML = p_xml.object[0];
                    var tran_xml:XML = info_xml.object[0];

                    if (_M_data[p_xml.text()] == null)
                        return;
                    if (_M_data[p_xml.text()][info_xml.text()] == null)
                        return;
                    if (_M_data[p_xml.text()][info_xml.text()][tran_xml.text()] == null)
                        return;
                    arr = _M_data[p_xml.text()][info_xml.text()][tran_xml.text()];
                }
                else if (dxml.DICT != undefined)
                {
                    //arr = P_data.data;
                    arr = P_data.proxy;
                }
                else
                    return;
                //xingj
                var W_cont2:int = P_data.cont;
                P_data.cont++;
                P_data[W_cont2] = new Object;
                var W_data2:Object = P_data[W_cont2];
                W_data2.XML = dxml;
                W_data2.obj = dg;

                //xingj ..

                for each (var childs1:XML in dxml.elements())
                {
                    child_name = childs1.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(dg, childs1);
                    }
                    if (child_name == 'button')
                    {
                        ShowButton(dg, childs1);
                    }
                    else if (child_name == 'pool')
                    {
                        ShowPool(dg, childs1);
                    }
                    else if (child_name == 'event')
                    {
                        var fd2:FunctionDelegate = new FunctionDelegate;
                        addEventListener(childs1.text().toString(), fd2.create(onDragDropHandler, childs1.ACTION.text()));
                    }
                }
                dg.dataProvider = arr;
                dg.setStyle('borderStyle', 'solid');
                dg.setStyle('fontSize', '12');
                container.addChild(dg);
                arr.refresh();
            }
        }

        private function itemEditEndHandler(e:DataGridEvent):void
        {
            e.target.dataProvider.refresh();
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

                var dgc:DataGridColumn =  new DataGridColumn;

                for each (var kid:XML in dxml.attributes())
                {
                    if (kid.name() == "editable")
                        dgc.editable = kid.toString();
                }
                var ch_name:String = dxml.display.LABEL.@text;
                var en_name:String = dxml.services.@NAME;
                dgc.headerText = ch_name;
                dgc.dataField = en_name;
                if (!P_data.data[0].hasOwnProperty(en_name))
                {
                    P_data.data[0][en_name] = new String;
                    //Set DEFAULT VALUE
                    if (dxml.services.@DEFAULT == null)
                        P_data.proxy[0][en_name] = '';
                    else
                    {
                        var str:String = dxml.services.@DEFAULT;
                        P_data.proxy[0][en_name] = str;
                    }
                }
                dg.columns = dg.columns.concat(dgc);
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

//                            <list labelField="GENDER">
//                                <listarg>
//                                    <GENDER> 女 </GENDER>
//                                    <GENDER_ID> 0 </GENDER_ID>
//                                </listarg>
//                                <listarg>
//                                    <GENDER> 男 </GENDER>
//                                    <GENDER_ID> 1 </GENDER_ID>
//                                </listarg>
//                            </list>
                if (dxml.display.TEXTINPUT.list != undefined)
                { //ComboBox
                    var coboBox:ComboBox = new ComboBox;
                    if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                        coboBox.labelFunction = show; //if (xml.display.TEXTINPUT.list.@labelField != null)
                    else
                        coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

                    if (dxml.display.TEXTINPUT.list..attribute('labelField') != null)
                        coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

                    coboBox.addEventListener("close", comboboxchange);
                    coboBox.prompt = "请选择...";
                    coboBox.labelFunction = comboboxshowlabel;
                    coboBox.dataProvider = arr;
                    coboBox.data = {'name': ti_name, 'index': 0, 'xml': dxml};
                    this.addChild(coboBox);


                }

                for (var i:int = 0; i <= P_data.ti.length; i++)
                {
                    if (i == P_data.ti.length)
                    {
                        P_data.ti.addItem(new Object);
                    }
                    if (P_data.ti[i][ti.data.name] == null)
                        P_data.ti[i][ti.data.name] = new Object;
                    if (P_data.ti[i][ti.data.name][ti.data.index] == null)
                    {
                        //ti ArrayCollection 的 i个Object的[英文名][索引号]
                        P_data.ti[i][ti.data.name][ti.data.index] = ti;
                        break;
                    }
                }
                if (!P_data.data[0].hasOwnProperty(ti_name))
                {
                    P_data.data[0][ti_name] = new String;
                    //Set DEFAULT VALUE
                    if (dxml.services.@DEFAULT == null)
                        P_data.proxy[0][ti_name] = '';
                    else
                    {
                        var str1:String = dxml.services.@DEFAULT;
                        P_data.proxy[0][ti_name] = str1;
                    }
                }
                else
                {
                    var str2:String = P_data.data[0][ti_name];
                    ti.text = str2;
                }
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

        private function comboboxshowlabel(o:Object):String
        {
            return (item.GENDER + " - " + item.GENDER_ID);
        }

        private function comboboxchange(evt:Event):void
        {

            var tmpcobox:ComboBox = evt.target as ComboBox;

            var o:Object = (evt.target as ComboBox).selectedItem;
            if (o == null)
                return;
            var x:XML = tmpcobox.data.xml;
            P_data.proxy[tmpcobox.data.index][tmpcobox.data.name] = o[tmpcobox.data.name];

            P_data.data.refresh();
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
                    for each (var aa:Object in P_data.ti[i][dictname][dictNum].dataProvider)
                    {
                        if (aa[dictname] == dictvalue)
                            P_data.ti[i][dictname][dictNum].selectedItem = aa;
                    }
                }
            }
        }

        private function ShowButton(container:*, button_xml:XML):void
        {
            if (container is DataGrid)
            {
                var dg:DataGrid = container as DataGrid;
                var dgc:DataGridColumn = new DataGridColumn;
                dgc.editable = false;
                dgc.headerText = button_xml.@LABEL;

                var fac:ClassFactory = new ClassFactory(com.esria.samples.dashboard.view.datagridbtn);
                fac.properties = {xml: button_xml, yspod: this, dg: container};
                dgc.itemRenderer = fac;
                dg.columns = dg.columns.concat(dgc);
            }
            else
            {
                var btn:Button = new Button;
                btn.label = button_xml.@LABEL;
                btn.data = button_xml;
                var func_delegate:FunctionDelegate = new FunctionDelegate;
                btn.addEventListener(MouseEvent.CLICK, OnBtnClick);
                var fd:FunctionDelegate = new FunctionDelegate;
                btn.addEventListener(StackSendXmlEvent.EVENT_STACK_SENDXML, fd.create(doBttonActions, container));
                btn.setStyle('fontWeight', 'normal');
                container.addChild(btn);
            }
        }

        public function OnBtnClick(e:MouseEvent):void
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
            //var_name=dict名字
            for each (var var_name:String in bus_in_name_args)
            {
                // 参数从本地bus中获�?xingjun getfrist is err
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
                main_bus.RemoveByKey(var_name);
                if (bus[var_name] == null)
                    continue;
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
                    for each (var textinput:*in t.getChildren())
                    {
                        if (textinput is TextInput)
                        {
                            arr.push(textinput);
                        }
                    }

                }
            else
                for each (var textinput1:*in o.getChildren())
                {
                    if (textinput1 is TextInput)
                    {
                        arr.push(textinput1);
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

        //private function OnTextInputFocusOut(event:Event, key_name:String):void
        //{
        //var main_bus:UserBus = _pool.MAIN_BUS as UserBus;
//            var ti:TextInput = event.target.owner as TextInput;
//            var ys_var:YsVarArray = main_bus[ti.data.key]
//            ys_var.value[ti.data.index].value = ti.text;
        //main_bus.RemoveByKey(key_name);
        //main_bus.Add(key_name, event.target.text);
        //}

        public function clean_allti_ta(obj:Object):void
        {
            var children:Array;
            var o:Object;

            children = obj.getChildren();
            for each (o in children)
            {
                if ((o is HBox) || (o is Form) || o is NewWindow || o is FormItem)
                    clean_allti_ta(o);
                else if (o is TextArea)
                {
                    var ta:TextArea = o as TextArea;
                    ta.text = ta.data.value = '';
                    _M_data.TRAN[P_cont].proxy[ta.data.index][ta.data.name] = '';
                }
                else if (o is TextInput)
                {
                    var ti:TextInput = o as TextInput;
                    ti.text = ti.data.value = '';
                    _M_data.TRAN[P_cont].proxy[ti.data.index][ti.data.name] = '';
                }
            }
        }

        public function _YsInfoQueryComplete(event:DBTableQueryEvent):void
        {
            CursorManager.removeBusyCursor();
            var info:DBTable = _pool.info as DBTable;
            var i:int = 0;

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
                if (_M_data.POOL.INFO[event.query_name].length <= i)
                    _M_data.POOL.INFO[event.query_name].addItem(vare);
                i++;
            }
            _M_data.POOL.INFO[event.query_name].refresh();
            //xingj ..
        }
    }
}
