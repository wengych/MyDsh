package com.yspay.util
{

    public class Lexical
    {
        protected var le_arr:Array;

        public function Lexical(str:String, sep:String='.')
        {
            le_arr = new Array;

            str.search(sep)
        }

        public function GetNext():String
        {

        }
    }
}