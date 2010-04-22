

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import mx.core.IPropertyChangeNotifier;
import mx.events.PropertyChangeEvent;
import mx.utils.ObjectProxy;
import mx.utils.UIDUtil;

import mx.controls.Button;
import mx.collections.ArrayCollection;
import flexlib.controls.SuperTabBar;
import mx.containers.ViewStack;
import mx.controls.TextInput;
import mx.containers.Panel;
import mx.controls.CheckBox;
import mx.controls.LinkButton;
import mx.controls.Label;
import mx.controls.ComboBox;

class BindableProperty
{
	/**
	 * generated bindable wrapper for property action (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'action' moved to '_1422950858action'
	 */

    [Bindable(event="propertyChange")]
    public function get action():mx.controls.TextInput
    {
        return this._1422950858action;
    }

    public function set action(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1422950858action;
        if (oldValue !== value)
        {
            this._1422950858action = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "action", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property btnLogin (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'btnLogin' moved to '_2090736237btnLogin'
	 */

    [Bindable(event="propertyChange")]
    public function get btnLogin():mx.controls.Button
    {
        return this._2090736237btnLogin;
    }

    public function set btnLogin(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._2090736237btnLogin;
        if (oldValue !== value)
        {
            this._2090736237btnLogin = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "btnLogin", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property btnReset (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'btnReset' moved to '_2095990867btnReset'
	 */

    [Bindable(event="propertyChange")]
    public function get btnReset():mx.controls.Button
    {
        return this._2095990867btnReset;
    }

    public function set btnReset(value:mx.controls.Button):void
    {
    	var oldValue:Object = this._2095990867btnReset;
        if (oldValue !== value)
        {
            this._2095990867btnReset = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "btnReset", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property ipChoose (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'ipChoose' moved to '_945272350ipChoose'
	 */

    [Bindable(event="propertyChange")]
    public function get ipChoose():mx.controls.ComboBox
    {
        return this._945272350ipChoose;
    }

    public function set ipChoose(value:mx.controls.ComboBox):void
    {
    	var oldValue:Object = this._945272350ipChoose;
        if (oldValue !== value)
        {
            this._945272350ipChoose = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "ipChoose", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property lblCheckCode (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'lblCheckCode' moved to '_593080833lblCheckCode'
	 */

    [Bindable(event="propertyChange")]
    public function get lblCheckCode():mx.controls.Label
    {
        return this._593080833lblCheckCode;
    }

    public function set lblCheckCode(value:mx.controls.Label):void
    {
    	var oldValue:Object = this._593080833lblCheckCode;
        if (oldValue !== value)
        {
            this._593080833lblCheckCode = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "lblCheckCode", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property linkbtnReGenerate (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'linkbtnReGenerate' moved to '_2085793142linkbtnReGenerate'
	 */

    [Bindable(event="propertyChange")]
    public function get linkbtnReGenerate():mx.controls.LinkButton
    {
        return this._2085793142linkbtnReGenerate;
    }

    public function set linkbtnReGenerate(value:mx.controls.LinkButton):void
    {
    	var oldValue:Object = this._2085793142linkbtnReGenerate;
        if (oldValue !== value)
        {
            this._2085793142linkbtnReGenerate = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "linkbtnReGenerate", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property panel1 (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'panel1' moved to '_995543379panel1'
	 */

    [Bindable(event="propertyChange")]
    public function get panel1():mx.containers.Panel
    {
        return this._995543379panel1;
    }

    public function set panel1(value:mx.containers.Panel):void
    {
    	var oldValue:Object = this._995543379panel1;
        if (oldValue !== value)
        {
            this._995543379panel1 = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "panel1", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property rember (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'rember' moved to '_934623819rember'
	 */

    [Bindable(event="propertyChange")]
    public function get rember():mx.controls.CheckBox
    {
        return this._934623819rember;
    }

    public function set rember(value:mx.controls.CheckBox):void
    {
    	var oldValue:Object = this._934623819rember;
        if (oldValue !== value)
        {
            this._934623819rember = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "rember", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property s_ipChoose (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 's_ipChoose' moved to '_88426390s_ipChoose'
	 */

    [Bindable(event="propertyChange")]
    public function get s_ipChoose():mx.controls.ComboBox
    {
        return this._88426390s_ipChoose;
    }

    public function set s_ipChoose(value:mx.controls.ComboBox):void
    {
    	var oldValue:Object = this._88426390s_ipChoose;
        if (oldValue !== value)
        {
            this._88426390s_ipChoose = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "s_ipChoose", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property tabBar (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'tabBar' moved to '_881418178tabBar'
	 */

    [Bindable(event="propertyChange")]
    public function get tabBar():flexlib.controls.SuperTabBar
    {
        return this._881418178tabBar;
    }

    public function set tabBar(value:flexlib.controls.SuperTabBar):void
    {
    	var oldValue:Object = this._881418178tabBar;
        if (oldValue !== value)
        {
            this._881418178tabBar = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "tabBar", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property txtCheckCode (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'txtCheckCode' moved to '_2010751355txtCheckCode'
	 */

    [Bindable(event="propertyChange")]
    public function get txtCheckCode():mx.controls.TextInput
    {
        return this._2010751355txtCheckCode;
    }

    public function set txtCheckCode(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._2010751355txtCheckCode;
        if (oldValue !== value)
        {
            this._2010751355txtCheckCode = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "txtCheckCode", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property txtPassword (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'txtPassword' moved to '_1970565419txtPassword'
	 */

    [Bindable(event="propertyChange")]
    public function get txtPassword():mx.controls.TextInput
    {
        return this._1970565419txtPassword;
    }

    public function set txtPassword(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._1970565419txtPassword;
        if (oldValue !== value)
        {
            this._1970565419txtPassword = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "txtPassword", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property txtUsername (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'txtUsername' moved to '_487866214txtUsername'
	 */

    [Bindable(event="propertyChange")]
    public function get txtUsername():mx.controls.TextInput
    {
        return this._487866214txtUsername;
    }

    public function set txtUsername(value:mx.controls.TextInput):void
    {
    	var oldValue:Object = this._487866214txtUsername;
        if (oldValue !== value)
        {
            this._487866214txtUsername = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "txtUsername", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property viewStack (public)
	 * - generated setter
	 * - generated getter
	 * - original public var 'viewStack' moved to '_1584105757viewStack'
	 */

    [Bindable(event="propertyChange")]
    public function get viewStack():mx.containers.ViewStack
    {
        return this._1584105757viewStack;
    }

    public function set viewStack(value:mx.containers.ViewStack):void
    {
    	var oldValue:Object = this._1584105757viewStack;
        if (oldValue !== value)
        {
            this._1584105757viewStack = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "viewStack", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property comboboxDP (private)
	 * - generated setter
	 * - generated getter
	 * - original private var 'comboboxDP' moved to '_1627849comboboxDP'
	 */

    [Bindable(event="propertyChange")]
    private function get comboboxDP():ArrayCollection
    {
        return this._1627849comboboxDP;
    }

    private function set comboboxDP(value:ArrayCollection):void
    {
    	var oldValue:Object = this._1627849comboboxDP;
        if (oldValue !== value)
        {
            this._1627849comboboxDP = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "comboboxDP", oldValue, value));
        }
    }

	/**
	 * generated bindable wrapper for property ipDP (private)
	 * - generated setter
	 * - generated getter
	 * - original private var 'ipDP' moved to '_3237875ipDP'
	 */

    [Bindable(event="propertyChange")]
    private function get ipDP():ArrayCollection
    {
        return this._3237875ipDP;
    }

    private function set ipDP(value:ArrayCollection):void
    {
    	var oldValue:Object = this._3237875ipDP;
        if (oldValue !== value)
        {
            this._3237875ipDP = value;
            this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "ipDP", oldValue, value));
        }
    }



}
