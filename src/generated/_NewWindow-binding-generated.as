

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.containers.Form;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property form (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'form' moved to '_3148996form'
	 */

    [Bindable(event="propertyChange")]
    public function get form():mx.containers.Form
    {
        return this._3148996form;
    }

    public function set form(value:mx.containers.Form):void
    {
    	var oldValue:Object = this._3148996form;
        if (oldValue !== value)
        {
            this._3148996form = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "form", oldValue, value));
        }
    }



}
