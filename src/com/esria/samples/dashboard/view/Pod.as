/*
 * Container which holds PodContentBase subclasses.
 */

package com.esria.samples.dashboard.view
{
    import com.esria.samples.dashboard.events.PodStateChangeEvent;

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.HBox;
    import mx.containers.Panel;
    import mx.controls.Button;
    import mx.events.DragEvent;

// Drag events.
    [Event(name="dragStart", type="mx.events.DragEvent")]
    [Event(name="dragComplete", type="mx.events.DragEvent")]
// Resize events.
    [Event(name="minimize", type="com.esria.samples.dashboard.events.PodStateChangeEvent")]
    [Event(name="maximize", type="com.esria.samples.dashboard.events.PodStateChangeEvent")]
    [Event(name="restore", type="com.esria.samples.dashboard.events.PodStateChangeEvent")]
    [Event(name="close", type="com.esria.samples.dashboard.events.PodStateChangeEvent")]

    public class Pod extends Panel
    {
        public static const MINIMIZED_HEIGHT:Number = 22;
        public static const WINDOW_STATE_DEFAULT:Number = -1;
        public static const WINDOW_STATE_MINIMIZED:Number = 0;
        public static const WINDOW_STATE_MAXIMIZED:Number = 1;

        public var windowState:Number; // Corresponds to one of the WINDOW_STATE variables.
        public var index:Number; // Index within the layout.

        private var controlsHolder:HBox;
        private var minimizeButton:Button;
        public var maximizeRestoreButton:Button;
        private var closeButton:Button;

        private var headerDivider:Sprite;

        // Variables used for dragging the pod.
        private var dragStartMouseX:Number;
        private var dragStartMouseY:Number;
        private var dragStartX:Number;
        private var dragStartY:Number;
        private var dragMaxX:Number;
        private var dragMaxY:Number;

        private var _showControls:Boolean;
        private var _showControlsChanged:Boolean;

        private var _maximize:Boolean;
        private var _maximizeChanged:Boolean;

        public function Pod()
        {
            super();
            doubleClickEnabled = true;
            setStyle("titleStyleName", "podTitle");

            windowState = WINDOW_STATE_DEFAULT;
            //   horizontalScrollPolicy = "off";
        }

        override protected function createChildren():void
        {
            super.createChildren();

            if (!headerDivider)
            {
                headerDivider = new Sprite();
                titleBar.addChild(headerDivider);
            }

            if (!controlsHolder)
            {
                controlsHolder = new HBox();
                controlsHolder.setStyle("paddingRight", getStyle("paddingRight"));
                controlsHolder.setStyle("horizontalAlign", "right");
                controlsHolder.setStyle("verticalAlign", "middle");
                controlsHolder.setStyle("horizontalGap", 3);
                rawChildren.addChild(controlsHolder);
            }

            if (!minimizeButton)
            {
                minimizeButton = new Button();
                minimizeButton.width = 14;
                minimizeButton.height = 14;
                minimizeButton.styleName = "minimizeButton";
                controlsHolder.addChild(minimizeButton);
            }

            if (!maximizeRestoreButton)
            {
                maximizeRestoreButton = new Button();
                maximizeRestoreButton.width = 14;
                maximizeRestoreButton.height = 14;
                maximizeRestoreButton.styleName = "maximizeRestoreButton";
                controlsHolder.addChild(maximizeRestoreButton);
            }
            if (!closeButton)
            {
                closeButton = new Button();
                closeButton.width = 14;
                closeButton.height = 14;
                closeButton.styleName = "closeButton";
                controlsHolder.addChild(closeButton);
            }

            addEventListeners();
        }

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            // Shift the divider one pixel up if minimized so there isn't a gap between the left and right borders.
            // The bottom border is removed if minimized.
            var deltaY:Number = windowState == WINDOW_STATE_MINIMIZED ? -1 : 0;
            var graphics:Graphics = headerDivider.graphics;
            graphics.clear();
            graphics.lineStyle(1, getStyle("borderColor"));
            graphics.moveTo(1, titleBar.height + deltaY);
            graphics.lineTo(titleBar.width, titleBar.height + deltaY);
            controlsHolder.y = titleBar.y;
            controlsHolder.width = unscaledWidth;
            controlsHolder.height = titleBar.height;

            titleTextField.width = titleBar.width - getStyle("paddingLeft") - getStyle("paddingRight");
        }

        private function addEventListeners():void
        {
            titleBar.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownTitleBar);
            titleBar.addEventListener(MouseEvent.DOUBLE_CLICK, onClickMaximizeRestoreButton);
            titleBar.addEventListener(MouseEvent.CLICK, onClickTitleBar);
            minimizeButton.addEventListener(MouseEvent.CLICK, onClickMinimizeButton);
            maximizeRestoreButton.addEventListener(MouseEvent.CLICK, onClickMaximizeRestoreButton);
            closeButton.addEventListener(MouseEvent.CLICK, onClickCloseButton);

            addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }

        private function onMouseDown(event:Event):void
        {
            // Moves the pod to the top of the z-index.
            parent.setChildIndex(this, parent.numChildren - 1);
        }

        private function onClickMinimizeButton(event:MouseEvent):void
        {
            dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.MINIMIZE));
            // Set the state after the event is dispatched so the old state is still available.
            minimize();
        }

        public function minimize():void
        {
            // Hide the bottom border if minimized otherwise the headerDivider and bottom border will be staggered. 
            setStyle("borderSides", "left top right");
            windowState = WINDOW_STATE_MINIMIZED;
            height = MINIMIZED_HEIGHT;
            showControls = false;
        }

        private function onClickMaximizeRestoreButton(event:MouseEvent=null):void
        {
            showControls = true;
            if (windowState == WINDOW_STATE_DEFAULT)
            {
                dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.MAXIMIZE));
                // Call after the event is dispatched so the old state is still available.
                maximize();
            }
            else
            {
                dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.RESTORE));
                // Set the state after the event is dispatched so the old state is still available.
                windowState = WINDOW_STATE_DEFAULT;
                maximizeRestoreButton.selected = false;
            }
        }

        private function onClickCloseButton(event:MouseEvent):void
        {
            dispatchEvent(new PodStateChangeEvent(PodStateChangeEvent.CLOSE));
        }

        public function maximize():void
        {
            windowState = WINDOW_STATE_MAXIMIZED;

            _maximize = true;
            _maximizeChanged = true;
        }

        private function onClickTitleBar(event:MouseEvent):void
        {
            if (windowState == WINDOW_STATE_MINIMIZED)
            {
                // Add the bottom border back in case we were minimized.
                setStyle("borderSides", "left top right bottom");
                onClickMaximizeRestoreButton();
            }
        }

        private function onMouseDownTitleBar(event:MouseEvent):void
        {
            if (windowState == WINDOW_STATE_DEFAULT) // Only allow dragging if we are in the default state.
            {
                dispatchEvent(new DragEvent(DragEvent.DRAG_START));
                dragStartX = x;
                dragStartY = y;
                dragStartMouseX = parent.mouseX;
                dragStartMouseY = parent.mouseY;
                dragMaxX = parent.width - width;
                dragMaxY = parent.height - height;

                // Use the stage so we get mouse events outside of the browser window.
                stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
                stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            }
        }

        private function onMouseMove(e:MouseEvent):void
        {
            // Make sure we don't go off the screen on the right.
            var targetX:Number = Math.min(dragMaxX, dragStartX + (parent.mouseX - dragStartMouseX));
            // Make sure we don't go off the screen on the left.
            x = Math.max(0, targetX);

            // Make sure we don't go off the screen on the bottom.
            var targetY:Number = Math.min(dragMaxY, dragStartY + (parent.mouseY - dragStartMouseY));
            // Make sure we don't go off the screen on the top.
            y = Math.max(0, targetY);
        }

        private function onMouseUp(event:MouseEvent):void
        {
            dispatchEvent(new DragEvent(DragEvent.DRAG_COMPLETE));

            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        }

        public function set showControls(value:Boolean):void
        {
            _showControls = value;
            _showControlsChanged = true;
            invalidateProperties();
        }

        override protected function commitProperties():void
        {
            super.commitProperties();

            if (_showControlsChanged)
            {
                controlsHolder.visible = _showControls;
                _showControlsChanged = false;
            }

            if (_maximizeChanged)
            {
                maximizeRestoreButton.selected = _maximize;
                _maximizeChanged = false;
            }
        }
    }
}