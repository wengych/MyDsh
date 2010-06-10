// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsData.PData;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.controls.Alert;
    import mx.core.UIComponent;

    public function data_grid_delete_line(ui_comp:UIComponent,
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
        var obj:Object = data_grid.dataProvider[idx];
        data_grid.dataProvider.removeItemAt(idx);

        for (var key:String in obj)
        {
            if (!(data_grid.toDataObject.hasOwnProperty(key)))
                continue;
            for each (var to_data:PData in data_grid.toDataObject[key].GetAllTarget())
            {
                // var idx_in_data:int = to_data.data[key].indexOf(obj[key]);
                // to_data.data[key].splice(idx_in_data, 1);
                to_data.data[key].splice(idx, 1);
            }
        }
    }
}
