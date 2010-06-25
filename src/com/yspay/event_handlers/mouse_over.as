// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsAction;
    import com.yspay.YsControls.YsButton;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.core.UIComponent;

    public function mouse_over(ui_comp:UIComponent,
                               source_event:Event,
                               action_info:XML):Boolean
    {
        if (!(source_event is MouseEvent))
        {
            trace('事件类型不匹配，不是MouseEvent');
            return false;
        }

        var mouse_event:MouseEvent = source_event as MouseEvent;
        var tool_tip_str:String = '';
        var _xml:XML = action_info;

        if (ui_comp is YsButton)
        {
            var btn:YsButton = ui_comp as YsButton;

            for each (var action:YsAction in btn.action_list)
            {
                if (tool_tip_str != '')
                    tool_tip_str += '\n';

                tool_tip_str += action.action_name;
            }
            ui_comp.toolTip = tool_tip_str;
        }

        return true;
    }
}