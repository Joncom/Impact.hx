package impact;

import kha.Scheduler;

class Timer
{
    var target : Float = 0;
    var base : Float = 0;
    var last : Float = 0;
    var pausedAt : Float = 0;

    public function new ( ?seconds : Float = 0 )
    {
        base = time;
        last = time;

        target = seconds;
    }

    public function set ( ?seconds : Float = 0 ) {
        target = seconds;
        base = time;
        pausedAt = 0;
    }

    public function reset ()
    {
        this.base = time;
        this.pausedAt = 0;
    }

    public function tick ()
    {
        if(Timer.usingFixedStep) return Timer.fixedStepAmount; // <-- CUSTOM FIXED STEP LOGIC
        var delta = time - this.last;
        this.last = time;
        return (this.pausedAt != 0 ? 0 : delta);
    }

    public function delta ()
    {
        return (this.pausedAt != 0 ? this.pausedAt : time) - this.base - this.target;
    }

    public function pause ()
    {
        if( this.pausedAt == 0 ) {
            this.pausedAt = time;
        }
    }

    public function unpause ()
    {
        if( this.pausedAt != 0 ) {
            this.base += time - this.pausedAt;
            this.pausedAt = 0;
        }
    }

    private static var _last : Float = 0;
    private static var time : Float = 0;
    public static var timeScale : Float = 1;
    public static var maxStep : Float = 0.05;

    private static function defaultStepFunction () // <-- Used to be named "step" before adding fixed step logic
    {
        var current : Float = Scheduler.time();
        var delta : Float = (current - _last);
        time += Math.min(delta, maxStep) * timeScale;
        _last = current;
    }

    // CUSTOM FIXED STEP LOGIC:
    public static var step ( default, null ) = defaultStepFunction;
    private static var usingFixedStep = false;
    private static var fixedStepAmount : Float = 0;
    private static function fixedStepFunction () { Timer.time += Timer.fixedStepAmount; }
    public static function useFixedStep (step : Float = 0.0167) { // Defaults to 60 FPS
        Timer.fixedStepAmount = step;
        Timer.usingFixedStep = true;
        Timer.step = Timer.fixedStepFunction;
    }
    public static function useDefaultStep () {
        Timer.usingFixedStep = false;
        Timer.step = Timer.defaultStepFunction;
    }
}
