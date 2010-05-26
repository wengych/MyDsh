package com.yspay.YsControls
{
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.events.EventDragToDatagrid;
    import com.yspay.util.UtilFunc;
    import com.yspay.util.YsClassFactory;

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
            this.addEventListener(EventDragToDatagrid.EVENT_NAME, OnDragDrop);
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

        public function GetSaveXml():XML
        {
            var rtn:XML =
                <L KEY="DATAGRID" KEYNAME="DATAGRID" VALUE=""/>
                ;

            var xml_line:XML =
                <L KEY="" KEYNAME="" VALUE="">
                    <L KEY="From" KEYNAME="From" VALUE="pod"/>
                    <L KEY="To" KEYNAME="To" VALUE="pod"/>
                </L>
                ;

            for each (var ctrl:XML in this.GetXml().children())
            {
                if (ctrl.name().toString() != "DICT")
                    continue;

                var newxml:XML = new XML(xml_line);

                newxml.@KEY = ctrl.name().toString();
                newxml.@KEYNAME = ctrl.name().toString();

                newxml.@VALUE = ctrl.text().toString();

                rtn.appendChild(newxml);
                newxml = null;
            }
            return rtn;
        }

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function GetLinkXml():XML
        {
            return GetSaveXml();
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

                // 清空DataGridColumns
                columns = []; //.splice(0, columns.length);

                // TODO:  用对象关注数据,对象再和datagrid的对应数据格关联
                //        创建一行数据，就建立了对应的一组DICT对象

                if (xml.attribute('editable').length() > 0 && xml.@editable == "true")
                {
                    var dgc:DataGridColumn = new DataGridColumn;
                    dgc.itemRenderer = new YsClassFactory(YsButton, this, btn_xml);
                    dgc.editable = false;

                    columns = columns.concat(dgc);
                }
            }

            for each (child in xml.elements())
            {
                node_name = child.localName().toString().toLowerCase();

                if (YsMaps.ys_type_map.hasOwnProperty(node_name))
                {
                    child_ctrl = new YsMaps.ys_type_map[node_name](this);
                    child_ctrl.Init(child);
                }
            }
        }

        protected var btn_xml:XML =
            <BUTTON LABEL="删除">删除
                <ACTION>data_grid_delete_line</ACTION>
            </BUTTON>
            ;

        private function OnDragDrop(event:EventDragToDatagrid):void
        {
            var obj:Object = event.drag_object;

            if (!(obj.hasOwnProperty('TYPE') && obj.hasOwnProperty('NAME')))
                return;

            var child_type:String = obj.TYPE.toLowerCase();
            if (!YsMaps.ys_type_map.hasOwnProperty(child_type))
                return;

            var child_xml:XML = new XML('<' + obj.TYPE + '/>');
            child_xml.appendChild(obj.TYPE + '://' + obj.NAME);
            child_xml.appendChild('<To>pod</To>');
            child_xml.appendChild('<From>pod</From>');

            var child:YsControl = new YsMaps.ys_type_map[child_type](this);
            child.Init(child_xml);

            this._xml.appendChild(child_xml);
        }

        private function itemEditEndHandler(e:DataGridEvent):void
        {
            e.target.dataProvider.refresh();
        }
    }
}