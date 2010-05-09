// ActionScript file
package com.yspay.util
{
    import flash.display.DisplayObjectContainer;
    
    import mx.core.Container;
    
    public function GetParentByType(container:DisplayObjectContainer, parent_type:Class):*
    {
        var parent:* = null;
        
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