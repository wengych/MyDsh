package com.yspay.util
{
    import com.yspay.YsControls.YsDataGrid;
    import com.yspay.YsData.PData;
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Pool;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.net.SharedObject;
    import flash.system.Capabilities;
    import flash.utils.getDefinitionByName;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.Application;
    import mx.core.Container;

    public class UtilFunc
    {

        private static const LOGIN_SHAREDOBJECT:String = "yspay_login_info";

        public function UtilFunc()
        {
        }

        public static function GetParentByTypeName(container:Container, type_name:String):*
        {
            var parent:* = null;

            var parent_type:Class = getDefinitionByName(type_name) as Class;
            if (parent_type == null)
                return parent;

            while (container != null)
            {
                if (container is parent_type)
                {
                    parent = container as parent_type;
                    break;
                }
                container = container.parent as Container;
            }
            return parent;
        }

        public static function YsGetParentByType(ys_obj:Object, ys_type:Class):*
        {
            var parent:* = null;

            while (ys_obj != null)
            {
                if (ys_obj is ys_type)
                {
                    parent = ys_obj;
                    break;
                }

                if (ys_obj.hasOwnProperty('_parent'))
                    ys_obj = ys_obj._parent;
                else
                    ys_obj = parent = null;
            }

            return parent;
        }

        public static function GetParentByType(container:DisplayObjectContainer,
                                               parent_type:Class):*
        {
            var parent:* = null;

            while (container != null)
            {
                if (container is parent_type)
                {
                    parent = container as parent_type;
                    break;
                }

                container = container.parent;
            }

            return parent;
        }

        //lzy   判断 container及子显示列表中是否含有child_type类型对象
        public static function HasChildByType(container:Container, child_type:Class):Boolean
        {

            if (container is child_type)
            {
                return true;
            }
            for each (var o:DisplayObject in container.getChildren())
            {
                if (o is child_type)
                    return true;
                else
                {
                    if (o is Container)
                    {
                        if (UtilFunc.HasChildByType(o as Container, child_type))
                            return true;
                    }
                }
            }
            return false;
        }

        //lzy
        public static function getSharedObjectInstance(name:String):SharedObject
        {
            return SharedObject.getLocal(name);

        }

        public static function ArrayColAddEmptyItems(arr:ArrayCollection, count:int):void
        {
            if (count <= 0)
                return;

            for (var i:int = 0; i <= count; ++i)
            {
                arr.addItem(new Object);
            }
        }

        // 替换链接为完整xml
        public static function FullXml(xml:XML):XML
        {
            var rtn:XML = new XML(xml);
            var pool:Pool = Application.application._pool;

            var search_str:String = '://';
            var url:String = xml.text();
            var idx:int = url.search(search_str);
            if (idx > 0)
            {
                var query_key:String = url.substr(0, idx).toLocaleUpperCase();
                var obj_key:String = url.substr(idx + search_str.length);
                if (pool.info[query_key][obj_key] == undefined)
                {
                    // Alert.show('error！');
                    Alert.show('无dts项,type[' + query_key + '], key[' + obj_key + ']');
                    return null;
                }
                var dts_no:String = pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = pool.dts as DBTable;
                //var temp:XML = new XML(dts[dts_no].__DICT_XML);
                if (!(dts.hasOwnProperty(dts_no)))
                {
                    Alert.show('dts查询出错，无此dts号: ' + dts_no);
                    return null;
                }
                if (!(dts[dts_no].hasOwnProperty('__DICT_XML')))
                {
                    Alert.show('dts查询出错，未找到__DICT_XML属性');
                    return null;
                }
                rtn = new XML(dts[dts_no].__DICT_XML);

                for each (var attr:XML in xml.attributes())
                {
                    rtn.@[attr.name().toString()] = attr.toString();
                }
                for each (var val:XML in xml.elements())
                {
                    rtn.appendChild(val);
                }
            }
            return rtn;
        }

        /**
         *
         * @return 返回数据下标，返回-1表示取全部
         */
        public static function GetDataIndex(from_pdata:PData, dict_name:String, ctrl:Object):int
        {
            // 处理datagrid时,判断当前service的父事件或按钮是否为datagrid中的按钮或事件
            // 若为datagrid中的事件或按钮,则只取当前选中行的数据
            var dg:YsDataGrid =
                UtilFunc.YsGetParentByType(ctrl._parent,
                                           YsDataGrid) as YsDataGrid;
            // 非DataGrid子项,取全部
            if (dg == null)
                return -1;

            // DataGrid的ToData中无此字典项,取全部
            if (dg.toDataObject[dict_name] == undefined)
                return -1;

            var arr:Array = dg.toDataObject[dict_name].GetAllTarget();
            if (arr.indexOf(from_pdata) < 0)
                return -1;

            return dg.selectedIndex;

            return -1;
        }

        public static function getRatio():Array
        {
            var resX:int = Capabilities.screenResolutionX;
            var resY:int = Capabilities.screenResolutionY;
            return [resX, resY];
        }

    }
}