package com.yspay
{
    import com.yspay.util.GetParentByType;

    import flash.events.Event;

    import mx.controls.ComboBox;
    import mx.controls.Label;
    import mx.controls.TextInput;
    import mx.core.Container;

    public class YsDict
    {
        public var label:Label;
        public var text_input:TextInput;
        public var combo_box:YsComboBox;
        protected var P_data:Object;

        public function YsDict(dxml:XML)
        {
            if (dxml.display.LABEL != undefined)
            {
                label = new Label;
                label.text = dxml.display.LABEL.@text;
            }
            if (dxml.display.TEXTINPUT != undefined)
            {
                text_input = CreateTextInput(dxml);
            }
            if (dxml.display.TEXTINPUT.list != undefined)
            {
                combo_box = CreateComboBox(dxml);
            }
        }

        private function tichange(evt:Event):void
        {
            var tt:TextInput = evt.target as TextInput;
            var ys_pod:YsPod = GetParentByType(text_input.parent as Container, YsPod) as YsPod;
            var P_data:Object = ys_pod._M_data[ys_pod.P_cont];
            P_data.proxy[tt.data.index][tt.data.name] = tt.text;
            P_data.data.refresh();
        }

        private function CreateTextInput(dxml:XML):TextInput
        {

            var ti:TextInput = new TextInput;
            ti.text = '';
            ti.maxChars = int(dxml.services.@LEN);
            ti.width = (dxml.display.TEXTINPUT.@length * 50 > 200) ? 200 : (dxml.display.TEXTINPUT.@length) * 50;
            ti.displayAsPassword = (dxml.display.TEXTINPUT.@displayAsPassword == 0 ? false : true);
            ti.data = {'name': dxml.services.@NAME, //'ys_var': main_bus.GetVarArray(ti_name),
                    'index': 0}; //arr[0];
            ti.addEventListener(Event.CHANGE, tichange);

            return ti;
        }

        private function CreateComboBox(dxml:XML):YsComboBox
        {

            var coboBox:YsComboBox = new YsComboBox(dxml, dxml.services.@NAME);
            if (dxml.display.TEXTINPUT.list.attribute('labelField').length() == 0)
                coboBox.labelFunction = comboboxshowlabel; //if (xml.display.TEXTINPUT.list.@labelField != null)
            else
                coboBox.labelField = dxml.display.TEXTINPUT.list.@labelField;

            coboBox.addEventListener("close", comboboxchange);
            coboBox.prompt = "请选择...";

            return coboBox;
        }

        private function ff(dxml:XML):ComboBox
        {
            var ys_pod:YsPod = GetParentByType(text_input.parent as Container, YsPod) as YsPod;
            var P_data:Object = ys_pod._M_data[ys_pod.P_cont];

            if (dxml.display.TEXTINPUT.list != undefined)
            { //ComboBox

                //xingj
                var W_cont3:int = P_data.cont;
                P_data.cont++;
                P_data[W_cont3] = new Object;
                var W_data3:Object = P_data[W_cont3];
                W_data3.XML = dxml;
                W_data3.obj = coboBox;
                W_data3.datacont = 10000;
                var D_data:String = "data" + W_data3.datacont;
                W_data3.datacont++;
                W_data3[D_data] = new ArrayCollection;
                //xingj ..
                if (dxml.display.TEXTINPUT.list.listarg != undefined)
//                            <list labelField="GENDER">
//                                <listarg>
//                                    <GENDER> 女 </GENDER>
//                                    <GENDER_ID> 0 </GENDER_ID>
//                                </listarg>
//                                <listarg>
//                                    <GENDER> 男 </GENDER>
//                                    <GENDER_ID> 1 </GENDER_ID>
//                                </listarg>
//                            </list>
                    for each (var x:XML in dxml.display.TEXTINPUT.list.*)
                    {
                        W_data3[D_data].addItem(new Object);
                        for each (var xx:XML in x.*)
                        {
                            W_data3[D_data][W_data3[D_data].length - 1][xx.name().toString()] = xx.text().toString();
                        }
                    }
                else if (dxml.display.TEXTINPUT.list.action != undefined)
                {
//功能：
//                            <list labelField="NAME">
//                                <listdict>this:P_data:ACNO</listdict>
//                                <listdict>this:P_data:NAME</listdict>
//                            </list>
//                            <process>\
//                                <Services sendbus="YsPod:P_data" recvbus="this:P_data">YsUserAdd</Services>
//                                
//                            </process>

//                           1、通过定义的listdict建立W_data,并将W_data与ComboBox关联
//                           2、通过服务调用将符合条件的记录取得，放到W_data中，
//                           DoServices:
//                           Services名字
//                           Services参数
//                           CallBack:
//                           Services返回的BUS
//                           将BUS内容放到指定的W_data中
                }
                else if (dxml.display.TEXTINPUT.list.DICT != undefined)
                {
                    for each (var x:XML in dxml.display.TEXTINPUT.list.DICT)
                    {
                        var en_name:String = x.text().toString();
                        en_name = en_name.substr(en_name.search("://") + 3);
                        for (i = 0; i <= P_data.DataGrid.length; i++)
                        {
                            if (P_data.DataGrid.length == i)
                                P_data.DataGrid.addItem(new Object);
                            if (P_data.DataGrid[i][en_name] == undefined)
                            {
                                P_data.DataGrid[i][en_name] = new Object;
                                P_data.DataGrid[i][en_name].W_data = W_cont3;
                                P_data.DataGrid[i][en_name].D_data = D_data;
                                break;
                            }
                        }
                        for (i = 0; i < P_data.data.length; i++)
                        {
                            if (P_data.data[i][en_name] == null)
                                break;
                            if (W_data3[D_data][i] == null)
                                W_data3[D_data].addItem(new Object);
                            W_data3[D_data][i][en_name] = P_data.data[i][en_name];
                        }

                    }
                }
                coboBox.dataProvider = W_data3[D_data];
                for (var i:int = 0; i <= P_data.ti.length; i++)
                {
                    if (i == P_data.ti.length)
                    {
                        P_data.ti.addItem(new Object);
                    }
                    if (P_data.ti[i][ti.data.name] == null)
                        P_data.ti[i][ti.data.name] = new Object;
                    if (P_data.ti[i][ti.data.name][ti.data.index] == null)
                    {
                        //ti ArrayCollection 的 i个Object的[英文名][索引号]
                        P_data.ti[i][ti.data.name][ti.data.index] = coboBox;
                        break;
                    }
                }
            }

            for (var i:int = 0; i <= P_data.ti.length; i++)
            {
                if (i == P_data.ti.length)
                {
                    P_data.ti.addItem(new Object);
                }
                if (P_data.ti[i][ti.data.name] == null)
                    P_data.ti[i][ti.data.name] = new Object;
                if (P_data.ti[i][ti.data.name][ti.data.index] == null)
                {
                    //ti ArrayCollection 的 i个Object的[英文名][索引号]
                    P_data.ti[i][ti.data.name][ti.data.index] = ti;
                    break;
                }
            }
            if (!P_data.data[0].hasOwnProperty(ti_name))
            {
                P_data.data[0][ti_name] = new String;
                //Set DEFAULT VALUE
                if (dxml.services.@DEFAULT == null)
                    P_data.proxy[0][ti_name] = '';
                else
                {
                    var str1:String = dxml.services.@DEFAULT;
                    P_data.proxy[0][ti_name] = str1;
                }
            }
            else
            {
                var str2:String = P_data.data[0][ti_name];
                ti.text = str2;
            }
            ti.addEventListener(FlexEvent.ENTER, enterHandler);
        }

        private function comboboxshowlabel(item:Object):String
        {
            var returnvalue:String = new String;
            if (item.hasOwnProperty("mx_internal_uid"))
                item.setPropertyIsEnumerable('mx_internal_uid', false);

            for (var o:Object in item)

                returnvalue += item[o].toString() + ' - ';

            return (returnvalue.substring(0, returnvalue.length - 3));
        }

        private function comboboxchange(evt:Event):void
        {

            var tmpcobox:ComboBox = evt.target as ComboBox;

            var o:Object = (evt.target as ComboBox).selectedItem;
            if (o == null)
                return;
            var x:XML = tmpcobox.data.xml;
            P_data.proxy[tmpcobox.data.index][tmpcobox.data.name] = o[x.services.@NAME];

            P_data.data.refresh();
        }

    }
}
