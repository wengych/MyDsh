package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;

    import mx.containers.HBox;
    import mx.controls.DataGrid;
    import mx.core.Application;
    import mx.events.FlexEvent;


    public class YsHBox extends HBox implements YsControl
    {
        protected var _pool:Pool;
        protected var _xml:XML;
        public var _parent:DisplayObjectContainer;
        public var D_data:PData = new PData;

        public function YsHBox(parent:DisplayObjectContainer)
        {
            super();
            _pool = Application.application._pool;
            _parent = parent;
        }

        protected override function measure():void
        {
            if (UtilFunc.HasChildByType(this, DataGrid))
                this.percentHeight = 100;
            super.measure();
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function GetSaveXml():XML
        {
            if (_xml.@save == 'false')
                return null;
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
    }
}