

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.controls.Button;
import mx.controls.TextInput;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property cancel (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'cancel' moved to '_1367724422cancel'
	 */

    [Bindable(event="propertyChange")]
    public function get cancel():mx.controls.Button
    {
        return this._1367724422cancel;
    }

    public function set cancel(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._1367724422cancel;
        if (oldValue !== value)
        {
            this._1367724422cancel = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "cancel", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property submit (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'submit' moved to '_891535336submit'
	 */

    [Bindable(event="propertyChange")]
    public function get submit():mx.controls.Button
    {
        return this._891535336submit;
    }

    public function set submit(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._891535336submit;
        if (oldValue !== value)
        {
            this._891535336submit = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "submit", oldValue, value));
        }
    }

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
