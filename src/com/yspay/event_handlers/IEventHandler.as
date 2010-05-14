package com.yspay.event_handlers
{

    import mx.core.UIComponent;
    import flash.events.Event;

    // TODO: 下阶段通过接口的方式改进event_handlers内反射函数名的方式获取action对应方法的方式

    public interface IEventHandler
    {
        function Work(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    }
}