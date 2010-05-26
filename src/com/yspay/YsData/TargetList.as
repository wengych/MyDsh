package com.yspay.YsData
{
    import com.yspay.YsControls.YsDict;
    import com.yspay.YsControls.YsPod;
    import com.yspay.YsControls.YsTitleWindow;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import mx.core.Application;

    public class TargetList
    {
        protected var object:Object;
        protected var target_arr:Array = new Array;
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
                if (item_text == 'dict')
                {
                    var dict:YsDict;
                    if (obj is YsDict)
                        dict = obj as YsDict;
                    else
                        dict = UtilFunc.GetParentByType(obj._parent, YsDict) as YsDict;

                    target_arr.push(dict.D_data);
                    target_name_arr.push('dict');
                }
                else if (item_text == 'windows')
                {
                    var wnd:YsTitleWindow = UtilFunc.GetParentByType(obj._parent, YsTitleWindow) as YsTitleWindow;
                    target_arr.push(wnd.D_data);
                    target_name_arr.push('windows');
                }
                else if (item_text == 'pod')
                {
                    var pod:YsPod = UtilFunc.GetParentByType(obj._parent, YsPod) as YsPod;
                    target_arr.push(pod.D_data);
                    target_name_arr.push('pod');
                }
                else if (item_text == 'parent')
                {
                    target_arr.push(obj._parent.D_data);
                    target_name_arr.push('parent');
                }
                else if (item_text == 'pool')
                {
                    var pool:Pool = Application.application._pool;
                    target_arr.push(pool.D_data);
                    target_name_arr.push('pool');
                }
            }
        }

        public function GetAllTarget():Array
        {
            return target_arr;
        }

        public function GetAllTargetName():Array
        {
            return target_name_arr;
        }

    }
}
