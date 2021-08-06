package;

import flixel.system.FlxSound;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['Concrete-Jungle', 'Noreaster', 'Sub-Zero']
	];
	var curChar:Int = 0;
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true];
	public static var unlockedFrostbite:Bool = false;

	var weekCharacters:Array<Dynamic> = [
		['ace', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		"Ace",
	];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var characterSelectors:FlxGroup;
	var leftCharArrow:FlxSprite;
	var rightCharArrow:FlxSprite;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	
	// Unlock variables
	var shadeBG:FlxSprite;
	var aceIcon:HealthIcon;
	var unlockText:FlxText;

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [];
		
		weeks.push(true);

		for(i in 0...FlxG.save.data.weekUnlocked)
		{
			weeks.push(true);
		}
		return weeks;
	}

	override function create()
	{
		weekUnlocked = unlockWeeks();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		Conductor.changeBPM(90);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			if(FlxG.save.data.antialiasing)
				weekThing.antialiasing = true;

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				if(FlxG.save.data.antialiasing)
					lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);
		difficultySelectors.visible = false;

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('swapped', 'SWAPPED');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		characterSelectors = new FlxGroup();
		add(characterSelectors);

		leftCharArrow = new FlxSprite(400, 200);
		leftCharArrow.frames = ui_tex;
		leftCharArrow.animation.addByPrefix('idle', "arrow left");
		leftCharArrow.animation.addByPrefix('press', "arrow push left");
		leftCharArrow.animation.play('idle');
		characterSelectors.add(leftCharArrow);

		rightCharArrow = new FlxSprite(850, 200);
		rightCharArrow.frames = ui_tex;
		rightCharArrow.animation.addByPrefix('idle', "arrow right");
		rightCharArrow.animation.addByPrefix('press', "arrow push right");
		rightCharArrow.animation.play('idle');
		characterSelectors.add(rightCharArrow);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		if (unlockedFrostbite)
		{
			shadeBG = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
			shadeBG.alpha = 0.9;
			add(shadeBG);

			aceIcon = new HealthIcon('ace-stare');
			aceIcon.animation.curAnim.curFrame = 2;
			aceIcon.screenCenter();
			add(aceIcon);

			unlockText = new FlxText(0, 0, 0, 'A new storm appears in Freeplay!', 42);
			unlockText.screenCenter();
			unlockText.y += 150;
			add(unlockText);
		}

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		// For animations on beat
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (unlockedFrostbite)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(shadeBG, {alpha: 0}, 1);
				FlxTween.tween(aceIcon, {alpha: 0}, 1);
				FlxTween.tween(unlockText, {alpha: 0}, 1);
				unlockedFrostbite = false;
			}
		}
		else
		{
			if (!movedBack)
			{
				if (!selectedWeek)
				{
					if (controls.RIGHT)
					{
						rightArrow.animation.play('press');
						rightCharArrow.animation.play('press');
					}		
					else
					{
						rightArrow.animation.play('idle');
						rightCharArrow.animation.play('idle');
					}

					if (controls.LEFT)
					{
						leftArrow.animation.play('press');
						leftCharArrow.animation.play('press');
					}
					else
					{
						leftArrow.animation.play('idle');
						leftCharArrow.animation.play('idle');
					}

					if (controls.RIGHT_P)
					{
						if (difficultySelectors.visible)
							changeDifficulty(1);
						else
							changeCharacter(1);
					}
						
					else if (controls.LEFT_P)
					{
						if (difficultySelectors.visible)
							changeDifficulty(-1);
						else
							changeCharacter(-1);
					}
				}

				if (controls.ACCEPT)
				{
					if (difficultySelectors.visible)
						selectWeek();
					else
						changeSelection();
				}
			}

			if (controls.BACK && !movedBack && !selectedWeek)
			{
				if (difficultySelectors.visible)
					changeSelection();
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					movedBack = true;
					FlxG.switchState(new MainMenuState());
				}
			}
		}
		

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		for (i in 0...grpWeekCharacters.length)
		{
			grpWeekCharacters.members[0].bopHead();
			grpWeekCharacters.members[1].bopHead();
			grpWeekCharacters.members[2].bopHead();
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				if (curChar == 0)
					grpWeekCharacters.members[1].animation.play('bfConfirm');
				else if (curChar == 1)
					grpWeekCharacters.members[1].animation.play('ace-bfConfirm');
				else
					grpWeekCharacters.members[1].animation.play('retro-bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyChar = curChar;
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeCharacter(change:Int = 0):Void
	{
		curChar += change;

		if (curChar < 0)
			curChar = 2;
		if (curChar > 2)
			curChar = 0;

		switch (curChar)
		{
			case 0:
				grpWeekCharacters.members[1].setCharacter('bf');
			case 1:
				grpWeekCharacters.members[1].setCharacter('ace-bf');
			case 2:
				grpWeekCharacters.members[1].setCharacter('retro-bf');
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
			case 3:
				sprDifficulty.animation.play('swapped');
				sprDifficulty.offset.x = 70;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeSelection()
	{
		if (difficultySelectors.visible)
		{
			difficultySelectors.visible = false;
			characterSelectors.visible = true;

			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		else
		{
			difficultySelectors.visible = true;
			characterSelectors.visible = false;

			FlxG.sound.play(Paths.sound('confirmMenu'));
		}
	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
	}

	// No
	/*public static function unlockNextWeek(week:Int):Void
	{
		if(week <= weekData.length - 1 && FlxG.save.data.weekUnlocked == week)
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}*/
}
