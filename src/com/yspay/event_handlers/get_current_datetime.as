// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.AdvanceArray;

    import flash.events.Event;

    import mx.core.UIComponent;
    import mx.formatters.DateFormatter;

    public function get_current_datetime(ui_comp:UIComponent,
                                         source_event:Event,
                                         action_info:XML):Boolean
    {
        var now:Date = new Date;
        var df:DateFormatter = new DateFormatter;
        df.formatString = action_info.Format
        trace(now);

        var datetime_string:String = df.format(now);
        trace(datetime_string);

        var to_targets:TargetList = new TargetList;
        to_targets.Init(ui_comp, action_info.To);
        var to_target_dict:Array = to_targets.GetTargetDictArr();

        var to_target_list:Array = to_targets.GetAllTarget();

        for (var idx:int = 0; idx < to_target_list.length; ++idx)
        {
            var to_data:PData = to_target_list[idx];

            for each (var dict_name:String in to_target_dict)
            {
                if (to_data.data[dict_name] == undefined)
                    to_data.data[dict_name] = new AdvanceArray;
                to_data.data[dict_name][0] = datetime_string;
            }
        }

        return true;
    }
}
