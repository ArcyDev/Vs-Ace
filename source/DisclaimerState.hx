package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DisclaimerState extends FlxState
{
    var selectSprite:FlxSprite;
    var loadingImage:FlxSprite;
    var confirmText:FlxText;
    var effects:Bool = true;
    var barProgress:Float = 0;

	override public function create():Void
	{
		super.create();

        var description1:FlxText = new FlxText(0, 100, 0, "This mod contains visual effects", 36);
        description1.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description1.screenCenter(X);
        var description2:FlxText = new FlxText(0, 150, 0, "that take a lot of processing power", 36);
        description2.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description2.screenCenter(X);
        var description3:FlxText = new FlxText(0, 200, 0, "and could cause the game to run poorly", 36);
        description3.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description3.screenCenter(X);

        var askText:FlxText = new FlxText(0, 350, 0, "Do you want to keep these visual effects on?", 36);
        askText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        askText.screenCenter(X);

        var description4:FlxText = new FlxText(0, 400, 0, "(Visual effects can be turned on or off in the Appearance options)", 24);
        description4.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE);
        description4.screenCenter(X);

        selectSprite = new FlxSprite(460, 495).makeGraphic(140, 75, FlxColor.GRAY);
        var yes:FlxText = new FlxText(470, 500, "YES", 64);
        yes.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE);
        var no:FlxText = new FlxText(690, 500, "NO", 64);
        no.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE);

        confirmText = new FlxText(0, 650, 0, "Press Enter to confirm", 36);
        confirmText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        confirmText.screenCenter(X);

        add(selectSprite);
        add(description1);
        add(description2);
        add(description3);
        add(description4);
        add(askText);
        add(yes);
        add(no);
        add(confirmText);
	}

	override function update(elapsed:Float)
	{
        if ((FlxG.keys.justPressed.LEFT || PlayerSettings.player1.controls.LEFT_P) && selectSprite.x == 660)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            selectSprite.x = 460;
            effects = true;
        }
        else if ((FlxG.keys.justPressed.RIGHT || PlayerSettings.player1.controls.RIGHT_P) && selectSprite.x == 460)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            selectSprite.x = 660;
            effects = false;
        }  
        else if (FlxG.keys.justPressed.ENTER || PlayerSettings.player1.controls.ACCEPT)
        {
            FlxG.save.data.distractions = effects;
            FlxG.save.data.snow = effects;
            FlxG.switchState(new TitleState());
        } 

		super.update(elapsed);
	}
}