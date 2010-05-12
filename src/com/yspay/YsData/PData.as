package com.yspay.YsData
{
    import com.yspay.YsPod;

    import flash.display.DisplayObject;

    import mx.collections.ArrayCollection;
    import mx.events.PropertyChangeEvent;
    import mx.utils.ObjectProxy;

    /**
     *
     * @author Administrator
     */
    public dynamic class PData
    {
        /**
         *
         * @param pod
         */
        public function PData(pod:YsPod)
        {
            ys_pod = pod;

            cont = 10000;
            datacont = 1000;
            _data = new ArrayCollection;
            data = new ArrayCollection;
            dict_proxy = new ArrayCollection;
            data_grid = new ArrayCollection;

            CheckCount(1);
        }

        // 如果数据字典项下标超出现在的data的最大范围，则新增一个
        /**
         *
         * @param data_count
         */
        public function CheckCount(data_count:int):void
        {
            var curr:int = _data.length;
            if (data_count <= curr)
            {
                return;
            }

            _data.addItem(new Object);

            var proxy:ObjectProxy = new ObjectProxy(_data[curr]);
            proxy.DictNum = curr;
            proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                                   ys_pod.updateChange);
            data.addItem(proxy);
        }


        /**
         * 在ctrls_proxy中新加控件索引
         * 循环ArrayCollection所有坐标
         * 找到一个ctrl.data.name属性不存在的节点添加ctrl
         * 若循环至Array结尾，则新增元素存储ctrl
         * @param disp_obj
         */
        public function AddDict(dict:Object, default_value:*):void
        {

            for (var i:int = 0; i <= dict_proxy.length; i++)
            {
                if (i == dict_proxy.length)
                {
                    dict_proxy.addItem(new Object);
                }
                if (dict_proxy[i][dict.name] == null)
                    dict_proxy[i][dict.name] = new Object;
                if (dict_proxy[i][dict.name][dict.index] == null)
                {
                    //ti ArrayCollection 的 i个Object的[英文名][索引号]
                    dict_proxy[i][dict.name][dict.index] = dict;
                    break;
                }
            }

            if (_data[0][dict.name] == undefined)
            {
                // 如节点不存在,创建新节点
                _data[0][dict.name] = '';
                data[0][dict.name] = (default_value == null) ? '' : default_value.toString();
            }
            else
            {
                // 节点存在,为控件赋值
                dict.text = data[0][dict.name];
            }
        }

        /**
         *
         * @param disp
         * @return
         */
        public function Create(disp:DisplayObject):int
        {
            var obj:Object = new Object();
            this[cont] = obj;
            cont++;

            return (cont - 1);
        }

        /**
         *
         * @param index
         * @return
         */
        public function getPData(index:int):PData
        {
            return this[index];
        }

        /**
         *
         * @default
         */
        public var xml:XML;
        /**
         *
         * @default
         */
        public var cont:int;
        public var datacont:int;
        /**
         *
         * @default
         */
        public var ys_pod:YsPod;
        /**
         *
         * @default
         */
        public var _data:ArrayCollection; // 实际存放数据对象
        /**
         *
         * @default
         */
        public var data:ArrayCollection; // 数据访问proxy
        /**
         *
         * @default
         */
        public var dict_proxy:ArrayCollection; // 控件更新用的proxy
        /**
         *
         * @default
         */
        public var data_grid:ArrayCollection; // 反向查找序列号，数据更新使用(DataGrid)
    }
}