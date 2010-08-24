package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.ComboBox;
    import mx.core.UIComponent;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.managers.IFocusManagerComponent;

    public class YsComboBox extends ComboBox implements YsControl
    {

        public var _parent:DisplayObjectContainer;
        protected var data_count:String;
        protected var combo_data:ArrayCollection; //存放本作用域的数据

        protected var column_p_data:Object = new Object;
        protected var column_dict_arr:Array = new Array;

        protected var labelFields:Array;

        public function YsComboBox(parent:DisplayObjectContainer) //)xml:XML, key_name:String, key_index:int=0)
        {
            super();
            _parent = parent;
        }

        public function GetLink():XML
        {
            var rtn:XML = new XML;

            return rtn;
        }

        protected function InitLabel(dxml:XML):void
        {
            labelFunction = ComboBoxShowLabel;
            /*
               if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
               labelFunction = ComboBoxShowLabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
               else
             */
            if (dxml.display.TEXTINPUT.list.attribute('labelField').length() > 0)
            {
                var label_str:String = dxml.display.TEXTINPUT.list.@labelField;
                labelFields = new Array;
                labelFields = label_str.split(',');
            }
        }

        public function Init(dxml:XML):void
        {
            var idx:int = 0;
            var temp_xml:XML;
            combo_data = new ArrayCollection;

            InitLabel(dxml);

            prompt = "请选择...";
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
                for each (temp_xml in dxml.display.TEXTINPUT.list.*)
                {
                    combo_data.addItem(new Object);
                    for each (var xx:XML in temp_xml.*)
                    {
                        combo_data[combo_data.length - 1][xx.name().toString()] = xx.text().toString();
                    }
                }
            else if (dxml.display.TEXTINPUT.list.DICT != undefined)
            {
                for each (temp_xml in dxml.display.TEXTINPUT.list.DICT)
                {
                    var en_name:String = temp_xml.text().toString();
                    en_name = en_name.substr(en_name.search("://") + 3);

                    var from_list:TargetList = new TargetList;
                    from_list.Init(this, temp_xml.From);

                    column_p_data[en_name] = new Array;

                    for each (var from_item:PData in from_list.GetAllTarget())
                    {
                        from_item.AddToNotifiers(this, en_name);
                        column_p_data[en_name].push(from_item);
                    }

                    if (column_p_data[en_name].length == 0)
                        continue;

                    var D_data:PData = column_p_data[en_name][0];

                    column_dict_arr.push(en_name);

                    for (idx = 0; idx < D_data.data[en_name].length; ++idx)
                    {
                        if (combo_data.length <= idx)
                        {
                            combo_data.addItem(new Object);
                        }
                        combo_data[idx][en_name] = D_data.data[en_name][idx];
                    }
                }
            }
            dataProvider = combo_data;
        }

        private function ComboBoxShowLabel(item:Object):String
        {
            var rtn:String = '';
            var label_arr:Array;
            var field_name:String;
            if (labelFields == null)
            {
                label_arr = new Array;
                for (field_name in item)
                    if (field_name != 'mx_internal_uid')
                        label_arr.push(field_name);
            }
            else
                label_arr = labelFields;

            for each (field_name in label_arr)
            {
                if (item.hasOwnProperty(field_name))
                {
                    rtn += item[field_name].toString() + ' ';
                }
            }

            // 返回时删除字符串末尾的空格
            return (rtn.substring(0, rtn.length - 1));
        }

        override protected function collectionChangeHandler(event:Event):void
        {
            super.collectionChangeHandler(event);
            if (event is CollectionEvent)
            {
                var ce:CollectionEvent = CollectionEvent(event);
                if (ce.kind == CollectionEventKind.REMOVE)
                {
                    trace('remove item at ' + ce.location.toString());
                }
            }
        }

        protected function OnRemoveItems(p_data:PData,
                                         dict_name:String,
                                         startPos:int,
                                         count:int=-1):void
        {
            trace('YsComboBox::OnRemoveItems');
            if (combo_data.length > p_data.data[dict_name].length)
            {
                if (count < 0)
                    count = combo_data.length - startPos;
                while (--count >= 0)
                    combo_data.removeItemAt(startPos + count);
            }
        }

        protected function OnAddEmptyItems(p_data:PData,
                                           dict_name:String,
                                           count:int):void
        {
            trace('YsComboBox::OnAddEmptyItems');

            if (combo_data.length < p_data.data[dict_name].length)
            {
                while (--count >= 0)
                    combo_data.addItem(new Object);
            }
        }

        protected function OnInsert(p_data:PData,
                                    dict_name:String,
                                    startPos:int,
                                    ... rest):void
        {
            trace('YsComboBox::OnInsert');
        }

        public function NotifyFunctionCall(p_data:PData,
                                           dict_name:String,
                                           func_name:String,
                                           args:Array):void
        {
            trace('YsComboBox::NotifyFunctionCall( ' +
                  dict_name + ',' +
                  func_name + ',' +
                  args + ')');

            var func_map:Object =
                {
                    'RemoveItems': OnRemoveItems,
                    'AddEmptyItems': OnAddEmptyItems,
                    'Insert': OnInsert
                };

            func_map[func_name](p_data, dict_name, args);
        }

        public function Notify(p_data:PData,
                               dict_name:String,
                               index:int):void
        {
            var idx:int = column_dict_arr.indexOf(dict_name);
            if (idx < 0)
                return;

            combo_data.filterFunction = null;

            combo_data[index][dict_name] = p_data.data[dict_name][index];

            selectedIndex = 0;
            validateNow();

            selectedIndex = -1;
            validateNow();

            var focus_comp:IFocusManagerComponent =
                (_parent as YsDict)._focusManager.getFocus();
            //if (focus_comp != null && (_parent as YsDict).contains(focus_comp as DisplayObject))
            //    open();

            //(this._parent._text as TextInput).getFocus();
            //open();

            dropdown.selectedIndex = 0;
            dropdown.validateNow();
            dropdown.selectedIndex = -1;
            dropdown.validateNow();

            trace('YsComboBox.Notify');
        }

        public function GetXml():XML
        {
            trace('ComboBox不生成XML,由YsDict产生XMl');

            return null;
        }

        public function SetComboBox(key:String, value:String):void
        {
            trace("SetComboBox")
            var arr_col:ArrayCollection = combo_data;
            var filter_func:Function =
                function(combo_item:Object):Boolean
                {
                    return filterFunction(combo_item, key, value);
                }
            if (value == "")
            {
                prompt = "请选择...";
                arr_col.filterFunction = null;
                arr_col.refresh();
                selectedIndex = -1;
                open();
                return;
            }
            for each (var obj:Object in arr_col)
            {
                if (obj[key] == value)
                {
                    selectedItem = obj;
                    prompt = ComboBoxShowLabel(obj);
                    close();
                    arr_col.filterFunction = null;
                    arr_col.refresh();
                    return;
                }
            }
            arr_col.filterFunction = filter_func;
            arr_col.refresh();
            dropdown.selectedIndex = -1;
            dropdown.verticalScrollPosition = 0;
            //open();
        }

        private function filterFunction(item:Object,
                                        key:String,
                                        value:String):Boolean
        {
            if (!item.hasOwnProperty(key) || item[key] == null)
            {
                trace('combo box filerFunction error.');
                return false;
            }

            var val:String = item[key];
            var rtn:Boolean = item[key].toString().indexOf(value) != -1;
            return rtn;
        }

        public function GetSaveXml():XML
        {
            return null;
        }

        public function GetLinkXml():XML
        {
            return null;
        }

        public function get type():String
        {
            return '';
        }

        public function Print(print_container:UIComponent):UIComponent
        {
            return null;
        }
    }
}
