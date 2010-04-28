// ActionScript file

package com.yspay.event_handlers
{
    import com.esria.samples.dashboard.view.NewWindow;

    import mx.containers.Form;
    import mx.containers.FormItem;
    import mx.containers.HBox;
    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Application;
    import mx.core.Container;

    public function clean_text(wnd:Object, event_container:Container):void
    {
        wnd.clean_allti_ta(event_container);
    }
}