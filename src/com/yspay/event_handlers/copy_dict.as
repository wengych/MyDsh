// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsData.TargetList;

    import flash.events.Event;

    import mx.core.UIComponent;

    public function copy_dict(ui_comp:UIComponent,
                              source_event:Event,
                              action_info:XML):void
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

        for (var idx:int = 0; idx < from_target_list.length; ++idx)
        {
            for (var dict_idx:int = 0; dict_idx < from_target_dict[idx].length; ++dict_idx)
            {
                to_target_list[idx].data[to_target_dict[dict_idx]] =
                    from_target_list[idx].data[from_target_dict[dict_idx]];
            }
        }
    }
}