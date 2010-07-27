package com.yspay.util
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsControls.YsDgListItem;
    import com.yspay.YsControls.YsDict;

    import flash.display.DisplayObject;

    import mx.core.IFactory;

    public class YsClassFactory implements IFactory
    {
        public var generator:Class;
        protected var xml:XML;
        protected var parent:DisplayObject;

        public function YsClassFactory(_generator:Class, _parent:DisplayObject, _xml:XML)
        {
            generator = _generator;
            parent = _parent;
            xml = new XML(_xml);
        }

        public function newInstance():*
        {
            trace('YsClassFactory::newInstance() ', parent);
            /*
               var dict:YsDict = parent as YsDict;
               var dg:YsDataGrid; // = dict._parent as YsDataGrid;
               if (dict != null &&
               (dg = dict._parent as YsDataGrid) != null)
               {
               return new_dgItem(dict, dg);
               }
             else*/
            {
                var instance:Object = new generator(parent);
                instance.Init(xml);

                return instance;
            }
        }

        // YsDataGrid重新建立List后选中旧选中项
        protected function new_dgItem(dict:YsDict, dg:YsDataGrid):YsDgListItem
        {
            var instance:YsDgListItem = new generator(parent);

            var key:String = dict.dict.name;
            var label_key:String = key + '_list_label';
            var old_prompt:String = dg.selectedItem[label_key];
            var idx:int = -1;

            instance.Init(xml);
            for (var dp_idx:int = 0; dp_idx < instance.dataProvider.length; ++dp_idx)
            {
                var item:Object = instance.dataProvider[dp_idx];
                if (item[key] != undefined &&
                    item[key] == dg.selectedItem[key])
                {
                    idx = dp_idx;
                    break;
                }
            }

            instance.prompt = old_prompt;
            // instance.selectedIndex = idx;
            // instance.selectedItem;
            return instance;
        }
    }
}
