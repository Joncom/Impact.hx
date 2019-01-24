package impact;

class Map
{
    public var tilesize ( default, null ) : Int = 8;
    var width : Int = 1;
    var height : Int = 1;
    public var pxWidth ( default, null ) : Int;
    public var pxHeight ( default, null ) : Int;
    public var data : Array<Array<Int>> = [[]];
    public var name : String = null;

    public function new ( tilesize : Int, data : Array<Array<Int>> )
    {
        this.tilesize = tilesize;
        this.data = data;
        height = data.length;
        width = data[0].length;

        pxWidth = width * tilesize;
        pxHeight = height * tilesize;
    }

    public function getTile ( x : Float, y : Float ) {
        var tx : Int = Math.floor( x / tilesize );
        var ty : Int = Math.floor( y / tilesize );
        if(
            (tx >= 0 && tx <  width) &&
            (ty >= 0 && ty < height)
        ) {
            return data[ty][tx];
        }
        else {
            return 0;
        }
    }

    public function setTile ( x : Float, y : Float, tile : Int ) {
        var tx : Int = Math.floor( x / tilesize );
        var ty : Int = Math.floor( y / tilesize );
        if(
            (tx >= 0 && tx < width) &&
            (ty >= 0 && ty < height)
        ) {
            data[ty][tx] = tile;
        }
    }
}
