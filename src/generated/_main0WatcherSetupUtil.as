






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
public class _main0WatcherSetupUtil extends Sprite
    implements mx.binding.IWatcherSetupUtil
{
    public function _main0WatcherSetupUtil()
    {
        super();
    }

    public static function init(fbs:IFlexModuleFactory):void
    {
        import main0;
        (main0).watcherSetupUtil = new _main0WatcherSetupUtil();
    }

    public function setup(target:Object,
                          propertyGetter:Function,
                          bindings:Array,
                          watchers:Array):void
    {
        import mx.core.DeferredInstanceFromFunction;
        import com.esria.samples.dashboard.view.NewWindow;
        import mx.core.UIComponent;
        import mx.core.Application;
        import com.yspay.events.EventNewPod;
        import flash.display.DisplayObject;
        import mx.core.ClassFactory;
        import flexlib.events.SuperTabEvent;
        import mx.containers.ViewStack;
        import mx.controls.TextInput;
        import mx.core.IPropertyChangeNotifier;
        import com.esria.samples.dashboard.view.MemoryBusContent;
        import mx.containers.Panel;
        import mx.controls.Label;
        import com.esria.samples.dashboard.managers.PodLayoutManager;
        import mx.containers.Canvas;
        import mx.managers.CursorManager;
        import mx.controls.Alert;
        import flash.events.MouseEvent;
        import mx.controls.CheckBox;
        import com.esria.samples.dashboard.view.PodContentBase;
        import mx.events.FlexEvent;
        import mx.core.UIComponentDescriptor;
        import com.yspay.util.FunctionDelegate;
        import flash.events.Event;
        import com.yspay.util.EncryptUtil;
        import mx.containers.ApplicationControlBar;
        import mx.core.DeferredInstanceFromClass;
        import mx.rpc.http.HTTPService;
        import mx.states.State;
        import com.esria.samples.dashboard.view.DictContent;
        import mx.rpc.events.FaultEvent;
        import mx.binding.BindingManager;
        import com.esria.samples.dashboard.view.DeployedWindow;
        import flash.events.EventDispatcher;
        import mx.events.IndexChangedEvent;
        import mx.controls.LinkButton;
        import mx.states.AddChild;
        import mx.core.IDeferredInstance;
        import mx.events.DropdownEvent;
        import com.esria.samples.dashboard.view.NewService;
        import com.yspay.UserBus;
        import mx.states.RemoveChild;
        import mx.core.mx_internal;
        import mx.events.ItemClickEvent;
        import mx.utils.ObjectProxy;
        import com.esria.samples.dashboard.view.Pod;
        import com.esria.samples.dashboard.view.ServiceContent;
        import mx.controls.Button;
        import com.esria.samples.dashboard.view.SetupContent;
        import mx.utils.UIDUtil;
        import flexlib.controls.SuperTabBar;
        import mx.binding.IBindingClient;
        import mx.rpc.events.ResultEvent;
        import mx.controls.ComboBox;
        import com.yspay.YsPodLayoutManager;
        import mx.collections.ArrayCollection;
        import mx.events.PropertyChangeEvent;
        import com.esria.samples.dashboard.view.WindowContent;
        import mx.core.IFactory;
        import flash.events.IEventDispatcher;

        // writeWatcher id=2 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[2] = new mx.binding.PropertyWatcher("ipDP",
            {
                propertyChange: true
            }
,         // writeWatcherListeners id=2 size=2
        [
        bindings[2],
        bindings[3]
        ]
,
                                                                 propertyGetter
);

        // writeWatcher id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[0] = new mx.binding.PropertyWatcher("panel1",
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

        // writeWatcher id=1 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher shouldWriteChildren=true
        watchers[1] = new mx.binding.PropertyWatcher("comboboxDP",
            {
                propertyChange: true
            }
,         // writeWatcherListeners id=1 size=1
        [
        bindings[1]
        ]
,
                                                                 propertyGetter
);


        // writeWatcherBottom id=2 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[2].updateParent(target);

 





        // writeWatcherBottom id=0 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[0].updateParent(target);

 





        // writeWatcherBottom id=1 shouldWriteSelf=true class=flex2.compiler.as3.binding.PropertyWatcher
        watchers[1].updateParent(target);

 





    }
}

}
