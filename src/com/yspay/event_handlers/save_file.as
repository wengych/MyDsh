// ActionScript file

package com.yspay.event_handlers
{
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;

    import flash.events.Event;
    import flash.net.FileReference;
    import flash.utils.ByteArray;

    import mx.core.UIComponent;

    public function save_file(ui_comp:UIComponent, event:Event, action_info:XML):Boolean
    {
        var from_targets:TargetList = new TargetList;

        var type:String = action_info.Type;
        var name:String = action_info.Name;
        from_targets.Init(ui_comp, action_info.From);
        var from_target_list:Array = from_targets.GetAllTarget();
        var from_name_list:Array = from_targets.GetAllTargetName();
        var from_target_dict:Array = from_targets.GetTargetDictArr();
        var from_data:PData = from_target_list[0];
        var from_dict:Object = from_data.data[from_target_dict[0][0]];

        if (type == 'String')
        {
            var str:String = '';
            for each (var item:Object in from_dict)
            {
                str += item;
            }

            var file:FileReference = new FileReference;
            var byte_arr:ByteArray = new ByteArray;
            byte_arr.writeMultiByte(str, 'cn-GB');
            file.save(byte_arr, name);
        }

        return true;
    }
}