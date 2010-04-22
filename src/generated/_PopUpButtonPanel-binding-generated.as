

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.controls.TextInput;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property txtName (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'txtName' moved to '_878708453txtName'
	 */

    [Bindable(event="propertyChange")]
    public function get txtName():mx.controls.TextInput
    {
        return this._878708453txtName;
    }

    public function set txtName(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._878708453txtName;
        if (oldValue !== value)
        {
            this._878708453txtName = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "txtName", oldValue, value));
        }
    }



}
