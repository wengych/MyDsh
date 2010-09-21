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
                'pod': YsPod
                , 'hbox': YsHBox
                , 'vbox': YsVBox
                , 'windows': YsTitleWindow
                , 'datagrid': YsDataGrid
                , 'dict': YsDict
                , 'button': YsButton
                , 'pool': YsDictPool
                , 'event': YsXmlEvent
                , 'action': YsAction
                , 'services': YsService
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

        public static var pod_attrs:Object =
            {
                'title': {'default': 'POD'}
                , 'id': {'default': 'YsPod'}
            };

        // Windows支持的属性列表
        public static var windows_attrs:Object =
            {
                'title': {'default': 'windows'}
                , 'showCloseButton': {'default': false}
            };

        public static var vbox_attrs:Object =
            {
                'id': {'default': 'vbox'}
            };

        public static var hbox_attrs:Object =
            {
                'id': {'default': 'hbox'}
            };

        public static var button_attrs:Object =
            {
                'interruptable': {'default': true} // 默认为所有操作序列,一旦有一个出错,便中断当前操作序列
                , 'LABEL': {'default': 'Button'}
                , 'id': {'default': 'Button'}
            };

        // DataGrid支持的属性列表
        public static var datagrid_attrs:Object =
            {
                'editable': {'default': false}
                , 'dragEnabled': {'default': false}
                , 'allowMultipleSelection': {'default': true}
                , 'add': {'default': false}
                , 'ins': {'default': false}
                , 'del': {'default': false}
                , 'dragOut': {'default': false}
                , 'default_line': {'default': false}
                , 'id': {'default': 'YsDatagrid'}
            };

        public static var event_attrs:Object =
            {
                'interruptable': {'default': false}
            };

        // DataGrid中的dict所支持的属性列表
        public static var dict_dg_attrs:Object =
            {
                'editable': {}
            };

        public static var dict_attrs:Object =
            {
                'id': {'default': 'dict'}
                , 'LABEL': {}
                , 'InputType': {'default': 'TextInput'}
            };

        public static var service_attrs:Object =
            {
                'prepareEmptyDict': {'default': true}
            };

    }
}
