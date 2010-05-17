////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.yspay.YsControls
{

    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.getTimer;

    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.EdgeMetrics;
    import mx.core.IFlexDisplayObject;
    import mx.core.IInvalidating;
    import mx.core.UIComponent;
    import mx.core.UITextField;
    import mx.core.mx_internal;
    import mx.skins.ProgrammaticSkin;
    import mx.skins.RectangularBorder;
    import mx.styles.ISimpleStyleClient;
    import com.yspay.skins.MTISkin;

    use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

    /**
     *  Dispatched when the last character is entered in the
     *  Masked Text Input control through user input.
     *
     *  @eventType flash.events.Event
     *  @tiptext inputMaskEnd event
     */
    [Event(name="inputMaskEnd", type="flash.events.Event")]

//--------------------------------------
//  Styles
//--------------------------------------

    /**
     * The color of the background cell.
     *  @default 0xFF0000 if required property is set, 0x008CEA otherwise
     */
    [Style(name="cellColor", type="uint", format="Color", inherit="no")]

    /**
     * The color of the text when  required property is set,
     *  and the field is left incomplete.
     *  @default 0xFF0000
     */
    [Style(name="errorTextColor", type="uint", format="Color", inherit="no")]

//--------------------------------------
//  Skins
//--------------------------------------

    /**
     *  Name of the class to use as the skin for the background.
     *
     *  @default "com.adobe.flex.extras.controls.skins.MTISkin"
     */
    [Style(name="MTISkin", type="Class", inherit="no")]


    /**
     * 	The Masked Text Input component is a single-line,
     * 	text input field. This component adds support for
     * 	the validation of input against a specified mask expression.
     * 	For using the control, input mask should be provided
     * 	by setting the <code>inputMask</code> property of the
     * 	control. This control shows meaningful behavior only
     * 	when <code>inputMask</code> is specified in a correct manner.
     *
     * 	<p>If the mask is not specified correctly or it is
     * 	not provided, then the control will work as a
     * 	standard Text Input control.
     *
     * 	@mxml
     *
     * 	<p>The <code>&lt;mx:MaskedTextInput&gt;</code> tag inherits the attributes
     * 	of its superclass and adds the following attributes:</p>
     *
     *  <pre>
     *  &lt;fc:MaskedTextInput
     *    <b>Properties</b>
     *    inputMask=""
     * 	  text=""
     * 	  fullText=""
     * 	  defaultCharacter="_"
     * 	  required=false
     * 	  autoAdvance=false
     * 	  &nbsp;
     *    <b>Styles</b>
     *    cellColor="0x008CEA"
     * 	  errorTextColor="0xFF0000"
     * 	  &nbsp;
     *    <b>Events</b>
     * 	  inputMaskEnd="<i>No default</i>"
     *  /&gt;
     *  </pre>
     *
     *  @includeExample ../../../../../../docs/com/adobe/flex/extras/controls/example/MaskedTextInputExample/MaskedTextInputExample.mxml
     *
     *  @see mx.controls.TextInput
     *
     *  @tiptext TextInput is a single-line, editable text field.
     *
     */
    public class YsTextInput extends TextInput
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------

        /**
         *  Constructor.
         */
        public function YsTextInput()
        {
            super();

            // Adding Listeners for various events
            addEventListener(TextEvent.TEXT_INPUT, interceptChar, true, 0);
            addEventListener(MouseEvent.CLICK, reposition, true);
            addEventListener(MouseEvent.MOUSE_DOWN, reposition, true);
            addEventListener(KeyboardEvent.KEY_DOWN, interceptKey, true);
            addEventListener(FocusEvent.FOCUS_IN, interceptFocus, false);
            addEventListener(FocusEvent.FOCUS_OUT, interceptFocus);
            addEventListener(Event.CHANGE, menuHandler);

            // commented to retain the default Tab and Shift-Tab behavior
            // uncomment if you want the focus to be shifted to the
            // next/previous sub-field in case of a Tab/Shift-Tab respectively.
            //addEventListener(FocusEvent.KEY_FOCUS_CHANGE,tabHandler);


            this.doubleClickEnabled = true;
            addEventListener(MouseEvent.DOUBLE_CLICK, handleDoubleClick, true);

        }

        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------

        /**
         *  @private
         * The UITextField control for displaying embeded hints.
         */
        private var embedTextField:UITextField;

        /**
         *  @private
         *  Storage for Escape character.
         */
        private const ESCAPE:String = "/";

        /**
         *  Internal array to store the data in the Text Field.
         */
        mx_internal var _working:Array = [];

        /**
         *  @private
         *  Storage for current cursor position.
         */
        private var _position:Number = 0;

        /**
         *  @private
         *  Flag set when focus is set by using mouse click.
         */
        private var focusByClick:Boolean = false;

        /**
         *  @private
         *  Storage for the time when double click event happened.
         */
        private var lastTime:Number = 0;

        /**
         *  @private
         *  Flag set when _working is updated.
         */
        private var workingUpdated:Boolean = false;

        /**
         *  @private
         *  Flag set when inputMask is updated.
         */
        private var maskUpdated:Boolean = false;

        /**
         *  @private
         *  Flag set when text is updated.
         */
        private var textUpdated:Boolean = false;

        /**
         *  @private
         *  Flag set when font-family/font-size is updated.
         */
        private var fontUpdated:Boolean = true;

        /**
         *  @private
         *  Flag set when either the mask is entered wrongly or is not specified.
         *  The control will work as a standard Text Input if defaultBehaviour is set
         */
        private var defaultBehaviour:Boolean = true;

        /**
         *  @private
         *  Storage for the length of the Text Field.
         */
        private var actualLength:Number = 0;

        /**
         *  @private
         *  The String to be shown as the embeded hint.
         */
        private var embedStr:String = "";

        /**
         *  @private
         *  Specifies that the field is a date only field.
         */
        private var dateField:Boolean = false;

        /**
         *  @private
         *  Skin names.
         *  Allows subclasses to re-define the skin property names.
         */
        mx_internal var backgroundSkinName:String = "MTISkin";

        /**
         *  @private
         *  Storage for the autoAdvance property.
         */
        private var _autoAdvance:Boolean = false;

        [Bindable("change")]
        [Inspectable(category="General", defaultValue="false")]
        /**
         *  If set to true, focus will automatically move to the next field
         *  in the tab order.
         *
         *  @default false
         */
        public function set autoAdvance(value:Boolean):void
        {
            _autoAdvance = value;
        }

        public function get autoAdvance():Boolean
        {
            return _autoAdvance;
        }

        /**
         *  @private
         *  Storage for the required property.
         */
        private var _required:Boolean = false;

        [Bindable("change")]
        [Inspectable(category="General", defaultValue="false")]
        /**
         *  If set and if the field is left incomplete,
         *  the color of the characters in the field will be changed
         *  to errorTextColor or to red if errorTextColor is not specified,
         *
         *  @default false
         */
        public function set required(value:Boolean):void
        {
            _required = value;
            // when required is changed dynamically, 
            // then the change should be reflected.
            invalidateDisplayList();
        }

        public function get required():Boolean
        {
            return _required;
        }

        /**
         *  @private
         *  Storage for the defaultCharacter property.
         */
        private var _defaultCharacter:String = "_";

        [Bindable("change")]
        [Inspectable(category="General", defaultValue="_")]
        /**
         *  The character used in place of an empty space
         *  when fullText is returned.
         *
         *  @default "_"
         */
        public function set defaultCharacter(str:String):void
        {
            _defaultCharacter = str.charAt(0);
        }

        public function get defaultCharacter():String
        {
            return _defaultCharacter;
        }

        /**
         *  @private
         *  Storage for the input mask.
         */
        private var _inputMask:String = "";

        [Bindable("change")]
        [Inspectable(category="General", defaultValue="")]
        /**
         *  The input mask used for validating the input.
         *
         */
        public function get inputMask():String
        {
            return _inputMask;
        }

        public function set inputMask(s:String):void
        {
            maskMap = [];
            _inputMask = s;
            dateField = false;
            switch (_inputMask)
            {
                case "MM/DD/YYYY":
                    _inputMask = "##//##//####";
                    embedStr = "MM DD YYYY";
                    dateField = true;
                    break;
                case "DD/MM/YYYY":
                    _inputMask = "##//##//####";
                    embedStr = "DD MM YYYY";
                    dateField = true;
                    break;
                case "YYYY/MM/DD":
                    _inputMask = "####//##//##";
                    embedStr = "YYYY MM DD";
                    dateField = true;
                    break;
                case "YYYY/DD/MM":
                    _inputMask = "####//##//##";
                    embedStr = "YYYY DD MM";
                    dateField = true;
                    break;
                default:
                    break;
            }

            defaultBehaviour = false;
            checkMask();
            actualLength = calculateMaxChars();
            if (!defaultBehaviour)
                maxChars = actualLength;
            maskUpdated = true;
            invalidateDisplayList();
        }

        /**
         *  @private
         *  Storage for the text property.
         */
        private var _text:String = "";

        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(category="General", defaultValue="")]

        /**
         *  Returns only the text entered by the user.
         */
        override public function get text():String
        {
            if (defaultBehaviour)
                return super.text;

            var result:String = "";
            for (var i:Number = 0; i < _working.length; i++)
            {
                var c:String = _working[i];
                if (!maskMap[i][1])
                {
                    continue;
                }
                else if (c == " ")
                    c = "";
                result += c;
            }
            return result;
        }

        override public function set text(value:String):void
        {
            if (defaultBehaviour)
            {
                super.text = value;
                //invalidateDisplayList();
                return;
            }
            _text = value;
            textUpdated = true;
            invalidateDisplayList();
        }

        [Bindable("change")]
        [Bindable("valueCommit")]
        [Inspectable(category="General", defaultValue="")]
        /**
         *  Returns the whole text displayed in the Text Field.
         */
        public function get fullText():String
        {
            if (defaultBehaviour)
                return super.text;

            var result:String = "";
            for (var i:Number = 0; i < _working.length; i++)
            {
                var c:String = _working[i];
                if (c == " ")
                    c = _defaultCharacter;
                result += c;
            }
            return result;
        }

        /**
         *  Internal array to store each character in the mask
         *  and whether it is to be entered by the user or displayed as it is.
         */
        mx_internal var maskMap:Array;

        /**
         *  @private
         *  Calculate the number of characters which are displayed
         *  (i.e., number of character in the inputMask excluding
         *  the ESCAPE character) and can be entered in the text field.
         *  Also populate the array maskMap which specifies that
         *  a character at a particular position is to be
         *  entered by the user or displayed as it is.
         */
        private function calculateMaxChars():Number
        {
            maskMap = new Array();
            var count:Number = 0;
            for (var i:int = 0, k:int = 0; i < _inputMask.length; i++, k++)
            {
                if ((_inputMask.charAt(i) == ESCAPE && _inputMask.charAt(i + 1) == ESCAPE) || (_inputMask.charAt(i) == ESCAPE && isMask(_inputMask.charAt(i + 1))))
                {
                    maskMap[k] = [_inputMask.charAt(i + 1), false];
                    i++;
                }
                else if (isMask(_inputMask.charAt(i)))
                {
                    maskMap[k] = [_inputMask.charAt(i), true];
                }
                else
                    maskMap[k] = [_inputMask.charAt(i), false];
                count++;
            }
            return count;
        }

        /**
         *  @private
         *  Check for the validity of the mask specified.
         *  If the mask is not valid then set the flag defaultBehaviour to true.
         *  If flag defaultBehaviour is set then the Masked Text Input Control will
         *  function as a standard Text Input control.
         */
        private function checkMask():void
        {
            if (!_inputMask || _inputMask == "")
            {
                defaultBehaviour = true;
                return;
            }
            for (var i:int = 0; i < _inputMask.length; i++)
            {
                if ((_inputMask.charAt(i) == ESCAPE && _inputMask.charAt(i + 1) == ESCAPE) || (_inputMask.charAt(i) == ESCAPE && isMask(_inputMask.charAt(i + 1))))
                {
                    i++;
                    continue;
                }
                else if (_inputMask.charAt(i) == ESCAPE && (_inputMask.charAt(i + 1) != ESCAPE || !isMask(_inputMask.charAt(i + 1))))
                {
                    defaultBehaviour = true;
                    break;
                }
                else if (isMask(_inputMask.charAt(i)))
                    continue;
            }
        }

        /**
         *  @private
         *  Create child objects for displaying embeded hints.
         */
        override protected function createChildren():void
        {
            super.createChildren();

            if (dateField)
            {
                embedTextField = new UITextField();
                embedTextField.text = embedStr;
                addChildAt(UITextField(embedTextField), getChildIndex(textField as TextField));
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Event Handlers
        //
        //--------------------------------------------------------------------------

        /**
         *  @private
         *  Handles cut and do nothing.
         */
        private function menuHandler(event:Event):void
        {
            // In case of a standard text field, perform the default cut action
            if (defaultBehaviour)
            {
                return;
            }
            var str:String = super.text;
            super.text = _working.join("");
            event.preventDefault();
            return;
        }

        /**
         *  @private
         *  Handles TAB and SHIFT+TAB event and repositions the insertion point.
         *  The insertion point(cursor) is moved to the position of the
         *  next/previous subfield respectively.
         */
        //commented to retain the default Tab and Shift-Tab behavior
        //uncomment if you want the focus to be shifted to the
        // next/previous sub-field in case of a Tab/Shift-Tab respectively.
        /* private function tabHandler(event:FocusEvent):void
           {
           // Move the insertion point to the previous group of mask characters
           if(event.shiftKey && event.keyCode == Keyboard.TAB)
           {
           var foundMask:Boolean = false;
           if(!(_position <=0))
           {
           for(var i:int=_position; i >= 0; i--)
           {
           if(foundMask && (!maskMap[i][1] || i==0))
           {
           if(!maskMap[i][1])
           {
           _position = i + 1;
           setSelection(_position,_position);
           event.preventDefault();
           break;
           }
           if(i==0)
           {
           _position = 0;
           setSelection(_position,_position);
           event.preventDefault();
           break;
           }
           }

           if(!foundMask && (i>0 && i<actualLength) && !maskMap[i][1] && maskMap[i-1][1])
           {
           foundMask = true;
           }

           }
           changeSelection(_position);
           }
           }
           // Move the insertion point to the next group of mask characters
           else if(event.keyCode == Keyboard.TAB)
           {
           if(_position != actualLength-1)
           {
           for(i=_position; i < actualLength; i++)
           {
           if(!maskMap[i][1] && maskMap[i+1][1])
           {
           _position = i + 1;
           setSelection(_position,_position);
           changeSelection(_position);
           event.preventDefault();
           break;
           }
           }
           }
           }
         } */

        /**
         *  @private
         *  Handles MOUSE_CLICK event and repositions the insertion point.
         *  The insertion point(cursor) is moved to the position of the
         *  mouse click if all the characters in the subfield(to the left
         *  of the click point) are filled.
         */
        private function reposition(event:flash.events.MouseEvent):void
        {
            if (defaultBehaviour)
            {
                return;
            }

            // Adding MOUSE_UP event listener
            if (event.type == MouseEvent.MOUSE_DOWN)
                event.preventDefault();

            // Handles triple click
            var now:Number = getTimer();
            if (lastTime != 0 && (now - lastTime) < 300)
            {
                lastTime = 0;
                setSelection(0, actualLength);
                event.preventDefault();
                return;
            }

            // Changed so that cursor can not be positioned to a subfield
            // if any of the previous subfield is partially filled.
            //if(this.selectionBeginIndex <= actualLength 
            //	&& _working[this.selectionBeginIndex-1] == " ")
            if (this.selectionBeginIndex <= actualLength && isWorkingIncomplete(this.selectionEndIndex))
            {
                //if(maskMap[this.selectionBeginIndex-1][1])
                setSelection(_position, _position);
            }
            else
            {
                _position = this.selectionBeginIndex;
                if (focusByClick)
                {
                    setSelection(_position, _position);
                    focusByClick = false;
                }
            }
            event.preventDefault();
        }

        /**
         *  @private
         *  Handles MOUSE_DOUBLECLICK event and selects the sub field.
         */
        private function handleDoubleClick(event:MouseEvent):void
        {
            if (defaultBehaviour)
                return;

            textField.selectable = false;
            lastTime = getTimer();

            var startPos:int = textField.getCharIndexAtPoint(event.localX, event.localY) != -1 ? textField.getCharIndexAtPoint(event.localX, event.localY) : (event.localX < 10 ? 0 : (actualLength - 1));

            while (startPos > 0 && startPos < actualLength && maskMap[startPos - 1][1])
                startPos--;

            if (!isWorkingIncomplete(startPos))
                changeSelection(startPos);

            event.stopImmediatePropagation();
            event.preventDefault();

            textField.selectable = true;

            return;
        }

        /**
         *  @private
         *  Handles key press event for special keys like Delete, Backspace, etc.
         */
        private function interceptKey(event:flash.events.KeyboardEvent):void
        {
            if (defaultBehaviour)
            {
                super.keyDownHandler(event);
                return;
            }

            // Delete one character before the insertion point 
            // and moves the insertion point to one positi8on back.
            if (event.keyCode == Keyboard.BACKSPACE)
            {
                _position = selectionBeginIndex;
                handleDeletions(true);
            }
            // Delete one character at the insertion point 
            else if (event.keyCode == Keyboard.DELETE)
            {
                handleDeletions();
            }
            // Moves the insertion point to the previous viable input position
            else if (event.keyCode == Keyboard.LEFT)
            {
                if (_position > 0 && _working[_position - 1] == " ")
                {
                    setSelection(_position, _position);
                }
                else
                {
                    _position = this.selectionBeginIndex;
                    retreatPosition();
                }
                event.preventDefault();
            }
            // Moves the insertion point to the next viable input position
            else if (event.keyCode == Keyboard.RIGHT)
            {
                if (_position == actualLength - 1)
                {
                    ++_position;
                    setSelection(_position, _position);
                }
                else if (_position < actualLength && _working[_position] == " ")
                {
                    setSelection(_position, _position);
                }
                else
                    advancePosition();

                event.preventDefault();
            }
            // Moves the insertion point to the last viable input position
            else if (event.keyCode == Keyboard.END)
            {
                var b:Boolean = false;
                for (var i:int = _position; i < actualLength; i++)
                {
                    if (_working[i] == " ")
                    {
                        _position = i;
                        setSelection(i, i);
                        b = true;
                        break;
                    }
                }
                if (!b)
                    _position = _working.length;
                event.preventDefault();
            }
            // Moves the insertion point to the first viable input position
            else if (event.keyCode == Keyboard.HOME)
            {
                _position = -1;
                advancePosition(true);
            }
            workingUpdated = true;
            invalidateDisplayList();
        }

        /**
         *  @private
         *  Handle TEXT_INPUT events by matching the character with
         *  the mask and either blocking or allowing the character.
         */
        private function interceptChar(event:TextEvent):void
        {
            // If the mask is incorrect or not spceified then treat the control
            // as a standard TextInput control
            if (defaultBehaviour)
            {
                return;
            }

            // Get the typed characters
            var input:String = event.text;

            if (_position >= actualLength)
            {
                event.preventDefault();

                // If autoAdvance flag is set, then set the focus to the
                // next control according to the tab index.
                if (_autoAdvance && !isWorkingIncomplete())
                {
                    var obj:UIComponent = UIComponent(focusManager.getNextFocusManagerComponent());
                    if ((obj is YsTextInput) || (obj is TextInput) || (obj is TextArea))
                        obj.setFocus();
                }

                // Dispatch the inputMaskEnd Event
                dispatchEvent(new Event("inputMaskEnd"));
                return;
            }

            handleInput(input, event);
            dispatchEvent(new Event(Event.CHANGE));
        }

        /**
         *  @private
         *  Consumes the FOCUS_IN and FOCUS_OUT event and repositions the insertion
         *  point and perform additional checks based on the required property.
         */
        private function interceptFocus(event:FocusEvent):void
        {
            if (defaultBehaviour)
            {
                return;
            }

            if (event.type == FocusEvent.FOCUS_IN)
            {
                focusByClick = true;
                // If tab is used to move within the fields of the control,
                // then position the insertion point to the begining of the
                // next group of mask characters
                _position = -1;

                // advance the insertion point to the first viable input field.
                advancePosition();
                // selects the current subfield
                changeSelection(0);
            }
            else if (event.type == FocusEvent.FOCUS_OUT)
            {
                textField.setColor(0x000000);
                if (_required && isWorkingIncomplete())
                {
                    var errorTextColor:Number = getStyle("errorTextColor");
                    if (errorTextColor)
                        textField.setColor(errorTextColor);
                    else
                        textField.setColor(0xFF0000);
                }
            }

        }

        /**
         *  @private
         *  Handles Deletion of characters caused by pressing
         *  backspace/Delete key.
         */
        private function handleDeletions(backSpace:Boolean=false):void
        {
            var i:int = 0;
            var s:String = "";
            if (this.selectionBeginIndex == this.selectionEndIndex || this.selectionBeginIndex == this.selectionEndIndex + 1)
            {
                var startIndex:int = -1;
                var endIndex:int = actualLength;
                if (backSpace)
                {
                    startIndex = 0;
                    endIndex = actualLength + 1;
                }

                if (_position > startIndex && _position < endIndex)
                {
                    if (backSpace)
                        retreatPosition();

                    i = _position;
                    if (!maskMap[_position][1])
                        _working[_position] = maskMap[_position][0];
                    else
                    {
                        // Commented so that characters dont shift to left when deleting
                        /* while((i+1) < actualLength && _working[i+1] != " " && maskMap[i+1][1])
                           {
                           _working[i] = _working[i+1];
                           i++;
                         } */
                        _working[i] = " ";

                        // Added so that delete can work fine.
                        if (!backSpace && _position < actualLength - 1 && _working[_position + 1] != " ")
                        {
                            advancePosition();
                                //setSelection(_position,_position);
                        }

                        if (dateField)
                        {
                            s = embedTextField.text == null ? "" : embedTextField.text;
                            if (s.length > 0)
                            {
                                s = s.substring(0, _position) + " " + s.substring(_position + 1, s.length);
                                s = s.substring(0, i) + embedStr.charAt(i) + s.substring(i + 1, s.length);
                                embedTextField.text = s;
                            }
                        }
                    }
                }
            }
            else
            {
                _position = this.selectionBeginIndex;
                i = _position - 1;
                for (var j:int = this.selectionBeginIndex; j < this.selectionEndIndex; j++)
                {
                    // Commented so that characters dont shift to left when deleting
                    //i = _position;
                    //if(!maskMap[_position][1])
                    //	_working[_position] = maskMap[_position][0];
                    i++;

                    if (!maskMap[i][1])
                        _working[i] = maskMap[i][0];
                    else
                    {
                        // Commented so that characters dont shift to left when deleting
                        /* while((i+1) < actualLength && _working[i+1] != " " && maskMap[i+1][1])
                           {
                           _working[i] = _working[i+1];
                           i++;
                         } */
                        _working[i] = " ";

                        if (dateField)
                        {
                            s = embedTextField.text == null ? "" : embedTextField.text;
                            if (s.length > 0)
                            {
                                // Commented so that characters dont shift to left when deleting
                                //s = s.substring(0,_position) + " " + s.substring(_position+1, s.length);
                                //s = s.substring(0,i) + embedStr.charAt(i) + s.substring(i+1, s.length);
                                //embedTextField.text = s;

                                s = s.substring(0, i) + " " + s.substring(i + 1, s.length);
                                s = s.substring(0, i) + embedStr.charAt(i) + s.substring(i + 1, s.length);
                                embedTextField.text = s;
                            }
                        }
                    }
                }
            }
        }

        /**
         *  @private
         *  Change the selected text to select the text in the current subfield.
         */

        private function changeSelection(pos:Number):void
        {
            var startPos:int = pos;

            while (!maskMap[startPos][1])
                startPos++;

            var endPos:int = startPos;

            while (endPos < actualLength && maskMap[endPos][1] && _working[endPos] != " ")
                endPos++;
            setSelection(startPos, endPos);
        }

        /**
         *  @private
         *  Returns true if the text field is left incomplete.
         */
        private function isWorkingIncomplete(len:Number=-1):Boolean
        {
            if (len == -1)
                len = actualLength;

            for (var i:int = 0; i < len; i++)
            {
                if (_working[i] == " " && maskMap[i][1])
                {
                    return true;
                }
            }
            return false;
        }

        /**
         *  @private
         *  Handle the text entered by the user or specified in the
         *  text property.
         */
        private function handleInput(input:String, event:Event=null):void
        {
            for (var i:int = 0; i < input.length; i++)
            {

                var c:String = input.charAt(i);
                var m:String;
                if (_position >= actualLength)
                    return;

                var pos:Number = (_position < 0) ? 0 : ((_position >= actualLength) ? actualLength - 1 : _position);
                if (pos < actualLength && maskMap[pos][0] != null)
                    m = maskMap[pos][0];
                else
                {
                    if (event != null)
                        event.preventDefault();
                    return;
                }

                // Flag set to false if the character is not accepted
                var bAdvance:Boolean = true;
                // Check the character entered with the mask character at that position
                switch (m)
                {
                    case "#":
                        // if the character is a digit, accept it
                        if (isDigit(c))
                        {
                            allowChar(c);
                        }
                        else
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        break;
                    case "A":
                        // if the character is an alphabet, 
                        // convert it to upper case and accept it.
                        if (isLetter(c))
                        {
                            allowChar(c.toUpperCase());
                        }
                        else
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        break;
                    case "a":
                        // if the character is an alphabet, 
                        // convert it to lower case and accept it.
                        if (isLetter(c))
                        {
                            allowChar(c.toLowerCase());
                        }
                        else
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        break;
                    case "B":
                        // if the character is an alphabet, accept it.
                        if (isLetter(c))
                        {
                            allowChar(c);
                        }
                        else
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        break;
                    case ".":
                        // if the character is not a digit, accept it.
                        if (isDigit(c))
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        else
                        {
                            allowChar(c);
                        }
                        break;
                    case "*":
                        // if the character is a digit or an alphabet, accept it.
                        if (isDigit(c) || isLetter(c))
                        {
                            allowChar(c);
                        }
                        else
                        {
                            //event.preventDefault();
                            bAdvance = false;
                        }
                        break;
                    default:
                        break;
                }

                if (bAdvance)
                {
                    // If embeded hints are displayed then update the
                    // UITextField corresponding to the embeded hints
                    if (dateField)
                    {
                        var s:String = embedTextField.text == null ? "" : embedTextField.text;
                        if (s.length > 0)
                        {
                            s = s.substring(0, _position) + " " + s.substring(_position + 1, s.length);
                            embedTextField.text = s;
                        }
                    }

                    advancePosition();
                }
                else
                {
                    if (event != null)
                        event.preventDefault();
                }

                workingUpdated = true;

                invalidateDisplayList();

            }
        }

        /**
         *  @private
         *  Moves the insertion point forward (if possible) to the next viable
         *  input position.
         *  byArrow denotes that advancePosition is called when
         *  the user has pressed Arrow key or not.
         */
        private function advancePosition(byArrow:Boolean=false):void
        {
            var p:Number = _position;

            var posChanged:Boolean = false;

            while ((++p) < actualLength)
            {
                posChanged = true;
                if (p >= actualLength - 1)
                {
                    p = actualLength - 1;
                    break;
                }
                if (maskMap[p][1])
                    break;


            }

            if (posChanged || p == actualLength)
                _position = p;

            // byArrow denotes that advancePosition is called when
            // the user has pressed Arrow key or not
            if (p >= actualLength && !byArrow)
            {
                if (_autoAdvance && !isWorkingIncomplete())
                {
                    // Going to the next field
                    var obj:UIComponent = UIComponent(focusManager.getNextFocusManagerComponent());
                    if ((obj is YsTextInput) || (obj is TextInput) || (obj is TextArea))
                        obj.setFocus();

                }
                dispatchEvent(new Event("inputMaskEnd"));
            }
            setSelection(_position, _position);
        }

        /**
         *  @private
         *  Moves the insertion point backward (if possible) to the previous
         *  viable input position.
         */
        private function retreatPosition():void
        {
            var p:Number = _position;
            var posChanged:Boolean = false;

            while ((--p) >= 0)
            {
                posChanged = true;
                if (p <= 0 || maskMap[p][1])
                    break;
            }
            if (posChanged)
                _position = p;

            setSelection(_position, _position);
        }

        /**
         *  @private
         *  Returns true if the given character is a masking character.
         */
        private function isMask(c:String):Boolean
        {
            return (c == "#" || c == "A" || c == "a" || c == "B" || c == "." || c == "*");
        }

        /**
         *  @private
         *  Returns true if the given character is a digit.
         */
        private function isDigit(c:String):Boolean
        {
            return ((c >= "0" && c <= "9"));
        }

        /**
         *  @private
         *  Returns true if the given character is an Alphabet.
         */
        private function isLetter(c:String):Boolean
        {
            return (((c >= "a") && (c <= "z")) || ((c >= "A") && (c <= "Z")));
        }

        /**
         *  @private
         *  Inserts the character into the working array.
         */
        private function allowChar(c:String):void
        {
            // Commented so that the characeters dont shift to their left when deleting
            /* var insertionPossible:Boolean = false;
               var i:int = _position;
               while((i+1) <= actualLength && maskMap[i][1])
               {
               if(_working[i] == " " && !(maskMap[i][0] == " "))
               {
               insertionPossible = true;
               break;
               }
               i++;
               }
               while(insertionPossible && (i) > _position && maskMap[i][1])
               {
               _working[i] = _working[i-1];
               i--;
             } */
            _working[_position] = c;
        }

        /**
         *  @private
         *  Modifies the display according to how flags are set: if
         *  text has been updated, fold the text according to the mask. If
         *  the mask has been updated, modify the display.
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (defaultBehaviour)
            {
                defaultBehaviour = true;
                super.updateDisplayList(unscaledWidth, unscaledHeight);
                return;
            }

            super.updateDisplayList(unscaledWidth, unscaledHeight);

            if (maskUpdated)
            {
                maskUpdated = false;

                _working = [];
                for (var i:int = 0; i < actualLength; i++)
                {
                    var c:String = " ";
                    if (!maskMap[i][1])
                        c = maskMap[i][0];
                    _working.push(c);

                }

                width = measureText("W").width * actualLength + 2 * getStyle("borderThickness") + 5;
                workingUpdated = true;
            }

            if (textUpdated)
            {
                textUpdated = false;
                _working = [];
                for (var j:int = 0; j < actualLength; j++)
                {
                    var ch:String = " ";
                    if (!maskMap[j][1])
                        ch = maskMap[j][0];
                    _working.push(ch);

                }
                _position = 0;
                handleInput(_text);
                workingUpdated = true;
            }

            if (workingUpdated)
            {
                super.text = _working.join("");
                workingUpdated = false;
            }

            if (fontUpdated)
            {
                fontUpdated = false;

                // Set the font size to 72 if user has specified the
                // font size to be greater than 72
                if (getStyle("fontSize") > 72)
                {
                    setStyle("fontSize", 72);
                }

                // Check if Monospaced font is used or not
                // Set the font to Courier if font used is other then a monospaced font
                if (measureText("W").width != measureText("I").width)
                {
                    setStyle("fontFamily", "Courier");
                }

                // Set the width of the control
                width = measureText("W").width * actualLength + 2 * getStyle("borderThickness") + 5;
            }
            if (dateField)
            {
                // when inputMask is changed dynamically, 
                // then in case of a date mask,
                // create the embeded text field for showing
                // embeded hints if its not already created.
                // If it is created, then just change the embeded hint.
                if (!embedTextField)
                {
                    embedTextField = new UITextField();
                    addChildAt(embedTextField, getChildIndex(textField as TextField));
                }
                embedTextField.text = embedStr;

                embedTextField.alpha = 1;

                var txtFormat:TextFormat = new TextFormat();
                txtFormat.color = 0xFFFFFF;
                embedTextField.setTextFormat(txtFormat);
                embedTextField.x = textField.x;
                embedTextField.y = textField.y;
                embedTextField.setActualSize(width, height);
            }
            else
            {
                if (embedTextField)
                {
                    embedTextField.text = "";
                    embedTextField = null;
                }
            }

            // create or updates the control's skin
            createSkin();

            textField.width += 50;
        }

        /**
         *  @private
         */
        override protected function measure():void
        {
            super.measure();
            var bm:EdgeMetrics = border && border is RectangularBorder ? RectangularBorder(border).borderMetrics : EdgeMetrics.EMPTY;

            measuredMinHeight = measureText("Wj").height + 4 + bm.top + bm.bottom;
            measuredHeight = measuredMinHeight;
        }

        /**
         *  @private
         */
        override public function styleChanged(styleProp:String):void
        {
            super.styleChanged(styleProp);

            // using date mask with validators changes the text color to black,
            // in case of a validation failure.
            // setting the color of the embeded text field to white.
            if (styleProp == "themeColor")
            {
                if (embedTextField)
                    embedTextField.setColor(0xFFFFFF);
            }

            if (styleProp == "fontFamily" || styleProp == "fontSize")
            {
                fontUpdated = true;
                measuredMinHeight = measureText("Wj").height + 4;
                measuredHeight = measuredMinHeight;
                invalidateDisplayList();

            }
        }

        /**
         *  @private
         */
        override public function getStyle(styleProp:String):*
        {
            if (styleProp == "cellColor")
                if (!super.getStyle("cellColor"))
                    if (required)
                        return 0xFF0000;
                    else
                        return 0x008CEA;

            if (styleProp == "errorTextColor")
                if (!super.getStyle("errorTextColor"))
                    return 0xFF0000;

            return super.getStyle(styleProp);
        }

        /**
         *  @private
         */
        private function createSkin():void
        {
            var skinName:String = backgroundSkinName;

            // Has this skin already been created?
            var newSkin:IFlexDisplayObject = IFlexDisplayObject(getChildByName(skinName));

            // If not, create it.
            if (!newSkin)
            {
                var newSkinClass:Class = Class(getStyle(skinName));
                if (!newSkinClass)
                {
                    newSkinClass = MTISkin;
                }
                if (newSkinClass)
                {
                    newSkin = IFlexDisplayObject(new newSkinClass());

                    // Set its name so that we can find it in the future
                    // using getChildByName().
                    newSkin.name = skinName;

                    // Make the getStyle() calls in MTISkin find the styles
                    // for this control.
                    var styleableSkin:ISimpleStyleClient = newSkin as ISimpleStyleClient;
                    if (styleableSkin)
                        styleableSkin.styleName = this;

                    if (embedTextField)
                        addChildAt(DisplayObject(newSkin), getChildIndex(embedTextField));
                    else
                        addChild(DisplayObject(newSkin));

                    // If the skin is programmatic, and we've already been
                    // initialized, update it now to avoid flicker.
                    if (newSkin is IInvalidating && initialized)
                    {
                        IInvalidating(newSkin).validateNow();
                    }
                    else if (newSkin is ProgrammaticSkin && initialized)
                    {
                        ProgrammaticSkin(newSkin).invalidateDisplayList();
                    }
                }
            }
            // If the skin is already created then redraw it
            // depending on the characters entered in the text input
            else
            {
                ProgrammaticSkin(newSkin).invalidateDisplayList();
            }
        }
    }
}