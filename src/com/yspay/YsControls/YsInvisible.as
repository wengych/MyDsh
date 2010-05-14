package com.yspay.YsControls
{
    import mx.controls.Label;

    public class YsInvisible extends Label implements YsControl
    {
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

    }
}