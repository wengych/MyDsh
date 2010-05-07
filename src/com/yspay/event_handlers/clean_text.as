// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsPod;

    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Container;
    import mx.core.UIComponent;

    public function clean_text(ui_comp:UIComponent):void
    {
        // wnd.clean_allti_ta(event_container);
        var ys_pod:YsPod = EventHandlerFactory.GetParentYsPod(ui_comp.parent as Container);

        var func:Function = function(container:Container):void
            {
                for each (var child:* in container.getChildren())
                {
                    if (child is TextArea || child is TextInput)
                    {
                        child.text = child.data.value = '';

                        var Pod_data:Object = ys_pod._M_data.TRAN[ys_pod.P_cont];
                        Pod_data.proxy[child.data.index][child.data.name] = '';
                    }
                    else if (child is Container)
                    {
                        func(child);
                    }
                }
            }

        func(ys_pod);

        //children = wnd.getChildren();

    }

/*
   protected function clean_allti_ta(obj:Object):void
   {
   var children:Array;
   var o:Object;

   children = obj.getChildren();
   for each (o in children)
   {
   if ((o is HBox) || (o is Form) || o is NewWindow || o is FormItem)
   clean_allti_ta(o);
   else if (o is TextArea)
   {
   var ta:TextArea = o as TextArea;
   ta.text = ta.data.value = '';
   _M_data.TRAN[P_cont].proxy[ta.data.index][ta.data.name] = '';
   }
   else if (o is TextInput)
   {
   var ti:TextInput = o as TextInput;
   ti.text = ti.data.value = '';
   _M_data.TRAN[P_cont].proxy[ti.data.index][ti.data.name] = '';
   }
   }
   }
 */
}