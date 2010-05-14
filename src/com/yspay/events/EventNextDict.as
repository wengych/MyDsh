package com.yspay.events
{

    public class EventNextDict extends YsEvent
    {
        public static var EVENT_NAME:String = 'next_dict';

        public function EventNextDict(bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);
        }
    }
}