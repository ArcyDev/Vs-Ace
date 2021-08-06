package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class CreditsState extends MusicBeatState
{
    var artistArr:Array<Dynamic> = [
        ['BonesTheSkelebunny01', '@BSkelebunny01', 'bon'],
        ['Dax', '@Daxite_', 'dax'],
        ['D6', '@DSiiiiiix', 'd6'],
        ['Kamex', '@KamexVGM', 'kamex'],
        ['Pincer', '@PincerProd', 'pincer'],
        ['Shiba Chichi', '@lolychichi', 'chichi'],
        ['Sinna_roll', '@Sinna_roll', 'zhi'],
        ['Wildface', '@wildface1010', 'wildface'],
        ['WolfWrathKnight', '@wolfwrathknight', 'wolf']
    ];

    var animatorArr:Array<Dynamic> = [
        ['Shiba Chichi', '@lolychichi', 'chichi'],
        ['Tenzu', '@Tenzubushi', 'tenzu'],
        ['Wildface', '@wildface1010', 'wildface']
    ];

    var audioArr:Array<Dynamic> = [
        ['Kamex', '@KamexVGM', 'kamex']
    ];

    var programmingArr:Array<Dynamic> = [
        ['Arcy', '@AwkwardArcy', 'arcy'],
        ['AyeTSG', '@AyeTSG', 'tsg']
    ];

    var chartingArr:Array<Dynamic> = [
        ['ChubbyGamer464', '@ChubbyAlt', 'chubby'],
        ['Clipee', '@LilyClipster', 'clip'],
        ['DJ', '@AlchoholicDj', 'dj']
    ];

    var videoArr:Array<Dynamic> = [
        ['Retrospecter', '@RetroSpecter_', 'retro']
    ];

    var specialArr:Array<Dynamic> = [
        ['Kade', '@KadeDeveloper', 'kade'],
        ['Springy_4264', '@Springy_4264', 'springy']
    ];

    var selectList:Array<Dynamic> = [
        [
            [null, 'https://twitter.com/BSkelebunny01', 0xFFf66ebf],
            [null, 'https://twitter.com/Daxite_', 0xFF2b277d],
            [null, 'https://twitter.com/DSiiiiiix', 0xFF3063ff],
            [null, 'https://twitter.com/KamexVGM', 0xFFbae2ff],
            [null, 'https://twitter.com/PincerProd', 0xFF65faf3],
            [null, 'https://twitter.com/lolychichi', 0xFFfec4d0],
            [null, 'https://twitter.com/Sinna_roll', 0xFFeaffdd],
            [null, 'https://twitter.com/wildface1010', 0xFFe91313],
            [null, 'https://twitter.com/wolfwrathknight', 0xFF007cfe]
        ],
        [
            [null, 'https://twitter.com/lolychichi', 0xFFfec4d0],
            [null, 'https://twitter.com/Tenzubushi', 0xFF3b3b3b],
            [null, 'https://twitter.com/wildface1010', 0xFFe91313],
            [null, 'https://twitter.com/KamexVGM', 0xFFbae2ff],
            [null, 'https://twitter.com/AwkwardArcy', 0xFFed870f],
            [null, 'https://twitter.com/AyeTSG', 0xFF787878]
        ],
        [
            [null, 'https://twitter.com/ChubbyAlt', 0xFFc8a772],
            [null, 'https://twitter.com/LilyClipster', 0xFFfbef0b],
            [null, 'https://twitter.com/AlchoholicDj', 0xFF001698],
            [null, 'https://twitter.com/RetroSpecter_', 0xFF17d8e4],
            [null, 'https://twitter.com/KadeDeveloper', 0xFF4b6448],
            [null, 'https://twitter.com/Springy_4264', 0xFFac0047]
        ]
    ];

    var selector:Array<Int> = [0, 0];
    var iconList:FlxTypedGroup<FlxSprite>;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Reading Credits", null);
		#end

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
        Conductor.changeBPM(90);

        iconList = new FlxTypedGroup<FlxSprite>();

        var title:FlxText = new FlxText(0, 25, 0, 'CREDITS', 100);
        title.setFormat("VCR OSD Mono", 100, FlxColor.WHITE);
        title.screenCenter(X);
        add(title);

        var instructions:FlxText = new FlxText(10, 10, 500, 'Move to select a person\nConfirm to go to their Twitter page');
        instructions.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, FlxTextAlign.LEFT);
        add(instructions);
        
        var yPos = 180;

        // Artists
        var artistTitle:FlxText = new FlxText(50, 150, 0, 'Artists', 50);
        artistTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(artistTitle);

        for (i in 0...artistArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(50, yPos - 10).loadGraphic(Paths.image('icons/' + artistArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(115, yPos - 10, 0, artistArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[0][i][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(115, yPos + 10, 0, artistArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos = 180;

        // Animators
        var animatorTitle:FlxText = new FlxText(450, 150, 0, 'Animators', 50);
        animatorTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(animatorTitle);

        for (i in 0...animatorArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(450, yPos - 10).loadGraphic(Paths.image('icons/' + animatorArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(515, yPos - 10, 0, animatorArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[1][i][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(515, yPos + 10, 0, animatorArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos += 50;

        // Audio
        var audioTitle:FlxText = new FlxText(450, yPos, 0, 'Audio', 50);
        audioTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(audioTitle);

        yPos += 30;

        for (i in 0...audioArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(450, yPos - 10).loadGraphic(Paths.image('icons/' + audioArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(510, yPos - 10, 0, audioArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[1][i + animatorArr.length][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(510, yPos + 10, 0, audioArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos += 50;

        // Programming
        var programmingTitle:FlxText = new FlxText(450, yPos, 0, 'Programming', 50);
        programmingTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(programmingTitle);

        yPos += 30;

        for (i in 0...programmingArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(450, yPos - 10).loadGraphic(Paths.image('icons/' + programmingArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(510, yPos - 10, 0, programmingArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[1][i + animatorArr.length + audioArr.length][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(510, yPos + 10, 0, programmingArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos = 180;

        // Charting
        var chartingTitle:FlxText = new FlxText(850, 150, 0, 'Charting', 50);
        chartingTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(chartingTitle);

        for (i in 0...chartingArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(850, yPos - 10).loadGraphic(Paths.image('icons/' + chartingArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(910, yPos - 10, 0, chartingArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[2][i][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(910, yPos + 10, 0, chartingArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos += 50;

        // Video Editing
        var videoTitle:FlxText = new FlxText(850, yPos, 0, 'Video Editing', 50);
        videoTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(videoTitle);

        yPos += 30;

        for (i in 0...videoArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(850, yPos - 10).loadGraphic(Paths.image('icons/' + videoArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(910, yPos - 10, 0, videoArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[2][i + chartingArr.length][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(910, yPos + 10, 0, videoArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        yPos += 50;

        // Special Thanks
        var specialTitle:FlxText = new FlxText(850, yPos, 0, 'Special Thanks', 50);
        specialTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
        add(specialTitle);

        yPos += 30;

        for (i in 0...specialArr.length)
        {
            yPos += 50;
            var icon:FlxSprite = new FlxSprite(850, yPos - 10).loadGraphic(Paths.image('icons/' + specialArr[i][2], 'preload'));
            icon.setGraphicSize(50, 50);
            icon.updateHitbox();
            iconList.add(icon);

            var name:FlxTypeText = new FlxTypeText(910, yPos - 10, 0, specialArr[i][0], 24);
            name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
            selectList[2][i + chartingArr.length + videoArr.length][0] = name;
            add(name);
            name.start(0.1);

            var tag:FlxTypeText = new FlxTypeText(910, yPos + 10, 0, specialArr[i][1], 18);
            tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
            add(tag);
            tag.start(0.1);
        }

        add(iconList);

        selectList[selector[0]][selector[1]][0].setFormat("VCR OSD Mono", 24, selectList[selector[0]][selector[1]][2]);

		super.create();
	}

	override function update(elapsed:Float)
	{
        // For animations on beat
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        if (controls.BACK)
            FlxG.switchState(new MainMenuState());
        
        if (controls.ACCEPT)
            FlxG.openURL(selectList[selector[0]][selector[1]][1]);

        if (controls.UP_P)
            changeVertical(-1);
        else if (controls.DOWN_P)
            changeVertical(1);
        else if (controls.LEFT_P)
            changeHorizontal(-1);
        else if (controls.RIGHT_P)
            changeHorizontal(1);

        for (i in 0...iconList.length)
        {
            iconList.members[i].setGraphicSize(Std.int(FlxMath.lerp(50, iconList.members[i].width, 0.50)));
            iconList.members[i].updateHitbox();
        }

		super.update(elapsed);
	}

    override function beatHit()
    {
        for (i in 0...iconList.length)
            FlxTween.tween(iconList.members[i], {width: 60, height: 60}, 0.05, {ease: FlxEase.cubeOut});
    }

    function changeVertical(dir:Int)
    {
        selectList[selector[0]][selector[1]][0].setFormat("VCR OSD Mono", 24, FlxColor.WHITE);

        selector[1] += dir;
        if (selector[1] < 0)
            selector[1] = cast(selectList[selector[0]], Array<Dynamic>).length - 1;
        else if (selector[1] > cast(selectList[selector[0]], Array<Dynamic>).length - 1)
            selector[1] = 0;

        selectList[selector[0]][selector[1]][0].setFormat("VCR OSD Mono", 24, selectList[selector[0]][selector[1]][2]);
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    function changeHorizontal(dir:Int)
    {
        selectList[selector[0]][selector[1]][0].setFormat("VCR OSD Mono", 24, FlxColor.WHITE);

        selector[0] += dir;
        if (selector[0] < 0)
            selector[0] = selectList.length - 1;
        else if (selector[0] > selectList.length - 1)
            selector[0] = 0;

        if (selector[1] > cast(selectList[selector[0]], Array<Dynamic>).length - 1)
            selector[1] = cast(selectList[selector[0]], Array<Dynamic>).length - 1;

        selectList[selector[0]][selector[1]][0].setFormat("VCR OSD Mono", 24, selectList[selector[0]][selector[1]][2]);
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}
