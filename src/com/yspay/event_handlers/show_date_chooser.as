// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsDict;
    import com.yspay.YsData.PData;
    import com.yspay.YsData.TargetList;
    import com.yspay.util.AdvanceArray;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;

    import mx.controls.DateChooser;
    import mx.core.UIComponent;
    import mx.events.CalendarLayoutChangeEvent;
    import mx.formatters.DateFormatter;

    public function show_date_chooser(ui_comp:UIComponent,
                                      source_event:Event,
                                      action_info:XML):Boolean
    {
        var dict:YsDict = UtilFunc.YsGetParentByType(ui_comp, YsDict) as YsDict;
        var old_width:int = ui_comp.width;
        var date_chooser:DateChooser = new DateChooser;

        var df:DateFormatter = new DateFormatter;
        df.formatString = action_info.Format;

        var now:Date = new Date;
        var dict_date:String = dict.dict.text;

        var year:Number = dict_date.length == 8 ? Number(dict_date.substr(0, 4)) : now.fullYear;
        var month:Number = dict_date.length == 8 ? Number(dict_date.substr(4, 2)) : now.month;
        var day:Number = dict_date.length == 8 ? Number(dict_date.substr(6, 2)) : now.day;

        date_chooser.selectedDate = new Date(year, month - 1, day);

        var call_back:Function = function(event:CalendarLayoutChangeEvent):void
            {
                var datetime_string:String = df.format(event.newDate);

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

                dict.removeChild(date_chooser);
                ui_comp.width = old_width;
                ui_comp.visible = true;
            };

        date_chooser.yearNavigationEnabled = true;
        date_chooser.addEventListener(CalendarLayoutChangeEvent.CHANGE, call_back);
        ui_comp.visible = false;
        ui_comp.width = 0;
        dict.addChild(date_chooser);


        return true;
    }
}
