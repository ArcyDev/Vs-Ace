package;

import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		TimingStruct.clearTimings();
		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.create();
	}

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		var nextStep:Int = updateCurStep();

		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				curDecimalBeat = data.startBeat + (((Conductor.songPosition/1000) - data.startTime) * (data.bpm / 60));
			}
			else
			{
				curDecimalBeat = (Conductor.songPosition / 1000) * (Conductor.bpm/60);
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;

		if ((cast (Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
