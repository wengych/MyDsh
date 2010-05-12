package com.yspay.events
{
    import flash.events.Event;

    import mx.core.UIComponent;


    public class StackEvent extends YsEvent
    {

        public static const EVENT_NAME:String = 'event_stack_event';

        protected var _data:Array;
        protected var _target:UIComponent;
        protected var _source:Event;

        public function StackEvent(data:Array, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);

            this._data = data;

            TraceEventName(EVENT_NAME + '事件长度 ' + _data.length.toString());
        }

        public function NextEvent():Object
        {
            var rtn:Object = null;
            if (_data.length > 0)
            {
                rtn = _data.shift();
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
            var e:StackEvent = new StackEvent(_data);
            e.source = _source;
            e.target_component = _target;
            return e;
        }
    }
}
