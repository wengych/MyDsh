package com.yspay.YsControls
{
    import com.yspay.pool.Pool;
    import com.yspay.YsData.PData;

    import flash.display.DisplayObjectContainer;

    import mx.containers.VBox;
    import mx.core.Application;

    public class YsVBox extends VBox implements YsControl
    {
        protected var _pool:Pool;
        protected var _xml:XML;
        public var _parent:DisplayObjectContainer;
        public var D_data:PData = new PData;

        public function YsVBox(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;
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
                    continue;

                var child_ctrl:YsControl = new YsMaps.ys_type_map[child_name](this);
                child_ctrl.Init(child);
            }
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function GetSaveXml():XML
        {
            return null;
        }

        public function GetLinkXml():XML
        {
            return null;
        }

        public function get type():String
        {
            return _xml.name().toString();
        }

    }
}