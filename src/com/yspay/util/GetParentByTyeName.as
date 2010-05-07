// ActionScript file
package com.yspay.util
{
    import com.hurlant.crypto.symmetric.NullPad;
    import com.yspay.YsPod;

    import flash.utils.getDefinitionByName;

    import mx.core.Container;

    public function GetParentByTypeName(container:Container, type_name:String):*
    {
        var parent:* = null;

        var parent_type:Class = getDefinitionByName(type_name) as Class;
        if (parent_type == null)
            return parent;

        while (container != null)
        {
            if (container is parent_type)
            {
                parent = container as parent_type;
                break;
            }

            container = container.parent as Container;
        }

        return parent;
    }
}