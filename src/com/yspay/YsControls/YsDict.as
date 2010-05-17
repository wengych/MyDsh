package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventNextDict;
    import com.yspay.util.GetParentByType;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
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
        public var D_data:PData = new PData;

        protected var _label:Label;
        protected var _text:YsTextInput;
        protected var _combo:YsComboBox;
        protected var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public override function get name():String
        {
            return dict.name;
        }

        public override function set name(new_name:String):void
        {
            dict.name = new_name;
        }

        public function get text():String
        {
            return dict.text;
        }

        public function set text(new_text:String):void
        {
            dict.text = new_text;
        }

        public function YsDict(parent:DisplayObjectContainer)
        {
            _parent = parent;

            dict_object = {'text': '',
                    'To': 'P_data',
                    'From': 'P_data',
                    'index': 0,
                    'name': '',
                    'source': null,
                    'delimiter': 80};
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

            if (_xml.@From != undefined)
                dict.From = _xml.@From.toString();
            if (_xml.@To != undefined)
                dict.To = _xml.@To.toString();
            if (_xml.services.@NAME != undefined)
                dict.name = _xml.services.@NAME.toString();

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

                P_data.AddToNotifiers(_parent, dict.name, _xml.services.@DEFAULT.toString());

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

                if (dict.From == "P_data")
                    P_data.AddToNotifiers(this, dict.name, _xml.services.@DEFAULT.toString());
                else if (dict.From == "D_data")
                    D_data.AddToNotifiers(this, dict.name, _xml.services.@DEFAULT.toString());

                _parent.addChild(this);

                if (_xml.display.LABEL != undefined)
                {
                    if (_xml.@LABEL != undefined)
                        dict.label = _xml.@LABEL;
                    else
                        dict.label = _xml.display.LABEL.@text;

                    _label = new Label;
                    _label.text = dict.label;
                    _label.width = dict.delimiter;
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

                if (_xml.event != undefined)
                {
                    for each (var event_xml:XML in _xml.event)
                    {
                        var ys_event:YsXmlEvent = new YsXmlEvent(this);
                        ys_event.Init(event_xml);
                    }
                }

                    //??????        this.addEventListener(EventNextDict.EVENT_NAME, MoveToNextDict);
            }
        }

        public function Notify(dict_name:String, index:int):void
        {
            if (dict.From == 'D_data')
                return;
            if (dict_name != dict.name)
            {
                trace('error: ', '数据字典名不匹配');
                return;
            }

            var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];

            if (index == -1 && P_data.data[dict_name].length > dict.index)
            {
                dict.text = P_data.data[dict_name][dict.index];
            }
            else if (index == dict.index)
            {
                dict.text = P_data.data[dict_name][index];
            }
        }


        protected function DictChange(event:PropertyChangeEvent):void
        {
            trace("DictChange", event.property)
            if (event.property == 'text')
            {
                var ys_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
                var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
                if (dict.To == "P_data" && P_data.data[dict.name][dict.index] != dict.text)
                    P_data.data[dict.name][dict.index] = dict.text;
                //P_data._data[dict.name].refresh();

                if (_text != null && _text != dict.source)
                    _text.text = dict.text;
                if (_combo != null) //&& _combo != dict.source)
                    _combo.SetComboBox(dict.name, dict.text);

                dict.source = null;
            }
            if (event.property == 'delimiter')
            {
                if (_label != null)
                {
                    _label.width = dict.delimiter;
                }
            }
        }

        private function TextInputChange(evt:Event):void
        {
            var tt:TextInput = evt.target as TextInput;

            //if (_combo == null)
            {
                dict.source = _text;
                dict.text = tt.text;
            }
            //else
            //    _combo.SetComboBox(dict.name, dict.text);
        }

        private function EnterHandler(event:FlexEvent):void
        {
            //MoveToNextDict();
            this.dispatchEvent(new EventNextDict);
        }

        protected function MoveToNextDict(event:EventNextDict):void
        {
            var title_wnd:YsTitleWindow = GetParentByType(_parent, YsTitleWindow) as YsTitleWindow;
            var dict_arr:Array = new Array;

            for each (var wnd_child:Object in title_wnd.getChildren())
            {
                // 找YsDict
                if (!(wnd_child is YsDict))
                    continue;

                // 略过不可输入的YsDict.TextInput
                if (wnd_child._text != null && wnd_child._text.editable == false)
                    continue;

                // 略过不可选择的YsDict.ComboBox
                if (wnd_child._combo != null && wnd_child._combo.enabled == false)
                    continue;

                // 增加符合条件的Dict进array;
                if (wnd_child._text != null || wnd_child._combo != null)
                    dict_arr.push(wnd_child);
            }

            var curr_index:int = dict_arr.indexOf(this);
            if (++curr_index >= dict_arr.length)
                curr_index = 0;

            if (dict_arr[curr_index]._text != null)
                dict_arr[curr_index]._text.setFocus();
            else
                dict_arr[curr_index]._combo.setFocus();
        }

        private function CreateTextInput(dxml:XML):YsTextInput
        {
            var ti:YsTextInput = new YsTextInput;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            var mask:String = '';
            for (var j:int = 0; j < ti.maxChars; j++)
            {
                mask = mask + "*";
            }
            ti.inputMask = mask;
            if (ti.maxChars > 80)
                ti.width = 200;
            else if (int(dxml.display.TEXTINPUT.@length) < 10 && ti.maxChars < 10)
                ti.width = int(dxml.display.TEXTINPUT.@length) * 12;
            else
                ti.width = 200;
            //ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.text = dict.text;

            ti.addEventListener(Event.CHANGE, TextInputChange);
            ti.addEventListener(FlexEvent.ENTER, EnterHandler);

            return ti;
        }

        private function CreateComboBox(dxml:XML):YsComboBox
        {
            var coboBox:YsComboBox = new YsComboBox(this);

            coboBox.addEventListener("close", ComboChange);

            // TODO:ComboBox和YsPod.P_data.ctrls_proxy[index][name]

            coboBox.Init(dxml);

            return coboBox;
        }

        private function ComboChange(evt:Event):void
        {
            var sel_item:Object = _combo.selectedItem;
            if (sel_item == null)
                return;

            dict.source = _combo;
            dict.text = sel_item[dict.name];

            _text.dispatchEvent(new FlexEvent(FlexEvent.ENTER));
        }
    }
}
