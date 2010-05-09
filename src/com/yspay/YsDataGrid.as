package com.yspay
{
    import com.yspay.util.GetParentByType;

    import flash.display.DisplayObject;

    import mx.collections.ArrayCollection;
    import mx.controls.DataGrid;
    import mx.events.DataGridEvent;

    public class YsDataGrid extends DataGrid implements YsControl
    {
        protected var _xml:XML;
        protected var P_data:Object;
        public var P_cont:int;
        public var _M_data:Object;

        public function YsDataGrid()
        {
            super();

            percentWidth = 100;
            percentHeight = 100;
            setStyle('borderStyle', 'solid');
            setStyle('fontSize', '12');
        }

        public function Init(xml:XML):void
        {
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
                    else
                    {
                        if (hasEventListener("itemEditEnd"))
                            removeEventListener("itemEditEnd", itemEditEndHandler);
                    }
                }
            }

            var parent_pod:YsPod = GetParentByType(this.parent, YsPod) as YsPod;
            var pod_P_data:Object = parent_pod._M_data[parent_pod.P_cont];

            _M_data = parent_pod._M_data;

            P_cont = pod_P_data.cont;
            pod_P_data.cont++;
            pod_P_data[P_cont] = new Object;
            P_data = pod_P_data[P_cont];
            P_data.XML = xml;
            //W_data2.obj = dg;
            P_data.datacont = 10000;
            var D_data:String = "data" + P_data.datacont.toString();
            P_data[D_data] = new ArrayCollection;
            //xingj ..
            var arr:ArrayCollection;

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

                if (_M_data[p_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()][tran_xml.text()] == null)
                    return;
                arr = _M_data[p_xml.text()][info_xml.text()][tran_xml.text()];
            }
            else if (xml.DICT != undefined)
            {
                //arr = P_data.data;
                //arr = P_data.proxy;
                arr = P_data[D_data];
            }
            else
                return;

            for each (var child:XML in xml.elements())
            {
                var node_name:String = child.localName().toString().toLocaleLowerCase();
                var child_ctrl:DisplayObject = new YsMaps.ys_type_map[node_name](this);
                this.addChild(child_ctrl);

                (child_ctrl as YsControl).Init(child);
            }
            dataProvider = arr;
        }


        private function itemEditEndHandler(e:DataGridEvent):void
        {
            e.target.dataProvider.refresh();
        }
    }
}