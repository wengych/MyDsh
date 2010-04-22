
package 
{

import flash.display.Sprite;
import mx.core.IFlexModuleFactory;
import mx.core.mx_internal;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

[ExcludeClass]

public class _TitleWindowStyle
{
    [Embed(_pathsep='true', _resolvedSource='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', original='Assets.swf', source='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', _file='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$defaults.css', _line='1493', symbol='CloseButtonUp')]
    private static var _embed_css_Assets_swf_CloseButtonUp_1893453373:Class;
    [Embed(_pathsep='true', _resolvedSource='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', original='Assets.swf', source='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', _file='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$defaults.css', _line='1490', symbol='CloseButtonDisabled')]
    private static var _embed_css_Assets_swf_CloseButtonDisabled_1040696612:Class;
    [Embed(_pathsep='true', _resolvedSource='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', original='Assets.swf', source='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', _file='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$defaults.css', _line='1492', symbol='CloseButtonOver')]
    private static var _embed_css_Assets_swf_CloseButtonOver_816239284:Class;
    [Embed(_pathsep='true', _resolvedSource='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', original='Assets.swf', source='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$Assets.swf', _file='C:/Flex Builder 3/sdks/3.2.0/frameworks/libs/framework.swc$defaults.css', _line='1491', symbol='CloseButtonDown')]
    private static var _embed_css_Assets_swf_CloseButtonDown_983554978:Class;

    public static function init(fbs:IFlexModuleFactory):void
    {
        var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration("TitleWindow");
    
        if (!style)
        {
            style = new CSSStyleDeclaration();
            StyleManager.setStyleDeclaration("TitleWindow", style, false);
        }
    
        if (style.defaultFactory == null)
        {
            style.defaultFactory = function():void
            {
                this.paddingTop = 4;
                this.paddingLeft = 4;
                this.cornerRadius = 8;
                this.paddingRight = 4;
                this.dropShadowEnabled = true;
                this.closeButtonDownSkin = _embed_css_Assets_swf_CloseButtonDown_983554978;
                this.closeButtonOverSkin = _embed_css_Assets_swf_CloseButtonOver_816239284;
                this.closeButtonUpSkin = _embed_css_Assets_swf_CloseButtonUp_1893453373;
                this.closeButtonDisabledSkin = _embed_css_Assets_swf_CloseButtonDisabled_1040696612;
                this.paddingBottom = 4;
                this.backgroundColor = 0xffffff;
            };
        }
    }
}

}
