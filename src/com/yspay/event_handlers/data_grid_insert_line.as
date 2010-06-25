// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsControls.YsDgListItem;
    import com.yspay.util.UtilFunc;
    import com.yspay.util.YsClassFactory;

    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.UIComponent;

    public function data_grid_insert_line(ui_comp:UIComponent,
                                          source_event:Event,
                                          action_info:XML):Boolean
    {
        var data_grid:YsDataGrid = UtilFunc.GetParentByType(ui_comp.parent, YsDataGrid) as YsDataGrid;
        if (data_grid == null)
        {
            Alert.show('data_grid_insert_line: 控件类型不匹配');
            return false;
        }

        var idx:int = data_grid.selectedIndex;
        var arr:ArrayCollection = data_grid.dataProvider as ArrayCollection;

        var new_obj:Object = new Object;
        for each (var dgc:DataGridColumn in data_grid.columns)
        {
            if (dgc.itemRenderer != null)
                continue;

			if (dgc.itemEditor is YsClassFactory &&
				(dgc.itemEditor as YsClassFactory).generator == YsDgListItem)
				{
					var label_key:String = dgc.dataField + '_list_label';
					
					new_obj[label_key] = arr[idx][label_key];
				}
            new_obj[dgc.dataField] = arr[idx][dgc.dataField];
        }

        arr.addItemAt(new_obj, idx);

        return true;
    }
}