package com.yspay.util
{

    public dynamic class AdvanceArray extends Array
    {
        public function AdvanceArray(numElements:int=0)
        {
            super(numElements);
        }

        public function AddEmptyItems(count:int):void
        {
            while (count-- > 0)
                this.push('');
        }

        public function RemoveItems(startPos:int, count:int=-1):void
        {
            if (count < 0)
                this.splice(startPos, this.length - startPos);
            else
                this.splice(startPos, count);
        }

        public function Insert(startPos:int, value:*=null):void
        {
            if (!(value is Array))
                this.splice(startPos, 0, value);
            else
            {
                for each (var v:Object in value)
                    this.splice(startPos++, 0, v);
            }
        }
    }
}