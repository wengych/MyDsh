// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsControls.YsDgListItem;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.core.UIComponent;

    public function check_not_init(ui_comp:UIComponent, source_event:Event, action_info:XML):Boolean
    {
        if (ui_comp is YsDgListItem)
        {
            var dg_list:YsDgListItem = ui_comp as YsDgListItem;
            var dg:YsDataGrid = UtilFunc.YsGetParentByType(dg_list, YsDataGrid) as YsDataGrid;

            var dg_idx:int = dg.selectedIndex;
            var list_item_key:String = dg_list.dict_name + '_list_data';
            var sel_obj:Object = dg.dataProvider[dg_idx];

            if (sel_obj[list_item_key].length == 0)
                return true;
        }

        return false;
    }
}
