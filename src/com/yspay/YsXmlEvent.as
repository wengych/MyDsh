package com.yspay
{
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.util.FunctionDelegate;

    import flash.display.DisplayObjectContainer;

    public class YsXmlEvent implements YsControl
    {
        protected var _parent:DisplayObjectContainer;

        public function YsXmlEvent(parent:DisplayObjectContainer)
        {
            _parent = parent;
        }

        public function Init(xml:XML):void
        {
            // TODO: 针对button的事件需要重新定义,携带事件对象
            var fd:FunctionDelegate = new FunctionDelegate;
            var func:Function = EventHandlerFactory.get_handler(xml.ACTION.text());
            _parent.addEventListener(xml.text().toString(), fd.create(func, _parent));
        }

    }
}