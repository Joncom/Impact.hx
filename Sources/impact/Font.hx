package impact;

import flambe.math.FMath;

class Font extends Image
{
	var widthMap : Array<Int> = [];
	var indices : Array<Int> = [];
	var firstChar : Int = 32;
	public var letterSpacing = 1;
	var lineSpacing : Int = 0;
	var alpha : Float = 1;

	override private function onload ( ev )
	{
		_loadMetrics( data );
		super.onload( ev );
	}

	public function widthForString ( text : String ) : Int
	{
		// Multiline?
		if( text.indexOf('\n') != -1 ) {
			var lines : Array<String> = text.split( '\n' );
			var width : Int = 0;
			for( i in 0...lines.length ) {
				width = FMath.max( width, this._widthForLine(lines[i]) );
			}
			return width;
		}
		else {
			return this._widthForLine( text );
		}
	}

	function _widthForLine ( text : String ) : Int
	{
		var width : Int = 0;
		for( i in 0...text.length ) {
			width += this.widthMap[text.charCodeAt(i) - this.firstChar] + this.letterSpacing;
		}
		return width;
	}


	public function heightForString ( text : String ) : Int
	{
		return text.split('\n').length * (this.height - 2 + this.lineSpacing); // - 2 because width pixels and spacer line contain no graphics data
	}


	// FIXME: This should really be overriding the "draw" function, but because it has
	// different arguments, in Haxe it cannot. However, the other overridden methods are
	// non-trivial, so just making a "draw2" method temporarily instead.
	public function draw2 ( text : String, x : Float, y : Float, ?align : ALIGN ) : Void
	{
		if( text == null ) {
			text = "null";
		}

		// Multiline?
		if( text.indexOf('\n') != -1 ) {
			var lines : Array<String> = text.split( '\n' );
			var lineHeight : Int = heightForString("");
			for( i in 0...lines.length ) {
				this.draw2( lines[i], x, y + i * lineHeight, align );
			}
			return;
		}

		if( align == ALIGN.RIGHT || align == ALIGN.CENTER ) {
			var width : Int = this._widthForLine( text );
			x -= align == ALIGN.CENTER ? width/2 : width;
		}


		if( this.alpha != 1 ) {
			// this.data.alpha = this.alpha;
		}

		for( i in 0...text.length ) {
			var c = text.charCodeAt(i);
			x += this._drawChar( c - this.firstChar, x, y );
		}

		if( this.alpha != 1 ) {
			// this.data.alpha = 1;
		}
		Image.drawCount += text.length;
	}


	function _drawChar ( c, targetX, targetY )
	{
		if( !this.loaded || c < 0 || c >= this.indices.length ) { return 0; }

		var charX = this.indices[c];
		var charY = 0;
		var charWidth = this.widthMap[c];
		var charHeight = (this.height-2);

		draw(
			targetX, targetY,
			charX, charY,
			charWidth, charHeight
		);

		return this.widthMap[c] + this.letterSpacing;
	}


	function _loadMetrics ( image : kha.Image )
	{
		// Draw the bottommost line of this font image into an offscreen canvas
		// and analyze it pixel by pixel.
		// A run of non-transparent pixels represents a character and its width

		height = image.height-1;
		this.widthMap = [];
		this.indices = [];

		var currentChar : Int = 0;
		var currentWidth : Int = 0;
		var x : Int = 0;
		var y : Int = image.height - 1;
		while( x < image.width ) {
			var color = image.at(x, y);
			var alpha = color.Ab;
			if( alpha > 127 ) {
				currentWidth++;
			}
			else if( alpha < 128 && currentWidth != 0 ) {
				this.widthMap.push( currentWidth );
				this.indices.push( x-currentWidth );
				currentChar++;
				currentWidth = 0;
			}
			x++;
		}
		this.widthMap.push( currentWidth );
		this.indices.push( x-currentWidth );

		/* START CUSTOM RETINA LOGIC */

		// Since metrics are built off the full high-resolution image, divide by
        // retina scale to put them back to what they'd normally be.
        if(retinaScale > 1) {
            var fn = function(n) { return Std.int( n / retinaScale ); };
            this.widthMap = this.widthMap.map(fn);
            this.indices = this.indices.map(fn);
        }

        /* END CUSTOM RETINA LOGIC */
	}
}

enum ALIGN {
	LEFT;
	RIGHT;
	CENTER;
}
