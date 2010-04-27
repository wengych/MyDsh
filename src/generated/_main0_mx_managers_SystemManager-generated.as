package
{

import flash.text.Font;
import flash.text.TextFormat;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;

import mx.managers.SystemManager;

public class _main0_mx_managers_SystemManager
    extends mx.managers.SystemManager
    implements IFlexModuleFactory
{
    public function _main0_mx_managers_SystemManager()
    {

        super();
    }

    override     public function create(... params):Object
    {
        if (params.length > 0 && !(params[0] is String))
            return super.create.apply(this, params);

        var mainClassName:String = params.length == 0 ? "main0" : String(params[0]);
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
            backgroundColor: "#ffffff",
            backgroundSize: "100%",
            compiledLocales: [ "en_US" ],
            compiledResourceBundleNames: [ "collections", "containers", "controls", "core", "effects", "logging", "messaging", "rpc", "skins", "states", "styles" ],
            currentDomain: ApplicationDomain.currentDomain,
            horizontalAlign: "center",
            mainClassName: "main0",
            minHeight: "600",
            minWidth: "600",
            mixins: [ "_main0_FlexInit", "_alertButtonStyleStyle", "_ScrollBarStyle", "_MenuStyle", "_TabStyle", "_ToolTipStyle", "_ComboBoxStyle", "_comboDropdownStyle", "_CheckBoxStyle", "_ListBaseStyle", "_globalStyle", "_windowStylesStyle", "_MenuBarStyle", "_PanelStyle", "_activeButtonStyleStyle", "_ApplicationControlBarStyle", "_errorTipStyle", "_CursorManagerStyle", "_dateFieldPopupStyle", "_ButtonBarButtonStyle", "_dataGridStylesStyle", "_LinkButtonStyle", "_TitleWindowStyle", "_PopUpButtonStyle", "_AlertStyle", "_DataGridItemRendererStyle", "_ControlBarStyle", "_activeTabStyleStyle", "_TabBarStyle", "_textAreaHScrollBarStyleStyle", "_DragManagerStyle", "_advancedDataGridStylesStyle", "_TextAreaStyle", "_ContainerStyle", "_textAreaVScrollBarStyleStyle", "_linkButtonStyleStyle", "_windowStatusStyle", "_richTextEditorTextAreaStyleStyle", "_todayStyleStyle", "_FormItemStyle", "_TextInputStyle", "_ButtonBarStyle", "_TabNavigatorStyle", "_plainStyle", "_ApplicationStyle", "_FormStyle", "_FormItemLabelStyle", "_headerDateTextStyle", "_ButtonStyle", "_DataGridStyle", "_popUpMenuStyle", "_opaquePanelStyle", "_swatchPanelTextFieldStyle", "_weekDayStyleStyle", "_headerDragProxyStyleStyle", "_main0WatcherSetupUtil", "_com_esria_samples_dashboard_view_WindowContentWatcherSetupUtil", "_com_esria_samples_dashboard_view_DictContentWatcherSetupUtil", "_com_esria_samples_dashboard_view_ServiceContentWatcherSetupUtil" ],
            paddingBottom: "35",
            paddingLeft: "45",
            paddingRight: "45",
            paddingTop: "34",
            verticalAlign: "middle"
        }
    }
}

}
