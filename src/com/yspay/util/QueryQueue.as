package com.yspay.util
{
    import com.yspay.pool.DBTable;
    import com.yspay.pool.Query;

    import flash.events.EventDispatcher;


    public class QueryQueue
    {
        protected var queue:Array;
        protected var table:DBTable;
        protected var disp:EventDispatcher;

        public function QueryQueue(db_table:DBTable, event_disp:EventDispatcher)
        {
            table = db_table;
            disp = event_disp;
            queue = new Array;
        }

        public function Add(key_name:String):void
        {
            queue.push(key_name);
        }

        public function Do(query_type:Class, query_cond:*=null, count:int=5):int
        {
            var rtn:int = 0;
            while (--count >= 0)
            {
                if (queue.length == 0)
                    break;

                var query_key:String = queue.pop();
                if (query_cond == null)
                    query_cond = query_key;
                table.AddQuery(query_key, query_type, query_cond, disp);
                table.DoQuery(query_key);

                ++rtn;
            }

            return rtn;
        }

    }
}