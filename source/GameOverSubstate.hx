package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var allowInputs:Bool = true;
	var allowRetry:Bool = true;
	var disableIce:Bool = true;

	public function new(x:Float, y:Float)
	{
		var daBf:String = '';
		switch (PlayState.boyfriend.curCharacter)
		{
			case 'bf-ace':
				daBf = 'bf-ace';
			case 'bf-retro':
				daBf = 'bf-retro';
			default:
				daBf = 'bf-cold';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		// Count the deaths on songs with ice notes
		if (FlxG.save.data.specialMechanics && PlayState.SONG.song != 'Concrete-Jungle' && !FlxG.save.data.botplay && !PlayState.loadRep)
			PlayState.deaths++;

		if (PlayState.deaths >= 2 && !PlayState.shownHint)
		{
			allowInputs = false;
			allowRetry = false;
		}
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (allowInputs && controls.ACCEPT)
		{
			if (allowRetry)
				endBullshit();
			else
			{
				allowInputs = false;
				FlxG.save.data.specialMechanics = !disableIce;
				FlxG.save.flush();
				remove(PlayState.selectSpr);
				remove(PlayState.yesText);
				remove(PlayState.noText);
				PlayState.acePortrait.animation.play('Neutral');
				if (disableIce)
					PlayState.hintText.resetText("Alright. I'll make sure they won't happen again.");
				else
					PlayState.hintText.resetText("Alright. If you ever change your mind, you can disable them in the gameplay settings menu.");
				PlayState.hintText.start(0.04, true, false, null, function()
				{
					allowInputs = true;
					allowRetry = true;
				});
			}
		}

		if (allowInputs && controls.BACK)
		{
			PlayState.deaths = 0;
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (!allowRetry && controls.LEFT_P && PlayState.selectSpr.x == 1040)
		{
			disableIce = true;
			PlayState.selectSpr.x = 840;
		}
		else if (!allowRetry && controls.RIGHT_P && PlayState.selectSpr.x == 840)
		{
			disableIce = false;
			PlayState.selectSpr.x = 1040;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver'));
			if (PlayState.deaths >= 2 && !PlayState.shownHint)
			{
				PlayState.shownHint = true;
				add(PlayState.acePortrait);
				add(PlayState.speechBubble);
				add(PlayState.hintDropText);
				add(PlayState.hintText);

				PlayState.acePortrait.animation.play('Embarassed');
				FlxTween.tween(PlayState.acePortrait, {alpha: 1}, 0.1);
				PlayState.speechBubble.animation.play('normalOpen');
				PlayState.speechBubble.animation.finishCallback = function(anim:String):Void
				{
					PlayState.speechBubble.animation.play('normal');
					PlayState.hintText.resetText("Sorry about the ice notes. Do you want me to disable them?");
					PlayState.hintText.start(0.04, true, false, null, function()
					{
						add(PlayState.selectSpr);
						add(PlayState.yesText);
						add(PlayState.noText);
						allowInputs = true;
					});
				}
			}
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		if (PlayState.hintDropText.text != PlayState.hintText.text)
			PlayState.hintDropText.text = PlayState.hintText.text;
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
			bf.playAnim('deathLoop', true);
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
