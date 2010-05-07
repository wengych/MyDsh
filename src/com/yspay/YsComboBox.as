package com.yspay
{
    import mx.controls.ComboBox;

    public class YsComboBox extends ComboBox implements YsControl
    {
        protected var P_data:Object;
        protected var bus_key_name:String;
        protected var bus_key_index:int;
        protected var _xml:XML;

        public function YsComboBox(xml:XML, key_name:String, key_index:int=0)
        {
            super();
            _xml = xml;
            bus_key_name = key_name;
            bus_key_index = key_index;
        }

        public function Init(xml:XML):void
        {
        }

    }
}