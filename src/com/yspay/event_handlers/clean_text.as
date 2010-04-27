// ActionScript file

package com.yspay.event_handlers
{
    import mx.controls.TextArea;
    import mx.controls.TextInput;
    import mx.core.Container;

    public function clean_text(wnd:Object, event_container:Container):void
    {
        var children:Array = event_container.getChildren();

        for each (var obj:Object in children)
        {
            var ti:TextInput = obj as TextInput;
            if (ti != null)
                ti.text = ti.data.value = '';

            var ta:TextArea = obj as TextArea;
            if (ta != null)
                ta.text = ta.data.value = '';
        }
    }
}