// ActionScript file
package com.yspay.util
{
    import mx.core.Container;
    
    public function GetParentByType(container:Container, parent_type:Class):*
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