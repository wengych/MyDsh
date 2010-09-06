package com.yspay.YsData
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsControls.YsDgListItem;
    import com.yspay.YsControls.YsDict;
    import com.yspay.YsControls.YsHBox;
    import com.yspay.YsControls.YsPod;
    import com.yspay.YsControls.YsTitleWindow;
    import com.yspay.YsControls.YsVBox;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import mx.core.FlexGlobals;

    public class TargetList
    {
        protected var object:Object;
        protected var target_arr:Array = new Array;
        protected var dict_arr_arr:Array = new Array;
        protected var target_name_arr:Array = new Array;

        public function TargetList()
        {
        }

        public function Init(obj:Object, xml_list:XMLList):void
        {
            object = obj;
            if (xml_list == null)
                return;

            for each (var item:XML in xml_list)
            {
                var item_text:String = item.text().toString().toLowerCase();
                var curr_pdata:PData;
                if (item_text == 'dict')
                {
                    var dict:YsDict;
                    if (obj is YsDict)
                        dict = obj as YsDict;
                    else
                        dict = UtilFunc.YsGetParentByType(obj._parent, YsDict) as YsDict;

                    if (dict == null)
                        continue;

                    curr_pdata = dict.D_data;
                }
                else if (item_text == 'datagrid')
                {
                    var dg:YsDataGrid;
                    if (obj is YsDataGrid)
                        dg = obj as YsDataGrid;
                    else
                        dg = UtilFunc.YsGetParentByType(obj._parent, YsDataGrid) as YsDataGrid;
                    curr_pdata = dg.D_data;
                }
                else if (item_text == 'dg_list')
                {
                    var dg_list:YsDgListItem;
                    if (obj is YsDgListItem)
                        dg_list = obj as YsDgListItem;
                    else
                        dg_list = UtilFunc.YsGetParentByType(obj._parent, YsDgListItem) as YsDgListItem;

                    curr_pdata = dg_list.D_data;
                }
                else if (item_text == 'hbox')
                {
                    var hbox:YsHBox;
                    if (obj is YsHBox)
                        hbox = obj as YsHBox;
                    else
                        hbox = UtilFunc.YsGetParentByType(obj._parent,
                                                          YsHBox) as YsHBox;
                    curr_pdata = hbox.D_data;
                }
                else if (item_text == 'vbox')
                {
                    var vbox:YsVBox;
                    if (obj is YsVBox)
                        vbox = obj as YsVBox;
                    else
                        vbox = UtilFunc.YsGetParentByType(obj._parent,
                                                          YsVBox) as YsVBox;

                    curr_pdata = vbox.D_data;
                }
                else if (item_text == 'windows')
                {
                    var wnd:YsTitleWindow = UtilFunc.YsGetParentByType(obj._parent,
                                                                       YsTitleWindow) as YsTitleWindow;
                    curr_pdata = wnd.D_data;
                }
                else if (item_text == 'pod')
                {
                    var pod:YsPod = UtilFunc.YsGetParentByType(obj._parent, YsPod) as YsPod;
                    curr_pdata = pod.D_data;
                }
                else if (item_text == 'parent')
                {
                    curr_pdata = obj._parent.D_data;
                }
                else if (item_text == 'pool')
                {
                    var pool:Pool = FlexGlobals.topLevelApplication._pool;
                    curr_pdata = pool.D_data;
                }
                else if (item_text == 'self')
                {
                    curr_pdata = obj.D_data;
                }

                target_arr.push(curr_pdata);
                target_name_arr.push(item_text);

                var dict_arr:Array = new Array;
                for each (var dict_item:XML in item.DICT)
                {
                    dict_arr.push(dict_item.text().toString());
                }
                dict_arr_arr.push(dict_arr);
            }
        }


        public function Add(xml_list:XMLList):void
        {
            var obj:Object = object;

            if (xml_list == null)
                return;

            for each (var item:XML in xml_list)
            {
                var item_text:String = item.text().toString().toLowerCase();
                var curr_pdata:PData;
                if (item_text == 'dict')
                {
                    var dict:YsDict;
                    if (obj is YsDict)
                        dict = obj as YsDict;
                    else
                        dict = UtilFunc.YsGetParentByType(obj._parent, YsDict) as YsDict;

                    if (dict == null)
                        continue;

                    curr_pdata = dict.D_data;
                }
                else if (item_text == 'datagrid')
                {
                    var dg:YsDataGrid;
                    if (obj is YsDataGrid)
                        dg = obj as YsDataGrid;
                    else
                        dg = UtilFunc.YsGetParentByType(obj._parent, YsDataGrid) as YsDataGrid;
                    curr_pdata = dg.D_data;
                }
                else if (item_text == 'dg_list')
                {
                    var dg_list:YsDgListItem;
                    if (obj is YsDgListItem)
                        dg_list = obj as YsDgListItem;
                    else
                        dg_list = UtilFunc.YsGetParentByType(obj._parent, YsDgListItem) as YsDgListItem;

                    curr_pdata = dg_list.D_data;
                }
                else if (item_text == 'hbox')
                {
                    var hbox:YsHBox;
                    if (obj is YsHBox)
                        hbox = obj as YsHBox;
                    else
                        hbox = UtilFunc.YsGetParentByType(obj._parent,
                                                          YsHBox) as YsHBox;
                    curr_pdata = hbox.D_data;
                }
                else if (item_text == 'vbox')
                {
                    var vbox:YsVBox;
                    if (obj is YsVBox)
                        vbox = obj as YsVBox;
                    else
                        vbox = UtilFunc.YsGetParentByType(obj._parent,
                                                          YsVBox) as YsVBox;

                    curr_pdata = vbox.D_data;
                }
                else if (item_text == 'windows')
                {
                    var wnd:YsTitleWindow = UtilFunc.YsGetParentByType(obj._parent,
                                                                       YsTitleWindow) as YsTitleWindow;
                    curr_pdata = wnd.D_data;
                }
                else if (item_text == 'pod')
                {
                    var pod:YsPod = UtilFunc.YsGetParentByType(obj._parent, YsPod) as YsPod;
                    curr_pdata = pod.D_data;
                }
                else if (item_text == 'parent')
                {
                    curr_pdata = obj._parent.D_data;
                }
                else if (item_text == 'pool')
                {
                    var pool:Pool = FlexGlobals.topLevelApplication._pool;
                    curr_pdata = pool.D_data;
                }
                else if (item_text == 'self')
                {
                    curr_pdata = obj.D_data;
                }

                target_arr.push(curr_pdata);
                target_name_arr.push(item_text);

                var dict_arr:Array = new Array;
                for each (var dict_item:XML in item.DICT)
                {
                    dict_arr.push(dict_item.text().toString());
                }
                dict_arr_arr.push(dict_arr);
            }
        }

        public function GetAllTarget():Array
        {
            return target_arr;
        }

        public function GetTargetDictArr():Array
        {
            return dict_arr_arr;
        }

        public function GetAllTargetName():Array
        {
            return target_name_arr;
        }

    }
}
