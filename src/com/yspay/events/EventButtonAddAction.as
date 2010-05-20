package com.yspay.events
{
    import flash.events.Event;


    public class EventButtonAddAction extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_ButtonAddAction';
        public var xml:XML;
        public var info_object:Object;

        public function EventButtonAddAction(_xml:XML, _info_object:Object, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            xml = _xml;
            info_object = _info_object;
        }

        override public function clone():Event
        {
            var e:EventButtonAddAction = new EventButtonAddAction(xml, info_object);

            return e;
        }
    }
}