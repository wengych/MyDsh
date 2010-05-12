package com.yspay
{
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.util.GetParentByType;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.controls.DataGrid;
    import mx.core.Application;
    import mx.events.DataGridEvent;

    public class YsDataGrid extends DataGrid implements YsControl
    {
        protected var _xml:XML;
        protected var P_data:Object;
        protected var _parent:DisplayObjectContainer;
        public var data_count:String;


        public function YsDataGrid(parent:DisplayObjectContainer)
        {
            super();

            _parent = parent;

            percentWidth = 100;
            percentHeight = 100;
            setStyle('borderStyle', 'solid');
            setStyle('fontSize', '12');
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function Init(xml:XML):void
        {
            var data_provider_arr:ArrayCollection;
            var child:XML;
            var node_name:String;
            var child_ctrl:YsControl;

            _parent.addChild(this);
            _xml = new XML(xml);
            for each (var kids:XML in _xml.attributes())
            {
                if (kids.name() == "editable")
                    editable = kids.toString();
                if (kids.name() == "dragEnabled")
                    dragEnabled = kids.toString();
                if (kids.name() == "append")
                {
                    data["attrib"] = new Object;
                    data["attrib"][kids.name().toString()] = kids.toString();
                }
                if (kids.name() == "itemEditEnd")
                {
                    if (kids.toString() == "true")
                        addEventListener("itemEditEnd", itemEditEndHandler);
                }
            }

            if (xml.POOL != undefined)
            {
                var ddxml:XMLList = xml.POOL;

                if (xml.POOL == undefined)
                    return;
                if (xml.POOL.object == undefined)
                    return;
                if (xml.POOL.object.object == undefined)
                    return;
                var p_xml:XML = xml.POOL[0];
                var info_xml:XML = p_xml.object[0];
                var tran_xml:XML = info_xml.object[0];

                var _M_data:MData = Application.application.M_data;

                if (_M_data[p_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()][tran_xml.text()] == null)
                    return;
                dataProvider = _M_data[p_xml.text()][info_xml.text()][tran_xml.text()];
            }
            else if (xml.DICT != undefined)
            {
                /*  <datagrid editable="true" itemEditEnd="true">
                   <DICT>DICT://DEPT_DTS</DICT>
                   <DICT>DICT://DEPTNAME</DICT>
                   <DICT>DICT://STATUS</DICT>
                   <DICT>DICT://STATUS_ID</DICT>
                   <DICT>DICT://DEPTNO</DICT>
                 </datagrid>*/
                //arr = P_data.data;
                //arr = P_data.proxy;
                var parent_pod:YsPod = GetParentByType(this.parent, YsPod) as YsPod;
                var P_data:PData = parent_pod._M_data.TRAN[parent_pod.P_cont];
                var data_cont:int = P_data.datacont++;
                data_count = "data" + data_cont.toString();
                P_data[data_count] = new ArrayCollection;
                //xingj ..
                dataProvider = P_data[data_count];
            }
            else
                return;

            // 清空DataGridColumns
            columns = []; //.splice(0, columns.length);

            for each (child in xml.elements())
            {
                node_name = child.localName().toString().toLocaleLowerCase();

                // 查表未发现匹配类型
                if (!YsMaps.ys_type_map.hasOwnProperty(node_name))
                    return;

                child_ctrl = new YsMaps.ys_type_map[node_name](this);
                child_ctrl.Init(child);
            }
        }

        private function itemEditEndHandler(e:DataGridEvent):void
        {
            e.target.dataProvider.refresh();
        }
    }
}