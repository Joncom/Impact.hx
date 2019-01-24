package impact;

import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.input.Surface;

class Input
{
    public static var KEY = {
		'MOUSE1': -1,
		'MOUSE2': -3,
		'MWHEEL_UP': -4,
		'MWHEEL_DOWN': -5,

		'BACKSPACE': 8,
		'TAB': 9,
		'ENTER': 13,
		'PAUSE': 19,
		'CAPS': 20,
		'ESC': 27,
		'SPACE': 32,
		'PAGE_UP': 33,
		'PAGE_DOWN': 34,
		'END': 35,
		'HOME': 36,
		'LEFT_ARROW': 37,
		'UP_ARROW': 38,
		'RIGHT_ARROW': 39,
		'DOWN_ARROW': 40,
		'INSERT': 45,
		'DELETE': 46,
		'_0': 48,
		'_1': 49,
		'_2': 50,
		'_3': 51,
		'_4': 52,
		'_5': 53,
		'_6': 54,
		'_7': 55,
		'_8': 56,
		'_9': 57,
		'A': 65,
		'B': 66,
		'C': 67,
		'D': 68,
		'E': 69,
		'F': 70,
		'G': 71,
		'H': 72,
		'I': 73,
		'J': 74,
		'K': 75,
		'L': 76,
		'M': 77,
		'N': 78,
		'O': 79,
		'P': 80,
		'Q': 81,
		'R': 82,
		'S': 83,
		'T': 84,
		'U': 85,
		'V': 86,
		'W': 87,
		'X': 88,
		'Y': 89,
		'Z': 90,
		'NUMPAD_0': 96,
		'NUMPAD_1': 97,
		'NUMPAD_2': 98,
		'NUMPAD_3': 99,
		'NUMPAD_4': 100,
		'NUMPAD_5': 101,
		'NUMPAD_6': 102,
		'NUMPAD_7': 103,
		'NUMPAD_8': 104,
		'NUMPAD_9': 105,
		'MULTIPLY': 106,
		'ADD': 107,
		'SUBSTRACT': 109,
		'DECIMAL': 110,
		'DIVIDE': 111,
		'F1': 112,
		'F2': 113,
		'F3': 114,
		'F4': 115,
		'F5': 116,
		'F6': 117,
		'F7': 118,
		'F8': 119,
		'F9': 120,
		'F10': 121,
		'F11': 122,
		'F12': 123,
		'SHIFT': 16,
		'CTRL': 17,
		'ALT': 18,
		'PLUS': 187,
		'COMMA': 188,
		'MINUS': 189,
		'PERIOD': 190
	};

	var bindings : std.Map<Int, Array<String>> = new std.Map();
	var actions : std.Map<String, Bool> = new std.Map();
	var presses : std.Map<String, Bool> = new std.Map();
	var locks : std.Map<String, Bool> = new std.Map();
	var delayedKeyup : std.Map<String, Bool> = new std.Map();

	public var touches ( default, null ) : Array<TouchPoint> = [];
	var delayedTouchUp : Array<Int> = [];

	var isUsingMouse = false;
	var isUsingKeyboard = false;
	var isUsingAccelerometer = false;
	public var mouse ( default, null ) : { x : Float, y : Float } = {x: 0, y: 0};
	var accel = {x: 0, y: 0, z: 0};

	public function new () {}

	function initMouse ()
	{
		if( isUsingMouse ) { return; }
		isUsingMouse = true;
		/*
		Global.system.canvas.addEventListener('mousewheel', mouseWheel, false );
		Global.system.canvas.addEventListener('DOMMouseScroll', mouseWheel, false );

		Global.system.canvas.addEventListener('contextmenu', contextmenu.bind(this), false );
		Global.system.canvas.addEventListener('mousedown', keydown.bind(this), false );
		Global.system.canvas.addEventListener('mouseup', keyup.bind(this), false );
		Global.system.canvas.addEventListener('mousemove', mousemove.bind(this), false );
		*/
		Mouse.get().notify(mousedown, mouseup, mousemove, mousewheel);

		if( Global.ua.touchDevice ) {
			/*
			// Standard
			ig.system.canvas.addEventListener('touchstart', keydown.bind(this), false );
			ig.system.canvas.addEventListener('touchend', keyup.bind(this), false );
			ig.system.canvas.addEventListener('touchcancel', keyup.bind(this), false );
			ig.system.canvas.addEventListener('touchmove', mousemove.bind(this), false );

			// MS
			ig.system.canvas.addEventListener('MSPointerDown', keydown.bind(this), false );
			ig.system.canvas.addEventListener('MSPointerUp', keyup.bind(this), false );
			ig.system.canvas.addEventListener('MSPointerMove', mousemove.bind(this), false );
			ig.system.canvas.style.msTouchAction = 'none';
			*/

			Surface.get().notify(touchStart, touchEnd, touchMove);
		}
	}

