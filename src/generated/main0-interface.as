
package 
{
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filters.*;
import flash.geom.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import flexlib.controls.SuperTabBar;
import mx.binding.*;
import mx.containers.Panel;
import mx.containers.ViewStack;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.LinkButton;
import mx.controls.TextInput;
import mx.core.Application;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.styles.*;
import mx.states.RemoveChild;
import mx.containers.ApplicationControlBar;
import mx.states.AddChild;
import mx.states.State;
import mx.controls.Label;
import mx.controls.ComboBox;
import mx.core.Application;

public class main0 extends mx.core.Application
{
	public function main0() {}

	[Bindable]
	public var action : mx.controls.TextInput;
	[Bindable]
	public var tabBar : flexlib.controls.SuperTabBar;
	[Bindable]
	public var viewStack : mx.containers.ViewStack;
	[Bindable]
	public var panel1 : mx.containers.Panel;
	[Bindable]
	public var txtUsername : mx.controls.TextInput;
	[Bindable]
	public var txtPassword : mx.controls.TextInput;
	[Bindable]
	public var btnLogin : mx.controls.Button;
	[Bindable]
	public var btnReset : mx.controls.Button;
	[Bindable]
	public var lblCheckCode : mx.controls.Label;
	[Bindable]
	public var linkbtnReGenerate : mx.controls.LinkButton;
	[Bindable]
	public var txtCheckCode : mx.controls.TextInput;
	[Bindable]
	public var rember : mx.controls.CheckBox;
	[Bindable]
	public var ipChoose : mx.controls.ComboBox;
	[Bindable]
	public var s_ipChoose : mx.controls.ComboBox;

	mx_internal var _bindings : Array;
	mx_internal var _watchers : Array;
	mx_internal var _bindingsByDestination : Object;
	mx_internal var _bindingsBeginWithWord : Object;

include "D:/workspace/MyDsh/src/main0.mxml:18,157";
include "D:/workspace/MyDsh/src/main0.mxml:195,309";

}}
