package com.yspay
{
    import com.esria.samples.dashboard.renderers.PopUpNamePanel;
    import com.esria.samples.dashboard.view.NewWindow;
    import com.esria.samples.dashboard.view.Pod;
    import com.esria.samples.dashboard.view.WindowContent;
    import com.yspay.events.EventCacheComplete;
    import com.yspay.events.EventPodShowXml;
    import com.yspay.events.StackSendXmlEvent;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Pool;
    import com.yspay.pool.QueryObject;
    import com.yspay.util.DateUtil;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.util.StackUtil;

    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;

    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Container;
    import mx.events.DragEvent;
    import mx.events.FlexEvent;
    import mx.managers.DragManager;
    import mx.managers.PopUpManager;

    public class YsPod extends Pod
    {
        protected var _pool:Pool;
        protected var _cache:EventCache;
        protected var _bus_ctrl_arr:Array = new Array;
        [Bindable]
        public var main_bus:UserBus;

        public function YsPod(pool:Pool)
        {
            super();
            _pool = pool;
            this.addEventListener(EventPodShowXml.EVENT_NAME, OnShowXml);
            this.addEventListener(EventCacheComplete.EVENT_NAME, OnEventCacheComplete);
            this.addEventListener(DragEvent.DRAG_ENTER, OnDragEnter);
            _cache = new EventCache(_pool);
            var dts:DBTable = _pool.dts as DBTable;
            main_bus = _pool.MAIN_BUS as UserBus;
        }

        protected function OnDragEnter(event:DragEvent):void
        {
            if (this == event.currentTarget)
                DragManager.acceptDragDrop(this);
        }

        public function onDragDropHandler(e:DragEvent, action:String):void
        {
            var xml:XML = <windows />
            var str:String = 'windows://' + (e.dragInitiator as WindowContent).dg.selectedItem.name;
            xml.appendChild(str);
            _cache.DoCache(xml.toXMLString(), this);
        }

        private function OnShowXml(event:EventPodShowXml):void
        {
            _cache.DoCache(event.xml.toXMLString(), this);
        }

        private function OnEventCacheComplete(event:EventCacheComplete):void
        {
            ShowWindow(event.cache_xml);
        }

        //相当于入口
        private function ShowWindow(xml:XML):void
        {
            var search_str:String = '://';
            var url:String = xml.text();
            var idx:int = url.search(search_str);
            var dxml:XML;
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                var dts_no:String = _pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;
                dxml = new XML(dts[dts_no].__DICT_XML);
            }
            else
                dxml = xml;

            if ((dxml.localName().toString().toLocaleLowerCase()) == 'pod')
            {
                for each (var child:XML in dxml.elements())
                {

                    child_name = child.name().toString().toLowerCase();
                    if (child_name == 'windows' || child_name == 'hbox')
                    {
                        ShowWindow(child);
                    }
                    else if (child_name == 'dict')
                    {
                        ShowDict(titleWindow.form, child);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(titleWindow, child);
                    }
                    else if (child_name == 'event')
                    {
                        var fd:FunctionDelegate = new FunctionDelegate;
                        addEventListener(child.text().toString(), fd.create(onDragDropHandler, child.ACTION.text()));
                    }
                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'windows')
            {
                var titleWindow:NewWindow = new NewWindow;
                var child_name:String;
                titleWindow.data = new Object;
                titleWindow.percentWidth = 100;
                titleWindow.title = dxml.@TITLE;
                this.addChild(titleWindow);
                for each (var kid:XML in dxml.elements())
                {
                    child_name = kid.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(titleWindow.form, kid);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(titleWindow, kid);
                    }

                }
            }
            else if ((dxml.localName().toString().toLocaleLowerCase()) == 'hbox')
            {
                var hbox:HBox = new HBox;
                hbox.data = {'xml': dxml};
                hbox.percentWidth = 100;
                hbox.setStyle('borderStyle', 'solid');
                hbox.setStyle('fontSize', '12');
                this.addChild(hbox);
                for each (var childs:XML in dxml.elements())
                {
                    child_name = childs.name().toString().toLowerCase();
                    if (child_name == 'dict')
                    {
                        ShowDict(hbox, childs);
                    }
                    else if (child_name == 'button')
                    {
                        ShowButton(hbox, childs);
                    }
                }
            }

        }

        //ShowDict 用完整的链接显示一个DICT
        private function ShowDict(container:Container, dict_xml:XML):void
        {
            var label:Label = new Label;
            var ti:TextInput = new TextInput;
            var search_str:String = '://';
            var url:String = dict_xml.text();
            var idx:int = url.search(search_str);
            var dxml:XML;
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                var query_obj:QueryObject = _pool.info[query_key][obj_key];

                if (query_obj == null)
                {
                    Alert.show('no this key in pool.info.' + query_key + '.' + obj_key);
                    return;
                }

                var dts_no:String = query_obj.Get().DTS;
                var dts:DBTable = _pool.dts as DBTable;

                dxml = new XML(dts[dts_no].__DICT_XML);
            }
            else
                dxml = dict_xml;

            label.text = dxml.display.LABEL.@text;
            var ti_name:String = dxml.services.@NAME;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            main_bus.Add(ti_name, '');
            ti.data = {'key': ti_name, //'ys_var': main_bus.GetVarArray(ti_name),
                    'index': 0}; //arr[0];

            var func_dele:FunctionDelegate = new FunctionDelegate;
            var ti_focus_out_func:Function = func_dele.create(OnTextInputFocusOut, ti_name);
            ti.addEventListener(FocusEvent.FOCUS_OUT, ti_focus_out_func);
            ti.addEventListener(FlexEvent.ENTER, enterHandler);
            if (container is HBox)
            {
                container.addChild(label);
                container.addChild(ti);
                return;
            }
            var formitem:FormItem = new FormItem;
            formitem.direction = "horizontal";
            formitem.label = label.text;
            formitem.addChild(ti);
            container.addChild(formitem);
            _bus_ctrl_arr.push({ti_name: ti});
        }

        private function ShowButton(container:Container, button_xml:XML):void
        {
            var btn:Button = new Button;
            btn.label = button_xml.@LABEL;

            btn.data = button_xml;

            var func_delegate:FunctionDelegate = new FunctionDelegate;
            var func:Function = func_delegate.create(OnBtnClick, container);
            btn.addEventListener(MouseEvent.CLICK, func);
            var fd:FunctionDelegate = new FunctionDelegate;
            btn.addEventListener(StackSendXmlEvent.EVENT_STACK_SENDXML, fd.create(doBttonActions, container));
            btn.setStyle('fontWeight', 'normal');
            container.addChild(btn);
        }

        private function OnBtnClick(e:MouseEvent, container:Container):void
        {
            var btn:Button = e.target as Button;
            var stackUtil:StackUtil = new StackUtil;
            var arr:Array = new Array;
            var serviceNum:int = 0;
            for each (var kid:XML in btn.data.children())
            {
                var type:String = (kid.localName().toString().toLocaleLowerCase());
                if (type == 'services')
                    serviceNum++;
                arr.push(kid);
            }
            /*
               if (serviceNum > 1) //多个SERVICES调用
               {
               //NEW SESSION
               var Session_New:XML =
               <SERVICES>
               YSDBSDTSObjectConfigInsert
               <SendPKG>
               <HEAD active="YSDBSDTSObjectConfigInsert"/>
               <BODY>
               <DICT>DICT://__DICT_XML</DICT>
               </BODY>
               </SendPKG>
               <RecvPKG>
               <BODY>
               <DICT>DICT://__SESSION_NO</DICT>
               <DICT>DICT://__DICT_OUT</DICT>
               </BODY>
               </RecvPKG>
               </SERVICES>;

               var Session_Commit:XML =
               <SERVICES>
               YSDBSDTSObjectConfigInsert
               <SendPKG>
               <HEAD active="YSDBSDTSObjectConfigInsert"/>
               <BODY>
               <DICT>DICT://__DICT_XML</DICT>
               </BODY>
               </SendPKG>
               <RecvPKG>
               <BODY>
               <DICT>DICT://__SESSION_NO</DICT>
               <DICT>DICT://__DICT_OUT</DICT>
               </BODY>
               </RecvPKG>
               </SERVICES>;

               var Session : Session = new session;
               bus.back();
               arr.unshift(Session_New);
               arr.push(Session_Commit);
               }
             */
            var event_bus2windowsXML:XML = <ACTION> event_bus2window </ACTION>;
            arr.push(event_bus2windowsXML);

            var fg:FunctionDelegate = new FunctionDelegate;
            stackUtil.addEventListener(StackUtil.EVENT_STACK_NEXT, fg.create(stackUtil.stack, btn, arr));
            //驱动栈
            stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
            trace(btn.label);
            // trace(btn.data.ACTION);
            trace(container.className);
        }

        //button一系列action services的最后一个
        private function event_bus2window(container:Container):void
        {
            var children:Array = container.getChildren();
            var ti:TextInput;
            /*
               for each (var obj:Object in children)
               {
               var ti:TextInput = obj as TextInput;
               if (ti != null && ti.data.key == '')

               }
             */
            Alert.show(main_bus.toString());
        }

        private function doBttonActions(e:StackSendXmlEvent, container:Container):void
        {
            var event_obj:Object = {'event_clean': event_clean,
                    'event_make_windows_xml': event_make_windows_xml,
                    'event_make_tran_xml': event_make_tran_xml,
                    'event_bus2window': event_bus2window,
                    'new_window': new_window,
                    'event_show_xml': show_xml};
            var action:XML = e.data as XML;
            var type:String = (action.localName().toString().toLocaleLowerCase());
            switch (type)
            {
                case 'action':
                {
                    if (event_obj.hasOwnProperty(action))
                    {
                        event_obj[action](container);
                        e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
                    }
                    else
                    {
                        trace('no this function: ', action);
                    }
                    break;
                }
                case 'services':
                {
                    DoService(e, GetServiceXml(action));
                    break;
                }
            }

        }

        private function GetServiceXml(service_desc:XML):XML
        {
            var service_value:String = service_desc.toString();
            var link_head:String = 'services://';
            trace(service_value);

            if (service_value.substr(0, link_head.length).toLowerCase() == link_head.toLowerCase())
            {
                var service_name:String = service_value.substr(link_head.length);
                var dts_no:String = _pool.info.SERVICES[service_name].Get().DTS;
                var service_xml:String = _pool.dts[dts_no].__DICT_XML;
                return new XML(service_xml);
            }

            return service_desc;
        }

        private function event_clean(container:Container):void
        {
            var children:Array = container.getChildren();

            for each (var obj:Object in children)
            {
                var ti:TextInput = obj as TextInput;
                if (ti != null)
                    ti.text = ti.data.value = '';

                var ta:TextArea = obj as TextArea;
                if (ta != null)
                    ta.text = ta.data.value = '';
            }
        }

        private function DoService(e:StackSendXmlEvent, service:XML):void
        {
            var dict_str:String;
            var dict_search:String = 'dict://';
            var bus_in_name_args:Array = new Array;
            var scall_name:String = service.SendPKG.HEAD.@active;
            var dict_list:XMLList = service.SendPKG.BODY.DICT;

            // 生成输入参数列表
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();

                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
                {
                    bus_in_name_args.push(dict_str.substr(dict_search.length));
                }
            }
            var scall:ServiceCall = new ServiceCall;
            var bus:UserBus = new UserBus;
            bus.Add(ServiceCall.SCALL_NAME, scall_name);
            for each (var var_name:String in bus_in_name_args)
            {
                // 参数从本地bus中获取 xingjun getfrist is err
                bus.Add(var_name, main_bus.GetFirst(var_name));
            }
            var ip:String = this.parentApplication.GetServiceIp(scall_name);
            var port:String = this.parentApplication.GetServicePort(scall_name);
            var func_dele:FunctionDelegate = new FunctionDelegate;
            scall.Send(bus, ip, port, func_dele.create(CallBack, service, e));
        }

        public function CallBack(bus:UserBus, service_info:XML, e:StackSendXmlEvent):void
        {
            trace('callback');
            trace(service_info.toXMLString());
            trace(bus);

            var dict_str:String
            var dict_search:String = 'dict://';
            var bus_out_name_args:Array = new Array;
            var dict_list:XMLList = service_info.RecvPKG.BODY.DICT;

            // 生成输出参数列表
            for each (var dict_xml:XML in dict_list)
            {
                dict_str = dict_xml.toString();

                if (dict_str.substr(0, dict_search.length).toLowerCase() == dict_search)
                {
                    bus_out_name_args.push(dict_str.substr(dict_search.length));
                }
            }

            /* xingjun add roolback
               if(bus.GetFirst("RTN") != "0" && bus.GetFirst("SESSION")!= Null)
               {
               //ROOLBACK
               /*
               bus.roolback()
               Session.Roolback()
               Session = Null;
               bus.rtn = -1;
               bus.rtmsg = "交易回退“

               }
             */
            //var main_bus:UserBus = _pool.MAIN_BUS as UserBus;
            for each (var var_name:String in bus_out_name_args)
            {
                main_bus.RemoveByKey(var_name);
                var ys_var:YsVar = bus[var_name];
                main_bus.Add(var_name, ys_var);
            }
            Alert.show(bus.toString());
            e.stackUtil.dispatchEvent(new Event(StackUtil.EVENT_STACK_NEXT));
        }

        private function event_make_tran_xml(container:Container):void
        {
            var win_per:String = "WINDOWS://";
            trace('event_make_windows_xml');
            var xml:XML = <L TYPE="TRAN" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing">
                    <L KEY="pod" KEYNAME="tran">
                        <A KEY="title" KEYNAME="title"/>
                    </L>
                </L>;
            var child_wnd:Container;
            var ename:Object = main_bus.GetFirst("__W_ENAME");
            var cname:Object = main_bus.GetFirst("__W_CNAME");
            var date:Date = new Date;
            xml.@NAME = ename;
            xml.L.@VALUE = ename;
            xml.L.A.@VALUE = cname;
            xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
            for each (child_wnd in getChildren())
            {
                var new_wnd:NewWindow = child_wnd as NewWindow
                if (new_wnd == null)
                    continue;
                var win_xml:XML = <L KEY="windows" KEYNAME="windows"/>;
                win_xml.@VALUE = (win_per + new_wnd.title);
                xml.L.appendChild(win_xml);
            }
            var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
            if (main_bus.GetVarArray('__DICT_XML') != null)
            {
                main_bus.RemoveByKey('__DICT_XML');
            }
            main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
        }

        private function event_make_windows_xml(container:Container):void
        {
            trace('event_make_windows_xml');
            var xml:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing" MEMO=""></L>;
            var child_wnd:Container;
            var date:Date = new Date;
            xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
            for each (child_wnd in getChildren())
            {
                var new_wnd:NewWindow = child_wnd as NewWindow
                if (new_wnd == null)
                    continue;
                var new_xml:XML = new_wnd.save_windows_xml();
                xml.appendChild(new_xml);
                xml.@NAME = new_xml.@VALUE;
                xml.@MEMO = new_xml.A.(@KEYNAME == 'Title').@VALUE;
            }
            var xml_head:String = '<?xml version="1.0" encoding="GBK"?>';
            if (main_bus.GetVarArray('__DICT_XML') != null)
            {
                main_bus.RemoveByKey('__DICT_XML');
            }
            main_bus.Add('__DICT_XML', xml_head + xml.toXMLString());
        }

        private function show_xml(container:Container):void
        {
            trace('show_xml');
            var xml:XML = <L TYPE="WINDOWS" NAME="IDNUMBER" VER="20091120999999" ISUSED="0" APPNAME="MapServer" CUSER="xing" MEMO=""></L>;
            var child_wnd:Container;
            var date:Date = new Date;
            xml.@VER = date.fullYear + DateUtil.doubleString(date.month + 1) + DateUtil.doubleString(date.date) + DateUtil.doubleString(date.hours) + DateUtil.doubleString(date.minutes) + DateUtil.doubleString(date.seconds);
            for each (child_wnd in getChildren())
            {
                var new_wnd:NewWindow = child_wnd as NewWindow
                if (new_wnd == null)
                    continue;
                var new_xml:XML = new_wnd.save_windows_xml();
                xml.appendChild(new_xml);
                xml.@NAME = new_xml.@VALUE;
                xml.@MEMO = new_xml.A.(@KEYNAME == 'Title').@VALUE;
            }
            Alert.show(xml.toXMLString());
        }

        private function new_window(container:Container):void
        {

            var new_popName:PopUpNamePanel = new PopUpNamePanel;
            new_popName.parentYsPod = this;
            PopUpManager.addPopUp(new_popName, this, true, null);
            PopUpManager.centerPopUp(new_popName);
        }

        public function OnNewWindowNameReady(name:String):void
        {
            var new_wnd:NewWindow = new NewWindow;
            new_wnd.title = name;
            this.addChild(new_wnd);
        }

        private function enterHandler(event:FlexEvent):void
        {
            var current:TextInput = event.target as TextInput;
            var hbox:HBox = (current.parent as HBox);
            var arr:Array = new Array;
            for each (var textinput:*in hbox.getChildren())
            {
                if (textinput is TextInput)
                {
                    arr.push(textinput);
                }
            }
            for (var i:int = 0; i < arr.length; i++)
            {
                if (arr[i] == current)
                {
                    if (i != arr.length - 1)
                        (arr[i + 1] as TextInput).setFocus();
                    else
                        (arr[0] as TextInput).setFocus();
                }
            }
        }

        private function OnTextInputFocusOut(event:Event, key_name:String):void
        {
            //var main_bus:UserBus = _pool.MAIN_BUS as UserBus;
            var ti:TextInput = event.target.owner as TextInput;
            var ys_var:YsVarArray = main_bus[ti.data.key]
            ys_var.value[ti.data.index].value = ti.text;

            //main_bus.RemoveByKey(key_name);
            //main_bus.Add(key_name, event.target.text);
        }
    }
}