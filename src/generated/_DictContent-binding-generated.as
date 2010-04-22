

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.controls.Button;
import mx.collections.ArrayCollection;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property refresh (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'refresh' moved to '_1085444827refresh'
	 */

    [Bindable(event="propertyChange")]
    public function get refresh():mx.controls.Button
    {
        return this._1085444827refresh;
    }

    public function set refresh(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._1085444827refresh;
        if (oldValue !== value)
        {
            this._1085444827refresh = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "refresh", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property dp (private)
	 * - generated setter
	 * - generated getter
	 * - original private var 'dp' moved to '_3212dp'
	 */

    [Bindable(event="propertyChange")]
    private function get dp():ArrayCollection
    {
        return this._3212dp;
    }

    private function set dp(value:ArrayCollection):void
    {
    	var oldValue:Object = this._3212dp;
        if (oldValue !== value)
        {
            this._3212dp = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "dp", oldValue, value));
        }
    }



}
