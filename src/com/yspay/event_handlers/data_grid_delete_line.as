// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.DataGrid;
    import mx.core.UIComponent;

    public function data_grid_delete_line(ui_comp:UIComponent, source_event:Event,
                                          action_info:XML):void
    {
        var data_grid:DataGrid = UtilFunc.GetParentByType(ui_comp.parent, DataGrid) as DataGrid;
        if (data_grid == null)
            return;

        var arr:ArrayCollection = data_grid.dataProvider as ArrayCollection;

        arr.removeItemAt(data_grid.selectedIndex);
    }
}
