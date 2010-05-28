package com.yspay.util
{
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Pool;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.Application;
    import flash.display.DisplayObjectContainer;
    import mx.core.Container;
    import flash.utils.getDefinitionByName;

    public class UtilFunc
    {
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

    }
}