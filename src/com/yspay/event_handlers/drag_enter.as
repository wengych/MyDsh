// ActionScript file

package com.yspay.event_handlers
{
    import flash.events.Event;

    import mx.core.UIComponent;
    import mx.managers.DragManager;

    public function drag_enter(ui_comp:UIComponent, source_event:Event, action_info:XML):Boolean
    {
        if (ui_comp == source_event.currentTarget)
            DragManager.acceptDragDrop(ui_comp);
        else if (ui_comp.parent == source_event.currentTarget)
            DragManager.acceptDragDrop(ui_comp.parent as UIComponent);

        return true;
    }
}
