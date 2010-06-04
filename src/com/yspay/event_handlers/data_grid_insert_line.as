// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.UIComponent;

    public function data_grid_insert_line(ui_comp:UIComponent,
                                          source_event:Event,
                                          action_info:XML):void
    {
        var data_grid:YsDataGrid = UtilFunc.GetParentByType(ui_comp.parent, YsDataGrid) as YsDataGrid;
        if (data_grid == null)
        {
            Alert.show('data_grid_delete_line: 控件类型不匹配');
            return;
        }

        var idx:int = data_grid.selectedIndex;
        var arr:ArrayCollection = data_grid.dataProvider as ArrayCollection;

        var new_obj:Object = new Object;
        for each (var dgc:DataGridColumn in data_grid.columns)
        {
            if (dgc.itemRenderer != null)
                continue;

            new_obj[dgc.dataField] = '';
        }

        arr.addItemAt(new_obj, idx);
    }
}