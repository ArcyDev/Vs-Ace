package;

import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import webm.WebmIo;
import webm.WebmIoFile;
import webm.WebmPlayer;
import webm.WebmEvent;
import flixel.input.keyboard.FlxKey;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
#if windows
import Discord.DiscordClient;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyChar:Int = 0;
	public static var storyDifficulty:Int = 1;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var speechBubble:FlxSprite;
	public static var acePortrait:FlxSprite;
	public static var hintText:FlxTypeText;
	public static var hintDropText:FlxText;
	public static var yesText:FlxText;
	public static var noText:FlxText;
	public static var selectSpr:FlxSprite;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	

	public var accuracy:Float = 0.00;
	public static var deaths:Int = 0;
	public static var shownHint:Bool = false;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	// Ace Frozen Notes Mechanic
	private var frozen:Array<Bool> = [false, false, false, false];
	private var breakAnims:FlxTypedGroup<FlxSprite>;

	// Special song effects
	private var scrollSpeedMultiplier:Float = 1;
	private var slowDown:Bool = false;
	private var bgDarken:FlxSprite;
	private var snowDarken:FlxSprite;
	private var endImage:FlxSprite;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	var notesHitArray:Array<Date> = [];
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var frontChars:FlxSprite;
	var backChars:FlxSprite;

	var snow:WebmPlayer;
	var snowSpr:FlxSprite;
	var snowVid:WebmIo;
	var snowfall:WebmPlayer;
	var snowfallSpr:FlxSprite;
	var snowfallVid:WebmIo;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var inCutscene:Bool = false;
	var endMusic:FlxSound;
	var endLoop:FlxSound;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;
	public static var missTime = 0.0; // Track time past last miss for setting voices volume on Optimized
	private var frozenTime:Float = 0; // Track time when frozen to prevent pause cheat

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (!isStoryMode)
		{
			sicks = 0;
			bads = 0;
			shits = 0;
			goods = 0;
		}
		misses = 0;

		highestCombo = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ curSong.replace('-', ' ')
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('concrete-jungle', 'concrete-jungle');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];

		if (isStoryMode && SONG.player1 == 'bf-cold')
		{
			endMusic = new FlxSound().loadEmbedded(Paths.music('end', 'shared'), false, true);
			endLoop =  new FlxSound().loadEmbedded(Paths.music('endLoop', 'shared'), true, true);
            FlxG.sound.list.add(endMusic);
			FlxG.sound.list.add(endLoop);
		}
	
		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(pos,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = pos;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		// dialogue shit
		switch (songLowercase)
		{
			case 'concrete-jungle':
				if (storyChar == 1)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/concrete-jungle/concrete-jungleDialogueAce'));
				else if (storyChar == 2)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/concrete-jungle/concrete-jungleDialogueRetro'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/concrete-jungle/concrete-jungleDialogue'));
			case 'noreaster':
				if (storyChar == 1)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/noreaster/noreasterDialogueAce'));
				else if (storyChar == 2)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/noreaster/noreasterDialogueRetro'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/noreaster/noreasterDialogue'));
			case 'sub-zero':
				if (storyChar == 1)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/sub-zero/sub-zeroDialogueAce'));
				else if (storyChar == 2)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/sub-zero/sub-zeroDialogueRetro'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/sub-zero/sub-zeroDialogue'));			
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'city';

		if (SONG.stage != null)
			stageCheck = SONG.stage;

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				case 'city':
					defaultCamZoom = 0.5;
					curStage = 'city';
					var bg:FlxSprite = new FlxSprite(0, 0);
					if (SONG.song == 'Frostbite')
						bg.loadGraphic(Paths.image('Background3', 'week-ace'));
					else if (SONG.song == 'Sub Zero')
						bg.loadGraphic(Paths.image('Background2', 'week-ace'));
					else
						bg.loadGraphic(Paths.image('Background1', 'week-ace'));
					if (FlxG.save.data.antialiasing)
						bg.antialiasing = true;
					bg.scrollFactor.set(1, 1);
					bg.active = false;
					bg.screenCenter();
					bg.y += 25;
					add(bg);

					backChars = new FlxSprite(0, 0);
					backChars.frames = Paths.getSparrowAtlas('Back Characters', 'week-ace');
					backChars.animation.addByPrefix('bop', 'bop', 24, false);
					if (FlxG.save.data.antialiasing)
						backChars.antialiasing = true;
					backChars.scrollFactor.set(1, 1);
					backChars.screenCenter();
					backChars.x -= 30;
					backChars.y += 86;
					add(backChars);

					var fences:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Fences', 'week-ace'));
					if (FlxG.save.data.antialiasing)
						fences.antialiasing = true;
					fences.scrollFactor.set(1, 1);
					fences.active = false;
					fences.screenCenter();
					fences.y += 25;
					add(fences);

					var snowLayer1:FlxSprite;
					switch(songLowercase)
					{
						case 'concrete-jungle':
							snowLayer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('P1Snow1', 'week-ace'));
						case 'noreaster':
							snowLayer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('P2Snow1', 'week-ace'));
						case 'sub-zero':
							snowLayer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('P3Snow1', 'week-ace'));
						case 'frostbite':
							snowLayer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('P4Snow1', 'week-ace'));
						default:
							snowLayer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('P1Snow1', 'week-ace'));
					}
					
					if (FlxG.save.data.antialiasing)
						snowLayer1.antialiasing = true;
					snowLayer1.scrollFactor.set(1, 1);
					snowLayer1.active = false;
					snowLayer1.screenCenter();
					snowLayer1.y += 25;
					add(snowLayer1);

					frontChars = new FlxSprite(0, 0);
					frontChars.frames = Paths.getSparrowAtlas('Front Characters', 'week-ace');
					frontChars.animation.addByPrefix('bop', 'bop', 24, false);
					if (FlxG.save.data.antialiasing)
						frontChars.antialiasing = true;
					frontChars.scrollFactor.set(1, 1);
					frontChars.screenCenter();
					frontChars.x -= 55;
					frontChars.y += 195;
					add(frontChars);

					var snowLayer2:FlxSprite;
					switch(songLowercase)
					{
						case 'concrete-jungle':
							snowLayer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('P1Snow2', 'week-ace'));
						case 'noreaster':
							snowLayer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('P1Snow2', 'week-ace'));
						case 'sub-zero':
							snowLayer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('P3Snow2', 'week-ace'));
						case 'frostbite':
							snowLayer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('P3Snow2', 'week-ace'));
						default:
							snowLayer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('P1Snow2', 'week-ace'));
					}
					if (FlxG.save.data.antialiasing)
						snowLayer2.antialiasing = true;
					snowLayer2.scrollFactor.set(1, 1);
					snowLayer2.active = false;
					snowLayer2.screenCenter();
					snowLayer2.y += 28;
					add(snowLayer2);

					var lamps:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Lamps', 'week-ace'));
					if (FlxG.save.data.antialiasing)
						lamps.antialiasing = true;
					lamps.scrollFactor.set(1, 1);
					lamps.active = false;
					lamps.screenCenter();
					lamps.y += 25;
					add(lamps);
			}
		}

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 50, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'ace':
				dad.y -= 75;
				dad.scale.set(1.25, 1.25);
		}

		if (storyChar == 1)
			SONG.player1 = 'bf-ace';
		else if (storyChar == 2)
			SONG.player1 = 'bf-retro';

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'city':
				boyfriend.x += 300;
				boyfriend.y += 198;
				gf.x -= 140;
				gf.y += 175;
				dad.x -= 300;
				dad.y += 200;
		}


		if (!PlayStateChangeables.Optimize)
		{
			if (SONG.song == 'Sub-Zero' || SONG.song == 'Frostbite')
			{
				bgDarken = new FlxSprite(-1000, -400).makeGraphic(3500, 1750, FlxColor.BLACK);
				if (SONG.song == 'Sub-Zero')
					bgDarken.alpha = 0;
				else
					bgDarken.alpha = 0.5;
				bgDarken.active = false;
				add(bgDarken);
			}

			add(gf);
			add(dad);
			add(boyfriend);

			if (curStage == 'city')
			{
				if (SONG.song == 'Sub-Zero' || SONG.song == 'Frostbite')
				{
					var snowLayer3 = new FlxSprite(0, 0).loadGraphic(Paths.image('P3Snow3', 'week-ace'));
					if (FlxG.save.data.antialiasing)
						snowLayer3.antialiasing = true;
					snowLayer3.scrollFactor.set(1, 1);
					snowLayer3.active = false;
					snowLayer3.screenCenter();
					snowLayer3.y += 97;
					add(snowLayer3);

					snowDarken = new FlxSprite(0, 0).loadGraphic(Paths.image('P3Snow3Darken', 'week-ace'));
					if (SONG.song == 'Sub-Zero')
						snowDarken.alpha = 0;
					else
						snowDarken.alpha = 0.5;
					if (FlxG.save.data.antialiasing)
						snowDarken.antialiasing = true;
					snowDarken.scrollFactor.set(1, 1);
					snowDarken.active = false;
					snowDarken.screenCenter();
					snowDarken.y += 97;
					add(snowDarken);
				}

				var overlay:FlxSprite = new FlxSprite(-1450, -900).loadGraphic(Paths.image('Overlay', 'week-ace'));
				overlay.scale.set(0.75, 0.75);
				if (FlxG.save.data.antialiasing)
					overlay.antialiasing = true;
				overlay.scrollFactor.set(1, 1);
				overlay.active = false;
				add(overlay);
			}
		}

		if (loadRep)
		{
			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		// Video stuff for effects
		if (!PlayStateChangeables.Optimize)
		{
			if (FlxG.save.data.snow)
			{
				switch(SONG.song)
				{
					case 'Concrete-Jungle':
						snowfallVid = new WebmIoFile(Paths.video('snowfall1', 'preload'));
					case 'Noreaster':
						snowfallVid = new WebmIoFile(Paths.video('snowfall2', 'preload'));
					case 'Sub-Zero':
						snowfallVid = new WebmIoFile(Paths.video('snowfall2', 'preload'));
					case 'Frostbite':
						snowfallVid = new WebmIoFile(Paths.video('snowfall4', 'preload'));
					default:
						snowfallVid = new WebmIoFile(Paths.video('snowfall1', 'preload'));
				}
				snowfall = new WebmPlayer();
				snowfall.fuck(snowfallVid, false);
				snowfallSpr = new FlxSprite().loadGraphic(snowfall.bitmapData);
				snowfallSpr.scale.set(2.5, 2.5);
				snowfallSpr.screenCenter();
				snowfallSpr.blend = BlendMode.SCREEN;
				snowfallSpr.y += 75;
				add(snowfallSpr);
				snowfall.play();
				snowfall.addEventListener(WebmEvent.STOP, loopSnowfall);
			}

			if (FlxG.save.data.distractions)
			{
				snowVid = new WebmIoFile(Paths.video('snow', 'preload'));
				snow = new WebmPlayer();
				snow.fuck(snowVid, false);
				snowSpr = new FlxSprite();
				snowSpr.loadGraphic(snow.bitmapData);
				snowSpr.screenCenter();
				snowSpr.scale.set(5.5, 5.5);
				snowSpr.blend = BlendMode.SCREEN;

				// Always playing for Frostbite
				if (SONG.song == 'Frostbite')
				{
					snow.addEventListener(WebmEvent.STOP, function(e) {
						recurseSnow();
					});
					snow.play();
				}
				else
					add(snowSpr);
			}
		}	

		var doof:DialogueBox = new DialogueBox(dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		breakAnims = new FlxTypedGroup<FlxSprite>();

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		generateStaticArrows(0);
		generateStaticArrows(1);

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			curSong.replace('-', ' ')
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty)
			+ (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
			add(replayTxt);
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		if (curSong == 'Frostbite')
			iconP2 = new HealthIcon('ace-stare', false);
		else
			iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		if (FlxG.save.data.distractions && !PlayStateChangeables.Optimize && curSong == 'Frostbite')
		{
			add(snowSpr);
			snowSpr.cameras = [camHUD];
		}		

		strumLineNotes.cameras = [camHUD];
		breakAnims.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		startingSong = true;

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case 'concrete-jungle':
					schoolIntro(doof);
				case 'noreaster':
					schoolIntro(doof);
				case 'sub-zero':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
			startCountdown();

		// Game over hint stuff
		if (!shownHint)
		{
			acePortrait = new FlxSprite(20, 100);
			acePortrait.frames = Paths.getSparrowAtlas('characters/portraits/AcePortraits', 'shared');
			acePortrait.animation.addByPrefix('Neutral', 'Neutral', 24, false);
			acePortrait.animation.addByPrefix('Embarassed', 'Embarassed', 24, false);

			speechBubble = new FlxSprite(50, 400);
			speechBubble.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
			speechBubble.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
			speechBubble.animation.addByPrefix('normal', 'speech bubble normal', 24);
			speechBubble.flipX = true;

			hintText = new FlxTypeText(125, 550, 1050, "", 32);
			hintText.font = 'Pixel Arial 11 Bold';
			hintText.color = 0xFF3c567a;
			hintText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];

			hintDropText = new FlxText(128, 552, 1050, "", 32);
			hintDropText.font = 'Pixel Arial 11 Bold';
			hintDropText.color = FlxColor.BLACK;

			yesText = new FlxText(850, 400, 0, 'YES', 48);
			yesText.font = 'Pixel Arial 11 Bold';
			yesText.color = FlxColor.WHITE;

			noText = new FlxText(1075, 400, 0, 'NO', 48);
			noText.font = 'Pixel Arial 11 Bold';
			noText.color = FlxColor.WHITE;

			selectSpr = new FlxSprite(840, 390).makeGraphic(160, 90, FlxColor.WHITE);
			selectSpr.alpha = 0.5;

			acePortrait.cameras = [camHUD];
			speechBubble.cameras = [camHUD];
			hintText.cameras = [camHUD];
			hintDropText.cameras = [camHUD];
			yesText.cameras = [camHUD];
			noText.cameras = [camHUD];
			selectSpr.cameras = [camHUD];
		}		

		if (!loadRep)
			rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;

				add(dialogueBox);
			}
			else
				startCountdown();
		});
	}

	var startTimer:FlxTimer;

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.playAnim('idle');
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
			return;
		if (keys[data])
			return;

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (!frozen[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
				return;

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.10;
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ curSong.replace('-', ' ')
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	public function generateSong(dataPath:String):Void
	{
		Conductor.changeBPM(SONG.bpm);

		curSong = SONG.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, storyDifficulty == 3));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, storyDifficulty == 3));
		else
			vocals = new FlxSound();
		#end

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);
		add(breakAnims);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
			}
		}
		#end

		var validNotes = new Array<Note>();
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, songNotes[3]);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset

					if (susLength == 0) // No sustain notes are valid
						validNotes.push(swagNote);
				}
			}
		}

		// Randomize ice notes
		if (FlxG.save.data.specialMechanics && (curSong == 'Noreaster' || curSong == "Sub-Zero" || curSong == 'Frostbite'))
		{
			var iceNoteAmount:Int;
			if (curSong == 'Noreaster')
				switch (storyDifficulty)
				{
					case 0:
						iceNoteAmount = 5;
					case 1:
						iceNoteAmount = 10;
					case 2:
						iceNoteAmount = 25;
					case 3:
						iceNoteAmount = 100;
					default:
						iceNoteAmount = 0;
				}
			else if (curSong == 'Sub-Zero')
				switch (storyDifficulty)
				{
					case 0:
						iceNoteAmount = 10;
					case 1:
						iceNoteAmount = 25;
					case 2:
						iceNoteAmount = 50;
					case 3:
						iceNoteAmount = 150;
					default:
						iceNoteAmount = 0;
				}
			else
				switch (storyDifficulty)
				{
					case 0:
						iceNoteAmount = 25;
					case 1:
						iceNoteAmount = 75;
					case 2:
						iceNoteAmount = 125;
					case 3:
						iceNoteAmount = 250;
					default:
						iceNoteAmount = 0;
				}

			for (i in 0...iceNoteAmount)
			{
				// No more ice notes can be added
				if (validNotes.length == 0)
					break;

				var targetNote = validNotes[FlxG.random.int(0, validNotes.length - 1)];
				var validArray:Array<Int> = [0, 1, 2, 3];

				// Check which notes we can use
				// This is absolutely atrocious on computation time I am so sorry I'm this bad
				for (j in 0...unspawnNotes.length)
				{
					if (Math.abs(unspawnNotes[j].strumTime - targetNote.strumTime) < 0.25 && unspawnNotes[j].mustPress)
						validArray.remove(unspawnNotes[j].noteData);
				}

				// Add in the ice note
				var newNote = new Note(targetNote.strumTime, validArray[FlxG.random.int(0, validArray.length - 1)], null, false, false, true);
				newNote.mustPress = true;
				unspawnNotes.push(newNote);
				validNotes.remove(targetNote);
			}
		}

		unspawnNotes.sort(sortByShit);

		// Always put a frozen note on the first player note
		if (FlxG.save.data.specialMechanics && curSong == 'Noreaster')
		{
			for (i in 0...unspawnNotes.length)
			{
				if (unspawnNotes[i].mustPress)
				{
					var validArray:Array<Int> = [0, 1, 2, 3];
					validArray.remove(unspawnNotes[i].noteData);

					var newNote = new Note(unspawnNotes[i].strumTime, validArray[FlxG.random.int(0, validArray.length - 1)], null, false, false, true);
					newNote.mustPress = true;
					unspawnNotes.insert(i, newNote);
					break;
				}
			}
		}

		if (curSong == 'Sub-Zero')
		{
			slowDown = true;
			scrollSpeedMultiplier = 0.66;
		}

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var breakAnim:FlxSprite = new FlxSprite(0, strumLine.y);

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			breakAnim.frames = Paths.getSparrowAtlas('IceBreakAnim');

			var lowerDir:String = dataSuffix[i].toLowerCase();

			for (j in 0...4)
				babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
			babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
			babyArrow.animation.addByPrefix('frozen', 'arrowFrozen' + dataSuffix[i]);
			babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
			babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

			breakAnim.animation.addByPrefix('break', lowerDir, 24, false);

			babyArrow.x += Note.swagWidth * i;
			breakAnim.x += Note.swagWidth * i;
			
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			breakAnim.setGraphicSize(Std.int(babyArrow.width), Std.int(babyArrow.height));

			if (FlxG.save.data.antialiasing)
			{
				babyArrow.antialiasing = true;
				breakAnim.antialiasing = true;
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			breakAnim.updateHitbox();
			breakAnim.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
					breakAnims.add(breakAnim);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			breakAnim.x += 25 + ((FlxG.width / 2) * player);

			breakAnim.visible = false;
			breakAnim.animation.finishCallback = function(str:String)
			{
				breakAnim.visible = false;
			}
			
			if (PlayStateChangeables.Optimize)
			{
				babyArrow.x -= 275;
				breakAnim.x -= 275;
			}				
			
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (snow != null)
				snow.changePlaying(false);
			if (snowfall != null)
				snowfall.changePlaying(false);
			
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ curSong.replace('-', ' ')
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (snow != null)
				snow.changePlaying(true);
			if (snowfall != null)
				snowfall.changePlaying(true);

			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ curSong.replace('-', ' ')
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition);
			}
			else
				DiscordClient.changePresence(detailsText, curSong.replace('-', ' ') + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ curSong.replace('-', ' ')
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var updateFrame = 0;

	override public function update(elapsed:Float)
	{
		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
					
					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}
			updateFrame++;
		}
		else if (updateFrame < 5)
			updateFrame++;


		var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

		if (timingSeg != null)
		{
			var timingSegBpm = timingSeg.bpm;

			if (timingSegBpm != Conductor.bpm)
				Conductor.changeBPM(timingSegBpm, false);
		}

		var newScroll = PlayStateChangeables.scrollSpeed;

		if (SONG.eventObjects != null)
		{
			for(i in SONG.eventObjects)
			{
				switch(i.type)
				{
					case "Scroll Speed Change":
						if (i.position < curDecimalBeat)
							newScroll = i.value;
				}
			}
		}	

		PlayStateChangeables.scrollSpeed = newScroll;
	
		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		scoreTxt.screenCenter(X);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else if ((controls.PAUSE || controls.ACCEPT) && endingSong && endScreen)
		{
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			paused = true;
			camHUD.visible = true;

			FlxG.sound.music.stop();
			vocals.stop();
			if (endMusic.playing)
			{
				endMusic.fadeOut(1, 0, function(flx:FlxTween){ endMusic.stop(); });
				endMusic.onComplete = null;
			}
			else
				endLoop.fadeOut(1, 0, function(flx:FlxTween){ endLoop.stop(); });
			PlayState.deaths = 0;

			// Has no use yet
			//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

			if (SONG.validScore)
				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

			//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;

			// More hard coding I'm sorry
			if (!FreeplayState.unlockedSongs[3] && !PlayStateChangeables.botPlay)
			{
				FreeplayState.unlockedSongs[3] = true;
				FlxG.save.data.unlockedSongs = FreeplayState.unlockedSongs;
				StoryMenuState.unlockedFrostbite = true;
				FlxG.save.flush();
			}

			if (FlxG.save.data.scoreScreen)
			{
				endScreen = false; // Prevents infinite loop and crash
				// Work around for not exiting score screen immediately
				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					openSubState(new ResultsScreen());
				});
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					inResults = true;
				});
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.switchState(new StoryMenuState());
			}

			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end	
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end

			if (snowfall != null)
			{
				snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
				snowfall.stop();
				remove(snowfallSpr);
			}

			if (snow != null)
			{
				snow.stop();
				remove(snowSpr);
			}	

			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else if (!endingSong)
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFollow.x != dad.getMidpoint().x + 500 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (FlxG.save.data.camzoom && curSong == 'Frostbite' && curBeat >= 448 && curBeat < 508)
					camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 250 + offsetY);
				else
					camFollow.setPosition(dad.getMidpoint().x + 500 + offsetX, dad.getMidpoint().y - 250 + offsetY);
				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 450)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (FlxG.save.data.camzoom && curSong == 'Frostbite' && curBeat >= 448 && curBeat < 508)
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				else
					camFollow.setPosition(boyfriend.getMidpoint().x - 450 + offsetX, boyfriend.getMidpoint().y - 250 + offsetY + (boyfriend.curCharacter == 'bf-retro' ? -15 : 0));

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
			}
		}

		if (FlxG.save.data.camzoom && camZooming && !endingSong)
		{
			if (curSong == 'Frostbite' && curBeat >= 448 && curBeat < 508)
				FlxG.camera.zoom = FlxMath.lerp(1.5, FlxG.camera.zoom, 0.95);
			else
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		if (health <= 0 && !cannotDie)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			camHUD.zoom = 1;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ curSong.replace('-', ' ')
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}
		else if (!inCutscene && FlxG.save.data.resetButton && FlxG.keys.justPressed.R)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			camHUD.zoom = 1;

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- "
				+ curSong.replace('-', ' ')
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];

				// Adjust height of sustain notes
				if (scrollSpeedMultiplier != 1 && dunceNote.isSustainNote && dunceNote.prevNote != null && dunceNote.prevNote.animation.name.endsWith('hold'))
				{
					// Reset size
					dunceNote.prevNote.setGraphicSize(Std.int(50 * 0.7)); // 50 is hard-coded to be the width of the notes
					dunceNote.prevNote.updateHitbox();

					// Calculate new height
					var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));
					dunceNote.prevNote.scale.y *= (stepHeight + 1) / dunceNote.prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
					dunceNote.prevNote.updateHitbox();
					dunceNote.prevNote.noteYOff = Math.round(-dunceNote.prevNote.offset.y);

					dunceNote.noteYOff = Math.round(dunceNote.offset.y * (PlayStateChangeables.useDownscroll ? 1 : -1));
				}
				// Adjust height of sustain notes
				else if (curSong == 'Frostbite' && dunceNote.isSustainNote && dunceNote.prevNote != null && dunceNote.prevNote.animation.name.endsWith('hold') && dunceNote.spawnStep >= 1760 && dunceNote.spawnStep < 2005)
				{
					// Reset size
					dunceNote.prevNote.setGraphicSize(Std.int(50 * 0.7)); // 50 is hard-coded to be the width of the notes
					dunceNote.prevNote.updateHitbox();

					// Calculate new height
					var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));
					dunceNote.prevNote.scale.y *= (stepHeight + 1) / dunceNote.prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
					dunceNote.prevNote.updateHitbox();
					dunceNote.prevNote.noteYOff = Math.round(-dunceNote.prevNote.offset.y);

					dunceNote.noteYOff = Math.round(dunceNote.offset.y * (PlayStateChangeables.useDownscroll ? 1 : -1));
				}
				
				dunceNote.spawnStep = curStep;

				notes.add(dunceNote);

				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (curSong == 'Frostbite' && daNote.spawnStep >= 1760 && daNote.spawnStep < 2005)
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * 0.5) - daNote.noteYOff;
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * 0.5) - daNote.noteYOff;
						}
						else
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * scrollSpeedMultiplier) - daNote.noteYOff;
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * scrollSpeedMultiplier) - daNote.noteYOff;
						}
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (curSong == 'Frostbite' && daNote.spawnStep >= 1760 && daNote.spawnStep < 2005)
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * 0.5) + daNote.noteYOff;
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * 0.5) + daNote.noteYOff;
						}
						else
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * scrollSpeedMultiplier) + daNote.noteYOff;
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2) * scrollSpeedMultiplier) + daNote.noteYOff;
						}

						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}
					
					// Accessing the animation name directly to play it
					if (!daNote.isSustainNote || (daNote.isSustainNote && dad.animation.name == 'idle'))
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
					}

					if (FlxG.save.data.cpuStrums)
					{
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (daNote.noteData == spr.ID)
								spr.animation.play('confirm', true);
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					#if windows
					if (luaModchart != null)
						luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
					#end

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive)
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (PlayState.curStage.startsWith('school'))
						daNote.x -= 11;
				}

				if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else if (!daNote.isFreezeNote)
					{
						if (loadRep && daNote.isSustainNote)
						{
							// im tired and lazy this sucks I know i'm dumb
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								if (!daNote.isSustainNote)
								{
									health -= 0.10;
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.sustainActive)
									vocals.volume = 0;
								if (daNote.isParent)
								{
									health -= 0.20; // give a health punishment for failing a LN
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										health -= 0.20; // give a health punishment for failing a LN
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
								}
							}
						}
						else
						{
							if (!daNote.isSustainNote)
							{
								health -= 0.10;
								noteMiss(daNote.noteData, daNote);
							}								
							if (daNote.sustainActive)
								vocals.volume = 0;
							if (daNote.isParent)
							{
								health -= 0.20; // give a health punishment for failing a LN
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									health -= 0.20; // give a health punishment for failing a LN
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
										misses++;
									updateAccuracy();
								}
							}
						}
					}

					missTime = 0; // Reset time since last miss
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		// Special case for optimized mode
		if (vocals.volume == 0 && PlayStateChangeables.Optimize)
		{
			missTime += elapsed;
			if (missTime > 1)
				vocals.volume = 1;
		}
		
		// Case for tracking time for freeze
		if (frozen.contains(true))
		{
			frozenTime += elapsed;
			if (frozenTime > (Conductor.stepCrochet / 1000) * 12)
			{
				for (i in 0...4)
				{
					frozen[i] = false;
					playerStrums.members[i].animation.play('static');
				}

				frozenTime = 0;
			}
		}
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (isStoryMode)
			campaignMisses = misses;

		endingSong = true;

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		camHUD.zoom = 1;

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
		}

		if (isStoryMode)
		{
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				if (storyChar == 0)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/endDialogue'));
				else if (storyChar == 1)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/endDialogueAce'));
				else if (storyChar == 2)
					dialogue = CoolUtil.coolTextFile(Paths.txt('data/endDialogueRetro'));
				var doof:DialogueBox = new DialogueBox(dialogue);
				doof.cameras = [camHUD];
				schoolIntro(doof);

				if (boyfriend.curCharacter == 'bf-cold')
				{
					var fade:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
					fade.alpha = 0;
					fade.cameras = [camHUD];
					endImage = new FlxSprite(0, 0).loadGraphic(Paths.image('End', 'week-ace'));
					endImage.alpha = 0;
					endImage.cameras = [camHUD];

					paused = true;
					camHUD.visible = true;

					FlxG.sound.music.stop();
					vocals.stop();
					PlayState.deaths = 0;

					doof.finishThing = function()
					{
						add(fade);
						FlxTween.tween(fade, {alpha: 1}, 1, {onComplete: function(flx:FlxTween)
						{
							// Stop the player from continuing to play becuase it crashes the game
							if (snow != null)
								snow.stop();

							if (snowfall != null)
							{
								snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
								snowfall.stop();
							}

							add(endImage);
							endMusic.play(true);
							endMusic.onComplete = function()
							{
								endMusic.onComplete = null;
								endLoop.play(true);
							}
							FlxTween.tween(endImage, {alpha: 1}, 1, {onComplete: function(flx:FlxTween)
							{
								endScreen = true;
							}});
						}});
					}
				}
				else
				{
					doof.finishThing = function()
					{
						transIn = FlxTransitionableState.defaultTransIn;
						transOut = FlxTransitionableState.defaultTransOut;

						paused = true;
						camHUD.visible = true;

						FlxG.sound.music.stop();
						vocals.stop();

						// Stop the player from continuing to play becuase it crashes the game
						if (snow != null)
							snow.stop();

						if (snowfall != null)
						{
							snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
							snowfall.stop();
						}

						//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

						if (SONG.validScore)
							Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

						//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;

						// More hard coding I'm sorry
						if (!FreeplayState.unlockedSongs[3] && !PlayStateChangeables.botPlay)
						{
							FreeplayState.unlockedSongs[3] = true;
							FlxG.save.data.unlockedSongs = FreeplayState.unlockedSongs;
							StoryMenuState.unlockedFrostbite = true;
							FlxG.save.flush();
						}

						if (FlxG.save.data.scoreScreen)
						{
							openSubState(new ResultsScreen());
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									inResults = true;
								});
						}
						else
						{
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							FlxG.switchState(new StoryMenuState());
						}

						#if windows
						if (luaModchart != null)
						{
							luaModchart.die();
							luaModchart = null;
						}
						#end
					}
				}

				// I broke your shit
				//StoryMenuState.unlockNextWeek(storyWeek);
			}
			else
			{
				// Stop the player from continuing to play becuase it crashes the game
				if (snow != null)
					snow.stop();

				if (snowfall != null)
				{
					snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
					snowfall.stop();
				}

				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

				var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			paused = true;
			camHUD.visible = true;

			FlxG.sound.music.stop();
			vocals.stop();
			PlayState.deaths = 0;

			// Stop the player from continuing to play becuase it crashes the game
			if (snow != null)
				snow.stop();

			if (snowfall != null)
			{
				snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
				snowfall.stop();
			}

			if (FlxG.save.data.scoreScreen) 
			{
				openSubState(new ResultsScreen());
				new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
			}
			else
				FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var endScreen:Bool = false;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		vocals.volume = 1;

		var coolText:FlxText = new FlxText(0, 0, 0, Std.string(combo), 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.06;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.03;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			rating.loadGraphic(Paths.image(daRating));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			rating.setGraphicSize(Std.int(rating.width * 0.7));
			if(FlxG.save.data.antialiasing)
				rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			if(FlxG.save.data.antialiasing)
				comboSpr.antialiasing = true;

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
				seperatedScore.push(Std.parseInt(comboSplit[i]));

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if(FlxG.save.data.antialiasing)
					numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		#if windows
		if (luaModchart != null)
		{
			if (controls.LEFT_P)
				luaModchart.executeState('keyPressed', ["left"]);
			if (controls.DOWN_P)
				luaModchart.executeState('keyPressed', ["down"]);
			if (controls.UP_P)
				luaModchart.executeState('keyPressed', ["up"]);
			if (controls.RIGHT_P)
				luaModchart.executeState('keyPressed', ["right"]);
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (!frozen[daNote.noteData] && daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
					goodNoteHit(daNote);
			});
		}

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);	

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length) // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData] && !frozen[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.playAnim('idle');
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
					{
						if (pressArray[shit])
							noteMiss(shit, null);
					}
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress && !daNote.isFreezeNote || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress && !daNote.isFreezeNote)
				{
					if (loadRep)
					{
						if (findByTime(daNote.strumTime) != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay || frozen.contains(true)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (!frozen[spr.ID])
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm' && !frozen[spr.ID])
					spr.animation.play('pressed');
				if (!holdArray[spr.ID] && spr.animation.finished)
					spr.animation.play('static');
			}
			else if (spr.animation.curAnim.name != 'frozen')
				spr.animation.play('frozen');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
			if (Math.abs(i[0] - time) < 0.0000000001) // Fucking bullshit floating point precision
				return i;
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
			if (Math.abs(rep.replay.songNotes[i][0] - time) < 0.0000000001)
				return i;
		return -1;
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;
			
			if(FlxG.save.data.missSounds)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			// Hole switch statement replaced with a single line :)
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', daNote != null ? !daNote.isSustainNote : true);

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (controlArray[note.noteData])
			goodNoteHit(note, (mashing > getKeyPresses(note)));
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isFreezeNote)
			{
				if (!note.isSustainNote)
				{
					popUpScore(note);
					combo += 1;
				}
				else
					totalNotesHit += 1;	
			}

			// Prevent animation playing while frozen
			if (!frozen[note.noteData] && (!note.isSustainNote || (note.isSustainNote && boyfriend.animation.name == 'idle')))
			{
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
			}
			

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end
				
			if(!loadRep && note.mustPress)
			{
				var array = [note.strumTime,note.sustainLength,note.noteData,noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}
			
			playerStrums.forEach(function(spr:FlxSprite)
			{
				// Ace Note Freeze Mechanic
				// Freeze the note for a specified time
				// Change arrow graphic state when freezing over
				if (note.noteData == spr.ID && note.isFreezeNote)
				{
					breakAnims.members[spr.ID].y = note.y;
					breakAnims.members[spr.ID].animation.play('break', true);
					breakAnims.members[spr.ID].visible = true;

					for (i in 0...4)
					{
						frozen[i] = true;
						playerStrums.members[i].animation.play('frozen');
						FlxG.sound.play(Paths.sound('icey'));
					}
				}
				else if (Math.abs(note.noteData) == spr.ID && !note.isFreezeNote)
					spr.animation.play('confirm', true);
			});

			note.kill();
			notes.remove(note, true);
			note.destroy();
			
			updateAccuracy();
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// Sub-zero special effects
		if (curSong == 'Sub-Zero')
		{
			if (slowDown && curStep >= 254)
			{
				slowDown = false;				
				scrollSpeedMultiplier = 1;

				// Adjust height of active sustain notes
				notes.forEachAlive(function(note:Note)
				{
					if (note.isSustainNote && note.prevNote != null && note.prevNote.animation.name.contains('hold'))
					{
						// Reset size
						var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));
						note.prevNote.setGraphicSize(Std.int(50 * 0.7)); // 50 is hard-coded to be the width of the notes
						note.prevNote.updateHitbox();

						// Calculate new height
						note.prevNote.scale.y *= (stepHeight + 1) / note.prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
						note.prevNote.updateHitbox();
					}
				});

				if (!PlayStateChangeables.Optimize)
				{
					if (FlxG.save.data.snow)
					{
						snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
						snowfall.stop();
						snowfallVid = new WebmIoFile(Paths.video('snowfall3', 'preload'));
						snowfall = new WebmPlayer();
						snowfall.fuck(snowfallVid, false);
						snowfallSpr.loadGraphic(snowfall.bitmapData);
						snowfall.play();
					}

					FlxTween.tween(bgDarken, {alpha: 0.5}, 0.01);
					FlxTween.tween(snowDarken, {alpha: 0.5}, 0.01);

					if (FlxG.save.data.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
				}
			}
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ curSong.replace('-', ' ')
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		if (!PlayStateChangeables.Optimize)
		{
			frontChars.animation.play('bop', true);
			backChars.animation.play('bop', true);

			if (curSong == 'Noreaster')
			{
				if (snow != null && curBeat >= 300 && curBeat % 100 == 0)
				{
					snow.stop();
					snow = new WebmPlayer();
					snow.fuck(snowVid, false);
					snowSpr.loadGraphic(snow.bitmapData);
					snow.play();
				}
			}
			else if (curSong == 'Sub-Zero')
			{
				if (curStep >= 254 && curBeat % 40 == 0)
				{
					if (snow != null)
					{
						snow.stop();
						snow = new WebmPlayer();
						snow.fuck(snowVid, false);
						snowSpr.loadGraphic(snow.bitmapData);
						snow.play();
					}

					if (snowfall != null)
					{
						snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
						snowfall.addEventListener(WebmEvent.STOP, loopSnowfall);
					}					
				}
			}
			else if (curSong == 'Frostbite')
			{
				// Background effects
				if (FlxG.save.data.flashing && curBeat >= 64 && curBeat < 448)
				{
					if (bgDarken.alpha == 0.75)
						FlxTween.tween(bgDarken, {alpha: 0.5}, 0.1);
					else if (bgDarken.alpha == 0.5)
						FlxTween.tween(bgDarken, {alpha: 0.75}, 0.1);

					if (snowDarken.alpha == 0.75)
						FlxTween.tween(snowDarken, {alpha: 0.5}, 0.1);
					else if (snowDarken.alpha == 0.5)
						FlxTween.tween(snowDarken, {alpha: 0.75}, 0.1);
				}
				else if (curBeat >= 448 && curBeat < 512 && bgDarken.alpha != 0.9)
				{
					if (FlxG.save.data.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
					FlxTween.tween(bgDarken, {alpha: 0.9}, 0.01);
					FlxTween.tween(snowDarken, {alpha: 0.9}, 0.01);
				}
				else if (FlxG.save.data.flashing && curBeat >= 512 && curBeat < 576)
				{
					if (bgDarken.alpha == 0.9)
						FlxTween.tween(bgDarken, {alpha: 0.5}, 0.01);
					else if (bgDarken.alpha == 0.25)
						FlxTween.tween(bgDarken, {alpha: 0.5}, 0.1);
					else if (bgDarken.alpha == 0.5)
						FlxTween.tween(bgDarken, {alpha: 0.25}, 0.1);

					if (snowDarken.alpha == 0.9)
						FlxTween.tween(snowDarken, {alpha: 0.5}, 0.01);
					else if (snowDarken.alpha == 0.25)
						FlxTween.tween(snowDarken, {alpha: 0.5}, 0.1);
					else if (snowDarken.alpha == 0.5)
						FlxTween.tween(snowDarken, {alpha: 0.25}, 0.1);
				}
				else if (curBeat >= 576)
				{
					if (bgDarken.alpha != 0)
						FlxTween.tween(bgDarken, {alpha: 0}, 0.1);

					if (snowDarken.alpha != 0)
						FlxTween.tween(snowDarken, {alpha: 0}, 0.1);
				}

				// Snow effect
				if (FlxG.save.data.snow && !PlayStateChangeables.Optimize && curBeat >= 576 && snowfallSpr.alpha == 1)
					FlxTween.tween(snowfallSpr, {alpha: 0}, 1, {onComplete: function(flx:FlxTween)
					{
						snowfall.removeEventListener(WebmEvent.STOP, loopSnowfall);
						snowfall.stop();
					}});
	
				// Camera effects
				if (FlxG.save.data.camzoom)
				{
					if (curBeat >= 380 && curBeat < 384)
					{
						FlxG.camera.zoom += 0.05;
						camHUD.zoom += 0.1;
					}
					else if (curBeat >= 448 && curBeat < 508 && FlxG.camera.zoom != 1.5)
						FlxG.camera.zoom = 1.5;
					else if (curBeat >= 508 && curBeat < 512)
					{
						var offsetX = 0;
						var offsetY = 0;
						#if windows
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
						if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
							camFollow.setPosition(boyfriend.getMidpoint().x - 450 + offsetX, boyfriend.getMidpoint().y - 250 + offsetY);
						else
							camFollow.setPosition(dad.getMidpoint().x + 500 + offsetX, dad.getMidpoint().y - 250 + offsetY);

						FlxG.camera.zoom += 0.05;
						camHUD.zoom += 0.1;
					}
				}
			}	
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// Dad doesnt interupt his own notes
			if ((SONG.notes[Math.floor(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")))
			{
				if (curBeat % idleBeat == 0)
					dad.dance(idleToBeat);
			}
		}

		if (FlxG.save.data.camzoom && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % idleBeat == 0)
			boyfriend.playAnim('idle', idleToBeat);
	}

	function recurseSnow()
	{
		if (curBeat < 576)
		{
			snow = new WebmPlayer();
			snow.fuck(snowVid, false);
			snowSpr.loadGraphic(snow.bitmapData);
			snow.play();
			snow.addEventListener(WebmEvent.STOP, function(e) {
				recurseSnow();
			});
		}
	}

	/*
	* Used for looping the snowfall video.
	*/
	function loopSnowfall(str:String)
	{
		snowfall = new WebmPlayer();
		snowfall.fuck(snowfallVid, false);
		snowfallSpr.loadGraphic(snowfall.bitmapData);
		snowfall.play();
	}
}
