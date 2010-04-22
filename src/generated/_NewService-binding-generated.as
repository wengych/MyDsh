

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.containers.HBox;
import mx.controls.Button;
import mx.controls.TextInput;
import mx.containers.Form;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property englishName (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'englishName' moved to '_1394945765englishName'
	 */

    [Bindable(event="propertyChange")]
    public function get englishName():mx.controls.TextInput
    {
        return this._1394945765englishName;
    }

    public function set englishName(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1394945765englishName;
        if (oldValue !== value)
        {
            this._1394945765englishName = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "englishName", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property form1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'form1' moved to '_97618925form1'
	 */

    [Bindable(event="propertyChange")]
    public function get form1():mx.containers.Form
    {
        return this._97618925form1;
    }

    public function set form1(value:mx.containers.Form):void
    {
    	var oldValue:Object = this._97618925form1;
        if (oldValue !== value)
        {
            this._97618925form1 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "form1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property form2 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'form2' moved to '_97618926form2'
	 */

    [Bindable(event="propertyChange")]
    public function get form2():mx.containers.Form
    {
        return this._97618926form2;
    }

    public function set form2(value:mx.containers.Form):void
    {
    	var oldValue:Object = this._97618926form2;
        if (oldValue !== value)
        {
            this._97618926form2 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "form2", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property formname (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'formname' moved to '_474449231formname'
	 */

    [Bindable(event="propertyChange")]
    public function get formname():mx.controls.TextInput
    {
        return this._474449231formname;
    }

    public function set formname(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._474449231formname;
        if (oldValue !== value)
        {
            this._474449231formname = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "formname", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property save (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'save' moved to '_3522941save'
	 */

    [Bindable(event="propertyChange")]
    public function get save():mx.controls.Button
    {
        return this._3522941save;
    }

    public function set save(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._3522941save;
        if (oldValue !== value)
        {
            this._3522941save = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "save", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property stateBox (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'stateBox' moved to '_1318169466stateBox'
	 */

    [Bindable(event="propertyChange")]
    public function get stateBox():mx.containers.HBox
    {
        return this._1318169466stateBox;
    }

    public function set stateBox(value:mx.containers.HBox):void
    {
    	var oldValue:Object = this._1318169466stateBox;
        if (oldValue !== value)
        {
            this._1318169466stateBox = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "stateBox", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property txtActive (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'txtActive' moved to '_1299618198txtActive'
	 */

    [Bindable(event="propertyChange")]
    public function get txtActive():mx.controls.TextInput
    {
        return this._1299618198txtActive;
    }

    public function set txtActive(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1299618198txtActive;
        if (oldValue !== value)
        {
            this._1299618198txtActive = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "txtActive", oldValue, value));
        }
    }



}
