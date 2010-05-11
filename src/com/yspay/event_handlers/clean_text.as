// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsData.PData;
    import com.yspay.YsHBox;
    import com.yspay.YsPod;
    import com.yspay.YsTitleWindow;
    import com.yspay.util.GetParentByType;

    import flash.display.DisplayObjectContainer;

    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Container;
    import mx.core.UIComponent;

    public function clean_text(ui_comp:UIComponent):void
    {
        var func:Function = function(container:Container, ys_pod:YsPod):void
            {
                for each (var child:*in container.getChildren())
                {
                    if (child is TextArea || child is TextInput)
                    {
                        child.text = '';

                        var Pod_data:PData = ys_pod._M_data.TRAN[ys_pod.P_cont];
                        Pod_data.data[child.data.index][child.data.name] = '';
                    }
                    else if (child is Container)
                    {
                        func(child);
                    }
                }
            }

        var target:DisplayObjectContainer = ui_comp;
        var pod:YsPod = GetParentByType(ui_comp.parent, YsPod) as YsPod;

        while (target != null)
        {
            if (target is YsHBox || target is YsTitleWindow || target is YsPod)
                break;

            target = target.parent;
        }

        if (target == null || pod == null)
            return;

        func(target, pod);
    }
}