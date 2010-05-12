package com.yspay.util
{
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Pool;

    import mx.controls.Alert;
    import mx.core.Application;

    public class UtilFunc
    {
        public function UtilFunc()
        {
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
                    Alert.show('error！');
                    return null;
                }
                var dts_no:String = pool.info[query_key][obj_key].Get().DTS;
                var dts:DBTable = pool.dts as DBTable;
                //var temp:XML = new XML(dts[dts_no].__DICT_XML);
                rtn = new XML(dts[dts_no].__DICT_XML);

                for each (var attr:XML in xml.attributes())
                {
                    trace(attr);
                    rtn.@[attr.name().toString()] = attr.toString();
                }
            }

            return rtn;
        }

    }
}