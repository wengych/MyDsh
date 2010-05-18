package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.StackEvent;
    import com.yspay.pool.Pool;

    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;

    import mx.controls.Button;
    import mx.core.Application;

    public class YsButton extends Button implements YsControl
    {
        public function YsButton(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;

        }
        protected var _pool:Pool;
        public var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public var action_list:Array = new Array;
        public var D_data:PData = new PData;

        public function Init(xml:XML):void
        {
            _parent.addChild(this);
            _xml = xml;

            this.setStyle('fontWeight', 'normal');
            this.label = _xml.@LABEL;

            var child_name:String;
            for each (var child:XML in _xml.elements())
            {
                child_name = child.name().toString().toLowerCase();

                // 查表未发现匹配类型
                if (!YsMaps.ys_type_map.hasOwnProperty(child_name))
                    return;

                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }

            this.addEventListener(MouseEvent.CLICK, OnBtnClick);
            this.addEventListener(StackEvent.EVENT_NAME, DoActions);
        }

        protected function DoActions(e:StackEvent):void
        {
            var curr_action:YsAction = e.NextEvent() as YsAction;
            if (curr_action != null)
                curr_action.Do(e, e.source);
            else
            {
                this.label = _xml.@LABEL;
                this.enabled = true;
            }
        }

        protected function OnBtnClick(event:MouseEvent):void
        {
            this.label = action_list.length.toString();
            this.enabled = false;

            var stack_event:StackEvent = new StackEvent(action_list.concat());
            stack_event.target_component = this;
            stack_event.source = event;

            this.dispatchEvent(stack_event);
        }

        public function GetXml():XML
        {
            return _xml;
        }
    }
}