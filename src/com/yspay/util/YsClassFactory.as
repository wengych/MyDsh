package com.yspay.util
{
    import flash.display.DisplayObject;

    import mx.core.IFactory;

    public class YsClassFactory implements IFactory
    {
        protected var generator:Class;
        protected var xml:XML;
        protected var parent:DisplayObject;

        public function YsClassFactory(_generator:Class, _parent:DisplayObject, _xml:XML)
        {
            generator = _generator;
            parent = _parent;
            xml = new XML(_xml);
        }

        public function newInstance():*
        {

            var instance:Object = new generator(parent);
            instance.Init(xml);

            return instance;
        }

    }
}