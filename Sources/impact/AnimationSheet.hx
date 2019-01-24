package impact;

import impact.Image;

class AnimationSheet
{
    public var width ( default, null ) : Int = 8;
    public var height ( default, null ) : Int = 8;
    public var image ( default, null ) : Image = null;
    
    public function new ( path : String, width : Int, height : Int ) {
        this.width = width;
        this.height = height;

        image = new Image( path );
    }
}
