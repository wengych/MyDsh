// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.*;
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.TitleWindow;
    import mx.controls.Button;
    import mx.controls.TextArea;
    import mx.core.UIComponent;
    import mx.managers.PopUpManager;

    public function dbg_out_dict(ui_comp:UIComponent, event:Event, action_info:XML):Boolean
    {
        /*
           <action>testaction
           <From>pool
           <DICT>CURR_USER_ID</DICT>
           </From>
           </action>
         */
        var title:TitleWindow;
        var btn_Click:Function = function(event:MouseEvent):void
            {
                trace('btn_Click.');
                PopUpManager.removePopUp(title);
            };

        title = PopUpManager.createPopUp(ui_comp
                                         , mx.containers.TitleWindow
                                         , true) as TitleWindow;
        title.width = 400;
        title.height = 600;
        var ta:TextArea = new TextArea;
        var btn:Button = new Button;
        btn.label = '关闭';

        title.addChild(ta);
        ta.width = title.width;
        ta.height = 500;
        title.addChild(btn);
        btn.addEventListener(MouseEvent.CLICK, btn_Click);

        PopUpManager.centerPopUp(title);


        var from_targets:TargetList = new TargetList;
        from_targets.Init(ui_comp, action_info.From);

        var from_target_list:Array = from_targets.GetAllTarget();
        var from_name_list:Array = from_targets.GetAllTargetName();


        var from_target_dict:Array = from_targets.GetTargetDictArr();
        var dict_idx:int = 0;

        var len:int = from_target_list.length;
        for (var idx:int = 0; idx < len; ++idx)
        {
            var from_data:PData = from_target_list[idx];
            var from_name:String = from_name_list[idx];

            for (var dict_name_idx:int = 0; dict_name_idx < from_target_dict[idx].length; ++dict_name_idx)
            {
                var from_dict:String = from_target_dict[idx][dict_name_idx];
                if (from_data.data[from_dict] == undefined)
                {
                    trace('指定元素名无效: ', from_dict);
                    continue;
                }

                ta.text += from_data.data[from_dict].length.toString();
                ta.text += '\n';
                for (dict_idx = 0; dict_idx < from_data.data[from_dict].length; ++dict_idx)
                {
                    ta.text += from_data.data[from_dict][dict_idx];
                    ta.text += ',';
                }
                ta.text += '\n';
            }
        }

        return true;
    }
}
