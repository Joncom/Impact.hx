package impact;

class SoundManager {
	/*
	clips: {},
	*/
	public var volume : Float = 1;
	/*
	format: null,
	*/

	public function new () {
		/*
		// Quick sanity check if the Browser supports the Audio tag
		if( !ig.Sound.enabled || !window.Audio ) {
			ig.Sound.enabled = false;
			return;
		}

		// Probe sound formats and determine the file extension to load
		var probe = new Audio();
		for( var i = 0; i < ig.Sound.use.length; i++ ) {
			var format = ig.Sound.use[i];
			if( probe.canPlayType(format.mime) ) {
				this.format = format;
				break;
			}
		}

		// No compatible format found? -> Disable sound
		if( !this.format ) {
			ig.Sound.enabled = false;
		}

		// Create WebAudio Context
		if( ig.Sound.enabled && ig.Sound.useWebAudio ) {
			this.audioContext = new AudioContext();
			this.boundWebAudioUnlock = this.unlockWebAudio.bind(this);
			document.addEventListener('touchstart', this.boundWebAudioUnlock, false);

		}
		*/
	}

	/*
	function unlockWebAudio () {
		document.removeEventListener('touchstart', this.boundWebAudioUnlock, false);

		// create empty buffer
		var buffer = this.audioContext.createBuffer(1, 1, 22050);
		var source = this.audioContext.createBufferSource();
		source.buffer = buffer;

		source.connect(this.audioContext.destination);
		source.start(0);
	}

	function load ( path, multiChannel, loadCallback ) {
		if( multiChannel && ig.Sound.useWebAudio ) {
			// Requested as Multichannel and we're using WebAudio?
			return this.loadWebAudio( path, multiChannel, loadCallback );
		}
		else {
			// Oldschool HTML5 Audio - always used for Music
			return this.loadHTML5Audio( path, multiChannel, loadCallback );
		}
	}

	function loadWebAudio ( path, multiChannel, loadCallback ) {
		// Path to the soundfile with the right extension (.ogg or .mp3)
		var realPath = ig.prefix + path.replace(/[^\.]+$/, this.format.ext) + ig.nocache;

		if( this.clips[path] ) {
			return this.clips[path];
		}

		var audioSource = new ig.Sound.WebAudioSource()
		this.clips[path] = audioSource;

		var request = new XMLHttpRequest();
		request.open('GET', realPath, true);
		request.responseType = 'arraybuffer';


		var that = this;
		request.onload = function(ev) {
			that.audioContext.decodeAudioData(request.response,
				function(buffer) {
					audioSource.buffer = buffer;
					if( loadCallback ) {
						loadCallback( path, true, ev );
					}
				},
				function(ev) {
					if( loadCallback ) {
						loadCallback( path, false, ev );
					}
				}
			);
		};
		request.onerror = function(ev) {
			if( loadCallback ) {
				loadCallback( path, false, ev );
			}
		};
		request.send();

		return audioSource;
	},

	function loadHTML5Audio ( path, multiChannel, loadCallback ) {

		// Path to the soundfile with the right extension (.ogg or .mp3)
		var realPath = ig.prefix + path.replace(/[^\.]+$/, this.format.ext) + ig.nocache;

		// Sound file already loaded?
		if( this.clips[path] ) {
			// Loaded as WebAudio, but now requested as HTML5 Audio? Probably Music?
			if( this.clips[path] instanceof ig.Sound.WebAudioSource ) {
				return this.clips[path];
			}

			// Only loaded as single channel and now requested as multichannel?
			if( multiChannel && this.clips[path].length < ig.Sound.channels ) {
				for( var i = this.clips[path].length; i < ig.Sound.channels; i++ ) {
					var a = new Audio( realPath );
					a.load();
					this.clips[path].push( a );
				}
			}
			return this.clips[path][0];
		}

		var clip = new Audio( realPath );
		if( loadCallback ) {

			// The canplaythrough event is dispatched when the browser determines
			// that the sound can be played without interuption, provided the
			// download rate doesn't change.
			// Mobile browsers stubbornly refuse to preload HTML5, so we simply
			// ignore the canplaythrough event and immediately "fake" a successful
			// load callback
			if( ig.ua.mobile ) {
				setTimeout(function(){
					loadCallback( path, true, null );
				}, 0);
			}
			else {
				clip.addEventListener( 'canplaythrough', function cb(ev){
					clip.removeEventListener('canplaythrough', cb, false);
					loadCallback( path, true, ev );
				}, false );

				clip.addEventListener( 'error', function(ev){
					loadCallback( path, false, ev );
				}, false);
			}
		}
		clip.preload = 'auto';
		clip.load();


		this.clips[path] = [clip];
		if( multiChannel ) {
			for( var i = 1; i < ig.Sound.channels; i++ ) {
				var a = new Audio(realPath);
				a.load();
				this.clips[path].push( a );
			}
		}

		return clip;
	}
	*/

	public function get ( path ) {
		/*
		// Find and return a channel that is not currently playing
		var channels = this.clips[path];

		// Is this a WebAudio source? We only ever have one for each Sound
		if( channels && channels instanceof Sound.WebAudioSource ) {
			return channels;
		}

		// Oldschool HTML5 Audio - find a channel that's not currently
		// playing or, if all are playing, rewind one
		for( var i = 0, clip; clip = channels[i++]; ) {
			if( clip.paused || clip.ended ) {
				if( clip.ended ) {
					clip.currentTime = 0;
				}
				return clip;
			}
		}

		// Still here? Pause and rewind the first channel
		channels[0].pause();
		channels[0].currentTime = 0;
		return channels[0];
		*/

		return kha.Assets.sounds.get(path);
	}
}
