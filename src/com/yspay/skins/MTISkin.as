////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.yspay.skins
{

    import com.yspay.YsControls.YsTextInput;

    import flash.display.Graphics;

    import mx.core.mx_internal;
    import mx.skins.ProgrammaticSkin;

    use namespace mx_internal;

    /**
     *  The skin for the background of the Masked Text Input control.
     */
    public class MTISkin extends ProgrammaticSkin
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        /**
         *  Constructor.
         */
        public function MTISkin()
        {
            super();
        }

        //--------------------------------------------------------------------------
        //
        //  Overridden methods
        //
        //--------------------------------------------------------------------------

        /**
         *  @private
         */
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);

            var fSize:Number = getStyle("fontSize");
            var cellWidth:Number = 0;
            if (parent is YsTextInput)
                cellWidth = YsTextInput(parent).measureText("W").width;

            var g:Graphics = this.graphics;
            g.clear();

            var cellColor:Number = getStyle("cellColor");
            if (!cellColor)
            {
                if (YsTextInput(parent).required)
                    cellColor = 0xFF0000;
                else
                    cellColor = 0x008CEA;
            }

            g.lineStyle(0, 0xFFFFFF, 1);
            g.beginFill(cellColor, 0.20);
            var x1:Number = 3;
            var y1:Number = 2;

            switch (name)
            {
                case "MTISkin":
                    if (parent is YsTextInput)
                    {
                        for (var i:int = 0; i < YsTextInput(parent).maskMap.length; i++)
                        {
                            if (YsTextInput(parent).maskMap[i][1] && YsTextInput(parent)._working[i] == " ")
                            {
                                g.drawRect(x1, y1, cellWidth, YsTextInput(parent).height - 5);
                                x1 = x1 + cellWidth;
                            }
                            else
                            {
                                x1 = x1 + cellWidth;
                            }
                        }
                        g.endFill();
                    }
                    break;
            }
        }

    }
}