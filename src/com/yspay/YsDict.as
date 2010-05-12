package com.yspay
{
    import com.yspay.YsData.PData;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.events.FlexEvent;
    import mx.events.PropertyChangeEvent;
    import mx.utils.ObjectProxy;

    public class YsDict extends HBox implements YsControl
    {
        protected var dict_object:Object;
        public var dict:ObjectProxy;

        protected var _label:Label;
        protected var _text:TextInput;
        protected var _combo:YsComboBox;
        protected var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public function YsDict(parent:DisplayObjectContainer)
        {
            //if (parent is YsHBox || parent is DataGrid)
            {
                _parent = parent;
            }
            /*else
               {
               _parent = new MyFormItem;
               parent.addChild(_parent);
             }*/
            dict_object = {'text': '',
                    'To': 'P_data',
                    'From': 'P_data',
                    'index': 0,
                    'name': ''};
            dict = new ObjectProxy(dict_object);

            dict.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, DictChange);
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function Init(xml:XML):void
        {
            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
            _xml = UtilFunc.FullXml(xml);

            if (_parent is YsDataGrid) //DATAGRID
            {
                var dg:YsDataGrid = _parent as YsDataGrid;
                var data:ArrayCollection = dg.dataProvider as ArrayCollection;
                var dgc:DataGridColumn =  new DataGridColumn;

                for each (var kid:XML in _xml.attributes())
                {
                    if (kid.name() == "editable")
                        dgc.editable = kid.toString();

                }
                var ch_name:String = _xml.display.LABEL.@text;
                var en_name:String = _xml.services.@NAME;
                dgc.headerText = ch_name;
                dgc.dataField = en_name;
                if (!P_data._data[0].hasOwnProperty(en_name)) //赋初值。
                {
                    P_data._data[0][en_name] = new String;
                    //Set DEFAULT VALUE
                    if (_xml.services.@DEFAULT == null)
                        P_data.data[0][en_name] = '';
                    else
                    {
                        var str:String = _xml.services.@DEFAULT;
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

                // 初始化dict_object
                if (_xml.@From != undefined)
                    dict.From = _xml.@From.toString();
                if (_xml.@To != undefined)
                    dict.To = _xml.@To.toString();
                if (_xml.services.@NAME != undefined)
                    dict.name = _xml.services.@NAME.toString();

                if (dict.From == "P_data")
                    P_data.AddDict(dict, _xml.services.@DEFAULT);


                if (_xml.display.LABEL != undefined)
                {
                    if (_xml.@LABEL != undefined)
                        dict.label = _xml.@LABEL;
                    else
                        dict.label = _xml.display.LABEL.@text;

                    _label = new Label;
                    _label.text = dict.label;
                    if (_xml.@LabelVisible != undefined)
                        if (_xml.@LabelVisible == "false")
                            _label.visible = false;
                    this.addChild(_label);
                }
                if (_xml.display.TEXTINPUT != undefined)
                {
                    _text = CreateTextInput(_xml);
                    if (_xml.@OutputOnly != undefined)
                        if (_xml.@OutputOnly == "true")
                            _text.editable = false;
                    if (_xml.@TextInputVisible != undefined)
                        if (_xml.@TextInputVisible == "false")
                            _text.visible = false;

                    this.addChild(_text);
                }
                if (_xml.display.TEXTINPUT.list != undefined)
                {
                    _combo = CreateComboBox(_xml);
                    if (_xml.@OutputOnly != undefined)
                        if (_xml.@OutputOnly == "true")
                            _combo.enabled = false;
                    if (_xml.@ComboBoxVisible != undefined)
                        if (_xml.@ComboBoxVisible == "false")
                            _combo.visible = false;
                    this.addChild(_combo);
                }

                _parent.addChild(this);
            }
        }

        protected function SetComboBox(key:String, value:String):void
        {
            var arr_col:ArrayCollection = _combo.dataProvider as ArrayCollection;

            for each (var obj:Object in arr_col)
            {
                if (obj[key] == value)
                {
                    _combo.selectedItem = obj;
                    break;
                }
            }
        }

        protected function DictChange(event:PropertyChangeEvent):void
        {
            if (event.property == 'text')
            {
                var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
                var P_data:Object = ys_pod._M_data.TRAN[ys_pod.P_cont];
                if (dict.To == "P_data" && P_data.data[dict.index][dict.name] != dict.text)
                    P_data.data[dict.index][dict.name] = dict.text;
                P_data._data.refresh();

                if (_text != null)
                    _text.text = dict.text;
                if (_combo != null)
                    SetComboBox(dict.name, dict.text);
            }
        }

        private function TextInputChange(evt:Event):void
        {
            var tt:TextInput = evt.target as TextInput;

            if (_combo == null)
            {
                dict.text = tt.text;
            }
        }

        private function EnterHandler(event:FlexEvent):void
        {
            var current:TextInput = event.target as TextInput; // == text_input
            var ti_parent:Object = _text.parent; // os: HBox, FormItem
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
            var ti:TextInput = new TextInput;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.text = dict.text;

            ti.addEventListener(Event.CHANGE, TextInputChange);
            ti.addEventListener(FlexEvent.ENTER, EnterHandler);

            return ti;
        }

        private function CreateComboBox(dxml:XML):YsComboBox
        {
            var coboBox:YsComboBox = new YsComboBox(_parent);
            if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                coboBox.labelFunction = ComboBoxShowLabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
            else
                coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

            coboBox.addEventListener("close", ComboChange);
            coboBox.prompt = "请选择...";

            // TODO:ComboBox和YsPod.P_data.ctrls_proxy[index][name]

            coboBox.Init(dxml);

            return coboBox;
        }

        private function ComboBoxShowLabel(item:Object):String
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

        private function ComboChange(evt:Event):void
        {
            var sel_item:Object = _combo.selectedItem;
            if (sel_item == null)
                return;

            dict.text = sel_item[dict.name];
        }
    }
}
