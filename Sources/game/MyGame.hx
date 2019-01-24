package game;

class MyGame extends impact.Game
{
    public var font : impact.Font = new impact.Font('04b03.font.png');

    public function new()
    {
    	super();
    }

    override public function update()
    {
        super.update();
    }

    override function draw () {
        super.draw();

        // Add your own drawing code here
        var x = impact.Global.system.width/2;
        var y = impact.Global.system.height/2;
        font.draw2('It Works!', x, y, impact.Font.ALIGN.CENTER);
    }
}
