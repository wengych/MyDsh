package com.yspay.YsControls
{
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;

    import mx.collections.ArrayCollection;
    import mx.controls.DataGrid;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.Application;
    import mx.events.DataGridEvent;

    public class YsDataGrid extends DataGrid implements YsControl
    {
        protected var _xml:XML;
        public var _parent:DisplayObjectContainer;
        public var data_count:String;
        public var D_data:PData = new PData;

        public function YsDataGrid(parent:DisplayObjectContainer)
        {
            super();

            _parent = parent;

            percentWidth = 100;
            percentHeight = 100;
            setStyle('borderStyle', 'solid');
            setStyle('fontSize', '12');
        }

        protected function RefreshColumn(P_data:PData, field_name:String):void
        {
            var j:int = int(dataProvider.length - 1);
            var i:int = 0;

            for each (var dgc:DataGridColumn in columns)
            {
                if (field_name == dgc.dataField)
                {
                    for (; i < P_data.data[field_name].length; ++i)
                    {
                        if (i >= dataProvider.length)
                        {
                            dataProvider.addItem(new Object);
                            dataProvider[i][field_name] = P_data.data[field_name][i];
                        }
                        else
                        {
                            dataProvider[i][field_name] = P_data.data[field_name][i];
                        }
                    }

                    // 清空后续元素的对应节点
                    for (; i < dataProvider.length; ++i)
                    {
                        if (!dataProvider[i].hasOwnProperty(field_name))
                            continue;
                        dataProvider[i][field_name] = null;
                    }

                    // 删除空行
                    for (; j >= 0; --j)
                    {
                        var empty_item:Boolean = true;
                        for (var arr_key:String in dataProvider[j])
                        {
                            if (arr_key == 'mx_internal_uid')
                                continue;

                            if (dataProvider[j][arr_key] == null)
                                continue;

                            empty_item = false;
                            break;
                        }

                        if (empty_item)
                            dataProvider.removeItemAt(j);
                    }

                    dataProvider.refresh();
                }
            }
        }

        public function Notify(p_data:PData, dict_name:String, index:int):void
        {
            var has_key:Boolean = false;
            for each (var col:DataGridColumn in columns)
            {
                if (col.dataField == dict_name)
                {
                    has_key = true;
                    break;
                }
            }
            if (!has_key)
                return;

            if (index == -1)
            {
                RefreshColumn(p_data, dict_name);
            }
            else
            {
                //var ys_pod:YsPod = UtilFunc.GetParentByType(_parent, YsPod) as YsPod;
                //var P_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
                if (dataProvider.length <= index)
                {
                    dataProvider.addItem(new Object);
                }

                dataProvider[index][dict_name] = p_data.data[dict_name][index];
            }
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
//                if (kids.name() == "append")
//                {
//                    data["attrib"] = new Object;
//                    data["attrib"][kids.name().toString()] = kids.toString();
//                }
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
                var parent_pod:YsPod = UtilFunc.GetParentByType(this.parent, YsPod) as YsPod;
                var P_data:PData = parent_pod._M_data.TRAN[parent_pod.P_cont];
                var data_cont:int = P_data.datacont++;
                data_count = "data" + data_cont.toString();
                dataProvider = new ArrayCollection;
                //xingj ..
                P_data[data_count] = dataProvider;
                trace(dataProvider.length);
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