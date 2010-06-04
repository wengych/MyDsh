package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.ComboBox;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.managers.IFocusManagerComponent;

    public class YsComboBox extends ComboBox implements YsControl
    {

        public var _parent:DisplayObjectContainer;
        protected var data_count:String;
        protected var combo_data:ArrayCollection = new ArrayCollection; //存放本作用域的数据

        protected var column_p_data:Object = new Object;
        protected var column_dict_arr:Array = new Array;

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

        public function Init(dxml:XML):void
        {
            //var parent_dict:YsDict = _parent as YsDict;
            var parent_pod:YsPod = UtilFunc.GetParentByType(_parent, YsPod) as YsPod;

            var P_data:PData = parent_pod.D_data;
            var data_cont:int = P_data.datacont++;
            var i:int = 0;
            var x:XML;

            if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                labelFunction = ComboBoxShowLabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
            else
                labelField = dxml.display.TEXTINPUT.list.@labelField;

            prompt = "请选择...";
            data = new Object;
            data.name = dxml.services.@NAME.toString();
            data.index = 0;
            data.xml = dxml;
            data_count = "data" + data_cont.toString();
            P_data[data_count] = combo_data;
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
                for each (x in dxml.display.TEXTINPUT.list.*)
                {
                    combo_data.addItem(new Object);
                    for each (var xx:XML in x.*)
                    {
                        combo_data[combo_data.length - 1][xx.name().toString()] = xx.text().toString();
                    }
                }
            else if (dxml.display.TEXTINPUT.list.DICT != undefined)
            {
                for each (x in dxml.display.TEXTINPUT.list.DICT)
                {
                    var en_name:String = x.text().toString();
                    en_name = en_name.substr(en_name.search("://") + 3);

                    var from_list:TargetList = new TargetList;
                    from_list.Init(this, x.From);

                    column_p_data[en_name] = new Array;

                    for each (var from_item:PData in from_list.GetAllTarget())
                    {
                        from_item.AddToNotifiers(this, en_name);
                        column_p_data[en_name].push(from_item);
                    }

                    if (column_p_data[en_name].length == 0)
                        continue;

                    var D_data:PData = column_p_data[en_name][0];

                    //combo_data.addItem(new Object); //选中项目？
                    column_dict_arr.push(en_name);

                    for (i = 0; i < D_data.data[en_name].length; ++i)
                    {
                        if (combo_data.length <= i)
                        {
                            combo_data.addItem(new Object);
                        }
                        combo_data[i][en_name] = D_data.data[en_name][i];
                    }
                }
            }
            dataProvider = combo_data;
        }

        private function ComboBoxShowLabel(item:Object):String
        {
            var sortarr:Array = new Array;
            var len:int;

            if (item == null)
                return '';

            var returnvalue:String = new String;
            if (item.hasOwnProperty("mx_internal_uid"))
                item.setPropertyIsEnumerable('mx_internal_uid', false);

            for (var o:Object in item)
                sortarr.push(o.toString());
            sortarr = sortarr.sort();
            for (; ; )
            {
                len = sortarr.length;
                if (len == 0)
                    break;
                o = sortarr.pop();
                if (item[o] == null)
                    continue;
                returnvalue += item[o].toString() + ' - ';
            }

            return (returnvalue.substring(0, returnvalue.length - 3));
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
            //prompt = "请选择...";
            //selectedIndex = -1;
            arr_col.filterFunction = filter_func;
            arr_col.refresh();
            if (arr_col.length == 0) //未找到符合条件记录
            {
                arr_col.filterFunction = null;
                arr_col.refresh();
                open();
                return;
            }
//            validateNow();
//            dropdown.validateNow();
            dropdown.selectedIndex = -1;
            dropdown.verticalScrollPosition = 0;
            open();

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
    }
}
