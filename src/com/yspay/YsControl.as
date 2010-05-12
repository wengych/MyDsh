package com.yspay
{
    import mx.core.IUIComponent;

    public interface YsControl
    {
        function Init(xml:XML):void;
        function GetXml():XML;
    }
}