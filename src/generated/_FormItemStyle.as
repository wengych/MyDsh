
package 
{

import flash.display.Sprite;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

[ExcludeClass]

public class _FormItemStyle
{
    [Embed(_pathsep='true', _resolvedSource='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', original='Assets.swf', source='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', _file='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$defaults.css', _line='715', symbol='mx.containers.FormItem.Required')]
    private static var _embed_css_Assets_swf_mx_containers_FormItem_Required_137779819:Class;

    public static function init(fbs:IFlexModuleFactory):void
    {
        var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration("FormItem");
    
        if (!style)
        {
            style = new CSSStyleDeclaration();
            StyleManager.setStyleDeclaration("FormItem", style, false);
        }
    
        if (style.defaultFactory == null)
        {
            style.defaultFactory = function():void
            {
                this.indicatorSkin = _embed_css_Assets_swf_mx_containers_FormItem_Required_137779819;
            };
        }
    }
}

}
