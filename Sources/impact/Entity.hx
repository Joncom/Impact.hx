package impact;

import flambe.math.FMath;
import impact.CollisionMap.TraceResult;

class Entity
{
    // Last used entity id; incremented with each spawned entity
    private static var _lastId : Int = 0;

    // Collision Types - Determine if and how entities collide with each other
    // In ACTIVE vs. LITE or FIXED vs. ANY collisions, only the "weak" entity moves,
    // while the other one stays fixed. In ACTIVE vs. ACTIVE and ACTIVE vs. PASSIVE
    // collisions, both entities are moved. LITE or PASSIVE entities don't collide
    // with other LITE or PASSIVE entities at all. The behaiviour for FIXED vs.
    // FIXED collisions is undefined.
    public static var COLLIDES ( default, null ) = {
        NEVER: 0,
        LITE: 1,
        PASSIVE: 2,
        ACTIVE: 4,
        FIXED: 8
    };

    // Entity Types - used for checks
    public static var TYPE ( default, null ) = {
        NONE: 0,
        A: 1,
        B: 2,
        BOTH: 3
    };

    public var id ( default, null ) : Int;
    public var name : String;

    public var size : { x : Float, y : Float } = { x: 16, y: 16 };
    var offset: { x : Float, y : Float } = { x: 0, y: 0 };

    public var pos : { x : Float, y : Float } = { x: 0, y: 0 };
    var last : { x : Float, y : Float } = { x: 0, y: 0 };
    public var vel : { x : Float, y : Float } = { x: 0, y: 0 };
    public var accel : { x : Float, y : Float } = { x: 0, y: 0 };
    var friction : { x : Float, y : Float } = { x: 0, y: 0 };
    var maxVel : { x : Float, y : Float } = { x: 100, y: 100 };
    public var zIndex : Int = 0;
    var gravityFactor : Float = 1;
    var standing : Bool = false;
    var bounciness : Float = 0;
    var minBounceVelocity : Float = 40;

    var anims : std.Map<String, Animation> = new std.Map();
    var animSheet : AnimationSheet;
    var currentAnim : Animation;
    var health : Float = 10;

    public var type : Int = TYPE.NONE;
    public var checkAgainst : Int = TYPE.NONE;
    public var collides : Int = COLLIDES.NEVER;

    public var _killed : Bool = false;

    var slopeStanding = { min: FMath.toRadians(44), max: FMath.toRadians(136) };

    public var drawEarly = false; // CUSTOM

    public function new ( x : Float, y : Float, ?settings )
    {
        id = ++_lastId;
        pos.x = last.x = x;
        pos.y = last.y = y;

        if( settings != null ) {
            Impact.merge( this, settings );
        }
    }

    private function addAnim ( name : String, frameTime : Float, sequence : Array<Int>, ?stop : Bool = false ) : Animation
    {
        if( animSheet == null ) {
            throw "No animSheet to add the animation "+name+" to.";
        }
        var a = new Animation( animSheet, frameTime, sequence, stop );
        anims.set(name, a);
        if( currentAnim == null ) {
            currentAnim = a;
        }

        return a;
    }

    public function update ()
    {
        last.x = pos.x;
        last.y = pos.y;
        vel.y += Global.game.gravity * Global.system.tick * gravityFactor;

        vel.x = getNewVelocity( vel.x, accel.x, friction.x, maxVel.x );
        vel.y = getNewVelocity( vel.y, accel.y, friction.y, maxVel.y );

        // movement & collision
        var mx = vel.x * Global.system.tick;
        var my = vel.y * Global.system.tick;
        var res : TraceResult = Global.game.collisionMap.trace(
            pos.x, pos.y, mx, my, size.x, size.y
        );
        handleMovementTrace( res );

        if( currentAnim != null ) {
            currentAnim.update();
        }
    }

    // FIXME: Normally defined in Impact.js, right?
    function limit ( n : Float, min : Float, max : Float ) : Float
    {
        return Math.max(Math.min(n, max), min);
    }

    function getNewVelocity ( vel : Float, accel : Float, friction : Float, max : Float )
    {
        if( accel != 0 ) {
            return limit( ( vel + accel * Global.system.tick ), -max, max );
        }
        else if( friction != 0 ) {
            var delta = friction * Global.system.tick;

            if( vel - delta > 0) {
                return vel - delta;
            }
            else if( vel + delta < 0 ) {
                return vel + delta;
            }
            else {
                return 0;
            }
        }
        return limit( vel, -max, max );
    }

