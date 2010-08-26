package com.yspay.YsControls
{
    import com.yspay.events.StackEvent;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.controls.ComboBox;
    import mx.controls.DataGrid;
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
            this.enabled = false;
            this.height = 0;
            this.width = 0;
            this.visible = false;

            if (_parent is DataGrid)
                ;
            else if (_parent is ComboBox)
                _parent.addChild(this);
            else
                _parent.addChild(this);
            _xml = xml;

            UtilFunc.InitAttrbutes(YsMaps.event_attrs, this, this._xml);

            this.setStyle('fontWeight', 'normal');
            this.label = _xml.@LABEL;
            var child_name:String;
            for each (var child:XML in _xml.elements())
            {
                child_name = child.name().toString().toLowerCase();
                // 查表未发现匹配类型
                if (!YsMaps.ys_type_map.hasOwnProperty(child_name))
                    continue;
                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }

            // TODO: event描述存入dts表
            //       event_name从xml属性"event_name"获取
            var event_name:String = _xml.text().toString();
            // 默认不显示
            //this.visible = xml.@VISABLE;
            this.label = event_name;
            need_save = false;

            this._parent.addEventListener(event_name, EventActived); //fd.create(func, _parent));
        }

        public override function GetXml():XML
        {
            if (need_save)
                return _xml;

            return null;
        }

        protected function EventActived(event:Event):void
        {
            trace('YsXmlEvent.EventActived ' + _xml.text().toString());
            var stack_event:StackEvent = new StackEvent(action_list.concat());
            stack_event.target_component = _parent as UIComponent;
            stack_event.source = event;

            this.dispatchEvent(stack_event);
        }

    }
}
