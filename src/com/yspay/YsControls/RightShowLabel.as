package com.yspay.YsControls
{
    import flash.text.TextLineMetrics;

    import mx.controls.Label;

    //此类用于自动截取label文本时从右侧开始
    public class RightShowLabel extends Label
    {
        public function RightShowLabel()
        {
            super();
            this.truncateToFit = false;
        }
        private var hasToolip:Boolean = false;

        protected override function commitProperties():void
        {
            super.commitProperties();
            this.callLater(redraw);
        }

        private function redraw():void
        {
            var s:String = text;
            var t:TextLineMetrics = this.measureText(s);
            var i:int = 0;
            while (this.width - 10 < t.width)
            {
                t = this.measureText(s.substr(i));
                i++;
            }
            if (i == 0)
                return;
            else
            {
                if (!hasToolip)
                {
                    this.toolTip = this.text;
                    hasToolip = true;
                }
                this.text = '...' + s.substr(i);
            }
        }
    }
}