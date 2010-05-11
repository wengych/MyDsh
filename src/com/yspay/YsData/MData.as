package com.yspay.YsData
{

    public class MData
    {
        public var TRAN:Tran = new Tran;
        public var POOL:Object = new Object;
        public var BUS:Object = new Object;

        public function MData()
        {
            this.POOL.INFO = new Object; // xingj

            this.BUS.MAIN = new Object;
            this.BUS.RECV = new Object;
        }

    }
}