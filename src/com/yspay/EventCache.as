package com.yspay
{
    import com.yspay.events.EventCacheComplete;
    import com.yspay.pool.*;

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    import mx.controls.Alert;

    public class EventCache extends EventDispatcher
    {
        protected var _pool:Pool;

        public function EventCache(pool:Pool, target:IEventDispatcher=null)
        {
            super(target);
            _pool = pool;
            cache_obj = new Object;
            dts_key_table = new Object;

            var dts:DBTable = _pool.dts as DBTable;
            this.addEventListener(dts.select_event_name, QueryCallBack);
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

        public function QueryLink(link_str:String):int
        {
            var info:DBTable = _pool.info as DBTable;
            var dts:DBTable = _pool.dts as DBTable;

            var link_key:String = GetLinkKey(link_str);
            var link_value:String = GetLinkValue(link_str);

            trace('link_key: ', link_key, ' link_value ', link_value);

            var dict:QueryWithIndex = info[link_key];

            var query_obj:* = dict[link_value];
            if (query_obj != null)
            {
                var dts_no:String = query_obj.Get().DTS;
                dts_key_table[dts_no] = link_str;

                //var dts_no:String = info[link_key][link_value].Get().DTS;

                dts.AddQuery(dts_no, Query, dts_no, this);
//                if (link_key == 'TRAN')
//                    dts.DoQuery(dts_no, true);
//                else
                dts.DoQuery(dts_no);

                return 1;
            }

            return 0;
        }

        public function Cache(xml:XML):int
        {
            var rtn:int = 0;

            if (xml == null)
            {
                return rtn;
            }

            if (xml.children().length() == 0)
            {
                rtn = QueryLink(xml.toString());

                return rtn;
            }

            if (xml.text().length() > 0)
            {
                var xml_str:String = xml.text().toString();
                if (!cache_obj.hasOwnProperty(xml_str) &&
                    IsLink(xml_str))
                {
                    rtn += QueryLink(xml_str);
                    cache_obj[xml_str] = false;
                }
            }

            for each (var xml_child:XML in xml.elements())
            {
                if (xml_child.children().length() > 0)
                {
                    rtn += Cache(xml_child);
                    continue;
                }

                if (!IsLink(xml_child) ||
                    cache_obj.hasOwnProperty(xml_child))
                {
                    continue;
                }

                var child_str:String = xml_child.toString();
                rtn += QueryLink(child_str);
                cache_obj[child_str] = false;
            }

            return rtn;
        }

        protected var dts_key_table:Object;
        protected var cache_obj:Object;
        protected var count:int;
        protected var disp:EventDispatcher;
        protected var cache_xml:XML;

        protected function CacheComplete():Boolean
        {
            // return true if all key in cache_obj is true;
            // return false otherwise
            var rtn:Boolean = true;
            for (var key:String in cache_obj)
            {
                if (cache_obj[key] == false)
                {
                    rtn = false;
                    trace('EventCache: ' + key + ' is false.');
                    break;
                }
            }

            return rtn;
        }

        public function DoCache(xml_str:String, _disp:EventDispatcher):void
        {
            disp = _disp;
            cache_xml = new XML(xml_str);
            count = Cache(new XML(xml_str));

            trace('EventCache.count ', count);

            // if (count == 0)
            if (CacheComplete())
            {
                var e:EventCacheComplete = new EventCacheComplete;
                e.cache_xml = cache_xml;
                e.cache_obj = this;
                disp.dispatchEvent(e);
            }
        }

        public function QueryCallBack(event:DBTableQueryEvent):void
        {
            if (event.error_event != null)
            {
                Alert.show(event.error_event.toString());
            }

            if (count == 0)
                return;
            // var xml:XML = event.target.xml as XML;
            var dts:DBTable = _pool.dts as DBTable;
            var xml:XML = new XML(dts[event.query_name].__DICT_XML);
            count += Cache(xml);

            --count;

            var link_str:String = dts_key_table[event.query_name];
            trace('EventCache: ' + link_str + ' query complete');
            cache_obj[link_str] = true;

            // if (count == 0)
            if (CacheComplete())
            {
                var e:EventCacheComplete = new EventCacheComplete;
                e.cache_xml = cache_xml;
                e.cache_obj = this;
                disp.dispatchEvent(e);
            }
        }
    }
}