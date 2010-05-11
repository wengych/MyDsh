package com.yspay.events
{
    import flash.events.Event;

    public class EventWindowShowXml extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_WindowShowXml';
        public var xml:XML;

        public function EventWindowShowXml(_xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            xml = _xml;
        }

    }
}