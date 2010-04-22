package com.yspay.util
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import com.yspay.events.StackSendXmlEvent;
    public class StackUtil implements IEventDispatcher
    {
        private var _disp:EventDispatcher;
        private var listeners:Array;

        public function StackUtil()
        {
            _disp = new EventDispatcher;
            listeners = new Array;
        }
        public static const EVENT_STACK_NEXT:String = "event_stack_next";

        public function stack(e:Event, main:EventDispatcher, arr:Array):void
        {
            if (arr.length <= 0)
            {
                trace("over")
                //删除监听器 并清空监听器数组
                for each (var o:Object in listeners)
                {
                    this.removeEventListener(o.type, o.listener, o.useCapture);
                }
                listeners.splice(0);
                return;
            }
            //驱动main程序
            var kid:Object = arr.shift();
            var se:StackSendXmlEvent = new StackSendXmlEvent(kid,this);
            main.dispatchEvent(se);

        }

        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
        {
            listeners.push({type: type, listener: listener, useCapture: useCapture});
            this._disp.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            this._disp.removeEventListener(type, listener, useCapture);
        }

        public function dispatchEvent(event:Event):Boolean
        {
            return this._disp.dispatchEvent(event);
        }

        public function hasEventListener(type:String):Boolean
        {
            return this.hasEventListener(type);
        }

        public function willTrigger(type:String):Boolean
        {
            return this.willTrigger(type);
        }

    }
}