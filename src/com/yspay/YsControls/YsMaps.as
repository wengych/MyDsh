package com.yspay.YsControls
{
    import com.yspay.events.*;

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

        public static var datagrid_attrs:Object =
            {
                'editable': {'default': false},
                'dragEnabled': {'default': false},
                'allowMultipleSelection': {'default': true},
                //'itemEditEnd': {'default': false},
                'add': {'default': false},
                'ins': {'default': false},
                'del': {'default': false},
                'default_line': {'default': false}
            };

        public static var button_attrs:Object =
            {
                '': ''
            };
    }
}