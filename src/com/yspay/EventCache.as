package com.yspay
{
    import com.yspay.events.EventCacheComplete;
    import com.yspay.pool.*;
    import com.yspay.util.QueryQueue;

    import flash.events.EventDispatcher;

    import mx.controls.Alert;
    import mx.core.Application;

    public class EventCache extends EventDispatcher
    {
        protected var _pool:Pool;
        protected var _disp:EventDispatcher;
        protected var cache_type_map:Object;
        protected var dts_key_table:Object;
        protected var check_comp_flag:Boolean;
        protected var cache_obj:Object;
        protected var count:int;
        protected var cache_xml:XML;
        protected var query_queue:QueryQueue;

        public function EventCache(disp:EventDispatcher) //, target:IEventDispatcher=null)
        {
            // super(target);
            _disp = disp;
            _pool = Application.application._pool;
            cache_obj = new Object;
            dts_key_table = new Object;
            check_comp_flag = false;

            cache_type_map =
                {
                    'SERVICES': true,
                    'DICT': true
                };

            var dts:DBTable = _pool.dts as DBTable;
            query_queue = new QueryQueue(dts, this);
            this.addEventListener(dts.select_event_name, QueryCallBack);
        }

        protected function CacheComplete():Boolean
        {
            var rtn:Boolean = true;

            if (check_comp_flag == true)
            {
                return false;
            }
            for (var key:String in cache_obj)
            {
                if (cache_obj[key] == false)
                {
                    rtn = false;
                    break;
                }
            }
            check_comp_flag = rtn;

            return rtn;
        }

        public function DoCache(xml_str:String):void
        {
            cache_xml = new XML(xml_str);

            DoCacheFunc(cache_xml);
        }

        protected function DoCacheFunc(xml:XML):void
        {
            Cache(xml);

            if (0 < query_queue.Do(Query))
                return;

            if (CacheComplete())
            {
                cache_obj = new Object;
                dts_key_table = new Object;
                var e:EventCacheComplete = new EventCacheComplete;
                e.cache_xml = cache_xml;
                e.cache_obj = this;
                _disp.dispatchEvent(e);
            }
        }

        protected function Cache(xml:XML):void
        {
            if (xml == null)
            {
                return;
            }

            if (xml.text().length() > 0)
            {
                var xml_str:String = xml.text().toString();
                if (!cache_obj.hasOwnProperty(xml_str) &&
                    IsLink(xml_str))
                {
                    QueryLink(xml_str);
                }
            }
            for each (var xml_child:XML in xml.elements())
            {
                if (xml_child.children().length() > 0)
                {
                    Cache(xml_child);
                    continue;
                }

                var child_str:String = xml_child.toString();
                if (!IsLink(child_str))
                {
                    continue;
                }
                if (cache_obj[child_str] != undefined)
                {
                    continue;
                }
                QueryLink(child_str);
            }

        }

        protected function QueryLink(link_str:String):void
        {
            var info:DBTable = _pool.info as DBTable;
            var dts:DBTable = _pool.dts as DBTable;

            var link_key:String = GetLinkKey(link_str);
            var link_value:String = GetLinkValue(link_str);

            trace('link_key: ', link_key, ' link_value ', link_value);

            var vv:QueryWithIndex = info[link_key];
            var query_obj:* = vv[link_value];

            if (query_obj != null)
            {
                cache_obj[link_str] = false;
                var dts_no:String = query_obj.Get().DTS;
                dts_key_table[dts_no] = link_str;

                var dts_cache:Object = _pool.dts_cache;
                var dts_xml:String = dts_cache[dts_no];
                if (dts_xml == null)
                {
                    query_queue.Add(dts_no);
                }
                else
                {
                    cache_obj[link_str] = true;
                    dts[dts_no] = dts_cache[dts_no];
                }
            }
            else
            {
                Alert.show(link_str, ' not exist!');
            }
        }

        protected function QueryCallBack(event:DBTableQueryEvent):void
        {
            if (event.error_event != null)
            {
                Alert.show(event.error_event.toString());
                return;
            }
            var dts:DBTable = _pool.dts as DBTable;
            var dts_no:String = event.query_name;

            var link_str:String = dts_key_table[dts_no];
            trace('EventCache: ' + link_str + ' query complete. dts no is ' + dts_no);
            cache_obj[link_str] = true;
            trace('EventCache::dts: ', dts_no);
            trace('EventCache::dts: ', dts[dts_no].__DICT_XML);

            var link_key:String = GetLinkKey(link_str);
            if (cache_type_map[link_key] != undefined &&
                cache_type_map[link_key] == true)
            {
                var enable_cache:Boolean =
                    Application.application.enable_cache.selected;
                if (enable_cache == true)
                    _pool.dts_cache[dts_no] = _pool.dts[dts_no];
            }

            var xml_str:String = dts[dts_no].__DICT_XML;
            DoCacheFunc(new XML(xml_str));

            trace('EventCache::dts: ', dts_no);
            trace('EventCache::dts: ', dts[dts_no].__DICT_XML);
        }

        public function IsLink(link_str:String):Boolean
        {
            if (link_str.search('://') >= 0)
                return true;
            else
                return false;
        }

        public function GetLinkKey(link_str:String):String
        {
            var rtn:String;
            var idx:int = link_str.search('://');

            rtn = link_str.substr(0, idx);
            return rtn.toUpperCase();
        }

        public function GetLinkValue(link_str:String):String
        {
            var rtn:String;
            var idx:int = link_str.search('://') + '://'.length;

            rtn = link_str.substr(idx);
            return rtn;
        }
    }
}
