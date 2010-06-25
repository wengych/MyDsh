// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.AdvanceArray;

    import flash.events.Event;

    import mx.core.UIComponent;

    public function copy_dict(ui_comp:UIComponent,
                              source_event:Event,
                              action_info:XML):Boolean
    {
        /*
           <action>copy_dict
           <From>pool
           <DICT>CURR_USER_ID</DICT>
           </From>
           <To>pod
           <DICT>REQ_USER_ID</DICT>
           </To>
           </action>
         */

        var from_targets:TargetList = new TargetList;
        from_targets.Init(ui_comp, action_info.From);
        var to_targets:TargetList = new TargetList;
        to_targets.Init(ui_comp, action_info.To);

        var from_target_list:Array = from_targets.GetAllTarget();
        var to_target_list:Array = to_targets.GetAllTarget();
        var from_target_dict:Array = from_targets.GetTargetDictArr();
        var to_target_dict:Array = to_targets.GetTargetDictArr();

        for (var idx:int = 0; idx < to_target_list.length; ++idx)
        {
            var from_data:PData = from_target_list[idx];
            var to_data:PData = to_target_list[idx];
            for (var dict_name_idx:int = 0; dict_name_idx < from_target_dict[idx].length; ++dict_name_idx)
            {
                var from_dict:String = from_target_dict[idx][dict_name_idx];
                var to_dict:String = to_target_dict[idx][dict_name_idx];

                if (!from_data.data.hasOwnProperty(from_dict))
                {
                    to_data.data[to_dict] = new AdvanceArray;
                    continue;
                }

                for (var dict_idx:int = 0; dict_idx < from_data.data[from_dict].length; ++dict_idx)
                {
                    if (!to_data.data.hasOwnProperty(to_dict))
                        to_data.data[to_dict] = new AdvanceArray;

                    if (to_data.data[to_dict].length <= dict_idx)
                        to_data.data[to_dict].Insert(dict_idx, '');
                    to_data.data[to_dict][dict_idx] = from_data.data[from_dict][dict_idx];
                }
            }
        }

        return true;
    }
}