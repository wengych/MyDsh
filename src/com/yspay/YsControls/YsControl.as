package com.yspay.YsControls
{
    import mx.core.IUIComponent;

    public interface YsControl
    {
        function Init(xml:XML):void;
        function GetXml():XML;
        function GetSaveXml():XML;
        function GetLinkXml():XML;
    }
}