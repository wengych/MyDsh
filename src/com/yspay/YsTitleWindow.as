package com.yspay
{
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.*;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.containers.Form;
    import mx.containers.TitleWindow;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.*;

    public class YsTitleWindow extends TitleWindow implements YsControl
    {
        public var form:Form;
        public var _M_data:Object = Application.application.M_data;
        public var _xml:XML;

        [Bindable]
        private var arr_col:ArrayCollection;
        private var _pool:Pool;
        private var func_helper:FunctionHelper = new FunctionHelper;
        private var dts_event_listener:Function;

        protected var _parent:DisplayObjectContainer;

        public function YsTitleWindow(parent:DisplayObjectContainer)
        {
            super();
            _parent = parent;
            this.percentHeight = 100;
            this.percentWidth = 100;
            this.setStyle("headerHeight", "10");
            this.showCloseButton = true;
            //this.setStyle("horizontalAlign", "center");
            this.addEventListener(CloseEvent.CLOSE, closeHandler);

            form = new Form;
            form.percentHeight = 100;
            form.percentWidth = 100;
            this.addChild(form);

            _pool = Application.application._pool;

            this.addEventListener(EventWindowShowXml.EVENT_NAME, OnShow);
        }

        public function Init(xml:XML):void
        {
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

        // TODO:暂时保留，拖拽事件需要参考此处部分代码
        protected function dragDropSelf(event:DragEvent):void
        {
            if ((event.dragInitiator as UIComponent).parent != this.form)
            {
                return;
            }
            var moveYSelf:Number = event.localY;
            var length:int = form.getChildren().length;
            var position:int = form.getChildIndex(event.dragInitiator as UIComponent);
            if (length <= 1)
                return;

            for (var i:int = 0; i < length; i++)
            {
                if (form.getChildAt(i).y >= moveYSelf)
                    break;
            }
            form.removeChild(event.dragInitiator as UIComponent);

            if (i >= length)
            {
                form.addChild(event.dragInitiator as UIComponent);
            }
            else if (i >= 1)
            {
                if (i >= position)
                    form.addChildAt(event.dragInitiator as UIComponent, i - 1);
                else
                    form.addChildAt(event.dragInitiator as UIComponent, i);
            }
            else
                form.addChildAt(event.dragInitiator as UIComponent, i);
        }

        public function save_windows_xml(p_cont:int):XML
        {

            var P_data:Object = _M_data.TRAN[p_cont];
            var ename:String = P_data.data[0]["__W_ENAME"];
            var cname:String = P_data.data[0]["__W_CNAME"];
            var rtn:XML = <L KEY="windows" KEYNAME="windows" VALUE="windows IN">
                    <A KEY="TITLE" KEYNAME="Title" />
                </L>;
            // var tb_xml_args:Object = {'TITLE': 'ENAME'};
            //  rtn.A.(@KEY == 'TITLE').@VALUE = (args_obj[tb_xml_args['TITLE']].text);
            rtn.@VALUE = ename;
            rtn.A.(@KEY == 'TITLE').@VALUE = cname;
            for each (var form_item:MyFormItem in form.getChildren())
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
            }
            return rtn;
        }
    }
}
