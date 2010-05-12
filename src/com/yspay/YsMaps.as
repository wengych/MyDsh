package com.yspay
{
    import com.yspay.events.*;

    import flash.events.Event;

    public class YsMaps
    {
        public function YsMaps()
        {
        }

        public static var ys_type_map:Object = {'hbox': YsHBox,
                'windows': YsTitleWindow,
                'datagrid': YsDataGrid,
                'dict': YsDict,
                'button': YsButton,
                'pool': YsDictPool,
                'event': YsXmlEvent,
                'action': YsAction,
                'services': YsService};
    }
}