package com.yspay
{

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
                'event': YsXmlEvent};
    }
}