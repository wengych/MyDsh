package com.yspay
{
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.events.StackEvent;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.controls.Button;

    public class YsAction extends YsInvisible implements YsControl
    {
        protected var action_name:String;
        protected var action_info:XML;
        protected var _parent:DisplayObjectContainer;

        public function YsAction(parent:DisplayObjectContainer)
        {
            _parent = parent;
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);

            action_info = new XML(xml);
            action_name = xml.text().toString();
            (_parent as Object).action_list.push(this);
        }

        public override function GetXml():XML
        {
            return action_info;
        }

        public function Do(stack_event:StackEvent, source_event:Event):void
        {
            var action_func:Function = EventHandlerFactory.get_handler(action_name);
            action_func(stack_event.target_component, stack_event.source);

            _parent.dispatchEvent(stack_event);
        }
    }
}
