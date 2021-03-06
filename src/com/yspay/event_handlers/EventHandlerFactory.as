package com.yspay.event_handlers
{

    import flash.utils.getDefinitionByName;

    import mx.core.Container;

    public class EventHandlerFactory
    {
        public function EventHandlerFactory()
        {
            var event_arr:Array = [clean_text
                                   , make_windows_xml
                                   , make_tran_xml
                                   , bus2window
                                   , drag_drop
                                   , show_xml
                                   , refresh_pool
                                   , drag_enter
                                   , dbg_out_dict
                                   , dict_change
                                   , dict_check
                                   , mouse_over
                                   , make_datagrid_xml
                                   , drag_object_to_datagrid
                                   , data_grid_delete_line
                                   , data_grid_insert_line
                                   , data_grid_append_line
                                   , copy_dict
                                   , check_not_init
                                   , message_box
                                   , close_pod
                                   , get_current_datetime
                                   , show_date_chooser
                                   , print
                                   , save_file];

        /*
           clean_text(null, null);
           make_windows_xml(null, null);
           make_tran_xml(null, null);
           bus2window(null, null);
           new_window(null, null);
           show_xml(null, null);
           refresh_pool(null, null);
         */
        }

        public static function get_handler(handler_name:String):Function
        {
            var func_name:String = 'com.yspay.event_handlers.' + handler_name;
            var func:Function = getDefinitionByName(func_name) as Function;

            return func;
        }
    }
}
