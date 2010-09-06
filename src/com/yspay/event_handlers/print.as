// ActionScript file
package com.yspay.event_handlers
{
    import com.yspay.YsControls.YsControl;
    import com.yspay.YsControls.YsMaps;
    import com.yspay.util.UtilFunc;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.FileReference;
    import flash.utils.ByteArray;

    import mx.containers.Panel;
    import mx.containers.TitleWindow;
    import mx.containers.VBox;
    import mx.controls.Alert;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.managers.PopUpManager;
    import mx.printing.FlexPrintJob;

    import org.alivepdf.fonts.IFont;
    import org.alivepdf.layout.Orientation;
    import org.alivepdf.layout.Size;
    import org.alivepdf.layout.Unit;
    import org.alivepdf.links.ILink;
    import org.alivepdf.links.InternalLink;
    import org.alivepdf.pages.Page;
    import org.alivepdf.pdf.PDF;
    import org.alivepdf.saving.Method;

    /**
     *
     * @param ui_comp
     * @param source_event
     * @param action_info
     * @return
     */
    /**
     *
     * @param ui_comp
     * @param source_event
     * @param action_info
     * @return
     */
    public function print(ui_comp:UIComponent, source_event:Event, action_info:XML):Boolean
    {
        /*
           <ACTION>print
           <Target>pod/windows
           </ACTION>
         */
        var target_type:Class = YsMaps.ys_type_map[action_info.Target.toString()];
        var orientation:String = 'Landscape';
        if (action_info.elements('Orientation').length() > 0)
        {
            orientation = action_info.Orientation.toString();
        }
        var page:Page = new Page(orientation);

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
            var pop:Panel =  PopUpManager.createPopUp(FlexGlobals.topLevelApplication as UIComponent,
                                                      Panel, true) as Panel;

            var print_page:VBox = new VBox;
            print_page.setStyle('border', 'none');
            print_page.setStyle('borderColor', '#ffffff');
            // 210 x 297
            print_page.width = page.width
            print_page.height = page.height;
            pop.addChild(print_page);
            pop.height = (page.height < FlexGlobals.topLevelApplication.height) ?
                page.height : FlexGlobals.topLevelApplication.height;
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
                    // print_area.width = print_job.pageWidth;
                    // print_area.height = print_job.pageHeight;
                    print_area.rotation = 90;
                    print_job.addObject(print_area);
                    print_job.send();
                        // print_area.rotation = 0;
                }
            };

            var printPDFBtn_Click:Function = function(event:Event):void
            {
                var p:PDF = new PDF(Orientation.PORTRAIT, Unit.MM, Size.A4);

                var l:ILink = new InternalLink(2, 0);

                p.addPage(page);

                p.addImage(print_area);

                var file:FileReference = new FileReference;
                // if (file.browse())
                file.save(p.save(Method.LOCAL), title + '.pdf');

            }

            var closeBtn:Button = new Button;
            closeBtn.label = '关闭';
            closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_Click);

            var printBtn:Button = new Button;
            printBtn.label = '输出PDF';
            printBtn.addEventListener(MouseEvent.CLICK, printPDFBtn_Click); //printBtn_Click);

            pop.addChildAt(closeBtn, 0);
            pop.addChildAt(printBtn, 0);

            var print_title:Label = new Label;
            print_title.width = print_page.width * 4 / 5;
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
