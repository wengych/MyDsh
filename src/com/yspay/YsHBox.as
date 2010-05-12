package com.yspay
{
    import com.yspay.pool.Pool;

    import flash.display.DisplayObjectContainer;

    import mx.containers.HBox;
    import mx.core.Application;

    public class YsHBox extends HBox implements YsControl
    {
        protected var _pool:Pool;
        protected var _parent:DisplayObjectContainer;
        protected var _xml:XML;

        public function YsHBox(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function Init(xml:XML):void
        {
            _xml = xml;
            if (_xml.@line != undefined)
            {
                if (_xml.@line == "bottom")
                {
                    _parent.addChild(this);
                }
                else
                {
                    _parent.addChildAt(this, 0);
                }
            }
            else
            {
                _parent.addChild(this);
            }


            percentWidth = 100;
            setStyle('borderStyle', 'solid');
            setStyle('fontSize', '12');

            var child_name:String;
            for each (var child:XML in _xml.elements())
            {
                child_name = child.name().toString().toLowerCase();

                // 查表未发现匹配类型
                if (!YsMaps.ys_type_map.hasOwnProperty(child_name))
                    return;

                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }
        }


    }
}