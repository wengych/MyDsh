package com.yspay.YsControls
{
    import mx.controls.DateField;
    import mx.formatters.DateFormatter;

    public class YsDateField extends DateField implements YsControl
    {
        public function YsDateField()
        {
            super();
            this.yearNavigationEnabled = true;
        }

        public function Init(xml:XML):void
        {
            // parse xml to get format
            var format:String = "YYYY/MM/DD";
            var showFormatHandler:Function = function(date:Date):String{
                    var df:DateFormatter = new DateFormatter;
                    df.formatString = format;
                    return df.format(date);
                };
            this.labelFunction = showFormatHandler;
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
            return null;
        }

        public function get type():String
        {
            return null;
        }

    }
}