package menus;

import important.Song;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxMultiGamepadAnalogStick.XY;
import flixel.addons.ui.FlxUIInputText;
import misc.CustomFadeTransition;
import flixel.FlxCamera;
#if desktop
import important.Discord.DiscordClient;
#end
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;

class DesktopMenu extends MusicBeatState
{
	var icons:Map<String, Dynamic> = [
		"discord" => "https://discord.gg/ron-874366610918473748",
		"random" => "https://facebook.com",
		"settings" => new options.OptionsState(),
		"freeplay" => new MasterFreeplayState(),
		"story mode" => "story mode is idiot",
		"credits" => new CreditMenu()
	];
	var camWhat:FlxCamera;
	var camText:FlxCamera;
	public static var leftState:Bool = false;
	public static var curClicked:String = "";
	var clickAmounts:Int = 0;
	var debugKeys:Array<FlxKey>;
	var buttons:Array<FlxButton> = [];
	var clicked:Bool = false;
	var time:Float = 0;
	var chromeOffset = (ClientPrefs.rgbintense/350);
	var transitioningToIdiotism:Bool = false;
	var window:FlxSprite;
	var ywindow:Float = FlxG.height/2-203;
	var tweening:Bool = false;
	override function create() {

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		important.WeekData.loadTheFirstEnabledMod();
		FlxG.mouse.visible = true;

		persistentUpdate = persistentDraw = true;
		var iconI:Int = 0;
		var iconFrames = Paths.getSparrowAtlas("menuIcons");
		var rainbowscreen = new FlxBackdrop(Paths.image('rainbowpcBg'), XY, 0, 0);
		var rainbTmr = new FlxTimer().start(0.005, function(tmr:FlxTimer)
		{
			rainbowscreen.x += (Math.sin(time)/5)+2;
			rainbowscreen.y += (Math.cos(time)/5)+1;
			tmr.reset(0.005);
		});
		add(rainbowscreen);
		add(new FlxSprite().loadGraphic(Paths.image("pcBg")));
		
		window = new FlxSprite(FlxG.width/1.3-405,ywindow);
		window.frames = Paths.getSparrowAtlas('menuCarNew');
		window.animation.addByPrefix('window', 'window', 24, true);
		window.animation.play('window');
		window.angle = 3;
		FlxTween.tween(window, {y: ywindow + 10, angle: -3}, 1, {ease: FlxEase.circInOut, type: PINGPONG});
		window.scale.set(1.5,1.5);
		add(window);
					
		for (i in icons.keys()) {
			var button:FlxButton;
			button = new FlxButton((iconI > 2 ? 180 : 20), 20 + (150 * (iconI > 2 ? iconI - 3:iconI)), "", function() {
				if (curClicked != i) {
					clickAmounts = 0;
					curClicked = i;
					for (i in buttons)
						i.color = 0xffffff;
 				}
				if (curClicked == i) {
					clickAmounts++;
					button.color = 0xFF485EC2;
					if (clickAmounts == 2) {
						if (icons[i] == "story mode is idiot") {
							StoryMenuState.musicTime = FlxG.sound.music.time;
							new StoryMenuState();
							transitioningToIdiotism = true;
							rainbTmr.cancel();
							new FlxTimer().start(1.5, function(tmr:FlxTimer){
								FlxG.camera.fade(0x88FFFFFF, 0.6, false);
								new FlxTimer().start(2, function(tmr:FlxTimer){ FlxG.switchState(new StoryMenuState()); FlxG.camera.fade(0x88FFFFFF, 0, true);});
							});
						}
						else if (icons[i].length != 0)
							CoolUtil.browserLoad(icons[i]);
						else
							MusicBeatState.switchState(icons[i]);
					}
						
				}
				clicked = true;
			});
			button.frames = iconFrames;
			button.animation.addByPrefix("normal", i);
			button.animation.addByPrefix("highlight", i);
			button.animation.addByPrefix("pressed", i);
			add(button);
			buttons.push(button);
			iconI++;
		}

		var input = new FlxUIInputText(0, FlxG.height - 38);
		input.screenCenter(X);
        add(input);

        var daButton = new FlxUIButton(0, FlxG.height - 18, 'Run', function hi() {
            teleport(input.text);
        });
		daButton.screenCenter(X);
        add(daButton);

		camText = new FlxCamera();
		camText.bgColor = 0;
		camWhat = new FlxCamera();
		FlxG.cameras.reset(camWhat);
		FlxG.cameras.add(camText);
		addShader(camWhat, "chromatic aberration");
		addShader(camWhat, "fake CRT");
		addShader(camWhat, "8bitcolor");
		Shaders["8bitcolor"].shader.data.enablethisbitch.value = [1.];
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset/2];
		Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
		FlxCamera.defaultCameras = [camWhat];
		CustomFadeTransition.nextCamera = camText;
		super.create();
	}
	override function closeSubState() {
		super.closeSubState();
	}
	override function update(elapsed:Float) {
		if (transitioningToIdiotism)
			return;
		time += elapsed;
		/*if ((FlxG.mouse.justPressed) && (FlxG.mouse.overlaps(window)))
		{
			tweening = false;
			FlxTween.cancelTweensOf(window);
			window.x = FlxG.mouse.x-window.width/2;
			window.y = FlxG.mouse.y-window.width/2;
			ywindow = window.y;
		}
		else
		{
			if (tweening == false)
			{
				tweening = true;
				FlxTween.tween(window, {y: ywindow + 10, angle: -10}, 1, {ease: FlxEase.circInOut, type: PINGPONG});
			}
		}*/
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset*Math.sin(time)];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [-chromeOffset*Math.sin(time)];
		#if desktop
		if (FlxG.keys.anyJustPressed(debugKeys))
		{
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		}
		#end
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}
		super.update(elapsed);
	}

	function teleport(a:String)
	{
		switch(a)
		{
			case 'ron-undertale':
			    PlayState.SONG = Song.loadFromJson('haemorrhage-hard', 'haemorrhage');
			    PlayState.isStoryMode = false;
			    PlayState.storyDifficulty = 2;
			    MusicBeatState.switchState(new PlayState());
			default:
				FlxG.sound.play(Paths.sound('vine'));
		}
	}
}
