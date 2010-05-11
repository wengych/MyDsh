// ActionScript file

package com.yspay.event_handlers
{
    import mx.core.UIComponent;
    import mx.events.DragEvent;
    import mx.managers.DragManager;

    public function drag_enter(event:DragEvent, ui_comp:UIComponent):void
    {
        if (ui_comp == event.currentTarget)
            DragManager.acceptDragDrop(ui_comp);
    }
}
