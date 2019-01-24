package impact;

import flambe.math.Matrix;

class System
{
    public var fps ( default, null ) : Int = 30;
    public var width ( default, null ) : Int = 320;
    public var height ( default, null ) : Int = 240;
    public var realWidth ( default, null ) : Float = 320;
    public var realHeight ( default, null ) : Float = 240;
    public var scale ( default, null ) : Int = 1;

    public var tick : Float = 0; // FIXME: Should not be publicly writable
    // public var animationId ( default, null ) : Int = 0;
    public var newGameClass = null; // FIXME: Should be private
    var running : Bool = false;

    var delegate : Delegate;
	public var clock : Timer; // FIXME: Should be private
	// var canvas = null;
	public var context ( default, default ) = null; // FIXME: Should not be publicly writable
	public var matrix : Matrix = new Matrix();
	public var graphics : kha.graphics2.Graphics;

	public function new ( canvasId, fps, width, height, ?scale : Int = 1 )
	{
		this.fps = fps;

		this.clock = new Timer();
		/*
		this.canvas = ig.$(canvasId);
		*/
		this.resize( width, height, scale );
		/*
		this.context = this.canvas.getContext('2d');
		*/

		getDrawPos = DRAW_SMOOTH; // FIXME: In ImpactJS, this could be set beforehand using "ig.System.drawMode"

		/*
		// Automatically switch to crisp scaling when using a scale
		// other than 1
		if( this.scale != 1 ) {
			ig.System.scaleMode = ig.System.SCALE.CRISP;
		}
		ig.System.scaleMode( this.canvas, this.context );
		*/
	}

	function resize ( width : Int, height : Int, scale : Int )
	{
		this.width = width;
		this.height = height;
		this.scale = scale;

		this.realWidth = this.width * this.scale;
		this.realHeight = this.height * this.scale;
		/*
		this.canvas.width = this.realWidth;
		this.canvas.height = this.realHeight;
		*/
	}

	public function setGame ( gameClass )
	{
		if( running ) {
			newGameClass = gameClass;
		}
		else {
			setGameNow( gameClass );
		}
	}

	public function setGameNow ( gameClass ) // FIXME: Should be private
	{
		Global.game = Type.createInstance( gameClass, [] );
		Global.system.setDelegate( Global.game );
	}

	function setDelegate ( object : Delegate )
	{
		delegate = object;
		startRunLoop();
	}

	function stopRunLoop ()
	{
		trace("TODO: ig.clearAnimation( this.animationId );");
		running = false;
	}

	function startRunLoop ()
	{
		stopRunLoop();
		trace("TODO: this.animationId = ig.setAnimation( this.run.bind(this), this.canvas );");
		running = true;
	}

	function run ()
	{
		Timer.step();
		tick = clock.tick();

		delegate.run();
		Global.input.clearPressed();

		if( newGameClass != null ) {
			setGameNow( newGameClass );
			newGameClass = null;
		}
	}

	public var getDrawPos ( default, null ) = null;
	function DRAW_AUTHENTIC ( p : Float ) : Int { return Math.round(p) * scale; }
	function DRAW_SMOOTH ( p : Float ) : Int { return Math.round(p * scale); }
	function DRAW_SUBPIXEL ( p : Float ) : Float { return p * scale; }
}
