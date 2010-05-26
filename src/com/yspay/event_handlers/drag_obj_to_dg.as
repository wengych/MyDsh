
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import mx.controls.Alert;
    import mx.core.UIComponent;
    import flash.events.Event;
    import mx.events.DragEvent;
    import mx.controls.listClasses.ListBase;
    import mx.controls.dataGridClasses.DataGridColumn;

    public function drag_obj_to_dg(ui_comp:UIComponent, source_event:Event, action_info:XML):void
    {
        var data_grid:YsDataGrid = ui_comp as YsDataGrid;
        if (data_grid == null)
        {
            Alert.show('drag_obj_to_dg: 控件类型不匹配');
            return;
        }
        var drag_event:DragEvent = source_event as DragEvent;
        if (drag_event == null)
        {
            Alert.show('drag_obj_to_dg: 事件类型不匹配');
        }


        var drag_object:Object = (drag_event.dragInitiator as ListBase).selectedItem;
        
        var new_item:Object;
        for each (var dgc:DataGridColumn in data_grid.columns)
        {
            if (!drag_object.hasOwnProperty(dgc.dataField))
            {
                Alert.show('drag_obj_to_dg: 无对应属性' + dgc.dataField);
                return;
            }
            new_item[dgc.dataField] = drag_object[dgc.dataField];
        }

        data_grid.dataProvider.addChild(new_item);
    }
}

