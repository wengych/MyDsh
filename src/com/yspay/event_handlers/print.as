// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsControl;
    import com.yspay.YsControls.YsMaps;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;
    import flash.printing.PrintJob;

    import mx.controls.Alert;
    import mx.core.UIComponent;
    import mx.managers.PopUpManager;

    public function print(ui_comp:UIComponent, source_event:Event, action_info:XML):Boolean
    {
        /*
           <ACTION>print
           <Target>pod/windows
           </ACTION>
         */
        var target_type:Class = YsMaps.ys_type_map[action_info.Target.toString()];
        if (target_type == null)
        {
            trace('获取类型失败, 类型名: ', action_info.Target.toString());
            Alert.show('获取类型失败, 类型名: ' + action_info.Target.toString());
            return true;
        }

        var target:YsControl = UtilFunc.YsGetParentByType(ui_comp, target_type) as YsControl;
        if (target == null)
        {
            trace('获取对象失败, 对象类型: ', action_info.Target.toString());
            Alert.show('获取对象失败, 对象类型: ' + action_info.Target.toString());
            return true;
        }
        var print_area:UIComponent = target.Print(null);
        /*
           var print_job:PrintJob = new PrintJob;

           if (print_job.start())
           {
           print_job.addPage(print_area);
           print_job.send();
           }

           PopUpManager.removePopUp(print_area);
         */
        return true;
    }
}
