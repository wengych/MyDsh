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
        protected var arr:Array = new Array;

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
                    arr.push(dict.D_data);
                }
                else if (item_text == 'windows')
                {
                    var wnd:YsTitleWindow = UtilFunc.GetParentByType(obj._parent, YsTitleWindow) as YsTitleWindow;
                    arr.push(wnd.D_data);
                }
                else if (item_text == 'pod')
                {
                    var pod:YsPod = UtilFunc.GetParentByType(obj._parent, YsPod) as YsPod;
                    arr.push(pod.D_data);
                }
                else if (item_text == 'parent')
                {
                    arr.push(obj._parent.D_data);
                }
                else if (item_text == 'pool')
                {
                    var pool:Pool = Application.application._pool;
                    arr.push(pool.D_data);
                }
            }
        }

        public function GetAllTarget():Array
        {
            return arr;
        }

    }
}