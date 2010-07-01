package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventButtonAddAction;
    import com.yspay.events.StackEvent;
    import com.yspay.pool.Pool;

    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;

    import mx.controls.DataGrid;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.Application;

    public class YsButton extends MyButton implements YsControl, IListItemRenderer
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
        public var interruptable:Boolean;

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function get data():Object
        {
            return this.label;
        }

        public function set data(value:Object):void
        {
            //this.label = value.toString();
        }

        public function Init(xml:XML):void
        {
            if (_parent is DataGrid)
            {
                ;
            }
            else
            {
                _parent.addChild(this);
            }
            _xml = xml;

            var attrs:Object = YsMaps.button_attrs;
            for (var attr_name:String in attrs)
            {
                if (!(this.hasOwnProperty(attr_name)))
                {
                    continue;
                }

                if (_xml.attribute(attr_name).length() == 0)
                {
                    // XML中未描述此属性，取默认值
                    this[attr_name] = attrs[attr_name]['default'];
                }
                else
                {
                    this[attr_name] = _xml.attribute(attr_name).toString();
                }
            }

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

            if (!this.hasEventListener(MouseEvent.CLICK))
            {
                this.addEventListener(MouseEvent.CLICK, OnBtnClick);
            }
        }

        protected function OnAddAction(event:EventButtonAddAction):void
        {
            //var obj:Object = event.info_object;
            var type:String = event.xml.name().toString();
            var name:String = event.xml.text().toString();

            // map中未查到对应类型
            if (!YsMaps.ys_type_map.hasOwnProperty(type))
                return;

            // 生成链接
            var child_xml:XML = new XML('<' + type + ' />');
            child_xml.appendChild(type + '://' + name);
            child_xml.appendChild(event.xml.From);
            child_xml.appendChild(event.xml.To);

            // 创建子节点
            var child:YsControl = new YsMaps.ys_type_map[type](this);
            child.Init(child_xml);
            _xml.appendChild(child_xml);
        }

        protected function DoActions(e:StackEvent):void
        {
            if (this.interruptable == true &&
                e.result == false)
            {
                // 可中断的事件遇到前一次的action返回false
                this.label = _xml.@LABEL;
                this.btn.enabled = true;
            }
            else
            {
                var curr_action:YsAction = e.NextEvent() as YsAction;
                if (curr_action != null)
                {
                    this.label = action_list.length.toString();
                    curr_action.Do(e, e.source);
                }
                else
                {
                    // 全部事件执行完毕
                    this.label = _xml.@LABEL;
                    this.btn.enabled = true;
                }
            }
        }

        protected function OnBtnClick(event:MouseEvent):void
        {
            this.label = action_list.length.toString();
            this.btn.enabled = false;

            var stack_event:StackEvent = new StackEvent(action_list.concat());
            stack_event.target_component = this;
            stack_event.source = event;

            this.dispatchEvent(stack_event);
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function GetSaveXml():XML
        {
            if (_xml.@save == "false")
                return null;

            var rtn:XML =
                <L KEY="" KEYNAME="" VALUE=""/>
                ;

            var label:XML =
                <A KEY="LABEL" KEYNAME="LABEL"/>
                ;
            label.@VALUE = this.label;
            rtn.@VALUE = this.label;
            rtn.@KEY = type;
            rtn.@KEYNAME = type;
            rtn.appendChild(label);


            for each (var ctrl:YsControl in action_list)
            {
                var ctrl_xml:XML = ctrl.GetLinkXml();
                if (ctrl_xml != null)
                    rtn.appendChild(ctrl_xml);
            }

            return rtn;
        }

        public function GetLinkXml():XML
        {
            return GetSaveXml();
        }
    }
}
