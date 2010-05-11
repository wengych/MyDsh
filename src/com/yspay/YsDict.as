package com.yspay
{
    import com.yspay.YsData.PData;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.containers.FormItem;
    import mx.controls.ComboBox;
    import mx.controls.DataGrid;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.events.FlexEvent;

    public class YsDict implements YsControl
    {
        protected var label:Label;
        protected var text_input:TextInput;
        protected var combo_box:YsComboBox;
        protected var _parent:DisplayObjectContainer;

        public function YsDict(parent:DisplayObjectContainer)
        {
            if (parent is YsHBox || parent is DataGrid)
            {
                _parent = parent;
            }
            else
            {
                _parent = new MyFormItem;
                parent.addChild(_parent);
            }
        }

        public function Init(xml:XML):void
        {

            xml = UtilFunc.FullXml(xml);
            if (_parent is YsDataGrid) //DATAGRID
            {
                var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
                var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
                var dg:YsDataGrid = _parent as YsDataGrid;
                var data:ArrayCollection = dg.dataProvider as ArrayCollection;
                var dgc:DataGridColumn =  new DataGridColumn;

                for each (var kid:XML in xml.attributes())
                {
                    if (kid.name() == "editable")
                        dgc.editable = kid.toString();

                }
                var ch_name:String = xml.display.LABEL.@text;
                var en_name:String = xml.services.@NAME;
                dgc.headerText = ch_name;
                dgc.dataField = en_name;
                if (!P_data._data[0].hasOwnProperty(en_name)) //赋初值。
                {
                    P_data._data[0][en_name] = new String;
                    //Set DEFAULT VALUE
                    if (xml.services.@DEFAULT == null)
                        P_data.data[0][en_name] = '';
                    else
                    {
                        var str:String = xml.services.@DEFAULT;
                        P_data.data[0][en_name] = str;
                    }
                }
                var i:int = new int;

                // 为当前dict项添加一个默认值，第0项
                for (i = 0; i < P_data._data.length; i++)
                {
                    if (!P_data._data[i].hasOwnProperty(en_name))
                        break;
                    if (data.length <= i)
                        data.addItem(new Object);
                    data[i][en_name] = P_data._data[i][en_name];
                }

                for (i = 0; i <= P_data.data_grid.length; i++)
                {
                    if (P_data.data_grid.length == i)
                        P_data.data_grid.addItem(new Object);
                    if (P_data.data_grid[i][en_name] != undefined)
                        continue;
                    P_data.data_grid[i][en_name] = dg.data_count;
                    break;
                }
                dg.columns = dg.columns.concat(dgc);
                    // TODO:针对DataGrid的处理方法
                    //(_parent as DataGrid); // 添加列
            }
            else //COMBOBOX || TEXTINPUT
            { //<DICT LABEL="CNAME" 
                //       LabelVisible="true" 
                //       TextInputVisible="true" 
                //       ComboBoxVisible="true" 
                //       OutputOnly="true"
                //       from="P_data" 
                //       from="D_data"
                //       to="P_data"
                //       to="D_data"
                //>
                if (xml.display.LABEL != undefined)
                {
                    label = new Label;
                    if (xml.@LABEL != undefined)
                        label.text = xml.@LABEL;
                    else
                        label.text = xml.display.LABEL.@text;
                    if (xml.@LabelVisible != undefined)
                        if (xml.@LabelVisible == "false")
                            label.visible = false;
                    _parent.addChild(label);
                }
                if (xml.display.TEXTINPUT != undefined)
                {
                    text_input = CreateTextInput(xml);
                    if (xml.@OutputOnly != undefined)
                        if (xml.@OutputOnly == "true")
                            text_input.editable = false;
                    if (xml.@TextInputVisible != undefined)
                        if (xml.@TextInputVisible == "false")
                            text_input.visible = false;

                    _parent.addChild(text_input);
                }
                if (xml.display.TEXTINPUT.list != undefined)
                {
                    combo_box = CreateComboBox(xml);
                    if (xml.@OutputOnly != undefined)
                        if (xml.@OutputOnly == "true")
                            combo_box.enabled = false;
                    if (xml.@ComboBoxVisible != undefined)
                        if (xml.@ComboBoxVisible == "false")
                            combo_box.visible = false;
                    _parent.addChild(combo_box);
                }
            }
        }

        private function tichange(evt:Event):void
        {
            var tt:TextInput = evt.target as TextInput;
            var ys_pod:YsPod = GetParentByType(text_input.parent, YsPod) as YsPod;
            var P_data:Object = ys_pod._M_data.TRAN[ys_pod.P_cont];
            if (tt.data.To == undefined || tt.data.To == "P_data")
                P_data.data[tt.data.index][tt.data.name] = tt.text;
            P_data._data.refresh();
        }

        private function enterHandler(event:FlexEvent):void
        {
            var current:TextInput = event.target as TextInput; // == text_input
            var ti_parent:Object = text_input.parent; // os: HBox, FormItem
            var arr:Array = new Array;
            var ti:TextInput;

            if (ti_parent is FormItem)
            {
                // 处理输入框的父窗体为FormItem的情况
                for each (var form_item:FormItem in ti_parent.parent.getChildren())
                {
                    if (form_item == null)
                        continue;

                    for each (ti in form_item.getChildren())
                    {
                        if (ti != null)
                        {
                            arr.push(ti);
                        }
                    }
                }
            }
            else // if (ti_parent is YsHBox)
            {
                // 处理其他情况
                for each (ti in ti_parent.getChildren())
                {
                    if (ti != null)
                        arr.push(ti);
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

        private function CreateTextInput(dxml:XML):TextInput
        {
            var ti_name:String = dxml.services.@NAME;
            var ti:TextInput = new TextInput;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.data = {'name': ti_name, //'ys_var': main_bus.GetVarArray(ti_name),
                    'index': 0}; //arr[0];
            ti.addEventListener(Event.CHANGE, tichange);

            if (dxml.@From == undefined)
                ti.data.From = "P_data";
            else
                ti.data.From = dxml.@From.toString();

            if (dxml.@To == undefined)
                ti.data.To = "P_data";
            else
                ti.data.To = dxml.@To.toString();

            if (ti.data.From == "P_data")
            {
                var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
                var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];

                P_data.AddCtrlProxy(ti, dxml.services.@DEFAULT);
            }

            ti.addEventListener(FlexEvent.ENTER, enterHandler);

            return ti;
        }

        private function CreateComboBox(dxml:XML):YsComboBox
        {
            var coboBox:YsComboBox = new YsComboBox(dxml, dxml.services.@NAME);
            if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                coboBox.labelFunction = comboboxshowlabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
            else
                coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

            coboBox.addEventListener("close", comboboxchange);
            coboBox.prompt = "请选择...";

            // TODO:ComboBox和YsPod.P_data.ctrls_proxy[index][name]

            return coboBox;
        }

        /*
           private function ff(dxml:XML):ComboBox
           {
           var ys_pod:YsPod = GetParentByType(text_input.parent as Container, YsPod) as YsPod;
           var P_data:Object = ys_pod._M_data[ys_pod.P_cont];

           if (dxml.display.TEXTINPUT.list != undefined)
           { //ComboBox

           //xingj
           var W_cont3:int = P_data.cont;
           P_data.cont++;
           P_data[W_cont3] = new Object;
           var W_data3:Object = P_data[W_cont3];
           W_data3.XML = dxml;
           W_data3.obj = combo_box;
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
           combo_box.dataProvider = W_data3[D_data];
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
           P_data.ti[i][ti.data.name][ti.data.index] = combo_box;
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
           }
         */
        private function comboboxshowlabel(item:Object):String
        {
            var returnvalue:String = new String;
            if (item.hasOwnProperty("mx_internal_uid"))
                item.setPropertyIsEnumerable('mx_internal_uid', false);

            for (var o:Object in item)
            {
                returnvalue += item[o].toString() + ' - ';
            }

            return (returnvalue.substring(0, returnvalue.length - 3));
        }

        private function comboboxchange(evt:Event):void
        {
            var tmpcobox:ComboBox = evt.target as ComboBox;

            var o:Object = (evt.target as ComboBox).selectedItem;
            if (o == null)
                return;
            var x:XML = tmpcobox.data.xml;

            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
            P_data.data[tmpcobox.data.index][tmpcobox.data.name] = o[x.services.@NAME];
            P_data._data.refresh();
        }
    }
}
