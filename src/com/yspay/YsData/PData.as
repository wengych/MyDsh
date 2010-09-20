package com.yspay.YsData
{
    import com.yspay.UserBus;
    import com.yspay.YsControls.YsPod;
    import com.yspay.util.AdvanceArray;
    import com.yspay.util.FunctionCallEvent;
    import com.yspay.util.YsObjectProxy;

    import flash.utils.flash_proxy;

    import mx.events.PropertyChangeEvent;
    import mx.utils.object_proxy;

    import org.osmf.layout.AbsoluteLayoutFacet;

    use namespace flash_proxy;
    use namespace object_proxy;

    public dynamic class PData
    {
        public function PData()
        {
            cont = 10000;
            datacont = 1000;
            _data = new Object;
            data = new YsObjectProxy(_data);
            dict_proxy = new Object;

            data.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                                  UpdateChange);
            data.addEventListener(FunctionCallEvent.EVENT_NAME,
                                  FunctionCalled);
        }

        protected function FunctionCalled(event:FunctionCallEvent):void
        {
            trace('PData::FunctionCalled:: ' + event.type + ' ' + event.function_name + ' ' + event.args);

            var dict_proxy_item:Object;
            var source_obj:Object = event.source.object;

            if (source_obj is AdvanceArray)
            {
                var dict_key:String = GetKeyByObject(source_obj);
                if (dict_key == '')
                    return;

                trace('PData::FunctionCalled::dict_key: ' + dict_key);
                trace('PData::FunctionCalled:: source_obj', source_obj);
                for each (dict_proxy_item in dict_proxy[dict_key])
                {
                    dict_proxy_item.NotifyFunctionCall(this,
                                                       dict_key,
                                                       event.function_name,
                                                       event.args);
                }
            }
        }

        protected function UpdateChange(event:PropertyChangeEvent):void
        {
            trace('PData::UpdateChange:: ' + event.type + ' ' + event.property + ' ' + event.newValue);

            var dict_proxy_item:Object;
            var source_obj:Object = event.source.object;

            if (source_obj is AdvanceArray)
            {
                // 某一项被更新，需要从_data查找key
                var dict_key:String = GetKeyByObject(source_obj)
                if (dict_key == '')
                    return;

                trace('PData::UpdateChange:: source_obj', source_obj);
                for each (dict_proxy_item in dict_proxy[dict_key])
                {
                    dict_proxy_item.Notify(this, dict_key, event.property);
                }
            }
        }

        /**
         * 在ctrls_proxy中新加控件索引
         * 循环ArrayCollection所有坐标
         * 找到一个ctrl.data.name属性不存在的节点添加ctrl
         * 若循环至Array结尾，则新增元素存储ctrl
         * @param disp_obj
         */
        public function AddToNotifiers(obj:Object,
                                       name:String,
                                       default_value:*=null):void
        {
            if (!dict_proxy.hasOwnProperty(name))
            {
                dict_proxy[name] = new AdvanceArray;

                if (!_data.hasOwnProperty(name))
                {
                    _data[name] = new AdvanceArray;
                    if (default_value != null)
                        _data[name].push(default_value);
                }
            }

            dict_proxy[name].push(obj);
        }

        public function GetKeyByObject(obj:Object):String
        {
            for (var key:String in _data)
            {
                if (obj == _data[key])
                    return key;
            }

            return '';
        }

        public function GetKeyNameByArrayItem(obj:Object):String
        {
            for (var key:String in _data)
            {
                if (obj == _data[key])
                    return key;

                for (var arr_obj:Object in _data[key])
                {
                    if (arr_obj == obj)
                        return key;
                }
            }

            return '';
        }

        public function HasChild(obj:Object):Boolean
        {
            for each (var child_arr:Array in _data)
            {
                if (obj == child_arr)
                    return true;

                for (var arr_obj:Object in child_arr)
                {
                    if (arr_obj == obj)
                        return true;
                }
            }

            return false;
        }

        public function getPData(index:int):PData
        {
            return this[index];
        }

        public function ClearDict(dict_key:String):void
        {
            if (_data.hasOwnProperty(dict_key))
                data[dict_key].RemoveItems(0);
        }

        public function Update(bus:UserBus, dict_key_arr:Array):void
        {
            var arr:Array;
            var new_item_count:int = 0;
            var idx:int = 0;

            for each (var key_name:String in dict_key_arr)
            {
                if (!(bus.hasOwnProperty(key_name)))
                    continue;

                if (bus[key_name][0].value is String ||
                    bus[key_name][0].value is int)
                {
                    if (!(data.hasProperty(key_name)))
                        data[key_name] = new AdvanceArray;
                    arr = bus.GetVarArray(key_name);
                    new_item_count = arr.length - data[key_name].length;
                    idx = 0;

                    if (new_item_count > 0)
                    {
                        data[key_name].AddEmptyItems(new_item_count);
                    }
                    else if (new_item_count < 0)
                    {
                        data[key_name].RemoveItems(arr.length);
                    }

                    for (idx = 0; idx < arr.length; ++idx)
                    {
                        data[key_name][idx] = arr[idx].value;
                    }
                }
            }
        }

        public var cont:int;
        public var datacont:int;
        public var ys_pod:YsPod;
        public var _data:Object; // 实际存放数据对象
        public var data:YsObjectProxy; // 数据访问proxy

        //  YsDict或YsDataGrid列表，数据更新时通知对应数据字典名列表中的每一个对象
        public var dict_proxy:Object;
    }
}
