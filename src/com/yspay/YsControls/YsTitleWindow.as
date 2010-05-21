package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.containers.TitleWindow;
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

        public function GetXml():XML
        {
            return _xml;
        }

        public function Init(xml:XML):void
        {
            _xml = xml;
            _parent.addChild(this);

            this.title = xml.@TITLE;
            this.name = xml.text().toString();

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

        public function GetSaveXml():XML
        {
            var rtn:XML = <L KEY="windows" KEYNAME="windows" VALUE="windows IN">
                    <A KEY="TITLE" KEYNAME="Title" />
                </L>;
            var xml_line:XML = <L KEY="" KEYNAME="" VALUE="" >
                    <L KEY="From" KEYNAME="From" VALUE="pod"/>
                    <L KEY="To" KEYNAME="To" VALUE="pod"/>
                </L>;

            var P_data = from
            var ename:String;
            var cname:String;
            if (P_data.data.__W_ENAME)

                return rtn;
        }

        public function GetLinkString():String
        {
            var rtn:String = 'WINDOWS://';
            rtn += _xml.text().toString();

            return rtn;
        }

        public function save_windows_xml(p_cont:int):XML
        {
            var P_data:Object = _M_data.TRAN[p_cont];

            if (!P_data.data.hasOwnProperty('__W_ENAME') || !P_data.data.hasOwnProperty('__W_CNAME'))
                return null;

            var ename:String = P_data.data["__W_ENAME"][0];
            var cname:String = P_data.data["__W_CNAME"][0];
            var rtn:XML = <L KEY="windows" KEYNAME="windows" VALUE="windows IN">
                    <A KEY="TITLE" KEYNAME="Title" />
                </L>;
            var xml_line:XML = <L KEY="" KEYNAME="" VALUE="" >
                    <L KEY="From" KEYNAME="From" VALUE="pod"/>
                    <L KEY="To" KEYNAME="To" VALUE="pod"/>
                </L>;
            // var tb_xml_args:Object = {'TITLE': 'ENAME'};
            //  rtn.A.(@KEY == 'TITLE').@VALUE = (args_obj[tb_xml_args['TITLE']].text);
            rtn.@VALUE = ename;
            rtn.A.(@KEY == 'TITLE').@VALUE = cname;
            for each (var ctrl:YsControl in this.getChildren())
            {

                var child_xml:XML = ctrl.GetXml();
                if (child_xml == null)
                    continue;

                var newxml:XML = new XML(xml_line);
                newxml.@KEY = child_xml.name().toString();
                if (child_xml.name().toString() == "DICT")
                    newxml.@KEYNAME = child_xml.display.LABEL.@text.toString();
                else if (child_xml.name().toString() == "BUTTON")
                {
                    var btn_xml:XML = ctrl.GetSaveXml();
                    newxml.@KEYNAME = child_xml.text().toString();

                }

                newxml.@VALUE = child_xml.name().toString() + "://" + child_xml.text().toString();

                rtn.appendChild(newxml);
                newxml = null;
            }
            return rtn;
        /*
           for each (var form_item:MyFormItem in this.getChildren())
           {
           var form_xml:XML = form_item.descXml;
           if (form_xml.name() == 'SERVICES')
           {
           var labelXml:XML = <A KEY="LABEL" KEYNAME="按钮信息"/>;
           labelXml.@VALUE = form_xml.@LABEL;
           var serviceXml:XML = <L KEY="SERVICES" KEYNAME="按钮服务"/>;
           serviceXml.@VALUE = "SERVICES://" + form_xml.text();
           var button_xml:XML = <L KEY="BUTTON" KEYNAME="按钮" VALUE=""/>;
           button_xml.appendChild(labelXml);
           button_xml.appendChild(serviceXml);
           rtn.appendChild(button_xml);
           }
           else
           {
           var dict_xml:XML = <L/>;
           dict_xml.@KEY = form_xml.localName();
           dict_xml.@KEYNAME = form_item.label;
           dict_xml.@VALUE = form_xml.localName() + "://" + form_xml.services.@NAME;
           rtn.appendChild(dict_xml);
           }
         }*/
        }
    }
}
