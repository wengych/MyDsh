package com.yspay.YsData
{
    import com.yspay.YsControls.YsPod;


    public dynamic class Tran
    {
        public var cont:int;

        public function Tran()
        {
            cont = 10000;
        }

        public function CreatePData(pod:YsPod):int
        {
            var obj:Object = new PData;
            this[cont] = obj;
            cont++;

            return (cont - 1);
        }

        public function getPData(index:int):PData
        {
            return this[index];
        }
    }
}