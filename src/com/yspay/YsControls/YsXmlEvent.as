package com.yspay.YsControls
{
    import com.yspay.events.StackEvent;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.controls.ComboBox;
    import mx.controls.DataGrid;
    import mx.core.UIComponent;

    public class YsXmlEvent extends YsButton implements YsControl
    {
        protected var need_save:Boolean;

        public function YsXmlEvent(parent:DisplayObjectContainer)
        {
            super(parent);
        }

        public override function Init(xml:XML):void
        {
            this.enabled = false;
            this.height = 0;
            this.width = 0;
            this.visible = false;

            /*if (_parent is DataGrid)
               ;
             else */
            if (_parent is ComboBox)
                _parent.addChild(this);
            else
                _parent.addChild(this);
            _xml = xml;

            this.setStyle('fontWeight', 'normal');
            UtilFunc.InitAttrbutes(YsMaps.event_attrs, this, _xml);
            UtilFunc.InitChild(this, _xml);

            need_save = false;
            var event_name:String = _xml.text().toString();

            this._parent.addEventListener(event_name, EventActived); //fd.create(func, _parent));
        }

        public override function GetXml():XML
        {
            if (need_save)
                return _xml;

            return null;
        }

        protected function EventActived(event:Event):void
        {
            trace('YsXmlEvent.EventActived ' + _xml.text().toString());
            var stack_event:StackEvent = new StackEvent(action_list.concat());
            stack_event.target_component = _parent as UIComponent;
            stack_event.source = event;

            this.dispatchEvent(stack_event);
        }

    }
}
