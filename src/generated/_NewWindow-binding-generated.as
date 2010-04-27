

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.collections.ArrayCollection;
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

	/**
	 * generated bindable wrapper for property arr_col (private)
	 * - generated setter
	 * - generated getter
	 * - original private var 'arr_col' moved to '_734522718arr_col'
	 */

    [Bindable(event="propertyChange")]
    private function get arr_col():ArrayCollection
    {
        return this._734522718arr_col;
    }

    private function set arr_col(value:ArrayCollection):void
    {
    	var oldValue:Object = this._734522718arr_col;
        if (oldValue !== value)
        {
            this._734522718arr_col = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "arr_col", oldValue, value));
        }
    }



}
