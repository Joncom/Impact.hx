package impact;

class Game implements Delegate
{
    // clearColor: '#000000',
    public var gravity : Float = 0;
    public var screen : { x : Float, y : Float } = { x: 0, y: 0 };
    public var _rscreen ( default, null ) : { x : Float, y : Float } = { x: 0, y: 0 };

    public var entities : Array<Entity> = [];

    var namedEntities : std.Map<String, Entity> = new std.Map();
    public var collisionMap ( default, null ) : CollisionMap = CollisionMap.staticNoCollision;
    public var backgroundMaps : Array<BackgroundMap> = [];
    var backgroundAnims : std.Map<String, std.Map<Int, Animation>> = new std.Map();

    var autoSort : Bool = false;
    var sortBy : Entity -> Entity -> Int = null;

    var cellSize : Int = 64;

    var _deferredKill : Array<Entity> = [];
    var _levelToLoad = null;
    var _doSortEntities = false;

    @:keep public function new () {
        this.sortBy = SORT.Z_INDEX;
    }

    public function loadLevel ( data : LevelData )
    {
        this.screen = {x: 0, y: 0};

        // Entities
        this.entities = [];
        this.namedEntities = new std.Map();
        for( i in 0...data.entities.length ) {
            var ent = data.entities[i];
            var entClass : Class<Entity> = cast Type.resolveClass( "game.entities." + ent.type );
            if( entClass == null ) {
                throw "Could not resolve string to class: " + ent.type;
            }
            this.spawnEntity( entClass, ent.x, ent.y, ent.settings );
        }
        this.sortEntities();

        // Map Layer
        this.collisionMap = CollisionMap.staticNoCollision;
        this.backgroundMaps = [];
        for( i in 0...data.layer.length ) {
            var ld = data.layer[i];
            if( ld.name == 'collision' ) {
                this.collisionMap = new CollisionMap(ld.tilesize, ld.data );
            }
            else {
                var newMap = new BackgroundMap(ld.tilesize, ld.data, new Image( ld.tilesetName ));
                var anims = this.backgroundAnims.get( ld.tilesetName );
                newMap.anims = ( anims != null ? anims : new std.Map() );
                newMap.repeat = ld.repeat;
                newMap.distance = ld.distance;
                newMap.foreground = !!ld.foreground;
                newMap.preRender = !!ld.preRender;
                newMap.name = ld.name;
                this.backgroundMaps.push( newMap );
            }
        }

        // Call post-init ready function on all entities
        for( i in 0...this.entities.length ) {
            this.entities[i].ready();
        }
    }

    public function loadLevelDeferred ( data ) {
        this._levelToLoad = data;
    }

    public function getMapByName ( name : String ) : Map
    {
        if( name == 'collision' ) {
            return this.collisionMap;
        }

        for( i in 0...this.backgroundMaps.length ) {
            if( this.backgroundMaps[i].name == name ) {
                return this.backgroundMaps[i];
            }
        }

        return null;
    }

    public function getEntityByName ( name : String ) : Entity
    {
        return this.namedEntities.get( name );
    }

    public function getEntitiesByType ( type : Class<Entity> ) : Array<Entity>
    {
        var a = [];
        for( i in 0...this.entities.length ) {
            var ent = this.entities[i];
            if( Std.is( ent, type ) ) {
                a.push( ent );
            }
        }
        return a;
    }

    public function spawnEntity ( type : Class<Entity>, x : Float = 0, y : Float = 0, ?settings : Dynamic ) : Entity
    {
        var ent : Entity = Type.createInstance( type, [ x, y, settings ] );
        entities.push( ent );
        if( ent.name != null ) {
            namedEntities.set( ent.name, ent );
        }
        return ent;
    }

    public function sortEntities ()
    {
        this.entities.sort( this.sortBy );
    }

    public function sortEntitiesDeferred ()
    {
        this._doSortEntities = true;
    }

    public function removeEntity ( ent : Entity )
    {
        // Remove this entity from the named entities
        if( ent.name != null ) {
            this.namedEntities.remove( ent.name );
        }

        // We can not remove the entity from the entities[] array in the midst
        // of an update cycle, so remember all killed entities and remove
        // them later.
        // Also make sure this entity doesn't collide anymore and won't get
        // updated or checked
        ent._killed = true;
        ent.type = Entity.TYPE.NONE;
        ent.checkAgainst = Entity.TYPE.NONE;
        ent.collides = Entity.COLLIDES.NEVER;
        this._deferredKill.push( ent );
    }

    public function run ()
    {
        this.update();
        this.draw();
    }

