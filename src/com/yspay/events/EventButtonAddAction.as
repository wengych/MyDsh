package com.yspay.events
{
    import flash.events.Event;


    public class EventButtonAddAction extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_ButtonAddAction';
        public var xml:XML;

        public function EventButtonAddAction(_xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            xml = _xml;
        }

        override public function clone():Event
        {
            var e:EventButtonAddAction = new EventButtonAddAction(xml);

            return e;
        }
    }
}