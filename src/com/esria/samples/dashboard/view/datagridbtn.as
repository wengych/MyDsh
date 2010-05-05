package com.esria.samples.dashboard.view
{
    import com.yspay.YsPod;

    import flash.events.MouseEvent;

    import mx.controls.Button;
    import mx.controls.DataGrid;
    import mx.controls.dataGridClasses.DataGridColumn;
    import mx.utils.ObjectProxy;

    public class datagridbtn extends Button
    {

        public var xml:XML;
        public var yspod:YsPod;
        public var dg:DataGrid;

        public function datagridbtn()
        {
            this.label = xml.@LABEL;
            if (xml.ACTION.text() == "_add_line")
                this.addEventListener(MouseEvent.CLICK, add);
            else if (xml.ACTION.text() == "_delete_line")
                this.addEventListener(MouseEvent.CLICK, del);
            else
                this.addEventListener(MouseEvent.CLICK, yspod.OnBtnClick);

        }

        public function del(e:MouseEvent):void
        {
            for each (var dgc:DataGridColumn in dg.columns)
            {
                var dictname:String = dgc.dataField;
                for (var i:int = dg.dataProvider.getItemIndex(data); i < dg.dataProvider.length; i++)
                {
                    if (dg.dataProvider[i][dictname] == null)
                        break;
                    dg.dataProvider[i][dictname] = dg.dataProvider[i + 1][dictname];
                }
            }
            dg.dataProvider.refresh();
        }

        public function add(e:MouseEvent):void
        {
            var P_data:Object = yspod._M_data.TRAN[yspod.P_cont];
            for each (var dgc:DataGridColumn in dg.columns)
            {
                var dictname:String = dgc.dataField;
                for (var i:int = dg.dataProvider.length; i > dg.dataProvider.getItemIndex(data); i--)
                {
                    if (dg.dataProvider[i] == null)
                    {
                        P_data.data.addItem(new Object);
                        P_data.proxy.addItem(new Object);
                        var proxy:ObjectProxy;
                        proxy = new ObjectProxy(P_data.data[i]);
                        proxy.DictNum = i;
//                        proxy.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
//                                               updateChange);
                        P_data.proxy[i] = proxy;
                    }
                    dg.dataProvider.addItem(new Object);
                    dg.dataProvider[i][dictname] = dg.dataProvider[i - 1][dictname];
                }
            }
            dg.dataProvider.refresh();
//            var obj:Object =;
//            arr.addItemAt(obj, arr.getItemIndex(data) + 1);
//            arr.refresh();
        }

    }
}