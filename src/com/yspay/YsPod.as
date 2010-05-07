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
        public var P_cont:int; //xingj
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

            P_data.XML = event.cache_xml;
            var dxml:XML = event.cache_xml;
            var child_name:String;
            for each (var child:XML in dxml.elements())
            {
                child_name = child.name().toString().toLowerCase();

                //if (child_name == 'windows' || child_name == 'hbox' || child_name == 'datagrid')
                if (child_name == 'windows' || child_name == 'hbox')
                {
                    ShowWindow(this, child);
                }
//                    else if (child_name == 'dict')
//                    {
//                        ShowDict(container, child);
//                    }
//                    else if (child_name == 'button')
//                    {
//                        ShowButton(container, child);
//                    }
                else if (child_name == 'event')
                {
                    var fd:FunctionDelegate = new FunctionDelegate;
                    addEventListener(child.text().toString(), fd.create(onDragDropHandler, child.ACTION.text()));
                }
            }
            //ShowWindow(this, event.cache_xml);
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
                for each (var child:XML in dxml.elements())
                {
                    child_name = child.name().toString().toLowerCase();
                    //if (child_name == 'windows' || child_name == 'hbox' || child_name == 'datagrid')
                    if (child_name == 'windows' || child_name == 'hbox')
                    {
                        ShowWindow(container, child);
                    }
//                    else if (child_name == 'dict')
//                    {
//                        ShowDict(container, child);
//                    }
//                    else if (child_name == 'button')
//                    {
//                        ShowButton(container, child);
//                    }
                    else if (child_name == 'event')
                    {
                        var fd:FunctionDelegate = new FunctionDelegate;
                        addEventListener(child.text().toString(), fd.create(onDragDropHandler, child.ACTION.text()));
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'windows')
            {
                var titleWindow:YsTitleWindow = new YsTitleWindow;
                var child_name:String;
                titleWindow.data = new Object;
                titleWindow.percentWidth = 100;
                titleWindow.title = dxml.text() + ":" + dxml.@TITLE;
                container.addChild(titleWindow);

                titleWindow.Init(dxml);

                //xingj
                var W_cont:int = P_data.cont;
                P_data.cont++;
                P_data[W_cont] = new Object;
                var W_data:Object = P_data[W_cont];
                W_data.XML = dxml;
                W_data.obj = titleWindow;
                W_data.datacont = 10000;


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
                W_data1.datacont = 10000;

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
                //xingj
                var W_cont2:int = P_data.cont;
                P_data.cont++;
                P_data[W_cont2] = new Object;
                var W_data2:Object = P_data[W_cont2];
                W_data2.XML = dxml;
                W_data2.obj = dg;
                W_data2.datacont = 10000;
                var D_data:* = "data" + W_data2.datacont;
                W_data2[D_data] = new ArrayCollection;
                //xingj ..
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
                    //arr = P_data.proxy;
                    arr = W_data2[D_data];
                }
                else
                    return;

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
                        ShowPool(dg, childs1); //pool中dict...等的哪那几列
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
        public function ShowDict(container:*, dict_xml:XML):void
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
                var data:ArrayCollection = dg.dataProvider as ArrayCollection;
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
                var i:int = new int;
                for (i = 0; i < P_data.data.length; i++)
                {
                    if (!P_data.data[i].hasOwnProperty(en_name))
                        break;
                    if (data.length < i)
                        data.addItem(new Object);
                    data[i][en_name] = P_data.data[i][en_name];
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

                if (dxml.display.TEXTINPUT.list != undefined)
                { //ComboBox

                    var coboBox:ComboBox = new ComboBox;
                    if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                        coboBox.labelFunction = comboboxshowlabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
                    else
                        coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

                    coboBox.addEventListener("close", comboboxchange);
                    coboBox.prompt = "请选择...";
                    coboBox.data = {'name': ti_name, 'index': 0, 'xml': dxml};

                    //xingj
                    var W_cont3:int = P_data.cont;
                    P_data.cont++;
                    P_data[W_cont3] = new Object;
                    var W_data3:Object = P_data[W_cont3];
                    W_data3.XML = dxml;
                    W_data3.obj = coboBox;
                    W_data3.datacont = 10000;
                    var D_data:String = "data" + W_data3.datacont;
                    W_data3.datacont++;
                    W_data3[D_data] = new ArrayCollection;
                    //xingj ..
                    if (dxml.display.TEXTINPUT.list.listarg != undefined)
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
                        for each (var x:XML in dxml.display.TEXTINPUT.list.*)
                        {
                            W_data3[D_data].addItem(new Object);
                            for each (var xx:XML in x.*)
                            {
                                W_data3[D_data][W_data3[D_data].length - 1][xx.name().toString()] = xx.text().toString();
                            }
                        }
                    else if (dxml.display.TEXTINPUT.list.action != undefined)
                    {
//功能：
//                            <list labelField="NAME">
//                                <listdict>this:P_data:ACNO</listdict>
//                                <listdict>this:P_data:NAME</listdict>
//                            </list>
//                            <process>\
//                                <Services sendbus="YsPod:P_data" recvbus="this:P_data">YsUserAdd</Services>
//                                
//                            </process>

//                           1、通过定义的listdict建立W_data,并将W_data与ComboBox关联
//                           2、通过服务调用将符合条件的记录取得，放到W_data中，
//                           DoServices:
//                           Services名字
//                           Services参数
//                           CallBack:
//                           Services返回的BUS
//                           将BUS内容放到指定的W_data中
                    }
                    else if (dxml.display.TEXTINPUT.list.DICT != undefined)
                    {
                        for each (var x:XML in dxml.display.TEXTINPUT.list.DICT)
                        {
                            var en_name:String = x.text().toString();
                            en_name = en_name.substr(en_name.search("://") + 3);
                            for (i = 0; i <= P_data.DataGrid.length; i++)
                            {
                                if (P_data.DataGrid.length == i)
                                    P_data.DataGrid.addItem(new Object);
                                if (P_data.DataGrid[i][en_name] == undefined)
                                {
                                    P_data.DataGrid[i][en_name] = new Object;
                                    P_data.DataGrid[i][en_name].W_data = W_cont3;
                                    P_data.DataGrid[i][en_name].D_data = D_data;
                                    break;
                                }
                            }
                            for (i = 0; i < P_data.data.length; i++)
                            {
                                if (P_data.data[i][en_name] == null)
                                    break;
                                if (W_data3[D_data][i] == null)
                                    W_data3[D_data].addItem(new Object);
                                W_data3[D_data][i][en_name] = P_data.data[i][en_name];
                            }

                        }
                    }
                    coboBox.dataProvider = W_data3[D_data];
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
                            P_data.ti[i][ti.data.name][ti.data.index] = coboBox;
                            break;
                        }
                    }
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
                    var formitem:MyFormItem = new MyFormItem;
                    formitem.direction = "horizontal";
                    formitem.label = label.text;
                    formitem.addChild(ti);
                    if (coboBox != null)
                        formitem.addChild(coboBox);
                    container.addChild(formitem);
                    _bus_ctrl_arr.push({ti_name: ti});
                }
            }

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
                    serviceNum++; //session?
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

        public function GetServiceXml(service_desc:XML):XML
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


        public function DoService(e:StackSendXmlEvent, service:XML):void
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
    }
}