    function handleMovementTrace ( res : TraceResult ) : Void
    {
        standing = false;

        if( res.collision.y ) {
            if( bounciness > 0 && Math.abs(vel.y) > minBounceVelocity ) {
                vel.y *= -bounciness;
            }
            else {
                if( vel.y > 0 ) {
                    standing = true;
                }
                vel.y = 0;
            }
        }
        if( res.collision.x ) {
            if( bounciness > 0 && Math.abs(vel.x) > minBounceVelocity ) {
                vel.x *= -bounciness;
            }
            else {
                vel.x = 0;
            }
        }
        if( res.collision.slope != null ) {
            var s = res.collision.slope;

            if( bounciness > 0 ) {
                var proj = vel.x * s.nx + vel.y * s.ny;

                vel.x = (vel.x - s.nx * proj * 2) * bounciness;
                vel.y = (vel.y - s.ny * proj * 2) * bounciness;
            }
            else {
                var lengthSquared = s.x * s.x + s.y * s.y;
                var dot = (vel.x * s.x + vel.y * s.y)/lengthSquared;

                vel.x = s.x * dot;
                vel.y = s.y * dot;

                var angle = Math.atan2( s.x, s.y );
                if( angle > slopeStanding.min && angle < slopeStanding.max ) {
                    standing = true;
                }
            }
        }

        pos = res.pos;
    }

    public function draw () : Void
    {
        if( currentAnim != null ) {
            currentAnim.draw(
                pos.x - offset.x - Global.game._rscreen.x,
                pos.y - offset.y - Global.game._rscreen.y
            );
        }
    }

    public function kill ()
    {
        Global.game.removeEntity( this );
    }

    function receiveDamage ( amount : Float, ?from : Entity )
    {
        this.health -= amount;
        if( this.health <= 0 ) {
            this.kill();
        }
    }

    public function touches ( other : Entity ) : Bool
    {
        return !(
            this.pos.x >= other.pos.x + other.size.x ||
            this.pos.x + this.size.x <= other.pos.x ||
            this.pos.y >= other.pos.y + other.size.y ||
            this.pos.y + this.size.y <= other.pos.y
        );
    }

    function distanceTo ( other : Entity ) : Float
    {
        var xd = (this.pos.x + this.size.x/2) - (other.pos.x + other.size.x/2);
        var yd = (this.pos.y + this.size.y/2) - (other.pos.y + other.size.y/2);
        return Math.sqrt( xd*xd + yd*yd );
    }


    function angleTo ( other : Entity ) : Float
    {
        return Math.atan2(
            (other.pos.y + other.size.y/2) - (this.pos.y + this.size.y/2),
            (other.pos.x + other.size.x/2) - (this.pos.x + this.size.x/2)
        );
    }

    function check ( other:Entity ) {}
    function collideWith ( other:Entity, axis ) {}
    public function ready () {}
    public function erase () {}

    public static function checkPair ( a:Entity, b:Entity )
    {
        // Do these entities want checks?
        if( a.checkAgainst & b.type > 0 ) {
            a.check( b );
        }

        if( b.checkAgainst & a.type > 0 ) {
            b.check( a );
        }

        // If this pair allows collision, solve it! At least one entity must
        // collide ACTIVE or FIXED, while the other one must not collide NEVER.
        if(
            a.collides != 0 && b.collides != 0 &&
            a.collides + b.collides > COLLIDES.ACTIVE
        ) {
            solveCollision( a, b );
        }
    }

