package impact;

import kha.math.Vector2;

class Image implements Loadable
{
    public var data ( default, null ) : kha.Image;
    public var width ( default, null ) : Int = 0;
    public var height ( default, null ) : Int = 0;
    public var loaded ( default, null ) : Bool = false;
    var failed : Bool = false;
    var loadCallback : String -> Bool -> Void;
    public var path ( default, null ) : String = '';
    var khaName : String;
    var _scratchVector = new Vector2(0, 0);

    public function new ( path : String )
    {
        khaName = Global.khaName(path);

        // HACK: Replace all "-hd" images with path to @4x version
        var needle = "_hd";
        var index = khaName.indexOf(needle);
        if(index >= 0) {
            // var prefix = path.substr(0, index);
            // var suffix = path.substr(index + needle.length); // Needed to include things after extension (example.png#color=FFF)
            khaName += "_4x"; // + suffix;
        }

        this.path = path;
        this.load();
    }

    public function load ( ?loadCallback )
    {
        if( this.loaded ) {
            if( loadCallback != null ) {
                loadCallback( this.path, true );
            }
            return;
        }
        // else if( !this.loaded && Global.ready ) {
            this.loadCallback = loadCallback;

            this.data = kha.Assets.images.get(khaName);
            if(data == null) {
                throw "Failed to load graphic: " + khaName;
            }
            // this.data.onload = this.onload.bind(this);
            // this.data.onerror = this.onerror.bind(this);
            // this.data.src = ig.prefix + this.path + ig.nocache;
            this.onload( null );
        /*
        }
        else {
            Global.addResource( this );
        }
        */
        Image.cache[this.path] = this;
    }

    function reload ()
    {
        /*
        this.loaded = false;
        this.data = new Image();
        this.data.onload = this.onload.bind(this);
        this.data.src = this.path + '?' + Date.now();
        */
    }

    function onload ( event )
    {
        this.width = this.data.width;
        this.height = this.data.height;
        this.loaded = true;

        if( Global.system.scale != 1 ) {
            this.resize( Global.system.scale );
        }

        if( this.loadCallback != null ) {
            this.loadCallback( this.path, true );
        }
    }

    function resize ( scale : Float )
    {
        /* START CUSTOM RETINA LOGIC */

        // Image is retina scale?
        if(retinaScale > 1) {
            // Reset metrics to what they'd normally be.
            // This assumes metrics were just set in the onload function.
            // Calling again might cause problems?
            this.width = Std.int( this.width / retinaScale );
            this.height = Std.int( this.height / retinaScale );

            /*
            // Image is already the correct scale?
            if(scale == retinaScale) {
                // No need to re-scale
                return;
            } else {
                var message = "The following image was loaded, but should not have been, because it's the wrong scale: " + this.path;
                throw message;
            }
            */
        }
        /* END CUSTOM RETINA LOGIC */

        /*
        // Nearest-Neighbor scaling

        // The original image is drawn into an offscreen canvas of the same size
        // and copied into another offscreen canvas with the new size.
        // The scaled offscreen canvas becomes the image (data) of this object.

        var origPixels = ig.getImagePixels( this.data, 0, 0, this.width, this.height );

        var widthScaled = this.width * scale;
        var heightScaled = this.height * scale;

        var scaled = ig.$new('canvas');
        scaled.width = widthScaled;
        scaled.height = heightScaled;
        var scaledCtx = scaled.getContext('2d');
        var scaledPixels = scaledCtx.getImageData( 0, 0, widthScaled, heightScaled );

        for( var y = 0; y < heightScaled; y++ ) {
            for( var x = 0; x < widthScaled; x++ ) {
                var index = (Math.floor(y / scale) * this.width + Math.floor(x / scale)) * 4;
                var indexScaled = (y * widthScaled + x) * 4;
                scaledPixels.data[ indexScaled ] = origPixels.data[ index ];
                scaledPixels.data[ indexScaled+1 ] = origPixels.data[ index+1 ];
                scaledPixels.data[ indexScaled+2 ] = origPixels.data[ index+2 ];
                scaledPixels.data[ indexScaled+3 ] = origPixels.data[ index+3 ];
            }
        }
        scaledCtx.putImageData( scaledPixels, 0, 0 );

        // Workaround for Chrome 49 bug - handling many offscreen canvases
        // seems to slow down the browser significantly. So we convert the
        // upscaled canvas back to an image.
        this.data = new Image();
        this.data.src = scaled.toDataURL();
        */
    }

