package com.yspay
{
    import mx.controls.DataGrid;
    import mx.events.DataGridEvent;

    public class YsDataGrid extends DataGrid implements YsControl
    {
        protected var _xml:XML;

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
        }


        private function itemEditEndHandler(e:DataGridEvent):void
        {
            e.target.dataProvider.refresh();
        }
    }
}