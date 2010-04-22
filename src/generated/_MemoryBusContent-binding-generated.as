

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.controls.TextArea;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property ta (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'ta' moved to '_3693ta'
	 */

    [Bindable(event="propertyChange")]
    public function get ta():mx.controls.TextArea
    {
        return this._3693ta;
    }

    public function set ta(value:mx.controls.TextArea):void
    {
    	var oldValue:Object = this._3693ta;
        if (oldValue !== value)
        {
            this._3693ta = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "ta", oldValue, value));
        }
    }



}
