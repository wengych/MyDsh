package com.yspay
{
    import com.yspay.pool.Pool;

    import mx.core.Application;
    import flash.display.DisplayObjectContainer;
    import mx.controls.dataGridClasses.DataGridColumn;

    public class YsDictPool implements YsControl
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

        public function Init(xml:XML):void
        {
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
