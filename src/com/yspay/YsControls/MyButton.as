package com.yspay.YsControls
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextLineMetrics;

    import mx.controls.Button;
    import mx.controls.TextInput;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.managers.IFocusManager;

    public class MyButton extends UIComponent
    {
        protected var ti:TextInput;
        protected var btn:Button;
        protected var _label:String;

        public var isEdit:Boolean;

        public function MyButton()
        {
            super();
            ti = new TextInput;
            btn = new Button;
            isEdit = false;
            btn.doubleClickEnabled = true
            btn.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
            ti.addEventListener(FlexEvent.ENTER, enterHandler);
        }

        private function enterHandler(event:FlexEvent):void
        {
            isEdit = !isEdit;
            this._label = ti.text;
            invalidateProperties();
            focusManager.setFocus(btn);
            focusManager.hideFocus();
            stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
        }

        private function stageUpHandler(event:Event):void
        {
            if (event.target.parent == ti)
                return;
            if (isEdit)
            {
                isEdit = !isEdit;
                this._label = ti.text;
                invalidateProperties();
                focusManager.setFocus(btn);
                focusManager.hideFocus();
            }
            stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
        }

        private function doubleClickHandler(event:MouseEvent):void
        {
            isEdit = !isEdit;
            ti.setFocus();
            stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
            invalidateProperties();

        }

        protected override function createChildren():void
        {
            super.createChildren();
            addChild(ti);
            addChild(btn);
        }

        protected override function commitProperties():void
        {
            super.commitProperties();
            btn.label = this._label;
            ti.text = this._label;
            invalidateSize();
            invalidateDisplayList();
        }

        protected override function measure():void
        {
            super.measure();
            var lineMetrics:TextLineMetrics;
            lineMetrics = ti.measureText(ti.text);
            this.measuredHeight = lineMetrics.height + 4 > 20 ? lineMetrics.height + 4 : 20;
            var temp:int = lineMetrics.width + btn.getStyle("paddingLeft") + btn.getStyle("paddingRight") + 15;
            this.measuredWidth = temp > 50 ? temp : 50;
        }

        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {

            super.updateDisplayList(unscaledWidth, unscaledHeight);
            if (!isEdit)
            {
                this.graphics.clear();
                ti.move(0, 0);
                btn.move(0, 0);
                btn.setActualSize(unscaledWidth, unscaledHeight);
                ti.setActualSize(0, 0);
            }
            else
            {
                ti.move(4, 4);
                btn.move(0, 0);
                this.graphics.clear();
                this.graphics.beginFill(0);
                this.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
                ti.setActualSize(unscaledWidth, unscaledHeight);
                btn.setActualSize(unscaledWidth, unscaledHeight);
                this.graphics.moveTo(4, 4);
                this.graphics.drawRect(4, 4, unscaledWidth, unscaledHeight);
                this.setChildIndex(btn, 0);
            }

        }

        public function set label(value:String):void
        {
            this._label = value;
            this.invalidateProperties();
        }

        public function get label():String
        {
            return this._label;
        }
    }
}