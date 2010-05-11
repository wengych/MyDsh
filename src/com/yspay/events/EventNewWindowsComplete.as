package com.yspay.events
{
    import com.yspay.YsPod;

    import flash.events.Event;

    public class EventNewWindowsComplete extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_CacheComplete';
        public var ys_pod:YsPod;

        public function EventNewWindowsComplete(type:String='Event_CacheComplete', bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            TraceEventName(EVENT_NAME);
        }

    }
}