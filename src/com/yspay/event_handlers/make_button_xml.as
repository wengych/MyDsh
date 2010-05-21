// ActionScript file
// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.util.BtnEdit;

    import flash.events.Event;

    import mx.core.UIComponent;

    public function make_button_xml(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var ti:BtnEdit = new BtnEdit;
        ui_comp.addChild(ti);
        ti.invalidateDisplayList();
        ;

    }
}