package impact;

class CollisionMap extends Map
{
    var lastSlope : Int = 1;
	var tiledef : TileDef = null;

	public function new ( tilesize : Int, data : Array<Array<Int>>, ?tiledef ) {
		super( tilesize, data );
		this.tiledef = ( tiledef != null ? tiledef : defaultTileDef );

		/*
		for( var t in this.tiledef ) {
			if( t|0 > lastSlope ) {
				lastSlope = t|0;
			}
		}
		*/
	}

	public function trace ( x : Float, y : Float, vx : Float, vy : Float, objectWidth : Float, objectHeight : Float ) : TraceResult
	{
		// Set up the trace-result
		var res : TraceResult = {
			collision: {x: false, y: false, slope: null},
			pos: {x: x, y: y},
			tile: {x: 0, y: 0}
		};

		// Break the trace down into smaller steps if necessary.
		// We add a little extra movement (0.1 px) when calculating the number of steps required,
		// to force an additional trace step whenever vx or vy is a factor of tilesize. This
		// prevents the trace step from skipping through the very first tile.
		var steps = Math.ceil((Math.max(Math.abs(vx), Math.abs(vy))+0.1) / tilesize);
		if( steps > 1 ) {
			var sx = vx / steps;
			var sy = vy / steps;

			var i : Int = 0;
			while( i < steps && ( sx != 0 || sy != 0 ) ) {
				_traceStep( res, x, y, sx, sy, objectWidth, objectHeight, vx, vy, i );

				x = res.pos.x;
				y = res.pos.y;
				if( res.collision.x ) {	sx = 0; vx = 0; }
				if( res.collision.y ) {	sy = 0;	vy = 0; }
				if( res.collision.slope != null ) { break; }

				i++;
			}
		}

		// Just one step
		else {
			_traceStep( res, x, y, vx, vy, objectWidth, objectHeight, vx, vy, 0 );
		}

		return res;
	}

	private function _traceStep ( res : TraceResult, x : Float, y : Float, vx : Float, vy : Float, width : Float, height : Float, rvx : Float, rvy : Float, step : Int ) : Void
	{
		res.pos.x += vx;
		res.pos.y += vy;

		var t = 0;

		// Horizontal collision (walls)
		if( vx != 0 ) {
			var pxOffsetX = (vx > 0 ? width : 0);
			var tileOffsetX = (vx < 0 ? tilesize : 0);

			var firstTileY : Int = cast Math.max( Math.floor(y / tilesize), 0 );
			var lastTileY : Int = cast Math.min( Math.ceil((y + height) / tilesize), this.height );
			var tileX : Int = Math.floor( (res.pos.x + pxOffsetX) / tilesize );

			// We need to test the new tile position as well as the current one, as we
			// could still collide with the current tile if it's a line def.
			// We can skip this test if this is not the first step or the new tile position
			// is the same as the current one.
			var prevTileX = Math.floor( (x + pxOffsetX) / tilesize );
			if( step > 0 || tileX == prevTileX || prevTileX < 0 || prevTileX >= this.width ) {
				prevTileX = -1;
			}

			// Still inside this collision map?
			if(	tileX >= 0 && tileX < this.width ) {
				for( tileY in firstTileY...lastTileY ) {
					if( prevTileX != -1 ) {
						t = data[tileY][prevTileX];
						if(
							t > 1 && t <= lastSlope &&
							_checkTileDef(res, t, x, y, rvx, rvy, width, height, prevTileX, tileY)
						) {
							break;
						}
					}

					t = data[tileY][tileX];
					if(
						t == 1 || t > lastSlope || // fully solid tile?
						(t > 1 && _checkTileDef(res, t, x, y, rvx, rvy, width, height, tileX, tileY)) // slope?
					) {
						if( t > 1 && t <= lastSlope && res.collision.slope != null ) {
							break;
						}

						// full tile collision!
						res.collision.x = true;
						res.tile.x = t;
						x = res.pos.x = tileX * tilesize - pxOffsetX + tileOffsetX;
						rvx = 0;
						break;
					}
				}
			}
		}

		// Vertical collision (floor, ceiling)
		if( vy != 0 ) {
			var pxOffsetY = (vy > 0 ? height : 0);
			var tileOffsetY = (vy < 0 ? tilesize : 0);

			var firstTileX : Int = cast Math.max( Math.floor(res.pos.x / tilesize), 0 );
			var lastTileX : Int = cast Math.min( Math.ceil((res.pos.x + width) / tilesize), this.width );
			var tileY : Int = Math.floor( (res.pos.y + pxOffsetY) / tilesize );

			var prevTileY = Math.floor( (y + pxOffsetY) / tilesize );
			if( step > 0 || tileY == prevTileY || prevTileY < 0 || prevTileY >= this.height ) {
				prevTileY = -1;
			}

			// Still inside this collision map?
			if( tileY >= 0 && tileY < this.height ) {
				for( tileX in firstTileX...lastTileX ) {
					if( prevTileY != -1 ) {
						t = data[prevTileY][tileX];
						if(
							t > 1 && t <= lastSlope &&
							_checkTileDef(res, t, x, y, rvx, rvy, width, height, tileX, prevTileY) ) {
							break;
						}
					}

					t = data[tileY][tileX];
					if(
						t == 1 || t > lastSlope || // fully solid tile?
						(t > 1 && _checkTileDef(res, t, x, y, rvx, rvy, width, height, tileX, tileY)) // slope?
					) {
						if( t > 1 && t <= lastSlope && res.collision.slope != null ) {
							break;
						}

						// full tile collision!
						res.collision.y = true;
						res.tile.y = t;
						res.pos.y = tileY * tilesize - pxOffsetY + tileOffsetY;
						break;
					}
				}
			}
		}

		// res is changed in place, nothing to return
	}

