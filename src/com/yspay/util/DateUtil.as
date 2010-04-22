package com.yspay.util
{

    public class DateUtil
    {
        public function DateUtil()
        {
        }

        public static function doubleString(arg:int):String
        {
            var str:String = arg.toString();
            if (str.length == 1)
            {
                str = "0" + str;
            }
            return str;
        }
    }
}