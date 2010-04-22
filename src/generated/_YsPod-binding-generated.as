

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import com.yspay.UserBus;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property main_bus (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'main_bus' moved to '_8114438main_bus'
	 */

    [Bindable(event="propertyChange")]
    public function get main_bus():UserBus
    {
        return this._8114438main_bus;
    }

    public function set main_bus(value:UserBus):void
    {
    	var oldValue:Object = this._8114438main_bus;
        if (oldValue !== value)
        {
            this._8114438main_bus = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "main_bus", oldValue, value));
        }
    }



}