	function initKeyboard ()
	{
		if( isUsingKeyboard ) { return; }
		isUsingKeyboard = true;
		/*
		window.addEventListener('keydown', keydown.bind(this), false );
		window.addEventListener('keyup', keyup.bind(this), false );
		*/
		Keyboard.get().notify(keydown, keyup);
	}

	/*
	function initAccelerometer ()
	{
		if( isUsingAccelerometer ) { return; }
		isUsingAccelerometer = true;
		window.addEventListener('devicemotion', devicemotion.bind(this), false );
	}

	*/
	function mousewheel ( delta : Int )
	{
		/*
		var delta = event.wheelDelta ? event.wheelDelta : (event.detail * -1);
		var code = delta > 0 ? ig.KEY.MWHEEL_UP : ig.KEY.MWHEEL_DOWN;
		var action = bindings[code];
		if( action ) {
			actions[action] = true;
			presses[action] = true;
			delayedKeyup[action] = true;
			event.stopPropagation();
			event.preventDefault();
		}
		*/
	}

	function mousemove ( x : Int, y : Int, moveX : Int, moveY : Int )
	{
		/*
		var internalWidth = parseInt(ig.system.canvas.offsetWidth) || ig.system.realWidth;
		var scale = ig.system.scale * (internalWidth / ig.system.realWidth);

		var pos = {left: 0, top: 0};
		if( ig.system.canvas.getBoundingClientRect ) {
			pos = ig.system.canvas.getBoundingClientRect();
		}

		this.mouse.x = (event.viewX - pos.left) / scale;
		this.mouse.y = (event.viewY - pos.top) / scale;
		*/

		var local = localPos( x, y );
		this.mouse.x = local.x;
		this.mouse.y = local.y;
	}

	function localPos ( x : Int, y : Int ) {
		var windowWidth = kha.System.windowWidth();
		var windowHeight = kha.System.windowHeight();
		var aspectRatioGame = Global.system.width / Global.system.height;
		var aspectRatioWindow = windowWidth / windowHeight;
		var scale = (aspectRatioGame >= aspectRatioWindow ? windowWidth / Global.system.width : windowHeight / Global.system.height);
		var letterboxWidth = (aspectRatioGame < aspectRatioWindow ? windowWidth - Global.system.width * scale : 0);
		var letterboxHeight = (aspectRatioGame > aspectRatioWindow ? windowHeight - Global.system.height * scale : 0);
		return {
			x: Math.round((x - letterboxWidth / 2) / scale),
			y: Math.round((y - letterboxHeight / 2) / scale)
		};
	}

	/*
	function contextmenu ( event )
	{
		if( bindings[ig.KEY.MOUSE2] ) {
			event.stopPropagation();
			event.preventDefault();
		}
	}
	*/

	function mousedown ( button : Int, x : Int, y : Int ) : Void
	{
		switch(button) {
			case 0:
				down( KEY.MOUSE1 );
			case 1:
				down( KEY.MOUSE2 );
			default:
				// no-op
		}
		// FIXME: Is updating mouse position needed here, or does mousemove already suffice?
	}

	function mouseup ( button : Int, x : Int, y : Int ) : Void
	{
		switch(button) {
			case 0:
				up( KEY.MOUSE1 );
			case 1:
				up( KEY.MOUSE2 );
			default:
				// no-op
		}
	}

	function keydown ( keyCode : KeyCode ) : Void
	{
		/*
		var tag = event.target.tagName;
		if( tag == 'INPUT' || tag == 'TEXTAREA' ) { return; }

		var code = event.type == 'keydown'
			? event.keyCode
			: (event.button == 2 ? ig.KEY.MOUSE2 : ig.KEY.MOUSE1);

		// Focus window element for mouse clicks. Prevents issues when
		// running the game in an iframe.
		if( code < 0 && !ig.ua.mobile ) {
			window.focus();
		}

		if( event.type == 'touchstart' || event.type == 'mousedown' ) {
			mousemove( event );
		}
		*/

		down( keyCode );
	}

	function keyup ( keyCode : KeyCode ) : Void
	{
		/*
		var tag = event.target.tagName;
		if( tag == 'INPUT' || tag == 'TEXTAREA' ) { return; }

		var code = event.type == 'keyup'
			? event.keyCode
			: (event.button == 2 ? ig.KEY.MOUSE2 : ig.KEY.MOUSE1);
		*/
		up( keyCode );
	}

