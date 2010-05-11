package com.yspay.events
{
    import flash.events.Event;

    public class YsEvent extends Event
    {
        public function YsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
        }

        public function TraceEventName(event_name:String):void
        {
            trace(event_name);
        }
    }
}