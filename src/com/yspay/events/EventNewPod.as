package com.yspay.events
{
    import flash.events.Event;


    public class EventNewPod extends Event
    {
        public static var EVENT_NAME:String = 'Event_NewPod';

        public var windows_type:String;

        public function EventNewPod(_windows_type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            windows_type = _windows_type;
            super(EVENT_NAME, bubbles, cancelable);
        }

    }
}