    public function draw ( targetX : Float, targetY : Float, ?sourceX : Int, ?sourceY : Int, ?width : Float, ?height : Float )
    {
        if( data != null ) {
            var scale = Global.system.scale;
            sourceX = sourceX != null ? sourceX : 0;
            sourceY = sourceY != null ? sourceY : 0;
            /*
            width = (width ? width : this.width) * scale;
            height = (height ? height : this.height) * scale;
            */
            width = (width == null ? this.width : width);
            height = (height == null ? this.height : height);

            _scratchVector.x = Global.system.matrix.m00;
            _scratchVector.y = Global.system.matrix.m01;
            var scaleX = _scratchVector.length;
            _scratchVector.x = Global.system.matrix.m10;
            _scratchVector.y = Global.system.matrix.m11;
            var scaleY = _scratchVector.length;

            Global.system.graphics.drawScaledSubImage(
                data,
                sourceX * retinaScale,
                sourceY * retinaScale,
                width * retinaScale,
                height * retinaScale,
                (Global.system.matrix.m02 + targetX * scaleX) * scale,
                (Global.system.matrix.m12 + targetY * scaleY) * scale,
                width * scale * scaleX,
                height * scale * scaleY
            );
            drawCount++;
        }
    }

    public function drawTile ( targetX : Float, targetY : Float, tile : Int, tileWidth : Int, ?tileHeight : Int, ?flipX : Bool = false, ?flipY : Bool = false )
    {
        tileHeight = (tileHeight != null ? tileHeight : tileWidth);

        if( !loaded || tileWidth > width || tileHeight > height ) { return; }

        var scale = Global.system.scale;
        var sourceX : Int = Std.int( Math.floor(tile * tileWidth) % width );
        var sourceY : Int = ( Math.floor(tile * tileWidth / width) * tileHeight );

        // TODO: Doesn't yet honor scaling via matrix
        Global.system.graphics.drawScaledSubImage(
            data,
            sourceX * retinaScale,
            sourceY * retinaScale,
            tileWidth * retinaScale,
            tileHeight * retinaScale,
            (targetX + Global.system.matrix.m02 + (flipX ? tileWidth : 0)) * scale,
            (targetY + Global.system.matrix.m12 + (flipY ? tileHeight : 0)) * scale,
            tileWidth * (flipX ? -1 : 1) * scale,
            tileHeight * (flipY ? -1 : 1) * scale
        );

        // TODO: Figure out the scale logic (greater than 1)

        /*
        var scale : Int = Global.system.scale;
        var tileWidthScaled : Int = Math.floor(tileWidth * scale);
        var tileHeightScaled : Int = Math.floor(tileHeight * scale);

        var scaleX : Int = flipX ? -1 : 1;
        var scaleY : Int = flipY ? -1 : 1;

        if( flipX || flipY ) {
            Global.system.context.save();
            Global.system.context.scale( scaleX, scaleY );
        }
        Global.system.context.drawSubTexture(
            data,
            Global.system.getDrawPos(targetX) * scaleX - (flipX ? tileWidthScaled : 0),
            Global.system.getDrawPos(targetY) * scaleY - (flipY ? tileHeightScaled : 0),
            ( Math.floor(tile * tileWidth) % width ) * scale,
            ( Math.floor(tile * tileWidth / width) * tileHeight ) * scale,
            tileWidthScaled,
            tileHeightScaled
        );
        if( flipX || flipY ) {
            Global.system.context.restore();
        }
        */

        drawCount++;
    }

    public var retinaScale ( get, null ) : Int = -1;
    function get_retinaScale () : Int
    {
        // Not yet initialized?
        if(retinaScale == -1) {
            var r = ~/^.*_([0-9])x+$/;
            return retinaScale = ( r.match( khaName ) ? Std.parseInt( r.matched( 1 ) ) : 1 );
        } else {
            return retinaScale;
        }
    }

    public static var drawCount = 0;
    public static var cache = new std.Map<String, Image>();
}
