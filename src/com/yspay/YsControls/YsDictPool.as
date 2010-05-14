package com.yspay.YsControls
{
    import com.yspay.pool.Pool;

    import flash.display.DisplayObjectContainer;

    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.Application;

    public class YsDictPool extends YsInvisible implements YsControl
    {
        protected var _pool:Pool;
        protected var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public function YsDictPool(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;
        }

        public override function GetXml():XML
        {
            return _xml;
        }

        public override function Init(xml:XML):void
        {
            super.Init(xml);

            _xml = xml;
            var dg:YsDataGrid = _parent as YsDataGrid;

            var arr_xml:XMLList = xml.object.object.object;
            for each (var field_xml:XML in arr_xml)
            {
                var dgc:DataGridColumn =  new DataGridColumn;
                var obj_name:String = field_xml.text();
                var obj_title:String = field_xml.@id;

                dgc.headerText = obj_title;
                dgc.dataField = obj_name;
                dg.columns = dg.columns.concat(dgc);
            }
        }
    }
}
