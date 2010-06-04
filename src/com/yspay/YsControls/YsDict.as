package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.events.EventNextDict;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.events.ListEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.FocusManager;
    import mx.managers.IFocusManagerContainer;
    import mx.utils.ObjectProxy;

    public class YsDict extends HBox implements YsControl
    {
        protected var dict_object:Object;
        public var dict:ObjectProxy;
        public var D_data:PData = new PData;
        public var _parent:DisplayObjectContainer;
        public var _focusManager:FocusManager = new FocusManager(this as IFocusManagerContainer);

        protected var _label:Label;
        protected var _text:TextInput;
        protected var _combo:YsComboBox;
        protected var _xml:XML;

        public var _To:TargetList = new TargetList;
        public var _From:TargetList =  new TargetList;

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

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function YsDict(parent:DisplayObjectContainer)
        {
            _parent = parent;

            dict_object = {'text': '',
                    'To': new TargetList,
                    'From': new TargetList,
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

        public function GetSaveXml():XML
        {
            if (_xml.@save == 'false')
                return null;
            // TODO: 实现生成保存格式的xml的方�

            return null;
        }

        public function GetLinkXml():XML
        {
            if (_xml.@save == 'false')
                return null;

            var rtn:XML = new XML('<L KEY="" KEYNAME="" VALUE="" />');
            rtn.@VALUE = type + '://' + _xml.text().toString();
            rtn.@KEY = type;
            rtn.@KEYNAME = type;

            var target_name:String;
            var target_node:XML;
            for each (target_name in dict.From.GetAllTargetName())
            {
                target_node = new XML('<L KEY="From" KEYNAME="From" VALUE="" />');
                target_node.@VALUE = target_name;
                rtn.appendChild(target_node);
            }
            for each (target_name in dict.To.GetAllTargetName())
            {
                target_node = new XML('<L KEY="To" KEYNAME="To" VALUE="" />');
                target_node.@VALUE = target_name;
                rtn.appendChild(target_node);
            }

            return rtn;
        }

        public function Init(xml:XML):void
        {
            var ys_pod:YsPod = UtilFunc.GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
            _xml = UtilFunc.FullXml(xml);

            if (_xml == null)
            {
                // TODO 将此处代码扩展到所有类型中
                Alert.show('无此dict' + xml.text().toString());
                return;
            }

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

                // P_data.AddToNotifiers(_parent, dict.name, _xml.services.@DEFAULT.toString());
                dg.fromDataObject[dict.name] = new TargetList;
                dg.fromDataObject[dict.name].Init(_parent, _xml.From);
                for each (var dg_from_data:PData in dg.fromDataObject[dict.name].GetAllTarget())
                {
                    dg_from_data.AddToNotifiers(_parent, dict.name);
                }

                dg.toDataObject[dict.name] = new TargetList;
                dg.toDataObject[dict.name].Init(_parent, _xml.To);


                dg.columns = dg.columns.concat(dgc);
                    // TODO:针对DataGrid的处理方�
                    //(_parent as DataGrid); // 添加�
            }
            else //COMBOBOX || TEXTINPUT
            { //<DICT LABEL="CNAME" 
                //       LabelVisible="true" 
                //       TextInputVisible="true" 
                //       ComboBoxVisible="true" 
                //       OutputOnly="true"
                //       from="pod"
                //       from="windows"
                //       from="dict"
                //       from="parent"
                //       to="pod"
                //       to="windows"
                //       to="dict"
                //       to="parent"
                //>

                // if (_xml.From != undefined)
                dict.From.Init(this, _xml.From);

                // if (_xml.To != undefined)
                dict.To.Init(this, _xml.To);
                // 初始化dict_object

                for each (var from_data:PData in dict.From.GetAllTarget())
                {
                    var default_value:String = null;
                    if (_xml.services.attribute('DEFAULT').length > 0)
                        default_value = _xml.services.@DEFAULT.text().toString();
                    from_data.AddToNotifiers(this, dict.name, default_value);
                }

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

                if (_xml.BUTTON != undefined)
                {
                    for each (var btn_xml:XML in _xml.BUTTON)
                    {
                        var ys_btn:YsButton = new YsButton(this);
                        ys_btn.Init(btn_xml);
                    }
                }
            }
        }

        public function NotifyFunctionCall(p_data:PData,
                                           dict_name:String,
                                           func_name:String,
                                           args:Array):void
        {
            trace('YsDict::NotifyFunctionCall( ' +
                  dict_name + ',' +
                  func_name + ',' +
                  args + ')');
        }

        public function Notify(p_data:PData, dict_name:String, index:int):void
        {
            if (dict_name != dict.name)
            {
                trace('error: ', '数据字典名不匹配');
                return;
            }

            if (index == -1 && p_data.data[dict_name].length > dict.index)
            {
                dict.text = p_data.data[dict_name][dict.index];
            }
            else if (index == dict.index)
            {
                dict.text = p_data.data[dict_name][index];
            }
        }


        protected function DictChange(event:PropertyChangeEvent):void
        {
            trace("DictChange", event.property)
            if (event.property == 'text')
            {
                trace('\tdict.text = ', event.newValue);
                for each (var p_data:PData in dict.To.GetAllTarget())
                {
                    if (p_data.data[dict.name] == null)
                        p_data.data[dict.name] = [''];
                    p_data.data[dict.name][dict.index] = dict.text;
                }

                if (_text != null && _text != dict.source)
                    _text.text = dict.text;
                //if (_combo != null && _combo != dict.source)
                if (_combo != null) //无论是输入还是选单，都需要修改COMBOBOX，如果是选单，需要修改PROMPT
                    _combo.SetComboBox(dict.name, dict.text);

                this.dispatchEvent(new EventNextDict);

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

        protected function MoveToNextDict(event:EventNextDict):void
        {
            var title_wnd:YsTitleWindow = UtilFunc.GetParentByType(_parent, YsTitleWindow) as YsTitleWindow;
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

        private function CreateTextInput(dxml:XML):TextInput
        {
            var ti:TextInput = new TextInput;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            var mask:String = '';
            for (var j:int = 0; j < ti.maxChars; j++)
            {
                mask = mask + "*";
            }
            //ti.inputMask = mask;
            var ti_len:int = int(dxml.display.TEXTINPUT.@length);
            if (ti.maxChars > 40)
                ti.width = 200;
            //else
            //    ti.width = ti.maxChars;
            else if (int(dxml.display.TEXTINPUT.@length) < 10 && ti.maxChars < 10)
                //    ti.width = int(dxml.display.TEXTINPUT.@length) * 12;
                ti.width = (ti_len * 50 > 200) ? 200 : ti_len * 50;
            else
                ti.width = 200;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.text = dict.text;

            ti.addEventListener(Event.CHANGE, TextInputChange);

            return ti;
        }

        private function CreateComboBox(dxml:XML):YsComboBox
        {
            var coboBox:YsComboBox = new YsComboBox(this);

            // coboBox.addEventListener("close", ComboChange);
            coboBox.addEventListener(ListEvent.CHANGE, ComboChange);

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
        }
    }
}
