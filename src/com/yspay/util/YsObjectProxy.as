package com.yspay.util
{
    import flash.utils.flash_proxy;

    import mx.utils.ObjectProxy;
    import mx.utils.object_proxy;

    use namespace object_proxy;
    use namespace flash_proxy;

    public dynamic class YsObjectProxy extends ObjectProxy
    {
        public function YsObjectProxy(item:Object=null, uid:String=null, proxyDepth:int=-1)
        {
            super(item, uid, proxyDepth);
        }

        override flash_proxy function getProperty(name:*):*
        {
            var result:* = super.getProperty(name);
            if (result is Array)
            {
                result = object_proxy::getComplexProperty(name, result);
            }

            return result;
        }
    }
}