package com.yspay
{
    import com.yspay.events.EventCacheComplete;
    import com.yspay.pool.*;

    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;

    public class EventCache extends EventDispatcher
    {
        protected var _pool:Pool;

        public function EventCache(pool:Pool, target:IEventDispatcher=null)
        {
            super(target);
            _pool = pool;

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

            var dict:QueryWithIndex = info[link_key];

            var query_obj:* = dict[link_value];
            if (query_obj != null)
            {
                var dts_no:String = query_obj.Get().DTS;

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
                QueryLink(xml.toString());
                rtn = 1;

                return rtn;
            }

            for each (var xml_child:XML in xml.children())
            {
                if (xml_child.children().length() > 0)
                {
                    rtn += Cache(xml_child);
                    continue;
                }

                if (!IsLink(xml_child))
                {
                    continue;
                }


                rtn += QueryLink(xml_child.toString());
            }

            return rtn;
        }

        protected var count:int;
        protected var disp:EventDispatcher;
        protected var cache_xml:XML;

        public function DoCache(xml_str:String, _disp:EventDispatcher):void
        {
            disp = _disp;
            cache_xml = new XML(xml_str);
            count = Cache(new XML(xml_str));

            if (count == 0)
            {
                var e:EventCacheComplete = new EventCacheComplete;
                e.cache_xml = cache_xml;
                e.cache_obj = this;
                disp.dispatchEvent(e);
            }
        }

        public function QueryCallBack(event:DBTableQueryEvent):void
        {
            // var xml:XML = event.target.xml as XML;
            var dts:DBTable = _pool.dts as DBTable;
            var xml:XML = new XML(dts[event.query_name].__DICT_XML);
            count += Cache(xml);

            --count;

            if (count == 0)
            {
                var e:EventCacheComplete = new EventCacheComplete;
                e.cache_xml = cache_xml;
                e.cache_obj = this;
                disp.dispatchEvent(e);
            }
        }
    }
}