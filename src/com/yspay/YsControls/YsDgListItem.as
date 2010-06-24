package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

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

        override public function Init(xml:XML):void
        {
            trace('YsDgListItem.Init');
            trace(xml.toString());
            super.Init(xml);
            this.addEventListener(ListEvent.CHANGE, ComboChange);

            _xml = UtilFunc.FullXml(xml);
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
            dict_name = _xml.services.@NAME;

            for each (var from_data:PData in from_target_list.GetAllTarget())
            {
                var default_value:String = null;
                if (_xml.services.attribute('DEFAULT').length > 0)
                    default_value = _xml.services.@DEFAULT.text().toString();
                from_data.AddToNotifiers(this, dict_name);
            }
        }

        private function ComboChange(evt:Event):void
        {
            var sel_item:Object = this.selectedItem;
            if (sel_item == null)
                return;

            var ys_dict:YsDict = _parent as YsDict;
            if (ys_dict == null)
                return;
            ys_dict.dict.source = this;
            ys_dict.dict.text = sel_item[ys_dict.dict.name];
        }
    }
}
