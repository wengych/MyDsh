package com.yspay.event_handlers
{
    import com.yspay.YsPod;

    import flash.utils.getDefinitionByName;

    import mx.core.Container;

    public class EventHandlerFactory
    {
        public function EventHandlerFactory()
        {
            var event_arr:Array = [clean_text, make_windows_xml, make_tran_xml,
                                   bus2window, new_window, show_xml, refresh_pool];

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
            if (handler_name.search('event_') >= 0)
            {
                handler_name = handler_name.substr('event_'.length);
            }
            var func_name:String = 'com.yspay.event_handlers.' + handler_name;
            var func:Function = getDefinitionByName(func_name) as Function;

            return func;
        }
    }
}
