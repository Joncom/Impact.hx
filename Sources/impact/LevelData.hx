package impact;

typedef LevelData = {
	var entities : Array<LevelEntity>;
	var layer : Array<LevelLayer>;
}

typedef LevelEntity = {
	var x : Int;
	var y : Int;
	var type : Class<Entity>;
	@:optional var settings : Dynamic;
}

typedef LevelLayer = {
	var name : String;
	var width : Int;
	var height : Int;
	var linkWithCollision : Bool;
	var visible : Bool;
	var tilesetName : String;
	var repeat : Bool;
	var preRender : Bool;
	var distance : Float;
	var tilesize : Int;
	var foreground : Bool;
	var data : Array<Array<Int>>;
}
