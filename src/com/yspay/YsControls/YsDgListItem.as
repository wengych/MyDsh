package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.events.DropdownEvent;
    import mx.events.ListEvent;

    public class YsDgListItem extends YsComboBox
    {
        protected var _xml:XML;
        public var D_data:PData = new PData;
        public var from_target_list:TargetList = new TargetList;
        public var to_target_list:TargetList = new TargetList;
        public var dict_name:String;

        public function YsDgListItem(parent:DisplayObjectContainer)
        {
            trace('YsDgListItem');
            //trace((dict as YsDict).dict.text);
            super(parent);
        }

        override public function Init(dxml:XML):void
        {
            _xml = UtilFunc.FullXml(dxml);
            dict_name = _xml.services.@NAME;
            trace('YsDgListItem.Init ', this.dict_name);

            var dg:YsDataGrid =
                UtilFunc.YsGetParentByType(this._parent, YsDataGrid) as YsDataGrid;
            var dg_idx:int = dg.selectedIndex;
            var dg_key:String = dict_name + '_list_data';

            var dg_data:ArrayCollection = dg.dataProvider as ArrayCollection;

            if (dg_data[dg_idx][dg_key] == undefined)
                dg_data[dg_idx][dg_key] = new ArrayCollection;
            combo_data = dg_data[dg_idx][dg_key];

            var idx:int = 0;
            var temp_xml:XML;

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
            this.addEventListener(ListEvent.CHANGE, ComboChange);
            this.addEventListener(DropdownEvent.CLOSE, ComboClose);

            if (_xml == null)
                return;

            if (_xml.event != undefined)
            {
                for each (var event_xml:XML in _xml.event)
                {
                    var ys_event:YsXmlEvent = new YsXmlEvent(this);
                    ys_event.Init(event_xml);
                }
            }

            from_target_list.Init(this, _xml.From);
            to_target_list.Init(this, _xml.To);

            for each (var from_data:PData in from_target_list.GetAllTarget())
            {
                var default_value:String = null;
                if (_xml.services.attribute('DEFAULT').length > 0)
                    default_value = _xml.services.@DEFAULT.text().toString();
                from_data.AddToNotifiers(this, dict_name);
            }
        }

        public override function get text():String
        {
            var sel_item:Object = this.selectedItem;
            if (sel_item == null)
                return '';

            return sel_item[this.dict_name];
        }

        protected function ComboChange(evt:Event):void
        {
            var dg:YsDataGrid =
                UtilFunc.YsGetParentByType(this._parent, YsDataGrid) as YsDataGrid;
            var dg_idx:int = dg.selectedIndex;

            var sel_item:Object = this.selectedItem;
            if (sel_item == null)
                return;

            var ys_dict:YsDict = _parent as YsDict;
            if (ys_dict == null)
                return;
            ys_dict.dict.source = this;

            //ys_dict.dict.data[dg_idx] = sel_item[ys_dict.dict.name];
            ys_dict.dict.text = sel_item[ys_dict.dict.name];
        }

        protected function ComboClose(evt:DropdownEvent):void
        {
            trace(evt.triggerEvent);
        }
    }
}
