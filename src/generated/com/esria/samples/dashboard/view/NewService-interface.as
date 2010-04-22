
package com.esria.samples.dashboard.view
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
import mx.binding.*;
import mx.containers.Form;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.mx_internal;
import mx.styles.*;
import mx.controls.Button;
import mx.containers.VBox;
import mx.controls.Label;

public class NewService extends mx.containers.VBox
{
	public function NewService() {}

	[Bindable]
	public var form1 : mx.containers.Form;
	[Bindable]
	public var form2 : mx.containers.Form;
	[Bindable]
	public var stateBox : mx.containers.HBox;
	[Bindable]
	public var formname : mx.controls.TextInput;
	[Bindable]
	public var englishName : mx.controls.TextInput;
	[Bindable]
	public var txtActive : mx.controls.TextInput;
	[Bindable]
	public var save : mx.controls.Button;

	mx_internal var _bindings : Array;
	mx_internal var _watchers : Array;
	mx_internal var _bindingsByDestination : Object;
	mx_internal var _bindingsBeginWithWord : Object;

include "D:/workspace/MyDsh/src/com/esria/samples/dashboard/view/NewService.mxml:8,199";

}}
