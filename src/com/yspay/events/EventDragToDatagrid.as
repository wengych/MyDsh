package com.yspay.events
{

    public class EventDragToDatagrid extends YsEvent
    {
        public static var EVENT_NAME:String = 'Event_DragToDatagrid';
        public var drag_object:Object

        public function EventDragToDatagrid(obj:Object, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(EVENT_NAME, bubbles, cancelable);
            TraceEventName(EVENT_NAME);

            drag_object = obj;
        }

    }
}