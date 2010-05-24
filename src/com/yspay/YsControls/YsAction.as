package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.StackEvent;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    public class YsAction extends YsInvisible implements YsControl
    {
        public var action_name:String;
        protected var action_arg_list:Array;
        public var _parent:DisplayObjectContainer;
        public var D_data:PData = new PData;

        public function YsAction(parent:DisplayObjectContainer)
        {
            _parent = parent;
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);
            _xml = UtilFunc.FullXml(xml);
            action_name = xml.text().toString();
            (_parent as Object).action_list.push(this);
        }

        public override function GetXml():XML
        {
            return _xml;
        }

        public function Do(stack_event:StackEvent, source_event:Event):void
        {
            var action_func:Function = EventHandlerFactory.get_handler(action_name);
            action_func(stack_event.target_component, stack_event.source, _xml);
            _parent.dispatchEvent(stack_event);
        }
    }
}
