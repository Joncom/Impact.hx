package impact;

using StringTools;
class Global
{
    public static var game : Game;
    public static var loader : Loader;
    public static var system : System;
    public static var input : Input;
    public static var soundManager : SoundManager;
    public static var music = {
        play : function(?name) {},
        stop : function() {},
        pause : function() {},
        setLooping : function(looping) {},
        currentTrack : null,
        namedTracks : new std.Map<String, Int>(),
    };
    public static var ready = false;
    public static var ua = {
        #if (kha_android || kha_ios)
        mobile: true,
        touchDevice: true,
        #else
        mobile: false,
        touchDevice: false,
        #end
    };

    // Converts ImpactJS asset path into a Kha asset name
    public static function khaName(path:String) {
        // Get filename
        var parts = path.split("/");
        var khaName = parts[parts.length-1];

        // Drop the extension
        var parts = khaName.split(".");
        if(parts.length > 1) {
            parts.pop();
        }
        khaName = parts.join(".");

        // Kha uses replaces - with _
        khaName = khaName.replace("-", "_");

        // Kha uses replaces . with _
        khaName = khaName.replace(".", "_");

        // Kha prepends a _ to filename if filename starts with a number
        if(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].indexOf(khaName.charAt(0)) >= 0) {
            khaName = "_" + khaName;
        }

        return khaName;
    }
}
