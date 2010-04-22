






package
{
import flash.display.Sprite;
import mx.core.IFlexModuleFactory;
import mx.binding.ArrayElementWatcher;
import mx.binding.FunctionReturnWatcher;
import mx.binding.IWatcherSetupUtil;
import mx.binding.PropertyWatcher;
import mx.binding.RepeaterComponentWatcher;
import mx.binding.RepeaterItemWatcher;
import mx.binding.StaticPropertyWatcher;
import mx.binding.XMLWatcher;
import mx.binding.Watcher;

[ExcludeClass]
[Mixin]
public class _com_esria_samples_dashboard_view_ServiceContentWatcherSetupUtil extends Sprite
    implements mx.binding.IWatcherSetupUtil
{
    public function _com_esria_samples_dashboard_view_ServiceContentWatcherSetupUtil()
    {
        super();
    }

    public static function init(fbs:IFlexModuleFactory):void
    {
        import com.esria.samples.dashboard.view.ServiceContent;
        (com.esria.samples.dashboard.view.ServiceContent).watcherSetupUtil = new _com_esria_samples_dashboard_view_ServiceContentWatcherSetupUtil();
    }

    public function setup(target:Object,
                          propertyGetter:Function,
                          bindings:Array,
                          watchers:Array):void
    {
        import mx.core.DeferredInstanceFromFunction;
        import flash.events.EventDispatcher;
        import mx.containers.HBox;
        import mx.core.UIComponent;
        import mx.controls.dataGridClasses.DataGridColumn;
        import com.yspay.pool.QueryObject;
        import com.yspay.pool.DBTableInsertEvent;
        import mx.containers.TitleWindow;
        import com.yspay.pool.DBTableQueryEvent;
        import mx.core.IDeferredInstance;
        import mx.core.Application;
        import mx.core.ClassFactory;
        import mx.core.mx_internal;
        import mx.core.IPropertyChangeNotifier;
        import mx.utils.ObjectProxy;
        import mx.rpc.http.mxml.HTTPService;
        import mx.managers.CursorManager;
        import mx.utils.StringUtil;
        import mx.controls.Button;
        import mx.utils.UIDUtil;
        import flash.events.MouseEvent;
        import mx.events.DragEvent;
        import mx.controls.DataGrid;
        import mx.binding.IBindingClient;
        import mx.rpc.events.ResultEvent;
        import mx.events.FlexEvent;
        import mx.containers.FormItem;
        import mx.managers.DragManager;
        import mx.core.UIComponentDescriptor;
        import mx.containers.VBox;
        import mx.collections.ArrayCollection;
        import mx.events.PropertyChangeEvent;
        import com.yspay.util.FunctionDelegate;
        import com.yspay.pool.QueryWithIndex;
        import mx.core.IFactory;
        import com.yspay.pool.DBTable;
        import flash.events.Event;
        import com.yspay.pool.Pool;
        import mx.core.DeferredInstanceFromClass;
        import mx.containers.Form;
        import mx.states.State;
        import mx.binding.BindingManager;
        import flash.net.SharedObject;
        import flash.events.IEventDispatcher;

        // writeWatcher id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[0] = new mx.binding.PropertyWatcher("dp",
            {
                propertyChange: true
            }
,         // writeWatcherListeners id=0 size=1
        [
        bindings[0]
        ]
,
                                                                 propertyGetter
);


        // writeWatcherBottom id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[0].updateParent(target);

 





    }
}

}
