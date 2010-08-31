package com.yspay.YsControls
{
    import mx.core.UIComponent;

    public interface YsControl
    {
        function Init(xml:XML):void;
        function GetXml():XML;
        function GetSaveXml():XML;
        function GetLinkXml():XML;
        function get type():String;

        function Print(print_container:UIComponent, print_call_back:Function):UIComponent;
    }
}