	private function _checkTileDef ( res : TraceResult, t : Int, x : Float, y : Float, vx : Float, vy : Float, width : Float, height : Float, tileX : Int, tileY : Int) {
		var def = tiledef[t];
		if( def == null ) { return false; }

		var lx = (tileX + def[0]) * tilesize,
			ly = (tileY + def[1]) * tilesize,
			lvx = (def[2] - def[0]) * tilesize,
			lvy = (def[3] - def[1]) * tilesize,
			solid = def[4];

		// Find the box corner to test, relative to the line
		var tx = x + vx + (lvy < 0 ? width : 0) - lx,
			ty = y + vy + (lvx > 0 ? height : 0) - ly;

		// Is the box corner behind the line?
		if( lvx * ty - lvy * tx > 0 ) {

			// Lines are only solid from one side - find the dot product of
			// line normal and movement vector and dismiss if wrong side
			if( vx * -lvy + vy * lvx < 0 ) {
				return solid;
			}

			// Find the line normal
			var length = Math.sqrt(lvx * lvx + lvy * lvy);
			var nx = lvy/length,
				ny = -lvx/length;

			// Project out of the line
			var proj = tx * nx + ty * ny;
			var px = nx * proj,
				py = ny * proj;

			// If we project further out than we moved in, then this is a full
			// tile collision for solid tiles.
			// For non-solid tiles, make sure we were in front of the line.
			if( px*px+py*py >= vx*vx+vy*vy ) {
				return solid || (lvx * (ty-vy) - lvy * (tx-vx) < 0.5);
			}

			res.pos.x = x + vx - px;
			res.pos.y = y + vy - py;
			res.collision.slope = {x: lvx, y: lvy, nx: nx, ny: ny};
			return true;
		}

		return false;
	}

	// Default Slope Tile definition. Each tile is defined by an array of 5 vars:
	// - 4 for the line in tile coordinates (0 -- 1)
	// - 1 specifing whether the tile is 'filled' behind the line or not
	// [ x1, y1, x2, y2, solid ]

	// Defining 'half', 'one third' and 'two thirds' as vars  makes it a bit
	// easier to read... I hope.
	private static inline var H = 1/2;
	private static inline var N = 1/3;
	private static inline var M = 2/3;
	private static inline var SOLID = true;
	private static inline var NON_SOLID = false;

