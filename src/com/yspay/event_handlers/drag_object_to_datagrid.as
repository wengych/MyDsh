
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.YsData.PData;

    import flash.events.Event;

    import mx.controls.Alert;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.controls.listClasses.ListBase;
    import mx.core.UIComponent;
    import mx.events.DragEvent;

    public function drag_object_to_datagrid(ui_comp:UIComponent, source_event:Event,
                                            action_info:XML):void
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


        //var drag_object:Object = (drag_event.dragInitiator as ListBase).selectedItem;
        var drag_items:Array = (drag_event.dragInitiator as ListBase).selectedItems;

        for each (var drag_item:Object in drag_items)
        {
            var new_item:Object = new Object;
            var key:String = '';

            for each (var dgc:DataGridColumn in data_grid.columns)
            {
                if (dgc.dataField == null)
                    continue;
                if (!(drag_item.hasOwnProperty(dgc.dataField)))
                {
                    Alert.show('drag_object_to_datagrid: 无对应属性' + dgc.dataField.toString());
                    return;
                }
                new_item[dgc.dataField] = drag_item[dgc.dataField];
            }

            for each (var item:Object in data_grid.dataProvider)
            {
                var item_exist:Boolean = true;
                for (key in new_item)
                {
                    if (new_item[key] != item[key])
                    {
                        item_exist = false;
                        break;
                    }
                }

                if (item_exist)
                {
                    Alert.show('对象已存在!');
                    return;
                }
            }

            for (key in new_item)
            {
                for each (var to_data:PData in data_grid.toDataObject[key].GetAllTarget())
                {
                    to_data.data[key].push('');
                    to_data.data[key][to_data.data[key].length - 1] = new_item[key]
                }
            }
        }

    /*var arr:ArrayCollection = data_grid.dataProvider as ArrayCollection;
       arr.addItem(new_item);
     arr.refresh();*/
    }
}

