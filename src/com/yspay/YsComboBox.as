package com.yspay
{
    import com.yspay.YsData.PData;
    import com.yspay.util.GetParentByType;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.controls.ComboBox;

    public class YsComboBox extends ComboBox implements YsControl
    {

        protected var _parent:DisplayObjectContainer;
        protected var data_count:String;
        protected var D_data:ArrayCollection = new ArrayCollection;

        public function YsComboBox(parent:DisplayObjectContainer) //)xml:XML, key_name:String, key_index:int=0)
        {
            super();
            _parent = parent;
            prompt = "请选择...";
        /*
           _xml = xml;
           bus_key_name = key_name;
           bus_key_index = key_index;
         */
        }

        public function Init(dxml:XML):void
        {
            var parent_pod:YsPod = GetParentByType(_parent, YsPod) as YsPod;
            var P_data:PData = parent_pod._M_data.TRAN[parent_pod.P_cont];
            var data_cont:int = P_data.datacont++;
            var i:int = 0;
            var x:XML;
            data = new Object;
            data.name = dxml.services.@NAME.toString();
            data.index = 0;
            data.xml = dxml;
            data_count = "data" + data_cont.toString();
            P_data[data_count] = D_data;
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
                for each (x in dxml.display.TEXTINPUT.list.*)
                {
                    D_data.addItem(new Object);
                    for each (var xx:XML in x.*)
                    {
                        D_data[D_data.length - 1][xx.name().toString()] = xx.text().toString();
                    }
                }
            else if (dxml.display.TEXTINPUT.list.action != undefined)
            {
                //功能：
                //                            <list labelField="NAME">
                //                                <DICT>DICT://ACNO</DICT>
//                //                                <DICT>this:P_data:ACNO</listdict>
//                //                                <DICT>this:P_data:NAME</listdict>
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
                for each (x in dxml.display.TEXTINPUT.list.DICT)
                {
                    var en_name:String = x.text().toString();
                    en_name = en_name.substr(en_name.search("://") + 3);
                    for (i = 0; i <= P_data.data_grid.length; i++)
                    {
                        if (P_data.data_grid.length == i)
                            P_data.data_grid.addItem(new Object);
                        if (P_data.data_grid[i][en_name] != undefined)
                            continue;
                        P_data.data_grid[i][en_name] = data_count;
                        break;

                    }
                    for (i = 0; i < P_data._data.length; i++)
                    {
                        if (!P_data._data[i].hasOwnProperty(en_name))
                            break;
                        if (D_data.length <= i)
                            D_data.addItem(new Object);
                        D_data[i][en_name] = P_data._data[i][en_name];
                    }
                }
            }
            dataProvider = D_data;
        /*
           for (i = 0; i <= P_data.ctrls_proxy.length; i++)
           {
           if (i == P_data.ctrls_proxy.length)
           {
           P_data.ctrls_proxy.addItem(new Object);
           }
           if (P_data.ctrls_proxy[i][data.name] == null)
           P_data.ctrls_proxy[i][data.name] = new Object;
           if (P_data.ctrls_proxy[i][data.name][data.index] == null)
           {
           //ti ArrayCollection 的 i个Object的[英文名][索引号]
           P_data.ctrls_proxy[i][data.name][data.index] = this;
           break;
           }
           }
         */
        }

        public function GetXml():XML
        {
            trace('ComboBox不生成XML,由YsDict产生XMl');

            return null;
        }
    }
}