	static var defaultTileDef : TileDef = [
		/* 15 NE */	 5 => [0,1, 1,M, SOLID],  6 => [0,M, 1,N, SOLID],  7 => [0,N, 1,0, SOLID],
		/* 22 NE */	 3 => [0,1, 1,H, SOLID],  4 => [0,H, 1,0, SOLID],
		/* 45 NE */  2 => [0,1, 1,0, SOLID],
		/* 67 NE */ 10 => [H,1, 1,0, SOLID], 21 => [0,1, H,0, SOLID],
		/* 75 NE */ 32 => [M,1, 1,0, SOLID], 43 => [N,1, M,0, SOLID], 54 => [0,1, N,0, SOLID],

		/* 15 SE */	27 => [0,0, 1,N, SOLID], 28 => [0,N, 1,M, SOLID], 29 => [0,M, 1,1, SOLID],
		/* 22 SE */	25 => [0,0, 1,H, SOLID], 26 => [0,H, 1,1, SOLID],
		/* 45 SE */	24 => [0,0, 1,1, SOLID],
		/* 67 SE */	11 => [0,0, H,1, SOLID], 22 => [H,0, 1,1, SOLID],
		/* 75 SE */	33 => [0,0, N,1, SOLID], 44 => [N,0, M,1, SOLID], 55 => [M,0, 1,1, SOLID],

		/* 15 NW */	16 => [1,N, 0,0, SOLID], 17 => [1,M, 0,N, SOLID], 18 => [1,1, 0,M, SOLID],
		/* 22 NW */	14 => [1,H, 0,0, SOLID], 15 => [1,1, 0,H, SOLID],
		/* 45 NW */	13 => [1,1, 0,0, SOLID],
		/* 67 NW */	 8 => [H,1, 0,0, SOLID], 19 => [1,1, H,0, SOLID],
		/* 75 NW */	30 => [N,1, 0,0, SOLID], 41 => [M,1, N,0, SOLID], 52 => [1,1, M,0, SOLID],

		/* 15 SW */ 38 => [1,M, 0,1, SOLID], 39 => [1,N, 0,M, SOLID], 40 => [1,0, 0,N, SOLID],
		/* 22 SW */ 36 => [1,H, 0,1, SOLID], 37 => [1,0, 0,H, SOLID],
		/* 45 SW */ 35 => [1,0, 0,1, SOLID],
		/* 67 SW */  9 => [1,0, H,1, SOLID], 20 => [H,0, 0,1, SOLID],
		/* 75 SW */ 31 => [1,0, M,1, SOLID], 42 => [M,0, N,1, SOLID], 53 => [N,0, 0,1, SOLID],

		/* Go N  */ 12 => [0,0, 1,0, NON_SOLID],
		/* Go S  */ 23 => [1,1, 0,1, NON_SOLID],
		/* Go E  */ 34 => [1,0, 1,1, NON_SOLID],
		/* Go W  */ 45 => [0,1, 0,0, NON_SOLID]

		// Now that was fun!
	];

	public static var staticNoCollision ( get, null ) : NoCollisionMap;
	private static function get_staticNoCollision () {
		// Define within getter, because `CollisionMap` not yet defined when defining `staticNoCollision`
		if(staticNoCollision == null) {
			staticNoCollision = new NoCollisionMap(16, [[]]);
		}
		return staticNoCollision;
	}
}

typedef TileDef = std.Map<Int, Array<Dynamic>>;

typedef TraceResult = {
	var collision : { x : Bool, y : Bool, slope : { x : Float, y : Float, nx : Float, ny : Float } };
	var pos : { x : Float, y : Float };
	var tile : { x : Int, y : Int };
}

class NoCollisionMap extends CollisionMap
{
	override public function trace ( x : Float, y : Float, vx : Float, vy : Float, objectWidth : Float, objectHeight : Float ) : TraceResult
	{
		return {
			collision: {x: false, y: false, slope: null},
			pos: {x: x+vx, y: y+vy},
			tile: {x: 0, y: 0}
		};
	}
}
