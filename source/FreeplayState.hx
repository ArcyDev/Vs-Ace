package;
import flixel.input.actions.FlxAction.FlxActionAnalog;
import openfl.media.Sound;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var unlockedSongs:Array<Bool> = [true, true, true, false];

	public static var songs:Array<SongMetadata> = [];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var curCharacter:Int = 0;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var charText:FlxText;
	var charIcon:FlxSprite;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var iceBlock:FlxSprite;
	private var iceBlockTargetY:Float;

	private var iconArray:Array<HealthIcon> = [];

	// Kade Engine doesn't accurately measure ratings for these songs
	private var difficultyRatings:Array<Dynamic> = [
		['2.94', '4.60', '6.46', '6.44'],
		['3.12', '4.88', '6.50', '6.53'],
		['3.79', '5.11', '6.79', '7.10'],
		['4.96', '6.66', '7.45', '7.37']
	];

	public static var songData:Map<String,Array<SwagSong>> = [];

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try 
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		}
		catch(ex)
		{
			// do nada
		}
	}

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
			songs.push(meta);
			var format = StringTools.replace(meta.songName, " ", "-");

			var diffs = [];
			FreeplayState.loadDiff(0,format,meta.songName,diffs);
			FreeplayState.loadDiff(1,format,meta.songName,diffs);
			FreeplayState.loadDiff(2,format,meta.songName,diffs);
			FreeplayState.loadDiff(3,format,meta.songName,diffs);
			FreeplayState.songData.set(meta.songName,diffs);
		}

		#if sys
		for(i in FileSystem.readDirectory("assets/sm/"))
		{
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file,"assets/sm/" + i + "/" + file.replace(" ","_"));
					if (file.endsWith(".sm"))
					{
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ","_"));
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new SongMetadata(file.header.TITLE, 0, "sm",file,"assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song,song,song]);
					}
				}
			}
		}
		#end

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		if(FlxG.save.data.antialiasing)
			bg.antialiasing = true;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			// Use a custom asset for Frostbite
			if (songs[i].songName == 'Frostbite' && !unlockedSongs[i])
				continue;

			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}

		// Hard coding lmao
		if (!unlockedSongs[3])
		{
			iceBlock = new FlxSprite(0, 70 * 3 + 30).loadGraphic(Paths.image('frostbite'));
			add(iceBlock);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 150, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		comboText = new FlxText(diffText.x + 115, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		charText = new FlxText(comboText.x - 50, comboText.y + 65, 0, "Tab to switch", 24);
		charText.font = comboText.font;
		add(charText);

		charIcon = new HealthIcon('bf-cold', true);
		switch (curCharacter)
		{
			case 0:
				charIcon.animation.play('bf-cold');
			case 1:
				charIcon.animation.play('bf-ace');
			case 2:
				charIcon.animation.play('bf-retro');
		}
		charIcon.setPosition(charText.x - 110, comboText.y + 10);
		charIcon.scale.set(0.5, 0.5);
		add(charIcon);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (iceBlock != null)
		{
			var scaledY = FlxMath.remapToRange(iceBlockTargetY, 0, 1, 0, 1.3);

			iceBlock.y = FlxMath.lerp(iceBlock.y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			iceBlock.x = FlxMath.lerp(iceBlock.x, (iceBlockTargetY * 20) + 90, 0.30);
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (controls.UP_P)
			changeSelection(-1);
		else if (controls.DOWN_P)
			changeSelection(1);

		if (controls.LEFT_P)
			changeDiff(-1);
		else if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.switchState(new MainMenuState());
		}

		else if (FlxG.keys.justPressed.TAB)
			changeChar();

		else if (controls.ACCEPT && unlockedSongs[curSelected])
		{
			var hmm;
			try
			{
				hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				if (hmm == null)
					return;
			}
			catch(ex)
			{
				return;
			}


			PlayState.SONG = hmm;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyChar = curCharacter;
			PlayState.storyWeek = songs[curSelected].week;
			#if sys
			if (songs[curSelected].songCharacter == "sm")
			{
				PlayState.isSM = true;
				PlayState.sm = songs[curSelected].sm;
				PlayState.pathToSm = songs[curSelected].path;
			}
			else
				PlayState.isSM = false;
			#else
			PlayState.isSM = false;
			#end
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;


		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][curDifficulty])}';
		diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
	}

	function changeChar()
	{
		curCharacter++;

		if (curCharacter > 2)
			curCharacter = 0;

		switch (curCharacter)
		{
			case 0:
				charIcon.animation.play('bf-cold');
			case 1:
				charIcon.animation.play('bf-ace');
			case 2:
				charIcon.animation.play('bf-retro');
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);

		diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][curDifficulty])}';
		
		#if PRELOAD_ALL
		if (songs[curSelected].songCharacter == "sm")
		{
			var data = songs[curSelected];
			var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
		}
		else if (unlockedSongs[curSelected])
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		else
			FlxG.sound.music.stop();
		#end

		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm != null)
				Conductor.changeBPM(hmm.bpm);
		}
		catch(ex)
		{}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			if (unlockedSongs[i])
				iconArray[i].alpha = 0.6;
		}

		if (unlockedSongs[curSelected])
			iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

		if (iceBlock != null)
			iceBlockTargetY = bullShit - curSelected;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	#if sys
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
