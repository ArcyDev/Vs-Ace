import flixel.util.FlxColor;
import Section.SwagSection;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxSprite;

class SectionRender extends FlxSprite
{
    public var section:SwagSection;
    public var icon:FlxSprite;
    public var lastUpdated:Bool;

    public function new(x:Float,y:Float,GRID_SIZE:Int, ?Height:Int = 16)
    {
        super(x,y);

        makeGraphic(GRID_SIZE * 8, GRID_SIZE * Height,FlxColor.BLACK);

        FlxGridOverlay.overlay(this,GRID_SIZE, Std.int(GRID_SIZE), GRID_SIZE * 8,GRID_SIZE * Height);
    }

    override function update(elapsed) 
    {
    }
}