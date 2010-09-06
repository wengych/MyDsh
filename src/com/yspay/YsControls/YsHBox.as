package com.yspay.YsControls
{
    import com.yspay.YsData.PData;
    import com.yspay.pool.Pool;
    import com.yspay.util.UtilFunc;

    import flash.display.DisplayObjectContainer;

    import mx.containers.HBox;
    import mx.controls.DataGrid;
    import mx.core.FlexGlobals;
    import mx.core.IUIComponent;
    import mx.core.UIComponent;


    public class YsHBox extends HBox implements YsControl
    {
        protected var _pool:Pool;
        protected var _xml:XML;
        public var _parent:DisplayObjectContainer;
        public var D_data:PData = new PData;

        public function YsHBox(parent:DisplayObjectContainer)
        {
            super();
            _pool = FlexGlobals.topLevelApplication._pool;
            _parent = parent;
            id = 'YsHBox';
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
            UtilFunc.InitAttrbutes(YsMaps.vbox_attrs, this, _xml);
            UtilFunc.InitChild(this, _xml);
        }

        public function Print(print_container:UIComponent, print_call_back:Function):UIComponent
        {
            var print_area:UIComponent;
            if (print_container == null)
                print_area = print_call_back();
            else
                print_area = print_container;

            var hbox:HBox = new HBox;
            //hbox.setStyle('border', 'none');
            //hbox.setStyle('borderColor', '#ffffff');

            for each (var child:Object in this.getChildren())
            {
                if (child is YsControl)
                    child.Print(hbox, print_call_back);
            }

            print_area.addChild(hbox);
            return print_area;
        }

        public function GetId():String
        {
            return id;
        }
    }
}
