// ActionScript file

package com.yspay.event_handlers
{
    import mx.core.Container;
    import mx.controls.Alert;
    import mx.controls.TextInput;

    public function bus2window(wnd:Object, container:Container):void
    {
        var children:Array = container.getChildren();
        var ti:TextInput;
    /*
       for each (var obj:Object in children)
       {
       var ti:TextInput = obj as TextInput;
       if (ti != null && ti.data.key == '')

       }
     */
         //Alert.show(wnd.main_bus.toString());
    }
}
