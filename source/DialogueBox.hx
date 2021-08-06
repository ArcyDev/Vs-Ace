package;

import openfl.display.Preloader.DefaultPreloader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curMood:String = '';
	var curCharacter:String = '';

	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitGF:FlxSprite;
	var portraitAceBF:FlxSprite;
	var portraitRetroBF:FlxSprite;
	var portraitRetro:FlxSprite;
	var portraitSine:FlxSprite;

	var bgFade:FlxSprite;

	public var music:FlxSound;

	public function new(dialogueList:Array<String>)
	{
		super();

		if (PlayState.isStoryMode)
		{
			music = new FlxSound().loadEmbedded(Paths.music('ambiance', 'shared'), true, true);
            music.volume = 0;
			music.fadeIn(1, 0, 0.8);
            FlxG.sound.list.add(music);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		// Box sprite
		box = new FlxSprite(-20, 350);
		box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);

		this.dialogueList = dialogueList;
		
		// Ace sprite
		portraitLeft = new FlxSprite(-20, 50);
		portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/AcePortraits', 'shared');
		portraitLeft.animation.addByPrefix('Neutral', 'Neutral', 24, false);
		portraitLeft.animation.addByPrefix('Happy', 'Happy', 24, false);
		portraitLeft.animation.addByPrefix('Shocked', 'Shocked', 24, false);
		portraitLeft.animation.addByPrefix('Embarassed', 'Embarassed', 24, false);
		portraitLeft.scrollFactor.set();
		portraitLeft.animation.play('Neutral', true);
		add(portraitLeft);
		portraitLeft.visible = false;

		// Bf sprite
		portraitRight = new FlxSprite(200, 75);
		portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/BFPortraits', 'shared');
		portraitRight.animation.addByPrefix('Neutral', 'Neutral', 24, false);
		portraitRight.animation.addByPrefix('Happy', 'Happy', 24, false);
		portraitRight.scrollFactor.set();
		portraitRight.animation.play('Neutral', true);
		add(portraitRight);
		portraitRight.visible = false;

		// Gf sprite
		portraitGF = new FlxSprite(200, 75);
		portraitGF.frames = Paths.getSparrowAtlas('characters/portraits/GFPortraits', 'shared');
		portraitGF.animation.addByPrefix('Neutral', 'Neutral', 24, false);
		portraitGF.animation.addByPrefix('Confused', 'Confused', 24, false);
		portraitGF.scrollFactor.set();
		portraitGF.animation.play('Neutral', true);
		add(portraitGF);
		portraitGF.visible = false;

		// Ace Bf sprite
		portraitAceBF = new FlxSprite(850, 150).loadGraphic(Paths.image('characters/portraits/BFAcePortrait', 'shared'));
		portraitAceBF.scrollFactor.set();
		add(portraitAceBF);
		portraitAceBF.visible = false;

		// Retro Bf sprite
		portraitRetroBF = new FlxSprite(850, 150).loadGraphic(Paths.image('characters/portraits/BFRetroPortrait', 'shared'));
		portraitRetroBF.scrollFactor.set();
		add(portraitRetroBF);
		portraitRetroBF.visible = false;

		// Retro sprite
		portraitRetro = new FlxSprite(850, 150).loadGraphic(Paths.image('characters/portraits/BGRetroPortrait', 'shared'));
		portraitRetro.scrollFactor.set();
		add(portraitRetro);
		portraitRetro.visible = false;

		// Sine sprite
		portraitSine = new FlxSprite(850, 125).loadGraphic(Paths.image('characters/portraits/SinePortrait', 'shared'));
		portraitSine.scrollFactor.set();
		add(portraitSine);
		portraitSine.visible = false;
		
		box.animation.play('normalOpen');
		add(box);

		box.screenCenter(X);
		box.x += 50;
		portraitLeft.screenCenter(X);
		portraitLeft.x -= 375;
		portraitRight.screenCenter(X);
		portraitRight.x += 400;
		portraitGF.screenCenter(X);
		portraitGF.x += 440;
		portraitRetro.screenCenter(X);
		portraitRetro.x -= 375;
		portraitSine.screenCenter(X);
		portraitSine.x -= 350;

		dropText = new FlxText(168, 477, 1000, "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = FlxColor.BLACK;
		add(dropText);

		swagDialogue = new FlxTypeText(165, 475, 1000, "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = FlxColor.WHITE;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted)
		{				
			if (!isEnding)
				FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (music.playing)
						music.fadeOut(1.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						portraitGF.visible = false;
						portraitAceBF.visible = false;
						portraitRetroBF.visible = false;
						portraitRetro.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		else if (PlayerSettings.player1.controls.BACK && dialogueStarted)
		{
			isEnding = true;

			if (music.playing)
				music.fadeOut(1.2, 0);

			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				swagDialogue.alpha -= 1 / 5;
				dropText.alpha = swagDialogue.alpha;
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				portraitSine.visible = false;
				portraitLeft.animation.play(curMood, true);
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					swagDialogue.color = 0xFF3c567a;
					box.flipX = true;
				}
			case 'bf':
				portraitLeft.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				portraitSine.visible = false;
				portraitRight.animation.play(curMood, true);
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					swagDialogue.color = FlxColor.fromRGB(80, 165, 235);
					box.flipX = false;
				}
			case 'gf':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				portraitSine.visible = false;
				portraitGF.animation.play(curMood, true);

				// Offset for confused portrait
				portraitGF.screenCenter(X);
				portraitGF.x += 440;
				if (curMood == 'Confused')
					portraitGF.x -= 50;

				if (!portraitGF.visible)
				{
					portraitGF.visible = true;
					swagDialogue.color = 0xFF9f72f3;
					box.flipX = false;
				}
			case 'ace':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				portraitSine.visible = false;
				if (!portraitAceBF.visible)
				{
					portraitAceBF.visible = true;
					swagDialogue.color = 0xFF3c567a;
					box.flipX = false;
				}
			case 'retro':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetro.visible = false;
				portraitSine.visible = false;
				if (!portraitRetroBF.visible)
				{
					portraitRetroBF.visible = true;
					swagDialogue.color = FlxColor.fromRGB(42, 136, 164);
					box.flipX = false;
				}
			case 'BGretro':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitSine.visible = false;
				if (!portraitRetro.visible)
				{
					portraitRetro.visible = true;
					swagDialogue.color = FlxColor.fromRGB(42, 136, 164);
					box.flipX = true;
				}
			case 'sine':
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitGF.visible = false;
				portraitAceBF.visible = false;
				portraitRetroBF.visible = false;
				portraitRetro.visible = false;
				if (!portraitSine.visible)
				{
					portraitSine.visible = true;
					swagDialogue.color = 0xFFe86b17;
					box.flipX = true;
				}
		}

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curMood = splitName[0];
		if (curMood == '')
			curMood = 'Neutral'; // Just for cleaner logic
		curCharacter = splitName[1];
		var dialogue:String = dialogueList[0].substr(splitName[1].length + 2 + splitName[0].length).trim();
		dialogue = dialogue.replace('[Happy]',':D').replace('[Surprised]',':0').replace('[Sad]',':(');
		dialogueList[0] = dialogue;
	}
}