    static function solveCollision ( a:Entity, b:Entity )
    {
        // If one entity is FIXED, or the other entity is LITE, the weak
        // (FIXED/NON-LITE) entity won't move in collision response
        var weak:Entity = null;
        if(
            a.collides == COLLIDES.LITE ||
            b.collides == COLLIDES.FIXED
        ) {
            weak = a;
        }
        else if(
            b.collides == COLLIDES.LITE ||
            a.collides == COLLIDES.FIXED
        ) {
            weak = b;
        }


        // Did they already overlap on the X-axis in the last frame? If so,
        // this must be a vertical collision!
        if(
            a.last.x + a.size.x > b.last.x &&
            a.last.x < b.last.x + b.size.x
        ) {
            // Which one is on top?
            if( a.last.y < b.last.y ) {
                seperateOnYAxis( a, b, weak );
            }
            else {
                seperateOnYAxis( b, a, weak );
            }
            a.collideWith( b, 'y' );
            b.collideWith( a, 'y' );
        }

        // Horizontal collision
        else if(
            a.last.y + a.size.y > b.last.y &&
            a.last.y < b.last.y + b.size.y
        ){
            // Which one is on the left?
            if( a.last.x < b.last.x ) {
                seperateOnXAxis( a, b, weak );
            }
            else {
                seperateOnXAxis( b, a, weak );
            }
            a.collideWith( b, 'x' );
            b.collideWith( a, 'x' );
        }
    }

    // FIXME: This is a mess. Instead of doing all the movements here, the entities
    // should get notified of the collision (with all details) and resolve it
    // themselfs.

    static function seperateOnXAxis ( left:Entity, right:Entity, weak:Entity ) {
        var nudge = (left.pos.x + left.size.x - right.pos.x);

        // We have a weak entity, so just move this one
        if( weak != null ) {
            var strong = left == weak ? right : left;
            weak.vel.x = -weak.vel.x * weak.bounciness + strong.vel.x;

            var resWeak = Global.game.collisionMap.trace(
                weak.pos.x, weak.pos.y, weak == left ? -nudge : nudge, 0, weak.size.x, weak.size.y
            );
            weak.pos.x = resWeak.pos.x;
        }

        // Normal collision - both move
        else {
            var v2 = (left.vel.x - right.vel.x)/2;
            left.vel.x = -v2;
            right.vel.x = v2;

            var resLeft = Global.game.collisionMap.trace(
                left.pos.x, left.pos.y, -nudge/2, 0, left.size.x, left.size.y
            );
            left.pos.x = Math.floor(resLeft.pos.x);

            var resRight = Global.game.collisionMap.trace(
                right.pos.x, right.pos.y, nudge/2, 0, right.size.x, right.size.y
            );
            right.pos.x = Math.ceil(resRight.pos.x);
        }
    }

    static function seperateOnYAxis ( top:Entity, bottom:Entity, weak:Entity ) {
        var nudge = (top.pos.y + top.size.y - bottom.pos.y);

        // We have a weak entity, so just move this one
        if( weak != null ) {
            var strong = top == weak ? bottom : top;
            weak.vel.y = -weak.vel.y * weak.bounciness + strong.vel.y;

            // Riding on a platform?
            var nudgeX : Float = 0;
            if( weak == top && Math.abs(weak.vel.y - strong.vel.y) < weak.minBounceVelocity ) {
                weak.standing = true;
                nudgeX = strong.vel.x * Global.system.tick;
            }

            var resWeak = Global.game.collisionMap.trace(
                weak.pos.x, weak.pos.y, nudgeX, weak == top ? -nudge : nudge, weak.size.x, weak.size.y
            );
            weak.pos.y = resWeak.pos.y;
            weak.pos.x = resWeak.pos.x;
        }

        // Bottom entity is standing - just bounce the top one
        else if( Global.game.gravity != 0 && (bottom.standing || top.vel.y > 0) ) {
            var resTop = Global.game.collisionMap.trace(
                top.pos.x, top.pos.y, 0, -(top.pos.y + top.size.y - bottom.pos.y), top.size.x, top.size.y
            );
            top.pos.y = resTop.pos.y;

            if( top.bounciness > 0 && top.vel.y > top.minBounceVelocity ) {
                top.vel.y *= -top.bounciness;
            }
            else {
                top.standing = true;
                top.vel.y = 0;
            }
        }

        // Normal collision - both move
        else {
            var v2 = (top.vel.y - bottom.vel.y)/2;
            top.vel.y = -v2;
            bottom.vel.y = v2;

            var nudgeX : Float = bottom.vel.x * Global.system.tick;
            var resTop = Global.game.collisionMap.trace(
                top.pos.x, top.pos.y, nudgeX, -nudge/2, top.size.x, top.size.y
            );
            top.pos.y = resTop.pos.y;

            var resBottom = Global.game.collisionMap.trace(
                bottom.pos.x, bottom.pos.y, 0, nudge/2, bottom.size.x, bottom.size.y
            );
            bottom.pos.y = resBottom.pos.y;
        }
    }
}
