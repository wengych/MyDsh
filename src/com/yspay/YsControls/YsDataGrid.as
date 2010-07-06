package com.yspay.YsControls
{
    import com.yspay.YsData.MData;
    import com.yspay.YsData.PData;
    import com.yspay.util.AdvanceArray;
    import com.yspay.util.UtilFunc;
    import com.yspay.util.YsClassFactory;

    import flash.display.DisplayObjectContainer;
    import flash.events.Event;

    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.controls.DataGrid;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.Application;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.DataGridEvent;
    import mx.events.PropertyChangeEvent;

    public class YsDataGrid extends DataGrid implements YsControl
    {
        protected var _xml:XML;

        public var del:Boolean;
        public var add:Boolean;
        public var ins:Boolean;
        public var default_line:Boolean;

        public var _parent:DisplayObjectContainer;
        public var data_count:String;
        public var D_data:PData = new PData;

        public var fromDataObject:Object = new Object;
        public var toDataObject:Object = new Object;
        public var dict_arr:Array = new Array;

        public function YsDataGrid(parent:DisplayObjectContainer)
        {
            super();

            _parent = parent;

            percentWidth = 100;
            percentHeight = 100;
        }

        protected function OnRemoveItems(p_data:PData,
                                         dict_name:String,
                                         startPos:int,
                                         count:int=-1):void
        {
            trace('YsDataGrid::OnRemoveItems');
            var arr:ArrayCollection = dataProvider as ArrayCollection;
            if (arr.length > p_data.data[dict_name].length)
            {
                if (count < 0)
                    count = arr.length - startPos;
                while (--count >= 0)
                    arr.removeItemAt(startPos + count);
            }
        }

        protected function OnAddEmptyItems(p_data:PData,
                                           dict_name:String,
                                           count:int):void
        {
            trace('YsDataGrid::OnAddEmptyItems');
            var arr:ArrayCollection = dataProvider as ArrayCollection;

            if (arr.length < p_data.data[dict_name].length)
            {
                while (--count >= 0 &&
                    arr.length < p_data.data[dict_name].length)
                    arr.addItem(new Object);
            }
        }

        protected function OnInsert(p_data:PData,
                                    dict_name:String,
                                    startPos:int,
                                    ... rest):void
        {
            trace('YsDataGrid::OnInsert');
            var arr:ArrayCollection = dataProvider as ArrayCollection;
        }

        public function NotifyFunctionCall(p_data:PData,
                                           dict_name:String,
                                           func_name:String,
                                           args:Array):void
        {
            trace('YsDataGrid::NotifyFunctionCall( ' +
                  dict_name + ',' +
                  func_name + ',' +
                  args + ')');

            var func_map:Object =
                {
                    'RemoveItems': OnRemoveItems,
                    'AddEmptyItems': OnAddEmptyItems,
                    'Insert': OnInsert
                };

            func_map[func_name](p_data, dict_name, args);
        }

        public function Notify(p_data:PData, dict_name:String, index:int):void
        {
            var has_key:Boolean = false;
            for each (var col:DataGridColumn in columns)
            {
                if (col.dataField == dict_name)
                {
                    has_key = true;
                    break;
                }
            }
            if (!has_key)
                return;

            var arr:ArrayCollection = dataProvider as ArrayCollection;
            if (arr.length <= index)
                return;
            arr[index][dict_name] = p_data.data[dict_name][index];
            arr.refresh();
        }

        public function GetXml():XML
        {
            return _xml;
        }

        public function GetSaveXml():XML
        {
            var rtn:XML =
                <L KEY="DATAGRID" KEYNAME="DATAGRID" VALUE=""/>
                ;

            var xml_line:XML =
                <L KEY="" KEYNAME="" VALUE="">
                    <L KEY="From" KEYNAME="From" VALUE="pod"/>
                    <L KEY="To" KEYNAME="To" VALUE="pod"/>
                </L>
                ;

            for each (var ctrl:XML in this.GetXml().children())
            {
                if (ctrl.name().toString() != "DICT")
                    continue;

                var newxml:XML = new XML(xml_line);

                newxml.@KEY = ctrl.name().toString();
                newxml.@KEYNAME = ctrl.name().toString();

                newxml.@VALUE = ctrl.text().toString();

                rtn.appendChild(newxml);
                newxml = null;
            }
            return rtn;
        }

        public function get type():String
        {
            return _xml.name().toString();
        }

        public function GetLinkXml():XML
        {
            if (_xml.@save == 'false')
                return null;

            var rtn:XML = new XML('<L KEY="" KEYNAME="" VALUE="" />');
            rtn.@VALUE = type + '://' + _xml.text().toString();
            rtn.@KEY = type;
            rtn.@KEYNAME = type;

            return rtn;
        }

        public function Init(xml:XML):void
        {
            var data_provider_arr:ArrayCollection;
            var child:XML;
            var node_name:String;
            var child_ctrl:YsControl;
            var dgc:DataGridColumn;

            _parent.addChild(this);
            _xml = new XML(xml);

            for (var attr_name:String in YsMaps.datagrid_attrs)
            {
                if (!(this.hasOwnProperty(attr_name)))
                {
                    Alert.show('YsDataGrid中没有 ' + attr_name + ' 属性');
                    continue;
                }

                if (_xml.attribute(attr_name).length() == 0)
                {
                    // XML中未描述此属性，取默认值
                    this[attr_name] = YsMaps.datagrid_attrs[attr_name]['default'];
                }
                else
                {
                    this[attr_name] = _xml.attribute(attr_name).toString();
                }
            }

            // 清空DataGridColumns
            columns = []; //.splice(0, columns.length);
            this.sortableColumns = false;

            if (xml.POOL != undefined)
            {
                var ddxml:XMLList = xml.POOL;

                if (xml.POOL == undefined)
                    return;
                if (xml.POOL.object == undefined)
                    return;
                if (xml.POOL.object.object == undefined)
                    return;
                var p_xml:XML = xml.POOL[0];
                var info_xml:XML = p_xml.object[0];
                var tran_xml:XML = info_xml.object[0];

                var _M_data:MData = Application.application.M_data;

                if (_M_data[p_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()] == null)
                    return;
                if (_M_data[p_xml.text()][info_xml.text()][tran_xml.text()] == null)
                    return;
                dataProvider = _M_data[p_xml.text()][info_xml.text()][tran_xml.text()];
            }
            else if (xml.DICT != undefined)
            {
                /*  <datagrid editable="true" itemEditEnd="true">
                   <DICT>DICT://DEPT_DTS</DICT>
                   <DICT>DICT://DEPTNAME</DICT>
                   <DICT>DICT://STATUS</DICT>
                   <DICT>DICT://STATUS_ID</DICT>
                   <DICT>DICT://DEPTNO</DICT>
                 </datagrid>*/
                //arr = P_data.data;
                //arr = P_data.proxy;
                var parent_pod:YsPod = UtilFunc.GetParentByType(this.parent, YsPod) as YsPod;
                var P_data:PData = parent_pod._M_data.TRAN[parent_pod.P_cont];
                var data_cont:int = P_data.datacont++;
                data_count = "data" + data_cont.toString();
                dataProvider = new ArrayCollection;
                //xingj ..
                P_data[data_count] = dataProvider;
                trace(dataProvider.length);

                // TODO:  用对象关注数据,对象再和datagrid的对应数据格关联
                //        创建一行数据，就建立了对应的一组DICT对象

                if (this.del)
                {
                    dgc = new DataGridColumn;
                    dgc.itemRenderer = new YsClassFactory(YsButton, this, del_btn_xml);
                    dgc.editable = false;
                    dgc.width = int(del_btn_xml.attribute('width'));

                    columns = columns.concat(dgc);
                }

                if (this.ins)
                {
                    dgc = new DataGridColumn;
                    dgc.itemRenderer = new YsClassFactory(YsButton, this, ins_btn_xml);
                    dgc.editable = false;
                    dgc.width = int(ins_btn_xml.attribute('width'));

                    columns = columns.concat(dgc);
                }

                if (this.add)
                {
                    dgc = new DataGridColumn;
                    dgc.itemRenderer = new YsClassFactory(YsButton, this, add_btn_xml);
                    dgc.editable = false;
                    dgc.width = int(add_btn_xml.attribute('width'));

                    columns = columns.concat(dgc);
                }
            }

            for each (child in xml.elements())
            {
                node_name = child.localName().toString().toLowerCase();

                if (node_name == 'button')
                {
                    dgc = new DataGridColumn;
                    dgc.itemRenderer = new YsClassFactory(YsButton, this, child);
                    dgc.editable = false;

                    columns = columns.concat(dgc);
                }
                else if (YsMaps.ys_type_map.hasOwnProperty(node_name))
                {
                    child_ctrl = new YsMaps.ys_type_map[node_name](this);
                    child_ctrl.Init(child);

                    if (child_ctrl is YsDict)
                        dict_arr.push(child_ctrl);
                }
            }

            var data_prov:ArrayCollection = dataProvider as ArrayCollection;
            if (this.default_line == true)
            {
                var new_item:Object = new Object;
                for each (dgc in columns)
                    if (dgc.itemRenderer == null)
                        new_item[dgc.dataField] = '';
                data_prov.addItem(new_item);
            }
        }

        protected var del_btn_xml:XML =
            <BUTTON LABEL="删除" width="60">删除
                <ACTION>data_grid_delete_line</ACTION>
            </BUTTON>
            ;

        protected var ins_btn_xml:XML =
            <BUTTON LABEL="插入" width="60">插入
                <ACTION>data_grid_insert_line</ACTION>
            </BUTTON>
            ;

        protected var add_btn_xml:XML =
            <BUTTON LABEL="追加" width="60">追加
                <ACTION>data_grid_append_line</ACTION>
            </BUTTON>
            ;

        protected function CheckEmptyObject(obj:Object):Boolean
        {
            var rtn:Boolean = true;
            for each (var obj_property:* in obj)
            {
                rtn = false;
                break;
            }

            return rtn;
        }

        private function itemEditEndHandler(e:DataGridEvent):void
        {
            this.listItems;
            e.target.dataProvider.refresh();
        }

        protected function OnCollectionAdd(event:CollectionEvent):void
        {
            var item:Object = event.items[0];
            // for each (var item:Object in event.items)
            {
                for each (var dgc:DataGridColumn in columns)
                    // for (var item_key:String in item)
                {
                    var item_key:String = dgc.dataField;
                    if (item_key == null)
                        continue;

                    for each (var to_data:PData in toDataObject[item_key].GetAllTarget())
                    {
                        if (!to_data.data.hasOwnProperty(item_key))
                            to_data.data[item_key] = new AdvanceArray;
                        to_data.data[item_key].Insert(event.location, item[item_key]);
                    }
                }
            }
        }

        protected function OnCollectionUpdate(event:CollectionEvent):void
        {
            for each (var event_item:PropertyChangeEvent in event.items)
            {
                var property:String = event_item.property.toString();
                var source_obj:Object = event_item.source;
                var arr:ArrayCollection = event.target as ArrayCollection;

                for each (var to_data:PData in toDataObject[property].GetAllTarget())
                {
                    if (!to_data.data.hasOwnProperty(property))
                        to_data.data[property] = new AdvanceArray;
                    //to_data.data[property]
                    var idx:int = arr.getItemIndex(source_obj);
                    to_data.data[property][idx] = source_obj[property];
                }
            }
        }

        protected override function collectionChangeHandler(event:Event):void
        {
            super.collectionChangeHandler(event);

            if (event is CollectionEvent)
            {
                var ceEvent:CollectionEvent = CollectionEvent(event);
                if (ceEvent.kind == CollectionEventKind.ADD)
                {
                    OnCollectionAdd(ceEvent);
                }
                else if (ceEvent.kind == CollectionEventKind.UPDATE)
                {
                    OnCollectionUpdate(ceEvent);
                }
            }
        }
    }
}