package com.yspay
{
    import com.yspay.event_handlers.EventHandlerFactory;
    import com.yspay.pool.Pool;

    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;

    import mx.containers.HBox;
    import mx.core.Application;

    public class YsHBox extends HBox implements YsControl
    {
        protected var _pool:Pool;
        protected var _parent:DisplayObjectContainer;

        public function YsHBox(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;
        }

        public function Init(xml:XML):void
        {
            if (xml.@line != undefined)
            {
                if (xml.@line == "bottom")
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
            for each (var child:XML in xml.elements())
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