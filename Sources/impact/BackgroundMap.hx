package impact;

class BackgroundMap extends Map
{
    var tiles : Image;
	var scroll : { x : Float, y : Float } = { x : 0, y : 0 };
	public var distance : Float = 1;
	public var repeat : Bool = false;
	public var tilesetName ( default, null ) : String = '';
	public var foreground : Bool = false;
	var enabled : Bool = true;

	public var preRender : Bool = false;
	var preRenderedChunks = null;
	var chunkSize = 512;
	var debugChunks = false;

	public var anims : std.Map<Int, Animation> = new std.Map();

	override public function new ( tilesize : Int, data : Array<Array<Int>>, tileset : Image )
	{
		super( tilesize, data );
		setTileset( tileset );
	}

	public function setTileset ( tileset : Image )
	{
		this.tilesetName  = tileset.path;
		this.tiles = tileset;
		this.preRenderedChunks = null;
	}

	public function setScreenPos ( x : Float, y : Float )
	{
		this.scroll.x = x / this.distance;
		this.scroll.y = y / this.distance;
	}

	function preRenderMapToChunks () {
		/*
		var totalWidth = this.width * this.tilesize * ig.system.scale,
			totalHeight = this.height * this.tilesize * ig.system.scale;

		// If this layer is smaller than the chunkSize, adjust the chunkSize
		// accordingly, so we don't have as much overdraw
		this.chunkSize = Math.min( Math.max(totalWidth, totalHeight), this.chunkSize );

		var chunkCols = Math.ceil(totalWidth / this.chunkSize),
			chunkRows = Math.ceil(totalHeight / this.chunkSize);

		this.preRenderedChunks = [];
		for( var y = 0; y < chunkRows; y++ ) {
			this.preRenderedChunks[y] = [];

			for( var x = 0; x < chunkCols; x++ ) {


				var chunkWidth = (x == chunkCols-1)
					? totalWidth - x * this.chunkSize
					: this.chunkSize;

				var chunkHeight = (y == chunkRows-1)
					? totalHeight - y * this.chunkSize
					: this.chunkSize;

				this.preRenderedChunks[y][x] = this.preRenderChunk( x, y, chunkWidth, chunkHeight );
			}
		}
		*/
	}

	function preRenderChunk ( cx, cy, w, h ) {
		/*
		var tw = w / this.tilesize / ig.system.scale + 1,
			th = h / this.tilesize / ig.system.scale + 1;

		var nx = (cx * this.chunkSize / ig.system.scale) % this.tilesize,
			ny = (cy * this.chunkSize / ig.system.scale) % this.tilesize;

		var tx = Math.floor(cx * this.chunkSize / this.tilesize / ig.system.scale),
			ty = Math.floor(cy * this.chunkSize / this.tilesize / ig.system.scale);


		var chunk = ig.$new('canvas');
		chunk.width = w;
		chunk.height = h;
		chunk.retinaResolutionEnabled = false; // Opt out for Ejecta

		var chunkContext = chunk.getContext('2d');
		ig.System.scaleMode(chunk, chunkContext);

		var screenContext = ig.system.context;
		ig.system.context = chunkContext;

		for( var x = 0; x < tw; x++ ) {
			for( var y = 0; y < th; y++ ) {
				if( x + tx < this.width && y + ty < this.height ) {
					var tile = this.data[y+ty][x+tx];
					if( tile ) {
						this.tiles.drawTile(
							x * this.tilesize - nx,	y * this.tilesize - ny,
							tile - 1, this.tilesize
						);
					}
				}
			}
		}
		ig.system.context = screenContext;

		// The following Chrome workaround which converts canvases into
		// images is not needed in Cocoon, and moreover causes problems
		// because the alpha is not carried over into the new image!
		if(isCocoonJS) {
			return chunk;
		}

		// Workaround for Chrome 49 bug - handling many offscreen canvases
		// seems to slow down the browser significantly. So we convert the
		// upscaled canvas back to an image.
		var image = new Image();
		image.src = chunk.toDataURL();

		return image;
		*/
	}

	public function draw ()
	{
		if( !tiles.loaded || !enabled ) {
			return;
		}

		if( preRender ) {
			drawPreRendered();
		}
		else {
			drawTiled();
		}
	}

