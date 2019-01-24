package;

import kha.Assets;
import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.Scaler;
import kha.System;

class Main {
    private static var backbuffer:Image;

    public static function main() {
        System.start({title: "Impact", width: 640, height: 480}, init);
    }

    private static function init(window) {
        var stageWidth = 320;
        var stageHeight = 240;
        var scale = 2;

        // create a buffer to draw to
        backbuffer = Image.createRenderTarget(stageWidth * scale, stageHeight * scale);

        // ig.main
        impact.Global.system = new impact.System("canvas", 60, stageWidth, stageHeight, scale);
        impact.Global.system.graphics = backbuffer.g2; // make graphics available to impact.Image class and other classes
        impact.Global.input = new impact.Input();
        impact.Global.soundManager = new impact.SoundManager();
        impact.Global.ready = true;

        impact.Global.loader = new impact.Loader(game.MyGame);
        impact.Global.loader.load();

        System.notifyOnFrames(render);
    }

    public static function render(framebuffers:Array<Framebuffer>):Void {
        var g = backbuffer.g2;

        // clear and draw to our backbuffer
        g.begin(false);
        g.color = Color.Black;
        g.fillRect(0, 0, backbuffer.width, backbuffer.height);
        g.color = Color.White;
        if (impact.Global.game != null) {
            impact.Global.game.draw();
        } else if (impact.Global.loader != null) {
            impact.Global.loader.draw();
        }
        g.end();

        // draw our backbuffer onto the active framebuffer
        var framebuffer = framebuffers[0];
        framebuffer.g2.begin();
        Scaler.scale(backbuffer, framebuffer, System.screenRotation);
        framebuffer.g2.end();

        // Update game
        if (impact.Global.game != null) {
            impact.Timer.step();
            impact.Global.system.tick = impact.Global.system.clock.tick();
            impact.Global.game.update();
            impact.Global.input.clearPressed();
            impact.Image.drawCount = 0;
        }
    }
}
