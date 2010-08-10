package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.events.EventNextDict;
    import com.yspay.util.AdvanceArray;
    import com.yspay.util.FunctionCallEvent;
    import com.yspay.util.UtilFunc;
    import com.yspay.util.YsClassFactory;
    import com.yspay.util.YsObjectProxy;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;
    import flash.utils.flash_proxy;

    import mx.collections.ArrayCollection;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.Label;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.events.FlexEvent;
    import mx.events.ListEvent;
    import mx.events.PropertyChangeEvent;
    import mx.managers.FocusManager;
    import mx.managers.IFocusManagerContainer;
    import mx.utils.object_proxy;

    use namespace flash_proxy;
    use namespace object_proxy;

    public class YsDict extends HBox implements YsControl
    {
        protected var dict_object:Object;

        public var editable:Boolean;

        public var LABEL:String = '';
        public var openfile:Boolean;

        public var dict:YsObjectProxy;
        public var D_data:PData = new PData;
        public var _parent:DisplayObjectContainer;
        public var _focusManager:FocusManager = new FocusManager(this as IFocusManagerContainer);

        protected var _label:Label;
        protected var _text:MultipleTextInput;
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
            dict_object = {
                    'text': '',
                    'data': new AdvanceArray,
                    'To': new TargetList,
                    'From': new TargetList,
                    'index': 0,
                    'name': '',
                    'labelFields': null,
                    'source': null,
                    'delimiter': 200};
            dict = new YsObjectProxy(dict_object);
            dict.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, DictChange);
            dict.addEventListener(FunctionCallEvent.EVENT_NAME,
                                  DictFunctionCalled);
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function GetSaveXml():XML
        {
            if (_xml.@save == 'false')
                return null;
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

        protected function InitAttrs():void
        {
            var attrs:Object = YsMaps.dict_dg_attrs;
            for (var attr_name:String in attrs)
            {
                if (!(this.hasOwnProperty(attr_name)))
                {
                    Alert.show('YsDict中没有 ' + attr_name + ' 属性');
                    continue;
                }

                if (_xml.attribute(attr_name).length() == 0)
                {
                    // XML中未描述此属性，取默认值
                    if (attrs[attr_name].hasOwnProperty('default'))
                        this[attr_name] = attrs[attr_name]['default'];
                }
                else
                {
                    this[attr_name] = _xml.attribute(attr_name).toString();
                }
            }
        }

        protected function FindInArr(arr:ArrayCollection, key:String, value:Object):int
        {
            for (var idx:int = 0; idx < arr.length; ++idx)
            {
                if (arr[idx][key] == value)
                    return idx;
            }

            return -1;
        }

        protected function DgComboLabelFunc(item:Object, column:DataGridColumn):String
        {
            trace(item);

            if (dict.labelFields == null)
                return item[dict.name];

            var rtn:String = '';
            var label_arr:Array;
            var field_name:String;

            label_arr = dict_object.labelFields;

            var list_key:String = dict.name + '_list_data';
            var label_key:String = dict.name + '_list_label';
            var list_datas:ArrayCollection = item[list_key];
            if (list_datas == null)
                return item[label_key];

            var idx:int = FindInArr(list_datas, dict.name, item[dict.name]);
            if (idx < 0)
                return item[dict.name];

            for each (field_name in label_arr)
            {
                if (list_datas[idx].hasOwnProperty(field_name) &&
                    list_datas[idx][field_name].length > 0)
                {
                    rtn += list_datas[idx][field_name] + ' ';
                }
            }

            rtn = rtn.substring(0, rtn.length - 1);
            item[label_key] = rtn;
            // 返回时删除字符串末尾的空格
            return rtn;
        }

        protected function InitAsDgChild():void
        {
            var dg:YsDataGrid = _parent as YsDataGrid;
            var data:ArrayCollection = dg.dataProvider as ArrayCollection;
            var dgc:DataGridColumn =  new DataGridColumn;
            this.editable = dg.editable;

            InitAttrs();

            dgc.editable = this.editable;
            dgc.headerText = this.LABEL;
            dgc.dataField = dict.name;
            if (_xml.display.TEXTINPUT.list != undefined)
            {
                dgc.itemEditor = new YsClassFactory(YsDgListItem, this, _xml);
                dgc.labelFunction = DgComboLabelFunc;
            }

            dg.fromDataObject[dict.name] = new TargetList;
            dg.fromDataObject[dict.name].Init(_parent, _xml.From);
            // dg.fromDataObject[dict.name].Add(_xml.Bind);
            // 初始化from data
            for each (var dg_from_data:PData in dg.fromDataObject[dict.name].GetAllTarget())
            {
                dg_from_data.AddToNotifiers(_parent, dict.name);

            }
            if (_xml.display.TEXTINPUT.list.attribute('labelField').length() > 0)
            {
                var label_str:String = _xml.display.TEXTINPUT.list.@labelField;
                dict.labelFields = new Array;
                dict.labelFields = label_str.split(',');
            }

            dg.toDataObject[dict.name] = new TargetList;
            dg.toDataObject[dict.name].Init(_parent, _xml.To);
            // dg.toDataObject[dict.name].Add(_xml.Bind);

            dg.columns = dg.columns.concat(dgc);
            dg.dict_arr.push(this);
            this.visible = false;
            this.height = 0;
            this.width = 0;
            dg.addChild(this);
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

            if (_xml.@LABEL != undefined)
                this.LABEL = _xml.@LABEL;
            else
                this.LABEL = _xml.display.LABEL.@text;

            if (_parent is YsDataGrid) //DATAGRID
            {
                InitAsDgChild();
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
                _parent.addChild(this);

                // if (_xml.From != undefined)
                dict.From.Init(this, _xml.From);
                // dict.From.Add(_xml.Bind);

                // if (_xml.To != undefined)
                dict.To.Init(this, _xml.To);
                // dict.To.Add(_xml.Bind);
                // 初始化dict_object

                for each (var from_data:PData in dict.From.GetAllTarget())
                {
                    var default_value:String = null;
                    if (_xml.services.attribute('DEFAULT').length > 0)
                        default_value = _xml.services.@DEFAULT.text().toString();
                    from_data.AddToNotifiers(this, dict.name, default_value);
                }

                // 初始化 ToData
                for each (var to_data:PData in dict.To.GetAllTarget())
                {
                    to_data.data[dict.name] = new AdvanceArray;
                }

                if (_xml.display.LABEL != undefined)
                {
                    if (_xml.@LABEL != undefined)
                        dict.label = _xml.@LABEL;
                    else
                        dict.label = _xml.display.LABEL.@text;

                    _label = new Label;
                    _label.setStyle("textAlign", "right");
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

                    if (_xml.@openfile != undefined &&
                        _xml.@openfile == 'true')
                        _text.fileable = true;
                    else if (_xml.display.TEXTINPUT.@openfile != undefined &&
                        _xml.display.TEXTINPUT.@openfile == 'true')
                        _text.fileable = true;
                    this.addChild(_text);
                }
                if (_xml.display.TEXTINPUT.list != undefined)
                {
                    _combo = CreateComboBox(_xml);
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

                if (_xml.attribute('default').length() > 0)
                    this.text = _xml.attribute('default').toString();
                trace(this.text);
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

            if (func_name == 'Insert')
                dict.data.Insert(args[0], args[1]);
            else if (func_name == 'RemoveItems')
                dict.data.RemoveItems(args[0], args[1]);
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

        protected function DictFunctionCalled(event:FunctionCallEvent):void
        {
            trace('Dict::FunctionCalled: ', event.args);
            var p_data:PData;
            if (event.function_name == 'Insert')
            {
                if (dict.data.length == _text.listDp.length)
                {
                    for each (p_data in dict.To.GetAllTarget())
                    {
                        trace('dict.Insert:SetValue');
                        p_data.data[dict.name][event.args[0]] = event.args[1];
                    }
                    return;
                }
                _text.listDp.addItemAt(event.args[0], event.args[1]);
            }
            else if (event.function_name == 'RemoveItems')
            {
                if (dict.data.length == _text.listDp.length)
                {
                    for each (p_data in dict.To.GetAllTarget())
                    {
                        trace('dict.RemoveItems: Remove item in PData');
                        if (p_data.data[dict.name].length > dict.data.length)
                            p_data.data[dict.name].RemoveItems(event.args[0], event.args[1]);
                    }
                    return;
                }
                else
                {
                    var cnt:int = event.args[1];
                    while (cnt-- > 0)
                        _text.listDp.removeItemAt(event.args[0]);
                }
            }

            for each (p_data in dict.To.GetAllTarget())
            {
                if (event.function_name == 'Insert')
                {
                    trace('dict.Insert( ' + event.args[0] + ', ' + event.args[1]);
                    p_data.data[dict.name].Insert(event.args[0], event.args[1]);
                }
                else if (event.function_name == 'RemoveItems')
                {
                    trace('dict.RemoveItems ' + event.args[0] + ', ' + event.args[1]);
                    p_data.data[dict.name].RemoveItems(event.args[0], event.args[1]);
                }
            }
        }

        protected function DictChange(event:PropertyChangeEvent):void
        {
            trace("DictChange: ", dict.name, ' ', event.property)
            if (event.property == 'text')
            {
                trace('\tdict.text = ', event.newValue);

                if (_text != null && _text != dict.source)
                    _text.SetText(dict.text);

                //if (_combo != null && _combo != dict.source)
                if (_combo != null) //无论是输入还是选单，都需要修改COMBOBOX，如果是选单，需要修改PROMPT
                    _combo.SetComboBox(dict.name, dict.text);

                this.dispatchEvent(new EventNextDict);
                dict.source = null;
            }

            if (event.source.object == dict_object.data)
            {
                if (event.property == '0')
                    dict.text = event.newValue;

                var idx:int = int(event.property);
                for each (var p_data:PData in dict.To.GetAllTarget())
                {
                    if (p_data.data[dict.name] == null)
                        p_data.data[dict.name] = [''];

                    p_data.data[dict.name][idx] = dict.data[idx];
                }
            }
            if (event.property == 'delimiter')
            {
                if (_label != null)
                {
                    _label.width = dict.delimiter;
                }
            }
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

        private function CreateTextInput(dxml:XML):MultipleTextInput
        {
            var ti:MultipleTextInput = new MultipleTextInput(this, dxml.@openfile);
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
            else if (int(dxml.display.TEXTINPUT.@length) < 10 && ti.maxChars < 10)
                ti.width = (ti_len * 50 > 200) ? 200 : ti_len * 50;
            else
                ti.width = 200;
            ti.width = ti.width + 60;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.text = dict.text;
            //ti.addEventListener(Event.CHANGE, TextInputChange);
            ti.addEventListener(FlexEvent.ENTER, TiEnter);
            return ti;
        }

        protected function TiEnter(event:FlexEvent):void
        {
            this.dispatchEvent(new EventNextDict);
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
