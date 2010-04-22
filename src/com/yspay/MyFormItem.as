package com.yspay
{
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.FormItem;
    import mx.controls.*;
    import mx.core.DragSource;
    import mx.events.FlexEvent;
    import mx.managers.DragManager;

    public class MyFormItem extends FormItem
    {
        private var _descXml:XML;

        public function get descXml():XML
        {
            return this._descXml;
        }

        public function set descXml(value:XML):void
        {
            this._descXml = value;
        }

        public function MyFormItem(completehandler:Boolean=true)
        {
            super();
            this.direction = "horizontal";
            if (completehandler)
                this.addEventListener(FlexEvent.CREATION_COMPLETE, completeHandler);

        }

        private function completeHandler(event:Event):void
        {
            this.itemLabel.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
        }

        private function mouseMoveHandler(event:MouseEvent):void
        {
            var ds:DragSource = new DragSource();
            ds.addData(this, 'self');
            var label:Label = new Label;
            label.text = this.label;
            label.height = 100;
            label.setStyle("fontSize", 12);
            DragManager.doDrag(this, ds, event, label, -event.localX + label.text.length * 5);
        }
    }
}