package com.yspay.util
{
    import flash.events.Event;

    public class FunctionCallEvent extends Event
    {
        public static var EVENT_NAME:String = 'Event_FunctionCall';
        public var function_name:String;
        public var source:Object;
        public var args:Array;

        public function FunctionCallEvent(bubbles:Boolean=false,
                                          cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
        }

        public override function clone():Event
        {
            var new_event:FunctionCallEvent = new FunctionCallEvent;
            new_event.function_name = function_name;
            new_event.source = source;
            new_event.args = args;

            return new_event;
        }
    }
}