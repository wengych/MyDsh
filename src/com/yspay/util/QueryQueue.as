package com.yspay.util
{
    import com.yspay.pool.DBTable;

    import flash.events.EventDispatcher;
    import flash.external.ExternalInterface;


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

        public function Do(query_type:Class, count:int=5):int
        {
            var rtn:int = 0;
            var query_cond_is_query_key:Boolean = true;

            while (--count >= 0)
            {
                if (queue.length == 0)
                    break;

                var query_key:String = queue.pop();
                table.AddQuery(query_key, query_type, query_key, disp);
                table.DoQuery(query_key);

                ++rtn;
            }

            return rtn;
        }

    }
}