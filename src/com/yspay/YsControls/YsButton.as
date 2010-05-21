package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventButtonAddAction;
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

            this.addEventListener(StackEvent.EVENT_NAME, DoActions);
            this.addEventListener(EventButtonAddAction.EVENT_NAME, OnAddAction);
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
                // 查表未发现匹配类�
                if (!YsMaps.ys_type_map.hasOwnProperty(child_name))
                    return;
                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }

            if (!this.hasEventListener(MouseEvent.CLICK))
                this.addEventListener(MouseEvent.CLICK, OnBtnClick);
        }

        protected function OnAddAction(event:EventButtonAddAction):void
        {
            var info_obj:Object = event.info_object;

            // dts_info没有TYPE或NAME字段则退出
            if (!(info_obj.hasOwnProperty('TYPE') && info_obj.hasOwnProperty('NAME')))
                return;
            // map中未查到对应类型
            if (!YsMaps.ys_type_map.hasOwnProperty(info_obj.TYPE))
                return;

            // 生成链接
            var child_xml:XML = new XML('<' + info_obj.TYPE + ' />');
            child_xml.appendChild(info_obj.TYPE + '://' + info_obj.NAME);
            child_xml.appendChild('<To>pod</To>');
            child_xml.appendChild('<From>pod</From>');

            // 创建子节点
            var child:YsControl = new YsMaps.ys_type_map[info_obj.TYPE](this);
            child.Init(child_xml);
            _xml.appendChild(child_xml);
        }

        protected function DoActions(e:StackEvent):void
        {
            var curr_action:YsAction = e.NextEvent() as YsAction;
            if (curr_action != null)
            {
                this.label = action_list.length.toString();
                curr_action.Do(e, e.source);
            }
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