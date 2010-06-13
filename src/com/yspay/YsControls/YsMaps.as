package com.yspay.YsControls
{
    import com.yspay.events.*;

    public class YsMaps
    {
        public function YsMaps()
        {
        }

        public static var ys_type_map:Object =
            {
                'hbox': YsHBox,
                'vbox': YsVBox,
                'windows': YsTitleWindow,
                'datagrid': YsDataGrid,
                'dict': YsDict,
                'button': YsButton,
                'pool': YsDictPool,
                'event': YsXmlEvent,
                'action': YsAction,
                'services': YsService
            };

        public static var ys_win_type_map:Object =
            {
                'hbox': YsHBox,
                'vbox': YsVBox,
                'datagrid': YsDataGrid,
                'dict': YsDict,
                'button': YsButton,
                'event': YsXmlEvent
            };

        // DataGrid支持的属性列表
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

        // DataGrid中的dict所支持的属性列表
        public static var dict_dg_attrs:Object =
            {
                'editable': {}

            };

        public static var button_attrs:Object =
            {
                '': ''
            };

        // Windows支持的属性列表
        public static var windows_attrs:Object =
            {
                'title': {},
                'showCloseButton': {'default': false}
            };
    }
}