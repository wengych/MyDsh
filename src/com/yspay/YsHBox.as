package com.yspay
{
    import com.yspay.pool.Pool;
    import com.yspay.util.FunctionDelegate;
    import com.yspay.event_handlers.EventHandlerFactory;

    import mx.containers.HBox;
    import mx.core.Application;

    public class YsHBox extends HBox implements YsControl
    {
        protected var _pool:Pool;

        public function YsHBox()
        {
            super();
            _pool = Application.application._pool;
        }

        public function Init(xml:XML):void
        {
            percentWidth = 100;
            setStyle('borderStyle', 'solid');
            setStyle('fontSize', '12');

            var child_name:String;
            for each (var child:XML in xml.elements())
            {
                child_name = child.name().toString().toLowerCase();
                if (child_name == 'dict')
                {
                    // ShowDict(hbox, childs);
                    var dict:YsDict = new YsDict(child);

                    if (dict.label != null)
                        this.addChild(dict.label);
                    if (dict.text_input != null)
                        this.addChild(dict.text_input);
                    if (dict.combo_box != null)
                        this.addChild(dict.combo_box);
                }
                else if (child_name == 'button')
                {
                    var ys_btn:YsButton = new YsButton;
                    this.addChild(ys_btn);
                    ys_btn.Init(child);
                }
                else if (child_name == 'event')
                {
                    /*
                       <event>
                       dragDrop
                       <ACTION>new_window</ACTION>
                       </event>
                     */
                    addEventListener(child.text().toString(),
                                     EventHandlerFactory.get_handler(child.ACTION.text()));
                }
            }
        }


    }
}