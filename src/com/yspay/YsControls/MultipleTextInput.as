package com.yspay.YsControls
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.utils.ByteArray;

    import mx.collections.ArrayCollection;
    import mx.controls.Button;
    import mx.controls.TextInput;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.managers.PopUpManager;
    import mx.utils.StringUtil;

    public class MultipleTextInput extends TextInput
    {
        public var _parent:YsDict;
        private var _backList:MyList;
        private var _btn:Button;
        private var _showList:Boolean;
        private var _index:int = 0;
        [Bindable]
        private var _listDp:ArrayCollection = new ArrayCollection;
        private var _append:Boolean = false;
        private var _listEditable:Boolean = false;
        private var _deleteable:Boolean = false;
        private var _fileable:Boolean = false;
        //file相关
        private var _showBrowse:Boolean;
        private var fr:FileReference;
        private var fileType:FileFilter;

        public function MultipleTextInput(parent:YsDict, openfile:String)
        {
            super();
            this.toolTip = "Ctrl+Home 打开\nCtrl+Insert 增加行\nCtrl+Delete 删除行";

            this.append = true;
            this.deleteable = true;
            this.listEditable = true;

            if (openfile == "true")
            {
                this.fileable = true;
                _btn = new Button;
                _btn.setStyle("fontSize", 12);
                _btn.label = '浏览';
                _btn.visible = true;
                // _btn.height = _btn.width = 0;
                _btn.addEventListener(MouseEvent.CLICK, btnClickHandler);
            }

            _showList = false;
            _backList = new MyList;
            _backList.setStyle('fontSize', 12);
            _backList.dataProvider = _listDp;
            addEventListener(Event.CHANGE, changeHandler);
            addEventListener(KeyboardEvent.KEY_DOWN, keydownHandler);
            _listDp.addEventListener(CollectionEvent.COLLECTION_CHANGE, ListChange);

            _parent = parent;
        }

        protected override function createChildren():void
        {
            super.createChildren();
            if (_btn != null)
                addChild(_btn);
        }

        protected override function commitProperties():void
        {
            super.commitProperties();
            if (_fileable)
            {
                _btn.label = "浏览";
                fr = new FileReference();
                fileType = new FileFilter("Text Files (*.txt)", "*.txt;");
                //增加当打开浏览文件后，用户选择好文件后的Listener
                fr.addEventListener(Event.SELECT, selectHandler);
                //增加一个文件加载load完成后的listener	
                fr.addEventListener(Event.COMPLETE, onLoadComplete);
            }
            invalidateDisplayList();
        }

        protected override function measure():void
        {
            super.measure();
            if (_btn != null)
                measuredWidth = measuredWidth + _btn.measuredWidth + 10;
        }

        protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if (_btn != null)
            {
                super.updateDisplayList(unscaledWidth - 10 - _btn.measuredWidth,
                                        unscaledHeight);
                _btn.move(unscaledWidth - 5 - _btn.measuredWidth, 0);
                _btn.setActualSize(_btn.measuredWidth, unscaledHeight);
            }
            else
            {
                super.updateDisplayList(unscaledWidth, unscaledHeight);
            }
        }

        //file相关
        private function selectHandler(event:Event):void
        {
            _showBrowse = false;
            //加载用户选中文件
            fr.load();
        }

        protected function ListChange(event:CollectionEvent):void
        {
            trace('MultipleTextInput::ListChange: ', event.kind, event.location);
            if (event.kind == CollectionEventKind.ADD)
            {
                if (_parent.dict.data.length == _listDp.length)
                    return;
                _parent.dict.data.Insert(event.location, '');
            }
            else if (event.kind == CollectionEventKind.REMOVE)
            {
                if (_parent.dict.data.length == _listDp.length)
                    return;
                _parent.dict.data.RemoveItems(event.location, 1);
            }
            else if (event.kind == CollectionEventKind.UPDATE)
                _parent.dict.data[event.location] =
                    event.target[event.location];
            else if (event.kind == CollectionEventKind.REPLACE)
                _parent.dict.data[event.location] =
                    event.target[event.location];
        }

        private function onLoadComplete(e:Event):void
        {
            cursorManager.setBusyCursor();
            var ba:ByteArray = new ByteArray;
            ba.writeBytes(fr.data);
            ba.position = 0;
            var str:String = transEncodingText(ba);
            var arr:Array = str.split("\n");
            for (var i:int = 0; i < arr.length; i++)
            {
                arr[i] = StringUtil.trim(arr[i]);
            }

            for (var idx:int = 0; idx < arr.length; ++idx)
            {
                if (_listDp.length <= idx)
                {
                    _listDp.addItem('');
                    _listDp[idx] = arr[idx];
                }
                else
                    _listDp[idx] = arr[idx];
            }

            while (_listDp.length > arr.length)
                _listDp.removeItemAt(arr.length);

            if (!_showList)
                popUpList();
            cursorManager.removeBusyCursor();
        }

        //hand events
        private function keydownHandler(event:KeyboardEvent):void
        {
            //ctrl+home 弹出list
            if (event.keyCode == 36 && event.ctrlKey && event.currentTarget == this)
            {
                if (!_showList)
                    popUpList();
            }
        }

        //list监听键盘事件
        private function listKeyDownHandler(event:KeyboardEvent):void
        {
            //ctrl+home 
            if (event.keyCode == 36 && event.ctrlKey)
            {
                if (_backList.itemEditorInstance != null && _backList.editedItemPosition != null)
                {
                    _listDp[_backList.editedItemPosition.rowIndex] = (_backList.itemEditorInstance as TextInput).text;
                }
                removePopList();

                if (_listDp.length == 0)
                    _listDp.addItem('');
                text = _listDp[0];
                return;
            }
            if (_backList.editedItemPosition == null)
                return;
            var temp:int = _backList.editedItemPosition.rowIndex;
            //up
            if (event.keyCode == 38)
            {
                if (temp > 0)
                {

                    _backList.editedItemPosition = {columnIndex: 0,
                            rowIndex: temp - 1};
                }
                else
                {
                    _backList.editedItemPosition = {columnIndex: 0,
                            rowIndex: _listDp.length - 1};
                }
                return;
            }
            //dowm
            if (event.keyCode == 40)
            {
                if (temp < _listDp.length - 1)
                {
                    _backList.editedItemPosition = {columnIndex: 0,
                            rowIndex: temp + 1};
                }
                else
                {
                    _backList.editedItemPosition = {columnIndex: 0,
                            rowIndex: 0};
                }
                return;
            }
            //delete
            if (event.keyCode == 46 && event.ctrlKey && deleteable)
            {
                if (temp == 0)
                    return;
                if (temp < _listDp.length)
                {
                    removePopList();
                    _listDp.removeItemAt(temp);
                    if (_listDp.length > temp)
                        _index = temp;
                    else
                        _index = temp - 1;
                    popUpList();
                }

                return;
            }
            //append
            if (event.keyCode == 45 && event.ctrlKey && _append)
            {
                removePopList();
                _listDp.addItemAt("", temp + 1);
                popUpList();
                _backList.editedItemPosition = {columnIndex: 0, rowIndex: temp + 1};
            }
        }

        public function SetText(txt:String):void
        {
            this.text = txt;

            if (_listDp.length == 0)
                _listDp.addItem('');
            _listDp[0] = txt;
        }

        //同步
        private function changeHandler(event:Event):void
        {
            if (_listDp.length == 0)
                _listDp.addItem('');
            _listDp[0] = text;

            _parent.dict.source = this;
            _parent.dict.text = text;
        }

        //点击按钮弹出list或browse
        private function btnClickHandler(event:MouseEvent):void
        {
            if (_fileable)
            {
                //打开浏览文件的dialog
                fr.browse(new Array(fileType));
                _showBrowse = true;
            }
            else
            {
                if (!_showList)
                    popUpList();
            }
        }

        //点击舞台任意地方list收回
        private function stageMouseDownHandler(event:MouseEvent):void
        {
            if (!parentIsThis(event.target as DisplayObject, this) &&
                !parentIsThis(event.target as DisplayObject, _backList) && _showList)
            {
                _showList = false;
                removePopList();
                if (_backList.itemEditorInstance != null && _backList.editedItemPosition != null)
                {
                    _listDp[_backList.editedItemPosition.rowIndex] = (_backList.itemEditorInstance as TextInput).text;
                }

                if (_listDp.length > 0)
                    text = _listDp[0];

                setFocus();
                setSelection(text.length, text.length);
            }
        }

        //使null行可以被编辑
        private function listClickHandler(event:Event):void
        {
            if (_backList.selectedItem == "" && _listEditable)
                _backList.editedItemPosition = {columnIndex: 0,
                        rowIndex: _backList.selectedIndex};
        }

        private function popUpList():void
        {
            _backList.editable = _listEditable;
            _backList.width = width;
            _backList.rowCount = _listDp.length;
            _backList.dataProvider = _listDp;
            PopUpManager.addPopUp(_backList, this);
            PopUpManager.centerPopUp(_backList);
            _showList = true;
            _backList.setFocus();
            if (_listEditable)
                _backList.editedItemPosition = {columnIndex: 0,
                        rowIndex: _index};
            _backList.addEventListener(KeyboardEvent.KEY_DOWN, listKeyDownHandler);
            _backList.addEventListener(MouseEvent.CLICK, listClickHandler);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
        }

        private function removePopList():void
        {
            _backList.removeEventListener(KeyboardEvent.KEY_DOWN, listKeyDownHandler);
            _backList.removeEventListener(MouseEvent.CLICK, listClickHandler);
            PopUpManager.removePopUp(_backList);
            _showList = false;
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
            _backList.dataProvider = null;

            if (_btn != null)
                _btn.setFocus();
        }

        //util
        private function parentIsThis(o:DisplayObject, p:DisplayObject):Boolean
        {
            if (o.parent != null)
            {
                if (o.parent == p)
                    return true;
                else
                    return parentIsThis(o.parent, p);
            }
            else
                return false;
        }

        // 读取不同 编码的文档   
        private function transEncodingText(bytes:ByteArray):String
        {
            // 1. unicode 文档 开头 16进制码为 FF FE ,对应 十进制 数 为 255，254   
            if (bytes[0] == 255 && bytes[1] == 254)
            {
                return bytes.toString();
            }
            // 2.unicode big endian 开头 16进制 为 FE FF，对应十进制数 为 254，255   
            if (bytes[0] == 254 && bytes[1] == 255)
            {
                return bytes.toString();
            }
            // utf-8
            if (bytes[0] == 0xEF && bytes[1] == 0xBB)
            {
                return bytes.readMultiByte(bytes.length, "utf-8");
            }
            // 默认采用gbk编码 
            return bytes.readMultiByte(bytes.length, "gb2312");
        }

        public function set append(value:Boolean):void
        {
            _append = value;
            invalidateProperties();
        }

        public function get append():Boolean
        {
            return _append;
        }

        public function set listEditable(value:Boolean):void
        {
            _listEditable = value;
            invalidateProperties();
        }

        public function get listEditable():Boolean
        {
            return _listEditable;
        }

        public function set deleteable(value:Boolean):void
        {
            _deleteable = value;
            invalidateProperties();
        }

        public function get deleteable():Boolean
        {
            return _deleteable;
        }

        public function set fileable(value:Boolean):void
        {
            _fileable = value;
        }

        public function get fileable():Boolean
        {
            return _fileable;
        }

        public function get listDp():ArrayCollection
        {
            return _listDp;
        }
    }
}

