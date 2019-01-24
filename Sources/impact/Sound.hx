package impact;

class Sound {
	var path = '';
	public var volume : Float = 1;
	var currentClip : kha.audio1.AudioChannel = null;
	// multiChannel: true,
	var loop (default, set) = false;

	var khaName : String;

	public function new ( path, ?multiChannel ) {
		this.path = path;
		//this.multiChannel = (multiChannel !== false);

		/*
		Object.defineProperty(this,"loop", {
			get: this.getLooping.bind(this),
			set: this.setLooping.bind(this)
		});
		*/

		khaName = Global.khaName(path);

		this.load();
	}

	function set_loop ( loop ) {
		this.loop = loop;

		/*
		if( this.currentClip ) {
			this.currentClip.loop = loop;
		}
		*/

		return loop;
	}

	function load ( ?loadCallback : String -> Bool -> Void ) {
		if( !Sound.enabled ) {
			if( loadCallback != null ) {
				loadCallback( this.path, true );
			}
			return;
		}

		/*
		if( ig.ready ) {
			ig.soundManager.load( this.path, this.multiChannel, loadCallback );
		}
		else {
			ig.addResource( this );
		}
		*/
	}

	public function play () {
		if( !Sound.enabled ) {
			return;
		}

		/*
		this.currentClip = Global.soundManager.get( this.path );
		this.currentClip.loop = this._loop;
		this.currentClip.volume = Global.soundManager.volume * this.volume;
		this.currentClip.play();
		*/

		var sound : kha.Sound = Global.soundManager.get( khaName );
		if(sound == null) {
			throw "Could not find sound to play: " + khaName;
		}
		this.currentClip = kha.audio1.Audio.play(sound, loop);
		this.currentClip.volume = Global.soundManager.volume * this.volume;
	}

	public function stop () {
		if( this.currentClip != null ) {
			this.currentClip.stop();
		}
	}

	// ig.Sound.channels = 4;
	public static var enabled = true;
}
