package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.containers.TitleWindow;
    import mx.controls.Alert;
    import mx.core.Application;
    import mx.events.*;

    public class YsTitleWindow extends TitleWindow implements YsControl
    {
        public var _M_data:Object = Application.application.M_data;
        public var _xml:XML;

        public var D_data:PData = new PData;

        [Bindable]
        private var arr_col:ArrayCollection;
        private var _pool:Pool;
        private var func_helper:FunctionDelegate = new FunctionDelegate;
        private var dts_event_listener:Function;

        public var _parent:DisplayObjectContainer;

        public function YsTitleWindow(parent:DisplayObjectContainer)
        {
            super();
            _parent = parent;
            this.percentHeight = 100;
            this.percentWidth = 100;
            this.setStyle("headerHeight", "10");
            this.setStyle("fontSize", "12");
            this.showCloseButton = true;
            //this.setStyle("horizontalAlign", "center");
            this.addEventListener(CloseEvent.CLOSE, closeHandler);


            _pool = Application.application._pool;

            this.addEventListener(EventWindowShowXml.EVENT_NAME, OnShow);
        }

        public function set ename(str:String):void
        {
            //_xml.appendChild(str);
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

        protected function InitAttributes():void
        {
            var wnd_attrs:Object = YsMaps.windows_attrs;
            for (var attr_name:String in wnd_attrs)
            {
                if (!(this.hasOwnProperty(attr_name)))
                {
                    Alert.show('YsTitleWindow中没有 ' + attr_name + ' 属性');
                    continue;
                }

                if (_xml.attribute(attr_name).length() == 0)
                {
                    // XML中未描述此属性，取默认值
                    if (wnd_attrs[attr_name].hasOwnProperty('default'))
                        this[attr_name] = wnd_attrs[attr_name]['default'];
                }
                else
                {
                    this[attr_name] = _xml.attribute(attr_name).toString();
                }
            }
        }

        public function Init(xml:XML):void
        {
            _xml = xml;
            _parent.addChild(this);
            this.name = xml.text().toString();

            InitAttributes();

            for each (var event_xml:XML in xml.elements())
            {
                var event:EventWindowShowXml = new EventWindowShowXml(event_xml);
                this.dispatchEvent(event);
            }
        }

        private function closeHandler(e:CloseEvent):void
        {
            this.parent.removeChild(this);
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
    }
}
