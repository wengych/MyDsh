package com.yspay.events
{
    import flash.events.Event;

    public class EventPodNewChild extends Event
    {
        public static var EVENT_NAME:String = 'Event_PodNewChild';
        public var child_desc:String;
        public function EventPodNewChild(_child_type:String, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            child_desc = _child_type;
            super(EVENT_NAME, bubbles, cancelable);
        }

    }
}