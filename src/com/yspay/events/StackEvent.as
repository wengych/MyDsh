package com.yspay.events
{
    import flash.events.Event;

    import mx.core.UIComponent;


    public class StackEvent extends YsEvent
    {

        public static const EVENT_NAME:String = 'event_stack_event';

        protected var _event_list:Array;
        protected var _target:UIComponent;
        protected var _source:Event;

        public var event_data:Object;

        public function StackEvent(data:Array, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);

            this._event_list = data;
            this.event_data = new Object;

            TraceEventName(EVENT_NAME + '事件长度 ' + _event_list.length.toString());
        }

        public function NextEvent():Object
        {
            var rtn:Object = null;
            if (_event_list.length > 0)
            {
                rtn = _event_list.shift();
            }

            return rtn;
        }

        public function get source():Event
        {
            return _source;
        }

        public function set source(source_event:Event):void
        {
            _source = source_event;
        }

        public function get target_component():UIComponent
        {
            return _target;
        }

        public function set target_component(ui_comp:UIComponent):void
        {
            _target = ui_comp;
        }

        override public function clone():Event
        {
            var e:StackEvent = new StackEvent(_event_list);
            e.source = _source;
            e.target_component = _target;
            return e;
        }
    }
}
