package;

import important.Conductor.BPMChangeEvent;
import important.PlayerSettings;
import openfl.filters.ShaderFilter;
import flixel.FlxCamera;
import misc.DynamicShaderHandler;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;

class MusicBeatState extends FlxUIState
{

	public static var animatedShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();
	public static var allShaders:Array<DynamicShaderHandler> = [];
	public var luaShaders:Map<String, DynamicShaderHandler> = new Map<String, DynamicShaderHandler>();

	public var Shaders = animatedShaders;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		allShaders = [];
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		super.create();

		if(!skip) {
			openSubState(new misc.CustomFadeTransition(0.7, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}
	public function addShader(camera:FlxCamera, shader:String)
	{
		if (animatedShaders[shader] == null) new DynamicShaderHandler(shader);
		if (ClientPrefs.shaders)
			camera.filters.push(new ShaderFilter(animatedShaders[shader].shader));
		
	}
	public function clearShader(camera:FlxCamera)
	{
		camera.setFilters([]);
		allShaders = [];
	}
	
	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		misc.FlxVideo.onFocus();
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		misc.FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		if(ClientPrefs.shaders)
		{
			for (shader in animatedShaders)
			{
				shader.update(elapsed);
			}
			#if LUA_ALLOWED
			for (key => value in luaShaders)
			{
				value.update(elapsed);
			}
			#end
		}

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
		if(ClientPrefs.shaders) Shaders = animatedShaders;
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
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

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new misc.CustomFadeTransition(0.6, false));
			if(nextState == FlxG.state) {
				misc.CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				misc.CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
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

		
	public function setBlockSize(bs:Float):Void
		//ShadersHandler.setBlockSize(bs);
	return;
}
