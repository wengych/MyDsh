package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventButtonAddAction;
    import com.yspay.events.StackEvent;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;
    import flash.utils.getDefinitionByName;

    import mx.controls.DataGrid;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.utils.ObjectUtil;

    public class YsButton extends MyButton implements YsControl, IListItemRenderer
    {
        public function YsButton(parent:DisplayObjectContainer)
        {
            super();
            _pool = FlexGlobals.topLevelApplication._pool;
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
            return this._label;
        }

        public function set data(value:Object):void
        {
            //this.label = value.toString();
        }

        public function Init(xml:XML):void
        {
            if (!(_parent is DataGrid))
            {
                _parent.addChild(this);
            }
            _xml = xml;

            UtilFunc.InitAttrbutes(YsMaps.button_attrs, this, this._xml);

            this.setStyle('fontWeight', 'normal');

            UtilFunc.InitAttrbutes(YsMaps.button_attrs, this, _xml);
            UtilFunc.InitChild(this, _xml);

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
                this._label = _xml.@LABEL;
                this.btn.enabled = true;
            }
            else
            {
                var curr_action:YsAction = e.NextEvent() as YsAction;
                if (curr_action != null)
                {
                    this._label = action_list.length.toString();
                    curr_action.Do(e, e.source);
                }
                else
                {
                    // 全部事件执行完毕
                    this._label = _xml.@LABEL;
                    this.btn.enabled = true;
                }
            }
        }

        protected function OnBtnClick(event:MouseEvent):void
        {
            this._label = action_list.length.toString();
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
            label.@VALUE = this._label;
            rtn.@VALUE = this._label;
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

        public function Print(print_container:UIComponent, print_call_back:Function):UIComponent
        {
            return null;
        }

        public function GetId():String
        {
            return id;
        }
    }
}
