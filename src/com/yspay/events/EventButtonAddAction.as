package com.yspay.events
{
    import flash.events.Event;


    public class EventButtonAddAction extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_ButtonAddAction';
        public var xml:XML;

        public function EventButtonAddAction(_xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            xml = _xml;
        }
    }
}