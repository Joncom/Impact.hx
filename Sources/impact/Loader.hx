package impact;

/*
ig.module(
	'impact.loader'
)
.requires(
	'impact.image',
	'impact.font',
	'impact.sound'
)
.defines(function(){ "use strict";
*/

/*
ig.Loader = ig.Class.extend({
*/
class Loader {
	/*
	resources: [],
	*/

	var gameClass : Class<Game>;
	/*
	status: 0,
	*/
	var done = false;

	/*
	_unloaded: [],
	*/
	var _drawStatus : Float = 0;
	/*
	_intervalId: 0,
	_loadCallbackBound: null,
	*/

	public function new ( gameClass : Class<Game>, ?resources ) {
		this.gameClass = gameClass;
		/*
		this.resources = resources;
		this._loadCallbackBound = this._loadCallback.bind(this);

		for( var i = 0; i < this.resources.length; i++ ) {
			this._unloaded.push( this.resources[i].path );
		}
		*/
	}

	public function load () {
		/*
		ig.system.clear( '#000' );

		if( !this.resources.length ) {
			this.end();
			return;
		}

		for( var i = 0; i < this.resources.length; i++ ) {
			this.loadResource( this.resources[i] );
		}
		this._intervalId = setInterval( this.draw.bind(this), 16 );
		*/

		kha.Assets.loadEverything(end);
	}

	/*
	loadResource: function( res ) {
		res.load( this._loadCallbackBound );
	},
	*/

	function end () {
		if( this.done ) { return; }

		this.done = true;
		/*
		clearInterval( this._intervalId );
		*/
		Global.system.setGame( this.gameClass );
	}

	public function draw () {
		#if cpp
			return; // XXX: Loader not yet visible on CPP targets (https://github.com/Kode/Kha/issues/937)
		#else
			if(kha.Assets.progress != null) {
				_drawStatus += (kha.Assets.progress - _drawStatus)/5;
			}
			var s = impact.Global.system.scale;
			var w = impact.Global.system.width * 0.6;
			var h = impact.Global.system.height * 0.1;
			var x = impact.Global.system.width * 0.5-w/2;
			var y = impact.Global.system.height * 0.5-h/2;

			var original : kha.Color = impact.Global.system.graphics.color;

			impact.Global.system.graphics.color = kha.Color.Black;
			impact.Global.system.graphics.fillRect( 0, 0, 480, 320 );

			impact.Global.system.graphics.color = kha.Color.White;
			impact.Global.system.graphics.fillRect( x*s, y*s, w*s, h*s );

			impact.Global.system.graphics.color = kha.Color.Black;
			impact.Global.system.graphics.fillRect( x*s+s, y*s+s, w*s-s-s, h*s-s-s );

			impact.Global.system.graphics.color = kha.Color.White;
			impact.Global.system.graphics.fillRect( x*s, y*s, w*s*_drawStatus, h*s );

			impact.Global.system.graphics.color = original;
		#end
	}

	/*
	_loadCallback: function( path, status ) {
		if( status ) {
			this._unloaded.erase( path );
		}
		else {
			throw( 'Failed to load resource: ' + path );
		}

		this.status = 1 - (this._unloaded.length / this.resources.length);
		if( this._unloaded.length == 0 ) { // all done?
			setTimeout( this.end.bind(this), 250 );
		}
	}
	*/
}
