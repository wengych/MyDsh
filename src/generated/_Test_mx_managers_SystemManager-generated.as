package
{

import flash.text.Font;
import flash.text.TextFormat;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;

import mx.managers.SystemManager;

public class _Test_mx_managers_SystemManager
    extends mx.managers.SystemManager
    implements IFlexModuleFactory
{
    public function _Test_mx_managers_SystemManager()
    {

        super();
    }

    override     public function create(... params):Object
    {
        if (params.length > 0 && !(params[0] is String))
            return super.create.apply(this, params);

        var mainClassName:String = params.length == 0 ? "Test" : String(params[0]);
        var mainClass:Class = Class(getDefinitionByName(mainClassName));
        if (!mainClass)
            return null;

        var instance:Object = new mainClass();
        if (instance is IFlexModule)
            (IFlexModule(instance)).moduleFactory = this;
        return instance;
    }

    override    public function info():Object
    {
        return {
            compiledLocales: [ "en_US" ],
            compiledResourceBundleNames: [ "collections", "containers", "controls", "core", "effects", "skins", "styles" ],
            currentDomain: ApplicationDomain.currentDomain,
            layout: "absolute",
            mainClassName: "Test",
            mixins: [ "_Test_FlexInit", "_alertButtonStyleStyle", "_ControlBarStyle", "_ScrollBarStyle", "_activeTabStyleStyle", "_textAreaHScrollBarStyleStyle", "_ToolTipStyle", "_DragManagerStyle", "_advancedDataGridStylesStyle", "_comboDropdownStyle", "_ListBaseStyle", "_textAreaVScrollBarStyleStyle", "_ContainerStyle", "_linkButtonStyleStyle", "_globalStyle", "_windowStatusStyle", "_PanelStyle", "_windowStylesStyle", "_activeButtonStyleStyle", "_errorTipStyle", "_richTextEditorTextAreaStyleStyle", "_FormItemStyle", "_CursorManagerStyle", "_todayStyleStyle", "_dateFieldPopupStyle", "_TextInputStyle", "_plainStyle", "_dataGridStylesStyle", "_TitleWindowStyle", "_FormStyle", "_ApplicationStyle", "_FormItemLabelStyle", "_headerDateTextStyle", "_ButtonStyle", "_popUpMenuStyle", "_AlertStyle", "_swatchPanelTextFieldStyle", "_opaquePanelStyle", "_weekDayStyleStyle", "_headerDragProxyStyleStyle" ]
        }
    }
}

}