	function drawPreRendered ()
	{
		trace("TODO");
		/*
		if( !this.preRenderedChunks ) {
			this.preRenderMapToChunks();
		}

		var dx = ig.system.getDrawPos(this.scroll.x),
			dy = ig.system.getDrawPos(this.scroll.y);


		if( this.repeat ) {
			var w = this.width * this.tilesize * ig.system.scale;
			dx = (dx%w + w) % w;

			var h = this.height * this.tilesize * ig.system.scale;
			dy = (dy%h + h) % h;
		}

		var minChunkX = Math.max( Math.floor(dx / this.chunkSize), 0 ),
			minChunkY = Math.max( Math.floor(dy / this.chunkSize), 0 ),
			maxChunkX = Math.ceil((dx+ig.system.realWidth) / this.chunkSize),
			maxChunkY = Math.ceil((dy+ig.system.realHeight) / this.chunkSize),
			maxRealChunkX = this.preRenderedChunks[0].length,
			maxRealChunkY = this.preRenderedChunks.length;


		if( !this.repeat ) {
			maxChunkX = Math.min( maxChunkX, maxRealChunkX );
			maxChunkY = Math.min( maxChunkY, maxRealChunkY );
		}


		var nudgeY = 0;
		for( var cy = minChunkY; cy < maxChunkY; cy++ ) {

			var nudgeX = 0;
			for( var cx = minChunkX; cx < maxChunkX; cx++ ) {
				var chunk = this.preRenderedChunks[cy % maxRealChunkY][cx % maxRealChunkX];

				// A pre-rendered chunk is an image element created from
				// a canvas data URL. In Chrome, the image.width and height
				// are 0 until after the image "load" event has fired.
				if(chunk.width === 0 || chunk.height === 0) {
					return;
				}

				var x = -dx + cx * this.chunkSize - nudgeX;
				var y = -dy + cy * this.chunkSize - nudgeY;
				ig.system.context.drawImage( chunk, x, y);
				ig.Image.drawCount++;

				if( this.debugChunks ) {
					ig.system.context.strokeStyle = '#f0f';
					ig.system.context.strokeRect( x, y, this.chunkSize, this.chunkSize );
				}

				// If we repeat in X and this chunk's width wasn't the full chunk size
				// and the screen is not already filled, we need to draw anohter chunk
				// AND nudge it to be flush with the last chunk
				if( this.repeat && chunk.width < this.chunkSize && x + chunk.width < ig.system.realWidth ) {
					nudgeX += this.chunkSize - chunk.width;
					maxChunkX++;
				}
			}

			// Same as above, but for Y
			if( this.repeat && chunk.height < this.chunkSize && y + chunk.height < ig.system.realHeight	) {
				nudgeY += this.chunkSize - chunk.height;
				maxChunkY++;
			}
		}
		*/
	}

	function drawTiled ()
	{
		var tile = 0,
			anim = null,
			tileOffsetX = Std.int(scroll.x / tilesize),
			tileOffsetY = Std.int(scroll.y / tilesize),
			pxOffsetX = scroll.x % tilesize,
			pxOffsetY = scroll.y % tilesize,
			pxMinX = -pxOffsetX - tilesize,
			pxMinY = -pxOffsetY - tilesize,
			pxMaxX = Global.system.width + tilesize - pxOffsetX,
			pxMaxY = Global.system.height + tilesize - pxOffsetY;


		// FIXME: could be sped up for non-repeated maps: restrict the for loops
		// to the map size instead of to the screen size and skip the 'repeat'
		// checks inside the loop.
		var mapY : Int = -2;
		var pxY : Float = pxMinY - tilesize;
		while( pxY < pxMaxY ) {
			mapY++;
			pxY += tilesize;

			var tileY = mapY + tileOffsetY;

			// Repeat Y?
			if( tileY >= height || tileY < 0 ) {
				if( !repeat ) { continue; }
				tileY = (tileY%height + height) % height;
			}

			var mapX : Int = -2;
			var pxX = pxMinX - tilesize;
			while( pxX < pxMaxX ) {
				mapX++;
				pxX += tilesize;

				var tileX = mapX + tileOffsetX;

				// Repeat X?
				if( tileX >= width || tileX < 0 ) {
					if( !repeat ) { continue; }
					tileX = (tileX%width + width) % width;
				}

				// Draw!
				if( (tile = data[tileY][tileX]) > 0 ) {
					if( (anim = anims.get(tile-1)) != null ) {
						anim.draw( pxX, pxY );
					}
					else {
						tiles.drawTile( pxX, pxY, tile-1, tilesize );
					}
				}
			} // end for x
		} // end for y
	}
}