	function down ( code : Int )
	{
		var actions = bindings.get( code );
		if( actions != null ) {
			for( i in 0...actions.length ) {
				var action : String = actions[i];
				this.actions.set( action, true );
				if( locks.get( action ) != true ) {
					presses.set( action, true );
					locks.set( action, true );
				}
			}
		}
	}

	function up ( code : Int )
	{
		var actions = bindings.get( code );
		if( actions != null ) {
			for( i in 0...actions.length ) {
				var action = actions[i];
				delayedKeyup.set( action, true );
				// event.preventDefault();
			}
		}
	}

	/*
	function devicemotion ( event )
	{
		accel = event.accelerationIncludingGravity;
	}
	*/

	public function bind ( key : Int, action : String ) : Void
	{
		if( key < 0 ) { initMouse(); }
		else if( key > 0 ) { initKeyboard(); }
		if( bindings.get( key ) == null ) {
			bindings.set( key, [] );
		}
		bindings.get( key ).push( action );
	}

	/*
	function bindTouch ( selector, action )
	{
		var element = ig.$( selector );

		var that = this;
		element.addEventListener('touchstart', function(ev) {that.touchStart( ev, action );}, false);
		element.addEventListener('touchend', function(ev) {that.touchEnd( ev, action );}, false);
		element.addEventListener('MSPointerDown', function(ev) {that.touchStart( ev, action );}, false);
		element.addEventListener('MSPointerUp', function(ev) {that.touchEnd( ev, action );}, false);
	}

	function unbind ( key, action )
	{
		var actions = bindings[key];
		if(actions) {
			for(var i = actions.length - 1; i >= 0; i--) {
				if(actions[i] === action) {
					delayedKeyup[action] = true;
					bindings[key].splice(i, 1);
				}
			}
		}
	}

	function unbindAll ()
	{
		bindings = {};
		actions = {};
		presses = {};
		locks = {};
		delayedKeyup = {};
	}
	*/

	public function state ( action : String ) : Bool
	{
		return actions.get( action );
	}

	public function pressed ( action : String ) : Bool
	{
		return presses.get( action );
	}

	public function released ( action : String ) : Bool
	{
		return !!delayedKeyup.get( action );
	}

	public function clearPressed ()
	{
		for( action in delayedKeyup.keys() ) {
			actions.set( action, false );
			locks.set( action, false );
		}
		delayedKeyup = new std.Map(); // FIXME: Is creating new data structure each frame a bad idea?
		presses = new std.Map();

		for ( id in delayedTouchUp ) {
			for( touch in touches ) {
				if( touch.id == id ) {
					touches.remove( touch );
					break;
				}
			}
		}
		this.delayedTouchUp = [];
	}

	// function touchStart ( event, action )
	function touchStart ( id : Int, x : Int, y : Int ) : Void {
		/*
		actions[action] = true;
		presses[action] = true;

		event.stopPropagation();
		event.preventDefault();
		return false;
		*/

		var actions = this.bindings.get( KEY.MOUSE1 );
		if ( actions != null ) {
			for( action in actions ) {
				this.actions[action] = true;
				this.presses[action] = true;
			}
		}
		for( touch in touches ) {
			if( touch.id == id ) { // This should never happen, but it seems to happen anyway!
				touchMove( id, x, y );
				return;
			}
		}
		var local = localPos( x, y );
		this.touches.push( new TouchPoint( id, local.x, local.y, 'down' ) );
	}

	function touchMove ( id : Int, x : Int, y : Int ) : Void {
		for( touch in touches ) {
			if( touch.id == id ) {
				var local = localPos( x, y );
				touch.x = local.x;
				touch.y = local.y;
				break;
			}
		}
	}

	// function touchEnd ( event, action )
	function touchEnd ( id : Int, x : Int, y : Int ) : Void {
		/*
		delayedKeyup[action] = true;
		event.stopPropagation();
		event.preventDefault();
		return false;
		*/

		for( touch in touches ) {
			if( touch.id == id ) {
				touch.state = 'up';
				this.delayedTouchUp.push( id );

				var actions = this.bindings[ KEY.MOUSE1 ];
				if ( actions != null && touches.length == 0 ) {
					for( action in actions ) {
						this.delayedKeyup[ action ] = true;
					}
				}
				break;
			}
		}
	}
}

class TouchPoint {
	public var id ( default, null ) : Int;
	public var x : Int;
	public var y : Int;
	public var state : String;
	public function new( id : Int, x : Int, y : Int, state : String ) {
		this.id = id;
		this.x = x;
		this.y = y;
		this.state = state;
	}
}
