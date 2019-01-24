package impact;

class Animation
{
    public var sheet : AnimationSheet = null;
    public var timer ( default, null ) : Timer = null;

    public var frameTime : Float;
    public var sequence : Array<Int> = [];
    public var flip : { x : Bool, y : Bool } = { x : false, y : false };
    var pivot : { x : Float, y : Float };
    public var stop : Bool;

    var frame : Int = 0;
    var tile : Int = 0;
    public var loopCount ( default, null ) : Int = 0;
    public var alpha : Float = 1;
    public var angle : Float = 0;
    public var scale = { x : 1.0, y: 1.0 };

    public function new ( sheet : AnimationSheet, frameTime : Float, sequence : Array<Int>, ?stop : Bool = false ) {
        this.sheet = sheet;
        this.pivot = {x: sheet.width/2, y: sheet.height/2 };
        this.timer = new impact.Timer();

        this.frameTime = frameTime;
        this.sequence = sequence;
        this.stop = stop;
        tile = this.sequence[0];
    }

    public function rewind () : Animation
    {
        timer.set();
        loopCount = 0;
        frame = 0;
        tile = this.sequence[0];
        return this;
    }

    public function gotoFrame ( f : Int ) : Void
    {
        // Offset the timer by one tenth of a millisecond to make sure we
        // jump to the correct frame and circumvent rounding errors
        timer.set( frameTime * -f - 0.0001 );
        update();
    }

    public function gotoRandomFrame () : Void
    {
        gotoFrame( Math.floor(Math.random() * sequence.length) );
    }

    public function update ()
    {
        var frameTotal = Math.floor(timer.delta() / frameTime);
        loopCount = Math.floor(frameTotal / sequence.length);
        if( stop && loopCount > 0 ) {
            frame = sequence.length - 1;
        }
        else {
            frame = frameTotal % sequence.length;
        }
        tile = sequence[ frame ];
    }

    public function draw ( targetX : Float, targetY : Float )
    {
        var bbsize : Float = Math.max(sheet.width, sheet.height);

        // On screen?
        if(
           targetX > Global.system.width || targetY > Global.system.height ||
           targetX + bbsize < 0 || targetY + bbsize < 0
        ) {
            return;
        }

        if( alpha != 1 ) {
            Global.system.graphics.set_opacity(this.alpha);
        }

        /*
        if(this.scale.x != 1 || this.scale.y != 1) {
            Global.system.context.save();
            var originX = targetX + (this.sheet.width/2);
            var originY = targetY + (this.sheet.height/2);
            Global.system.context.translate(originX * Global.system.scale, originY * Global.system.scale);
            Global.system.context.scale(this.scale.x, this.scale.y);
            Global.system.context.translate(-originX * Global.system.scale, -originY * Global.system.scale);
        }
        */

        if( angle == 0 ) {
            sheet.image.drawTile(
                targetX, targetY,
                tile, sheet.width, sheet.height,
                flip.x, flip.y
            );
        }
        else {
            // Global.system.context.save();
            var m00 = Global.system.matrix.m00;
            var m01 = Global.system.matrix.m01;
            var m02 = Global.system.matrix.m02;
            var m10 = Global.system.matrix.m10;
            var m11 = Global.system.matrix.m11;
            var m12 = Global.system.matrix.m12;

            Global.system.matrix.translate(
                // Global.system.getDrawPos(targetX + pivot.x),
                targetX + pivot.x,
                // Global.system.getDrawPos(targetY + pivot.y)
                targetY + pivot.y
            );
            Global.system.matrix.rotate( angle );
            sheet.image.drawTile(
                -pivot.x, -pivot.y,
                tile, sheet.width, sheet.height,
                flip.x, flip.y
            );

            // Global.system.context.restore();
            Global.system.matrix.set (m00, m10, m01, m11, m02, m12);
        }

        if( alpha != 1) {
            Global.system.graphics.set_opacity(1);
        }
    }
}
