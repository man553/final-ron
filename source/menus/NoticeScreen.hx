package menus;
#if desktop
import important.Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.system.ui.FlxSoundTray;
import lime.app.Application;
import openfl.Assets;

class NoticeScreen extends MusicBeatState
{
	var mmtw:FlxSound = new FlxSound();
	var screen:FlxSprite;
	var timer:Int;
	public function new() 
	{
		super();
	}
	
	override function create() 
	{
		super.create();
	
		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add(function(exitCode)
			{
				DiscordClient.shutdown();
			});
		}
		#end
		
		if (ClientPrefs.warnings)
		{
			var songName:String = ClientPrefs.pauseMusic;
			mmtw = new FlxSound();
			mmtw.volume = 0;
			mmtw.play(false, FlxG.random.int(0, Std.int(mmtw.length / 2))); // idk why it starts at a random point 
			addShader(FlxG.camera,"glitchsmh");
			addShader(FlxG.camera, "vhs");
			addShader(FlxG.camera, "fake CRT");
			Shaders["glitchsmh"].shader.data.on.value = [1.];
			var chromeOffset = (ClientPrefs.rgbintense/350);
			addShader(FlxG.camera, "chromatic aberration");

			var chromeOffset = (ClientPrefs.rgbintense/350);
			Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset/2];
			Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
			Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
			
			var blackScreen = new FlxSprite();
			blackScreen.frames = Paths.getSparrowAtlas('titleThing');
			blackScreen.animation.addByPrefix('idle', 'idle', 24, true);
			blackScreen.animation.play('idle');
			blackScreen.scale.set(2.25,2.25);
			blackScreen.updateHitbox();
			blackScreen.screenCenter();
			blackScreen.scrollFactor.set(0.1,0.1);
			blackScreen.alpha = 0.33;
			add(blackScreen);

			screen = new FlxSprite().loadGraphic(Paths.image("warning/lol1"));
			screen.screenCenter();
			screen.angle = -3;
			add(screen);
			
			FlxTween.tween(screen, {y: screen.y + 20}, 1, {ease: FlxEase.circInOut, type: PINGPONG});
			FlxTween.tween(screen, {angle: 3}, 2, {ease: FlxEase.backInOut, type: PINGPONG});
		}
		else
			MusicBeatState.switchState(new menus.TitleState());
	}
	
	override function update(elapsed:Float) 
	{	
		super.update(elapsed);
		timer += 1;
		if (mmtw.volume < .5) {
			mmtw.volume += elapsed * .01;
		}
		
		screen = new FlxSprite().loadGraphic(Paths.image("warning/lol1"));
		if (Math.floor(timer/30) % 2 == 0)
			screen = new FlxSprite().loadGraphic(Paths.image("warning/lol2"));
		
		if (FlxG.keys.justPressed.ENTER){
			mmtw.destroy();
			FlxG.sound.play(Paths.sound('resumeSong'));
			FlxTween.tween(FlxG.camera, {zoom: 0.5, angle: 45}, 0.75, {ease: FlxEase.quadIn});
			MusicBeatState.switchState(new menus.TitleState());
		}
	}
}