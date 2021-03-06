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
    import mx.controls.DataGrid;
    import mx.controls.Label;
    import mx.controls.Text;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.UIComponent;
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
        protected var _text:Object;
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
            // this.editable = dg.editable;

            UtilFunc.InitAttrbutes(YsMaps.dict_dg_attrs, this, _xml);

            // dgc.sortable = false;
            dgc.editable = dg.editable;
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

            dg.columns = dg.columns.concat(dgc);
            // dg.dict_arr.push(this);
            this.visible = false;
            this.height = 0;
            this.width = 0;
            dg.addChild(this);
        }

        protected function InitDict():void
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
            dict.To.Init(this, _xml.To);
            // 初始化数据
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

            // 设置label
            if (_xml.@LABEL != undefined)
                dict.label = _xml.@LABEL;
            else if (_xml.display.LABEL != undefined)
                dict.label = _xml.display.LABEL.@text;
            _label = CreateLabel();
            this.addChild(_label);

            if ((_xml.@InputType != undefined && _xml.@InputType == 'TextArea') ||
                (_xml.@InputType == undefined && _xml.display.TEXTAREA != undefined))
            {
                var ta:MultipleTextArea = CreateTextArea(_xml);

                _text = ta;
                this.addChild(ta);
            }
            if ((_xml.@InputType != undefined && _xml.@InputType == 'TextInput') ||
                (_xml.@InputType == undefined && _xml.display.TEXTINPUT != undefined))
            {
                var ti:MultipleTextInput =  CreateTextInput(_xml);

                _text = ti;
                this.addChild(ti);
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
                InitAsDgChild();
            else //COMBOBOX || TEXTINPUT
                InitDict();
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
                dict.source = p_data;
                dict.text = p_data.data[dict_name][dict.index];
            }
            else if (index == dict.index)
            {
                dict.source = p_data;
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
                    if (p_data.data[dict.name].length < dict.data.length)
                        p_data.data[dict.name].Insert(event.args[0], event.args[1]);
                }
                else if (event.function_name == 'RemoveItems')
                {
                    trace('dict.RemoveItems ' + event.args[0] + ', ' + event.args[1]);
                    if (p_data.data[dict.name].length > dict.data.length)
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

        protected function CreateLabel():Label
        {
            var label:Label = new Label;
            label.setStyle("textAlign", "right");
            label.text = dict.label;
            label.width = dict.delimiter;
            if (_xml.@LabelVisible != undefined)
                if (_xml.@LabelVisible == "false")
                    label.visible = false;

            return label;
        }

        private function CreateTextInput(dxml:XML):MultipleTextInput
        {
            var ti:MultipleTextInput = new MultipleTextInput(this);
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            var mask:String = '';
            for (var j:int = 0; j < ti.maxChars; j++)
            {
                mask = mask + "*";
            }
            //ti.inputMask = mask;
//            var maxchars:int = 40;
            var maxshowlen:int = 200;
            var maxcharwidth:int = 40;
            var ti_len:int = int(dxml.display.TEXTINPUT.@length);
            ti_len = (ti.maxChars > ti_len) ? ti.maxChars : ti_len;
            ti_len = (ti_len <= 0) ? 1 : ti_len;
            ti.width = ti_len * maxcharwidth;
            ti.width = (ti.width > maxshowlen) ? maxshowlen : ti.width;

            if (dxml.display.TEXTINPUT.@displayAsPassword != undefined &&
                dxml.display.TEXTINPUT.@displayAsPassword == 1)
                ti.displayAsPassword = true;
            // ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.text = dict.text;
            //ti.addEventListener(Event.CHANGE, TextInputChange);
            ti.addEventListener(FlexEvent.ENTER, TiEnter);

            if (_xml.@OutputOnly != undefined)
                if (_xml.@OutputOnly == "true")
                    ti.editable = false;
            if (_xml.@TextInputVisible != undefined)
                if (_xml.@TextInputVisible == "false")
                    ti.visible = false;

            if (_xml.@openfile != undefined &&
                _xml.@openfile == 'true')
                ti.fileable = true;
            else if (_xml.display.TEXTINPUT.@openfile != undefined &&
                _xml.display.TEXTINPUT.@openfile == 'true')
                ti.fileable = true;

            return ti;
        }

        private function CreateTextArea(dxml:XML):MultipleTextArea
        {
            var ta:MultipleTextArea = new MultipleTextArea(this);
            ta.text = '';
            ta.maxChars = int(dxml.services.@LEN);
            var mask:String = '';
            for (var j:int = 0; j < ta.maxChars; j++)
            {
                mask = mask + "*";
            }
            //ta.inputMask = mask;
//            var maxchars:int = 40;
            var maxshowlen:int = 500;
            var maxcharwidth:int = 40;
            var ta_len:int = int(dxml.display.TEXtaNPUT.@length);
            ta_len = (ta.maxChars > ta_len) ? ta.maxChars : ta_len;
            ta_len = (ta_len <= 0) ? 1 : ta_len;
            ta.width = ta_len * maxcharwidth;
            ta.width = (ta.width > maxshowlen) ? maxshowlen : ta.width;

            if (dxml.display.TEXTAREA.@displayAsPassword != undefined &&
                dxml.display.TEXTAREA.@displayAsPassword == 1)
                ta.displayAsPassword = true;
            ta.text = dict.text;

            if (_xml.@OutputOnly != undefined &&
                _xml.@OutputOnly == 'true')
                ta.editable = false;
            if (_xml.@TextAreaVisible != undefined &&
                _xml.@TextAreaVisible == 'false')
                ta.visible = false;

            if (_xml.@openfile != undefined &&
                _xml.@openfile == 'true')
                ta.fileable = true;
            else if (_xml.display.TEXTAREA.@openfile != undefined &&
                _xml.display.TEXTAREA.@openfile == 'true')
                ta.fileable = true;

            var line:int = 0;
            if (_xml.@line != undefined)
                line = int(_xml.@line);
            else if (_xml.display.TEXTAREA.line != undefined)
                line = int(_xml.display.TEXTAREA);
            ta.height = 16 * line;

            return ta;
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

        public function Print(print_container:UIComponent, print_call_back:Function):UIComponent
        {
            var print_area:UIComponent;
            if (print_container == null)
                print_area = print_call_back();
            else
                print_area = print_container;

            if (print_area is DataGrid)
                PrintDatagrid(print_area as DataGrid);
            else
                PrintDict(print_area);
            return print_area;
        }

        protected function PrintDatagrid(dg:DataGrid):void
        {
            var dgc:DataGridColumn =  new DataGridColumn;

            dgc.headerText = this.LABEL;
            dgc.dataField = dict.name;
            dgc.labelFunction = DgPrintLabelFunc;

            dg.columns = dg.columns.concat(dgc);
        }

        protected function DgPrintLabelFunc(item:Object, column:DataGridColumn):String
        {
            var label_key:String = dict.name + '_list_label';
            if (item[label_key] != undefined)
                return item[label_key];
            else
                return item[dict.name];
        }

        protected function PrintDict(print_area:UIComponent):void
        {
            var label_width:int = 100;
            var text_width:int = 160;
            var hbox:HBox = new HBox;
            //hbox.setStyle('border', 'none');
            //hbox.setStyle('borderColor', '#ffffff');

            var label:Label = new Label;
            var value:Text = new Text;


            label.setStyle("textAlign", "right");
            value.setStyle('fontWeight', 'normal');
            // label.setStyle('fontFamily', 'myFont');
            label.width = label_width;
            label.text = _label.text;

            value.setStyle('textAlign', 'justify');
            value.setStyle('fontWeight', 'normal');
            // value.setStyle('fontFamily', 'myFont');
            value.width = text_width;
            value.text = _text.text;

            hbox.addChild(label);
            hbox.addChild(value);

            print_area.addChild(hbox);
        }

        public function GetId():String
        {
            return id;
        }
    }
}
