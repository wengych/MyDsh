package com.yspay.YsControls
{
    import mx.controls.List;
    import mx.core.IFlexDisplayObject;
    import mx.managers.IFocusManagerContainer;

    public class MyList extends List implements IFocusManagerContainer
    {
        public function MyList()
        {
            super();
        }

        public function get defaultButton():IFlexDisplayObject
        {
            return null;
        }

        public function set defaultButton(value:IFlexDisplayObject):void
        {
        }

        protected override function measure():void
        {
            super.measure();
            this.measuredHeight = this.measuredHeight > 200 ? 200 : this.measuredHeight;
        }
    }
}