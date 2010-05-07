package com.yspay.events
{
    import flash.events.Event;

    public class EventPodShowXml extends Event
    {
        public static var EVENT_NAME:String = 'Event_PodShowXml';
        public var xml:XML;

        public function EventPodShowXml(_xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);

            xml = _xml;
        }

    }
}