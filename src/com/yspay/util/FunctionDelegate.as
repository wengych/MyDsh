package com.yspay.util
{

    public class FunctionDelegate
    {
        private var my_arg:Array;
        private var fun:Function;

        public function create(... args):Function
        {
            my_arg = args;
            fun = my_arg.splice(0, 1)[0];
            return _func;
        }

        private function _func(... args):void
        {
            for each (var o:Object in my_arg)
            {
                (args as Array).push(o);
            }
            fun.apply(null, args as Array);
        }

    }
}