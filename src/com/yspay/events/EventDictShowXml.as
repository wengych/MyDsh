package com.yspay.events
{

    import com.yspay.YsControls.YsPod;

    import flash.events.Event;

    public class EventDictShowXml extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_DictShowXml';
        public var xml:XML;

        public function EventDictShowXml(_xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            xml = _xml;
        }

    }
}