package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.containers.TitleWindow;
    import mx.controls.Alert;
    import mx.controls.DataGrid;
    import mx.core.FlexGlobals;
    import mx.core.Container;
    import mx.core.UIComponent;
    import mx.events.*;

    public class YsTitleWindow extends TitleWindow implements YsControl
    {
        public var TITLE:String;
        public var _M_data:Object = FlexGlobals.topLevelApplication.M_data;
        public var _xml:XML;

        public var D_data:PData = new PData;

        [Bindable]
        protected var arr_col:ArrayCollection;
        protected var _pool:Pool;
        protected var func_helper:FunctionDelegate = new FunctionDelegate;
        protected var dts_event_listener:Function;
        public var _parent:DisplayObjectContainer;

        public function YsTitleWindow(parent:DisplayObjectContainer)
        {
            super();
            _parent = parent;
            this.percentWidth = 100;
            _pool = FlexGlobals.topLevelApplication._pool;
            this.addEventListener(EventWindowShowXml.EVENT_NAME, OnShow);
        }

        protected override function measure():void
        {
            super.measure();
            if (UtilFunc.HasChildByType(this, DataGrid))
            {
                this.percentHeight = 100;
            }
            callLater(reDraw);

        }

        //在下一次重绘界面前根据其他同级组件的宽度设置宽度
        private function reDraw():void
        {
            if (parent != null && parent is Container)
            {
                var arr:Array = (parent as Container).getChildren();
                for each (var o:Object in arr)
                {
                    if (o is DisplayObject)
                    {
                        if (o.width > this.width)
                            this.width = o.width;
                    }
                }
            }
        }

        public function set ename(str:String):void
        {
            _xml.text()[0] = str;
        }

        public function set cname(str:String):void
        {
            _xml.@title = str;
        }

        public function get ename():String
        {
            return _xml.text().toString();
        }

        public function get cname():String
        {
            return _xml.@title.toString();
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function GetLinkXml():XML
        {
            var rtn:XML =
                <L KEY="" KEYNAME="" VALUE=""/>
                ;

            rtn.@KEY = type;
            rtn.@KEYNAME = type;
            rtn.@VALUE = type + '://' + _xml.text().toString();

            return rtn;
        }

        public function GetSaveXml():XML
        {
            if (_xml.@save == 'false')
                return null;

            var rtn:XML =
                <L KEY="windows" KEYNAME="windows" VALUE="windows IN"/>
                ;
            var title:XML =
                <A KEY="TITLE" KEYNAME="Title"/>
                ;

            rtn.@VALUE = ename;
            title.@VALUE = cname;
            rtn.appendChild(title);

            for each (var ctrl:YsControl in this.getChildren())
            {
                var child_xml:XML = ctrl.GetLinkXml();
                if (child_xml != null)
                    rtn.appendChild(child_xml);
            }

            return rtn;
        }

        public function Init(xml:XML):void
        {
            xml = com.yspay.util.UtilFunc.FullXml(xml);
            _xml = xml;
            _parent.addChild(this);
            this.name = xml.text().toString();

            UtilFunc.InitAttrbutes(YsMaps.windows_attrs, this, this._xml);

            for each (var event_xml:XML in xml.elements())
            {
                var event:EventWindowShowXml = new EventWindowShowXml(event_xml);
                this.dispatchEvent(event);
            }
        }

        protected function OnShow(event:EventWindowShowXml):void
        {
            var xml:XML = event.xml;
            var node_name:String = xml.name().toString().toLowerCase();

            // 查表未发现匹配类型
            if (!YsMaps.ys_type_map.hasOwnProperty(node_name))
                return;

            var child_ctrl:YsControl = new YsMaps.ys_type_map[node_name](this);
            child_ctrl.Init(xml);
        }

        public function Print(print_container:UIComponent, print_call_back:Function):UIComponent
        {
            var print_area:UIComponent;
            if (print_container == null)
                print_area = print_call_back();
            else
                print_area = print_container;

            for each (var child:Object in this.getChildren())
            {
                if (child is YsControl)
                    child.Print(print_area, print_call_back);
            }

            return print_area;
        }

        public function GetId():String
        {
            return id;
        }
    }
}
