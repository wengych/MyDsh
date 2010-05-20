package com.yspay.util
{
    import mx.controls.Button;
    import mx.controls.TextInput;

    public class BtnEdit extends TextInput
    {
        public function BtnEdit()
        {
            super();
        }

        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            trace(unscaledWidth);
            trace(unscaledHeight);
            var btn:Button = (this.parent as Button);

            this.width = btn.width;
            this.height = btn.height;
            this.move(btn.x, btn.y);
        }
    }
}