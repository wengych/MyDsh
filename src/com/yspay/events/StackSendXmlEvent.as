package com.yspay.events
{
    import com.yspay.util.StackUtil;

    import flash.events.Event;


    public class StackSendXmlEvent extends YsEvent
    {

        public static const EVENT_NAME:String = 'event_stack_sendxml';

        public var data:Object;
        public var stackUtil:StackUtil;

        public function StackSendXmlEvent(data:Object, stackUtil:StackUtil, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            this.data = data;
            this.stackUtil = stackUtil;
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);
        }

        override public function clone():Event
        {
            var e:StackSendXmlEvent = new StackSendXmlEvent(this.data, this.stackUtil);
            return e;
        }
    }
}