    public function update ()
    {
        // load new level?
        if( this._levelToLoad != null ) {
            this.loadLevel( this._levelToLoad );
            this._levelToLoad = null;
        }

        // update entities
        updateEntities();
        checkEntities();

        // remove all killed entities
        for( i in 0...this._deferredKill.length ) {
            this._deferredKill[i].erase();
            this.entities.remove(this._deferredKill[i]);
        }
        this._deferredKill = [];

        // sort entities?
        if( this._doSortEntities || this.autoSort ) {
            this.sortEntities();
            this._doSortEntities = false;
        }

        // update background animations
        for( tileset in this.backgroundAnims ) {
            for( anim in tileset ) {
                anim.update();
            }
        }
    }

    function updateEntities ()
    {
        for( i in 0...this.entities.length) {
            var ent = this.entities[i];
            if( !ent._killed ) {
                ent.update();
            }
        }
    }

    public function draw ()
    {
        /*
        if( this.clearColor ) {
            ig.system.clear( this.clearColor );
        }
        */

        // This is a bit of a circle jerk. Entities reference game._rscreen
        // instead of game.screen when drawing themselfs in order to be
        // "synchronized" to the rounded(?) screen position
        this._rscreen.x = Global.system.getDrawPos(this.screen.x)/Global.system.scale;
        this._rscreen.y = Global.system.getDrawPos(this.screen.y)/Global.system.scale;

        var mapIndex : Int = 0;
        while( mapIndex < this.backgroundMaps.length ) {
            var map = this.backgroundMaps[mapIndex];
            if( map.foreground ) {
                // All foreground layers are drawn after the entities
                break;
            }
            map.setScreenPos( this.screen.x, this.screen.y );
            map.draw();
            mapIndex++;
        }

        this.drawEntities();

        while( mapIndex < this.backgroundMaps.length ) {
            var map = this.backgroundMaps[mapIndex];
            map.setScreenPos( this.screen.x, this.screen.y );
            map.draw();
            mapIndex++;
        }
    }

    function drawEntities ()
    {
        for( i in 0...this.entities.length )
        {
            this.entities[i].draw();
        }
    }

    function checkEntities () : Void
    {
        // Insert all entities into a spatial hash and check them against any
        // other entity that already resides in the same cell. Entities that are
        // bigger than a single cell, are inserted into each one they intersect
        // with.

        // A list of entities, which the current one was already checked with,
        // is maintained for each entity.

        var hash : std.Map<Int, std.Map<Int, Array<Entity>>> = new std.Map();
        for( e in 0...this.entities.length ) {
            var entity = this.entities[e];

            // Skip entities that don't check, don't get checked and don't collide
            if(
                entity.type == Entity.TYPE.NONE &&
                entity.checkAgainst == Entity.TYPE.NONE &&
                entity.collides == Entity.COLLIDES.NEVER
            ) {
                continue;
            }

            var checked : std.Map<Int, Bool> = new std.Map(),
                xmin = Math.floor( entity.pos.x/this.cellSize ),
                ymin = Math.floor( entity.pos.y/this.cellSize ),
                xmax = Math.floor( (entity.pos.x+entity.size.x)/this.cellSize ) + 1,
                ymax = Math.floor( (entity.pos.y+entity.size.y)/this.cellSize ) + 1;

            for( x in xmin...xmax ) {
                for( y in ymin...ymax ) {

                    // Current cell is empty - create it and insert!
                    if( hash.get(x) == null ) {
                        hash.set(x, new std.Map());
                        hash.get(x).set(y, [entity]);
                    }
                    else if( hash[x][y] == null ) {
                        hash.get(x).set(y, [entity]);
                    }

                    // Check against each entity in this cell, then insert
                    else {
                        var cell = hash.get(x).get(y);
                        for( c in 0...cell.length ) {

                            // Intersects and wasn't already checkd?
                            if( entity.touches(cell[c]) && checked.get(cell[c].id) != true ) {
                                checked.set(cell[c].id, true);
                                Entity.checkPair( entity, cell[c] );
                            }
                        }
                        cell.push(entity);
                    }
                } // end for y size
            } // end for x size
        } // end for entities
    }

    static var SORT = {
        Z_INDEX: function( a : Entity, b : Entity ) : Int { return a.zIndex - b.zIndex; },
        POS_X:   function( a : Entity, b : Entity ) : Int { var n = (a.pos.x+a.size.x) - (b.pos.x+b.size.x); return (n == 0 ? 0 : ( n < 0 ? -1 : 1 ) ); },
        POS_Y:   function( a : Entity, b : Entity ) : Int { var n = (a.pos.y+a.size.y) - (b.pos.y+b.size.y); return (n == 0 ? 0 : ( n < 0 ? -1 : 1 ) ); }
    }
}
