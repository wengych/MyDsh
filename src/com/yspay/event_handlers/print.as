// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsControl;
    import com.yspay.YsControls.YsMaps;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;
    import flash.events.MouseEvent;

    import mx.containers.Panel;
    import mx.containers.TitleWindow;
    import mx.containers.VBox;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.core.Application;
    import mx.core.UIComponent;
    import mx.managers.PopUpManager;
    import mx.printing.FlexPrintJob;

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
        var CreatePrintPage:Function = function(title:String=''):UIComponent
            {
                trace('创建打印窗体');
                var pop:Panel =  PopUpManager.createPopUp(Application.application as UIComponent,
                                                          Panel, true) as Panel;

                var print_page:VBox = new VBox;
                print_page.setStyle('border', 'none');
                print_page.setStyle('borderColor', '#ffffff');
                // 210 x 297
                print_page.width = 210 * 3 - 60;
                print_page.height = 297 * 3 - 90;
                pop.addChild(print_page);
                pop.height = Application.application.height;
                pop.width = print_page.width + 100;
                PopUpManager.centerPopUp(pop);

                var closeBtn_Click:Function = function(event:Event):void
                    {
                        PopUpManager.removePopUp(pop);
                    };
                var printBtn_Click:Function = function(event:Event):void
                    {
                        var print_job:FlexPrintJob = new FlexPrintJob;

                        if (print_job.start())
                        {
                            print_job.addObject(print_area);
                            print_job.send();
                        }
                    };

                var closeBtn:Button = new Button;
                closeBtn.label = '关闭';
                closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_Click);

                var printBtn:Button = new Button;
                printBtn.label = '打印';
                printBtn.addEventListener(MouseEvent.CLICK, printBtn_Click);

                pop.addChildAt(closeBtn, 0);
                pop.addChildAt(printBtn, 0);

                var print_title:Label = new Label;
                print_title.width = print_page.width - 50;
                print_title.setStyle("textAlign", "center");
                print_title.text = title;
                print_title.setStyle('fontSize', '24');

                print_page.addChild(print_title);
                return print_page;
            }

        var print_area:UIComponent = target.Print(null, CreatePrintPage);
        return true;
    }
}
