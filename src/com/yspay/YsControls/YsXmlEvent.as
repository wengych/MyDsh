package com.yspay.YsControls
{
    import com.yspay.events.StackEvent;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.core.UIComponent;

    public class YsXmlEvent extends YsButton implements YsControl
    {
        protected var need_save:Boolean;

        public function YsXmlEvent(parent:DisplayObjectContainer)
        {
            super(parent);
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);

            // TODO: event描述存入dts表
            //       event_name从xml属性"event_name"获取
            var event_name:String = _xml.text().toString();
            // 默认不显示
            //this.visible = xml.@VISABLE;
            this.enabled = false;
            this.height = 0;
            this.width = 0;
            this.visible = false;
            this.label = event_name;

            need_save = false;

            _parent.addEventListener(event_name, EventActived); //fd.create(func, _parent));
        }

        public override function GetXml():XML
        {
            if (need_save)
                return _xml;

            return null;
        }

        protected function EventActived(event:Event):void
        {
            var stack_event:StackEvent = new StackEvent(action_list.concat());
            stack_event.target_component = _parent as UIComponent;
            stack_event.source = event;

            this.dispatchEvent(stack_event);
        }

    }
}
