package com.yspay.YsControls
{
    import com.yspay.YsData.TargetList;

    import mx.controls.Label;
    import mx.core.UIComponent;

    public class YsInvisible extends Label implements YsControl
    {
        protected var _xml:XML;
        protected var _from:TargetList = new TargetList;
        protected var _to:TargetList = new TargetList;

        //protected var _type:String = '';

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function YsInvisible()
        {
        }

        public function Init(xml:XML):void
        {
            this.enabled = false;
            this.visible = false;
            this.height = 0;
        }

        public function GetXml():XML
        {
            return null;
        }

        public function GetSaveXml():XML
        {
            return null;
        }

        public function GetLinkXml():XML
        {
            if (_xml.@save == 'false')
                return null;

            var rtn:XML = new XML('<L KEY="" KEYNAME="" VALUE="" />');
            rtn.@KEY = type;
            rtn.@KEYNAME = type;
            rtn.@VALUE = type + '://' + _xml.text().toString();

            var target_name:String;
            var target_node:XML;
            for each (target_name in _from.GetAllTargetName())
            {
                target_node = new XML('<L KEY="From" KEYNAME="From" VALUE="" />');
                target_node.@VALUE = target_name;
                rtn.appendChild(target_node);
            }
            for each (target_name in _to.GetAllTargetName())
            {
                target_node = new XML('<L KEY="To" KEYNAME="To" VALUE="" />');
                target_node.@VALUE = target_name;
                rtn.appendChild(target_node);
            }

            return rtn;
        }

        public function Print(print_container:UIComponent, print_call_back:Function):UIComponent
        {
            return null;
        }
    }
}