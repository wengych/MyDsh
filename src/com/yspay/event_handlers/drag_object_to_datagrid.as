
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;

    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.core.UIComponent;
    import mx.events.DragEvent;

    public function drag_object_to_datagrid(ui_comp:UIComponent, source_event:Event,
                                            action_info:XML):Boolean
    {
        var data_grid:YsDataGrid = ui_comp as YsDataGrid;
        if (data_grid == null)
        {
            Alert.show('drag_obj_to_dg: 控件类型不匹配');
            return false;
        }
        var drag_event:DragEvent = source_event as DragEvent;
        if (drag_event == null)
        {
            Alert.show('drag_obj_to_dg: 事件类型不匹配');
            return false;
        }


        //var drag_object:Object = (drag_event.dragInitiator as ListBase).selectedItem;
        var drag_source_grid:YsDataGrid = drag_event.dragInitiator as YsDataGrid;
        var drag_items:Array = drag_source_grid.selectedItems;
        var drag_column_arr:Array = new Array;
        var target_dict_name_arr:Array = new Array;
        var source_dict_name_arr:Array = new Array;
        var dict:YsDict;

        if (action_info.elements('DICT').length() == 0)
        {
            for each (dict in data_grid.dict_arr)
                target_dict_name_arr.push(dict.name);
            for each (dict in drag_source_grid.dict_arr)
                source_dict_name_arr.push(dict.name);

            for each (var dict_name:String in target_dict_name_arr)
            {
                if (source_dict_name_arr.indexOf(dict_name) >= 0)
                    drag_column_arr.push(dict_name);
            }
        }
        else
        {
            for each (var dict_xml:XML in action_info.DICT)
            {
                var dict_str:String = dict_xml.text().toString();
                drag_column_arr.push(dict_str);
            }
        }

        if (drag_column_arr.length == 0)
            return true;

        for each (var drag_item:Object in drag_items)
        {
            var new_item:Object = new Object;
            var key:String = '';

            for each (key in drag_column_arr)
            {
                new_item[key] = drag_item[key];
            }

            for each (var col:DataGridColumn in data_grid.columns)
            {
                if (col.dataField != null &&
                    new_item[col.dataField] == undefined)
                    new_item[col.dataField] = '';
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
                    return true;
                }
            }

            data_grid.dataProvider.addItem(new_item);
        }

        if (drag_source_grid.dragOut == true)
        {
            for each (var src_item:Object in drag_items)
            {
                var src_arr:ArrayCollection = drag_source_grid.dataProvider as ArrayCollection;
                var idx:int = src_arr.getItemIndex(src_item);
                drag_source_grid.dataProvider.removeItemAt(idx);
            }
        }

        return true;
    }
}

