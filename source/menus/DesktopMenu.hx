package menus;

import important.Song;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxGame;
import flixel.addons.ui.FlxMultiGamepadAnalogStick.XY;
import flixel.addons.ui.FlxUIInputText;
import misc.CustomFadeTransition;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
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

var rainbowscreen:FlxBackdrop;
var camWhat:FlxCamera;
class DesktopMenu extends MusicBeatState
{
	var icons:Map<String, Dynamic> = [
		"discord" => "https://discord.gg/ron-874366610918473748",
		"random" => "https://www.facebook.com",
		"settings" => new options.OptionsState(),
		"freeplay" => new MasterFreeplayState(),
		"story mode" => "story mode is idiot",
		"credits" => new CreditMenu()
	];
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

		persistentUpdate = persistentDraw = true;
		var iconI:Int = 0;
		var iconFrames = Paths.getSparrowAtlas("menuIcons");
		var sanstitre = new FlxBackdrop(Paths.image('sanstitre'), XY, 0, 0);
		rainbowscreen = new FlxBackdrop(Paths.image('rainbowpcBg'), XY, 0, 0);
		var rainbTmr = new FlxTimer().start(0.005, function(tmr:FlxTimer)
		{
			rainbowscreen.x += (Math.sin(time)/5)+2;
			rainbowscreen.y += (Math.cos(time)/5)+1;
			sanstitre.setPosition(rainbowscreen.x,rainbowscreen.y);
			tmr.reset(0.005);
		});
		add(sanstitre);
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
			button.allowSwiping = false;
			add(button);
			buttons.push(button);
			iconI++;
		}

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
			MusicBeatState.switchState(new editors.MasterEditorMenu());
		#end
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;
		super.update(elapsed);
		FlxG.mouse.visible = true;
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.R) add(new RunTab());
	}
}
class RunTab extends FlxGroup {
	var tab:FlxSprite;
	var ok:FlxButton;
	var cancel:FlxButton;
	var exit:FlxButton;
	var help:FlxButton;
	var field:FlxUIInputText;
	var tabBar:FlxButton;
	var t = Paths.getSparrowAtlas("run tab");
	public function new() {
		super();
		field = new FlxUIInputText(58, 643, 270, "", 18);
		field.font = Paths.font("w95.otf");
		field.callback = function(text, action) {
			if (action == "enter") {
				triggerRunEvent(field.text);
				field.text = "";
				field.caretIndex = 0;
			}
		}
		add(field);
		tab = new FlxSprite(0, 560);
		tab.frames = t;
		tab.animation.addByPrefix("d", "tab");
		tab.animation.play("d");
		add(tab); //270 text field length
		ok = new FlxButton(177, 685, "", function() {
			triggerRunEvent(field.text);
			field.text = "";
			field.caretIndex = 0;
		});
		cancel = new FlxButton(258, 685, "", function() {
			field.text = "";
			field.caretIndex = 0;
		});
		help = new FlxButton(308, 566, "", function() {
			CoolUtil.browserLoad("www.facebook.com");
		});
		exit = new FlxButton(327, 566, "", function() {
			destroy();
		});
		for (i=>button in [ok, cancel, help, exit]) {
			button.frames = t;
			var animIndex = ["ok", "cancel", "help", "exit"];
			button.animation.addByPrefix("normal", animIndex[i] + " neutral");
			button.animation.addByPrefix("highlight", animIndex[i] + " highlighted");
			button.animation.addByPrefix("pressed", animIndex[i] + " pressed");
			button.updateHitbox();
			add(button);
		}
		help.setSize(15,13);
		exit.setSize(15,13);
		tabBar = new FlxButton(0, 560, "");
		tabBar.width = 347;
		tabBar.height = 20;
		tabBar.alpha = 0;
		tabBar.allowSwiping = true;
		add(tabBar);
	}
	var justMousePos = new FlxPoint();
	var justTaskBarPos = new FlxPoint();
	var movingTab = false;
	override function update(elapsed) {
		super.update(elapsed);
		if (tabBar.status == 2) {
			if (FlxG.mouse.justPressed) {justMousePos = FlxG.mouse.getScreenPosition(); justTaskBarPos.set(tab.x, tab.y);movingTab = true;}
		}
		if (FlxG.mouse.justReleased) movingTab = false;
		if (movingTab) {
			tab.setPosition((FlxG.mouse.getScreenPosition().x - justMousePos.x) + justTaskBarPos.x, (FlxG.mouse.getScreenPosition().y - justMousePos.y) + justTaskBarPos.y);
			for (button in [ok, cancel, help, exit, tabBar, field]) {
				var offsetIndex:Map<Dynamic,Dynamic> =  [ok => [177, 125],cancel => [258, 125],help => [308, 6],exit => [327, 6],tabBar => [0, 0],field => [58, 84]];
				button.setPosition(tab.x + offsetIndex[button][0], tab.y + offsetIndex[button][1]);
			}
		}
	}
	function triggerRunEvent(runText:String) {
		switch (runText) {
			case "teevee": CoolUtil.browserLoad("https://youtu.be/X9hIJDzo9m0");
			case "ron": #if windows Sys.command("start RON.exe"); #end
			case "peak" | "ron undertale" | "for old times sake":
				var songIndex = ["peak" => "awesome-ron", "ron undertale" => "haemorrhage", "for old times sake" => "oneirophobia"];
				PlayState.SONG = Song.loadFromJson('${songIndex[runText]}-hard', songIndex[runText]);
			    PlayState.isStoryMode = false;
			    PlayState.storyDifficulty = 2;
			    MusicBeatState.switchState(new PlayState());
			case "full" | "full version" | "2.5" | "3.0" | "demo 3" | "next demo": CoolUtil.browserLoad("https://youtu.be/pNzGTCEmf3U");
			case "2012": 
				rainbowscreen.visible = false;
				FlxG.sound.play(Paths.sound('vine'));
		}
	}
}