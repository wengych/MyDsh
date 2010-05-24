package com.yspay.YsData
{
    import com.yspay.UserBus;
    import com.yspay.YsControls.YsPod;
    import com.yspay.YsVar;
    import com.yspay.util.YsObjectProxy;

    import mx.events.PropertyChangeEvent;
    import flash.utils.flash_proxy;
    import mx.utils.object_proxy;

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

            //CheckCount(1);
        }

        protected function UpdateChange(event:PropertyChangeEvent):void
        {

            var dict_proxy_item:Object;
            var source_obj:Object = event.source.object;

            if (source_obj is Array)
            {
                // 某一项被更新，需要从_data查找key
                var dict_key:String = GetKeyByObject(source_obj)
                if (dict_key == '')
                    return;
                for each (dict_proxy_item in dict_proxy[dict_key])
                {
                    dict_proxy_item.Notify(this, dict_key, event.property);
                }
            }
            else
            {
                // 某一数组被更新
                for each (dict_proxy_item in dict_proxy[event.property])
                {
                    dict_proxy_item.Notify(this, event.property, -1);
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
        public function AddToNotifiers(obj:Object, name:String, default_value:*=null):void
        {
            if (!dict_proxy.hasOwnProperty(name))
            {
                dict_proxy[name] = new Array;

                if (!_data.hasOwnProperty(name))
                {
                    _data[name] = new Array;
                    var def_v:* = (default_value == null) ? '' : default_value;
                    _data[name].push(def_v);
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

        public function Update(bus:UserBus):void
        {
            for each (var key_name:String in bus.GetKeyArray())
            {
                if (bus[key_name][0].value is String || bus[key_name][0].value is int)
                {
                    var arr:Array = new Array;
                    for each (var ys_var:YsVar in bus.GetVarArray(key_name))
                    {
                        arr.push(ys_var.value);
                    }
                    data[key_name] = arr;
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
