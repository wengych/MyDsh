// ActionScript file

package com.yspay.event_handlers
{
    import flash.events.Event;

    import mx.controls.Alert;
    import mx.core.UIComponent;

    public function message_box(ui_comp:UIComponent,
                                source_event:Event,
                                action_info:XML):Boolean
    {
        var msg:String = 'message_box';
        if (action_info.elements('message').length() > 0)
            msg = action_info.message.toString();

        Alert.show(msg);
        return true;
    }
}
