package com.yspay
{
    import com.esria.samples.dashboard.renderers.PopUpButtonPanel;
    import com.yspay.events.EventWindowShowXml;
    import com.yspay.pool.*;
    import com.yspay.util.FunctionDelegate;

    import mx.collections.ArrayCollection;
    import mx.containers.Form;
    import mx.containers.TitleWindow;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.listClasses.ListBase;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.events.*;
    import mx.managers.DragManager;
    import mx.managers.PopUpManager;
    import mx.utils.StringUtil;

    public class YsTitleWindow extends TitleWindow
    {
        public var form:Form;
        public var _M_data:Object = Application.application.M_data;
        public var _P_cont:int; //存放_M_data.TRAN.cont
        public var _P_data:Object; //存放父类YSPOD的P_DATA

        public var P_cont:int;
        public var P_data:Object;

        public var _YsPod:YsPod;

        [Bindable]
        private var arr_col:ArrayCollection;
        private var _pool:Pool;
        private var func_helper:FunctionHelper = new FunctionHelper;
        private var dts_event_listener:Function;

        public function YsTitleWindow()
        {
            super();
            this.percentHeight = 100;
            this.percentWidth = 100;
            this.setStyle("headerHeight", "10");
            this.showCloseButton = true;
            this.addEventListener(CloseEvent.CLOSE, closeHandler);

            form = new Form;
            form.percentHeight = 100;
            form.percentWidth = 100;
            this.addChild(form);

            onInit();

            // TODO: 拖拽事件的支持需要自定义
            // TODO: 目前直接支持拖拽事件
            form.addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler);
            form.addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
        }

        public function Init(xml:XML):void
        {
            var child_name:String;
            //xingj ..
            for each (var kid:XML in xml.elements())
            {
                child_name = kid.name().toString().toLowerCase();
                if (child_name == 'dict')
                {
                    ShowDict(titleWindow.form, kid);
                }
                else if (child_name == 'button')
                {
                    // ShowButton(titleWindow.form, kid);
                    var ys_btn:YsButton = new YsButton;
                    ys_btn.Init(kid);
                }
                else if (child_name == 'hbox')
                {
                    //ShowWindow(titleWindow, kid);
                }
                else if (child_name == 'windows')
                {
                    // ShowWindow(titleWindow, kid);
                    var titleWindow:YsTitleWindow = new YsTitleWindow;
                    titleWindow.Init(kid);
                }
                else if (child_name == 'event')
                {
                    var fhelper:FunctionDelegate = new FunctionDelegate;
                    addEventListener(kid.text().toString(), fhelper.create(onDragDropHandler, kid.ACTION.text()));
                }
            }
        }

        private function closeHandler(e:CloseEvent):void
        {
            this.parent.removeChild(this);
        }

        public function onInit():void
        {
            var o:Object = this;
            for (; ; )
            {
                if (o.parent is YsPod)
                {
                    _YsPod = o.parent;
                    break;
                }
                else
                    o = o.parent;
            }
            _P_cont = _YsPod.P_cont;
            _P_data = _M_data.TRAN[_P_cont];

            P_cont = _P_data.cont;
            _P_data.cont++;

            P_data = new Object;
            _P_data[P_cont] = P_data;
//M_DATA.TRAN.序列号.序列号
            P_data = _YsPod.P_cont++;
            _pool = Application.application._pool;
            this.addEventListener((_pool.dts as DBTable).select_event_name, OnDtsQueryComplete);
            this.addEventListener(EventWindowShowXml.EVENT_NAME, OnShow);
        }

        protected function OnShow(event:EventWindowShowXml):void
        {

        }

        protected function dragEnterHandler(event:DragEvent):void
        {
            if (form == event.currentTarget)
                DragManager.acceptDragDrop(form);
        }

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

        protected function dragDropNew(event:DragEvent):void
        {
            /*
               var arg:Object = new Object;
               var o:Object = (event.dragInitiator as TileList).selectedItem;
               arg.postion = event.localY;
               var bus:UserBus = new UserBus;
               var sc:ServiceCall = new ServiceCall;
               bus.Add(ServiceCall.SCALL_NAME, "YSDBSDTSObjectSelect");
               bus.Add("__DICT_IN", o.dts);
               var fd:FunctionDelegate = new FunctionDelegate;
               CursorManager.setBusyCursor();
               sc.Send(bus, IP, PORT, fd.create(onServiceComplete, arg));
             */
            var arg:Object = new Object;
            arg.postion = event.localY;
            var o:Object = (event.dragInitiator as ListBase).selectedItem;
            var dts:DBTable = _pool.dts as DBTable;
            dts.AddQuery(o.DTS, Query, o.DTS, this);
            //dts_event_listener = func_helper.create(OnDtsQueryComplete, arg);
            //this.addEventListener(dts.select_event_name, dts_event_listener);
            //CursorManager.setBusyCursor();
            dts.DoQuery(o.DTS);


        }

        public function OnDtsQueryComplete(event:DBTableQueryEvent):void //, arg:Object):void
        {
            //CursorManager.removeBusyCursor();
            var dts:DBTable = _pool.dts as DBTable;
            var temp:String = dts[event.query_name][dts.arg_select];
            temp = StringUtil.trim(temp);
            var arg:Object = new Object;
            arg.showxml = new XML(temp);
            addFormItem(arg);
            // this.removeEventListener(dts.select_event_name, dts_event_listener);
        }

        protected function onServiceComplete(bus:UserBus, arg:Object):void
        {

            if (bus)
            {
                var output_array:Array = bus.GetVarArray("__DICT_XML");
                var temp:String;
                for each (var output_arg:YsVar in output_array)
                {
                    temp += output_arg.getValue().toString();
                }
                temp = temp.replace("null", " ");
                temp = StringUtil.trim(temp);
                arg.showxml = new XML(temp);
                addFormItem(arg);
            }
            else
            {
                Alert.show('网络连接失败!');
            }
        }

        private function AddService(arg:Object):void
        {
            var pop:PopUpButtonPanel = PopUpManager.createPopUp(this, PopUpButtonPanel, true, null) as PopUpButtonPanel;
            pop.parentWindow = this;
            pop.arg = arg;
            PopUpManager.centerPopUp(pop);
            pop.txtName.setFocus();
            return;
        }

        private function AddDict(arg:Object):void
        {
            //var formitem:MyFormItem = new MyFormItem;
            var contentXml:XML = arg.showxml as XML;

            (this.parent as YsPod).ShowDict(form, contentXml);
//
//                formitem.descXml = contentXml;
//                formitem.label = contentXml.display.LABEL.@text;
//
//                var ti:TextInput = new TextInput;
//                ti.width = 200;
//
//                if (contentXml.services.@TYPE == "DOUBLE" || contentXml.services.@TYPE == "FLOAT")
//                {
//                    ti.setStyle("textAlign", "right");
//                }
//                if (contentXml.display.TEXTINPUT.@displayAsPassword == "0")
//                {
//                    ti.displayAsPassword = false;
//                }
//                else
//                {
//                    ti.displayAsPassword = true;
//                }
//                if (contentXml.display.TEXTINPUT.@length != null)
//                {
//                    ti.maxChars = contentXml.display.TEXTINPUT.@length;
//                    ti.toolTip = "最长输入" + ti.maxChars + "个字符";
//                }
//                formitem.addChild(ti);
//                form.addChild(formitem);
        }

        private function addFormItem(arg:Object):void
        {
            var xml_name:String = (arg.showxml as XML).name().toString().toLocaleLowerCase();
            if (xml_name == "services")
            {
                AddService(arg);
            }
            else if (xml_name == 'dict')
            {
                AddDict(arg);
            }
        /*
           var formitem:MyFormItem = new MyFormItem;
           var contentXml:XML = arg.showxml;
           formitem.descXml = contentXml;
           formitem.label = contentXml.display.LABEL.@text;
           var ti:TextInput = new TextInput;
           ti.width = 200;
           if (contentXml.services.@TYPE == "DOUBLE" || contentXml.services.@TYPE == "FLOAT")
           {
           ti.setStyle("textAlign", "right");
           }
           if (contentXml.display.TEXTINPUT.@displayAsPassword == "0")
           {
           ti.displayAsPassword = false;
           }
           else
           {
           ti.displayAsPassword = true;
           }
           if (contentXml.display.TEXTINPUT.@length != null)
           {
           ti.maxChars = contentXml.display.TEXTINPUT.@length;
           ti.toolTip = "最长输入" + ti.maxChars + "个字符";
           }
           formitem.addChild(ti);
           form.addChild(formitem);
         */ /*
           var moveY:Number = arg.postion;
           formitem.addChild(ti);
           var length:int = form.getChildren().length;
           for (var j:int = 0; j < length; j++)
           {
           if (form.getChildAt(j).y >= moveY)
           break;
           }
           if (j >= length)
           form.addChild(formitem);
           else if (j >= 1)
           form.addChildAt(formitem, j);
           else
           form.addChildAt(formitem, 0);
         */
        }

        protected function dragDropHandler(event:DragEvent):void
        {
            if (event.dragSource.hasFormat("self"))
                dragDropSelf(event);
            else
                dragDropNew(event);
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

        protected function submitHandler():void
        {
            var str:String = "";
            //var nameOfWindow:String = StringUtil.trim(formname.text);
            //if (nameOfWindow == "" || StringUtil.trim(englishName.text) == "")
            {
                Alert.show("请输入表单名!", "提示");
                return;
            }
            //(this.parent as Pod).title = formname.text;
            var length:int = form.getChildren().length;

            var resultOfWindow:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing">
                    <L KEY="windows" KEYNAME="windows IN" VALUE="windows IN">
                        <A KEY="TITLE" KEYNAME="Title" />
                    </L>
                </L>;
            resultOfWindow..A.(@KEY == "TITLE").@VALUE = nameOfWindow;
            for (var i:int = 0; i < length; i++)
            {
                var temp:XML = (form.getChildAt(i) as MyFormItem).descXml;
                if (temp.localName().toString() == "SERVICES")
                {
                    var labelXml:XML = <A KEY="LABEL" KEYNAME="按钮信息"/>;
                    labelXml.@VALUE = temp.@LABEL;
                    var serviceXml:XML = <L KEY="SERVICES" KEYNAME="按钮服务"/>;
                    serviceXml.@VALUE = "SERVICES://" + temp.text();
                    var buttonXml:XML = <L KEY="BUTTON" KEYNAME="按钮" VALUE=""/>;
                    buttonXml.appendChild(labelXml);
                    buttonXml.appendChild(serviceXml);
                    resultOfWindow.L.appendChild(buttonXml);
                }
                else
                {
                    var inserted:XML = <L/>;
                    inserted.@KEY = temp.localName();
                    inserted.@KEYNAME = (form.getChildAt(i) as MyFormItem).label;
                    inserted.@VALUE = temp.localName() + "://" + temp.services.@NAME;
                    //resultOfWindow.@NAME = formname.text;
                    //resultOfWindow.L.@VALUE = englishName.text;
                    resultOfWindow.L.appendChild(inserted);
                }
            }
            str += resultOfWindow.toXMLString();
            //str = '<?xml version="1.0" encoding="gbk"?>' + str;
            Alert.show(str);
            var dts:DBTable = _pool.dts as DBTable;

            this.addEventListener(dts.insert_event_name, OnDtsInsertComplete);
            dts.Insert([dts.arg_insert], ['<?xml version="1.0" encoding="gbk"?>' + str], this);
        }

        public function OnDtsInsertComplete(event:DBTableInsertEvent):void
        {
            var dts:DBTable = _pool.dts as DBTable;
            if (event.user_bus == null)
            {
                Alert.show("保存失败！！");
                this.removeEventListener(dts.insert_event_name, OnDtsInsertComplete);
                return;
            }
            var dts_no:String = event.user_bus.GetFirst('__DICT_OUT');
            this.removeEventListener(dts.insert_event_name, OnDtsInsertComplete);
            dts.AddQuery(dts_no, Query, dts_no, this);
            this.addEventListener(dts.select_event_name, OnQueryNewDtsWindow);
            dts.DoQuery(dts_no);
        }

        public function OnQueryNewDtsWindow(event:DBTableQueryEvent):void
        {
            var dts:DBTable = _pool.dts as DBTable;
            this.removeEventListener(dts.insert_event_name, OnQueryNewDtsWindow);
        }

        public function OnSureClickToAddButton(arg:Object):void
        {
            var formitem:MyFormItem = new MyFormItem;
            var contentXml:XML = arg.showxml;
            contentXml.@LABEL = arg.buttonName;
            formitem.descXml = contentXml;
            var button:Button = new Button;
            button.label = arg.buttonName;
            formitem.addChild(button);
            var moveY:Number = arg.postion;
            var length:int = form.getChildren().length;
            for (var j:int = 0; j < length; j++)
            {
                if (form.getChildAt(j).y >= moveY)
                    break;
            }
            if (j >= length)
                form.addChild(formitem);
            else if (j >= 1)
                form.addChildAt(formitem, j);
            else
                form.addChildAt(formitem, 0);
        }

    }
}