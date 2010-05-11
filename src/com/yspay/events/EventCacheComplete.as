package com.yspay.events
{
    import com.yspay.EventCache;

    import flash.events.Event;

    public class EventCacheComplete extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_CacheComplete';
        public var cache_xml:XML;
        public var cache_obj:EventCache;

        public function EventCacheComplete(type:String='Event_CacheComplete', bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            TraceEventName(EVENT_NAME);
        }

    }
}