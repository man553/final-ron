package menus;

import important.Song;
import flixel.addons.ui.FlxUIButton;
import flixel.sound.FlxSound;
import flixel.FlxGame;
import flixel.addons.ui.FlxMultiGamepadAnalogStick.XY;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIButton;
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
import flixel.text.FlxText;
using StringTools;

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
	var transitioningStory:Bool = false;
	override function create() {

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the desktop", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

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
							if (transitioningStory) {return;}
							transitioningStory = true;
							//StoryMenuState.musicTime = FlxG.sound.music.time;
							//new StoryMenuState();
							//transitioningToIdiotism = true;
							//rainbTmr.cancel();
							//new FlxTimer().start(1.5, function(tmr:FlxTimer){
							//	FlxG.camera.fade(0x88FFFFFF, 0.6, false);
							//	new FlxTimer().start(2, function(tmr:FlxTimer){ FlxG.switchState(new StoryMenuState()); FlxG.camera.fade(0x88FFFFFF, 0, true);});
							//});
							var video:misc.MP4Handler = new misc.MP4Handler();
							openSubState(new misc.CustomFadeTransition(.8, false));
							new FlxTimer().start(.5, function(tmr:FlxTimer)
							{
								PlayState.storyPlaylist = ["Ron","Wasted","Ayo","Bloodshed"];
								PlayState.isStoryMode = true;
								PlayState.storyWeek =0;

								var diffic = "-hard";

								PlayState.storyDifficulty = 0;
	
								PlayState.SONG = important.Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
								PlayState.campaignScore = 0;
								PlayState.campaignMisses = 0;
								CoolUtil.difficulties = ["Hard"];
								important.WeekData.reloadWeekFiles(true);
								video.playMP4(Paths.videoRon('ron'), new PlayState(), false, false, false);
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
	var t = Paths.getSparrowAtlas("windowsUi/run tab");
	public function new() {
		super();
		field = new FlxUIInputText(58, 643, 270, "", 18);
		field.font = Paths.font("w95.otf");
		field.callback = function(text, action) {
			if (action == "enter") {
				triggerRunEvent(field.text);
				destroy();
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
			destroy();
		});
		cancel = new FlxButton(258, 685, "", function() {
			destroy();
		});
		help = new FlxButton(308, 566, "", function() {
			CoolUtil.browserLoad("www.facebook.com");
		});
		exit = new FlxButton(327, 566, "", cancel.onUp.callback);
		for (i=>button in [ok, cancel, help, exit]) {
			button.frames = t;
			var animIndex = ["ok", "cancel", "help", "exit"];
			button.animation.addByPrefix("normal", animIndex[i] + " neutral");
			button.animation.addByPrefix("highlight", animIndex[i] + " neutral");
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
			tab.setPosition(Math.round(FlxG.mouse.getScreenPosition().x - justMousePos.x) + justTaskBarPos.x, Math.round(FlxG.mouse.getScreenPosition().y - justMousePos.y) + justTaskBarPos.y);
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
			case "full" | "full version" | "2.5" | "3.0" | "demo 3" | "next demo": CoolUtil.browserLoad("https://youtu.be/pNzGTCEmf3U");
			case "2012": 
				rainbowscreen.visible = false;
				FlxG.sound.play(Paths.sound('vine'));
			case "winver": FlxG.state.add(new Winver());
			case "cdplayer": 	FlxG.state.add(new MusicPlayer());
								FlxG.sound.music.volume = 0.01;
			case "passionatedevs": ClientPrefs.rtxMode = !ClientPrefs.rtxMode;
			default: if (runText.contains("www") || runText.contains("http") || runText.contains("com")) CoolUtil.browserLoad(runText);
		}
	}
}

class Winver extends FlxGroup {
	var tab = new FlxSprite(55, 55).loadGraphic(Paths.image("windowsUi/winver"));
	var ok:FlxButton;
	var exit:FlxButton;
	var tabBar:FlxButton;
	public function new() {
		super();
		add(tab);
		ok = new FlxButton(175, 238, "", function() {
			destroy();
		});
		exit = new FlxButton(340, 60, "", ok.onUp.callback);
		for (i=>button in [ok,exit]) {
			button.frames = Paths.getSparrowAtlas("windowsUi/run tab");
			var animIndex = ["ok", "exit"];
			button.animation.addByPrefix("normal", animIndex[i] + " neutral");
			button.animation.addByPrefix("highlight", animIndex[i] + " neutral");
			button.animation.addByPrefix("pressed", animIndex[i] + " pressed");
			button.updateHitbox();
			add(button);
		}
		tabBar = new FlxButton(55, 55, "");
		tabBar.width = 305;
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
			tab.setPosition(Math.round(FlxG.mouse.getScreenPosition().x - justMousePos.x) + justTaskBarPos.x, Math.round(FlxG.mouse.getScreenPosition().y - justMousePos.y) + justTaskBarPos.y);
			for (button in [ok, exit, tabBar]) {
				var offsetIndex:Map<Dynamic,Dynamic> =  [ok => [120, 183],exit => [285, 6],tabBar => [0, 0]];
				button.setPosition(tab.x + offsetIndex[button][0], tab.y + offsetIndex[button][1]);
			}
		}
	}
}
class MusicPlayer extends FlxGroup {
	var tabBar:FlxButton;
	var ronmusic:FlxSound;
	var ronmusicvox:FlxSound;
	var t = Paths.getSparrowAtlas("windowsUi/so retro");
	var tab:FlxSprite;
	var play:FlxUIButton;
	var pause:FlxUIButton;
	var voices:FlxUIButton;
	var timer:FlxText;
	var militimer:FlxText;
	var dropDown:FlxUIDropDownMenu;
	var backward:FlxButton;
	var forward:FlxButton;
	var exit:FlxButton;
	public function new() {
		super();
		ronmusic = new FlxSound();
		ronmusic.loadEmbedded(Paths.inst("bleeding"));
		ronmusic.onComplete = function() {play.toggled = false;}
		FlxG.sound.list.add(ronmusic);
		ronmusicvox = new FlxSound();
		ronmusicvox.loadEmbedded(Paths.voices("bleeding"));
		FlxG.sound.list.add(ronmusicvox);
		ronmusicvox.volume = 0;
		tab = new FlxSprite(250, 100);
		tab.frames = t;
		tab.animation.addByPrefix("t", "tab");
		tab.animation.play("t");
		add(tab);
		exit = new FlxButton(tab.x + 283, tab.y + 5, "", function() {
			destroy();
			FlxG.sound.music.volume = 1;
		});
		exit.frames = Paths.getSparrowAtlas("windowsUi/run tab");
		exit.animation.addByPrefix("normal", "exit neutral");
		exit.animation.addByPrefix("highlight", "exit neutral");
		exit.animation.addByPrefix("pressed", "exit pressed");
		add(exit);
		timer = new FlxText(tab.x + 61, tab.y + 38, 0, "NO SONG PLAYING", 23);
		timer.color = 0xFF808000;
		timer.antialiasing = false;
		add(timer);
		militimer = new FlxText(tab.x + 17, tab.y + 38, 0, "NO SONG PLAYING", 23);
		militimer.color = 0xFF808000;
		militimer.antialiasing = false;
		add(militimer);
		backward = new FlxButton(tab.x + 175, tab.y + 54, function() {
			if (ronmusic.playing) ronmusic.time -= 3000;
		});
		forward = new FlxButton(tab.x + 199, tab.y + 54, function() {
			if (ronmusic.playing) {
				if (ronmusic.time + 3000 > ronmusic.length) ronmusic.stop();
				else ronmusic.time += 3000;
			}
				
		});
		play = new FlxUIButton(tab.x + 175, tab.y + 27, function() {
			if (play.toggled) {
				if (pause.toggled) {
					pause.toggled = false;
					ronmusic.resume();
					ronmusicvox.resume();
				}
				else {ronmusic.play(); ronmusicvox.play();}
			}
			if (!play.toggled) {
				ronmusic.stop();
				ronmusicvox.stop();
			}
		});
		play.has_toggle = true;
		pause = new FlxUIButton(tab.x + 223, tab.y + 27, function() {
			if (pause.toggled) {
				play.toggled = false;
				ronmusic.pause();
				ronmusicvox.pause();
			}
			if (!pause.toggled) {
				play.toggled = true;
				ronmusic.resume();
				ronmusicvox.resume();
			}
		});
		pause.has_toggle = true;
		voices = new FlxUIButton(tab.x + 247, tab.y + 27);
		voices.has_toggle = true;
		for (i=>button in [backward=>"backwards", forward=>"forward", pause=>"pause", voices=>"voice", play=>"play"]) {
			i.frames = t;
			i.animation.addByPrefix("normal", button + " neutral");
			i.animation.addByPrefix("highlight", button + " neutral");
			i.animation.addByPrefix("pressed", button + " pressed");
			i.updateHitbox();
			add(i);
		}
		for (i=>j in [pause=>"pause", voices=>"voice", play=>"play"]) {
			i.animation.addByPrefix("normal_toggled", j + " pressed");
			i.animation.addByPrefix("highlight_toggled", j + " pressed");
			i.animation.addByPrefix("pressed_toggled", j + " pressed");
		}
		var header = new FlxUIDropDownHeader(244, new FlxSprite().makeGraphic(244, 16));
		//header.background = new FlxSprite().makeGraphic(244, 12);
		header.button.frames = t;
		header.button.animation.addByPrefix("normal", "select neutral");
		header.button.animation.addByPrefix("highlight", "select neutral");
		header.button.animation.addByPrefix("pressed", "select pressed");
		header.button.updateHitbox();
		header.button.label.offset.x += 50325;
		header.button.offset.x -= 244 - header.button.width;
		header.button.width = 244;
		header.text.y -= 3;
		header.text.font = Paths.font("w95.otf");
		header.text.size = 14;
		header.text.antialiasing = false;
		//header.background.setGraphicSize(244, 16);
		header.button.offset.x -= 10;
		dropDown = new FlxUIDropDownMenu(tab.x + 47, tab.y + 135, FlxUIDropDownMenu.makeStrIdLabelArray(sys.FileSystem.readDirectory("assets/songs")), function(song) {
			ronmusic.stop();
			ronmusicvox.stop();
			ronmusicvox.loadEmbedded(Paths.voices(song));
			ronmusic.loadEmbedded(Paths.inst(song));
			pause.toggled = false;
			play.toggled = false;
		}, header);
		dropDown.dropDirection = FlxUIDropDownMenuDropDirection.Down;
		dropDown.selectedLabel = "";
		for (i in dropDown.list) {
			i.label.font = Paths.font("w95.otf");
			i.label.size = 14;
			i.label.antialiasing = false;
		}
		add(dropDown);
		play.width = 47;
		tabBar = new FlxButton(250, 250, "");
		tabBar.width = 303;
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
		ronmusicvox.time = ronmusic.time;
		var timey:Float = ronmusic.time;
		militimer.text = '['+(Math.floor(timey /100)%10 == 0 && Math.floor(timey /100) > 5 ? "1" : "0")+Math.floor(timey /100) % 10;
		timer.text = "] " + (Math.floor((timey /100000) * 1.6666) < 10 ? "0" : "")+Math.floor((timey /100000) * 1.6666) + (Math.floor((timey/1000) % 60) < 10 ? ":0" : ":")+Math.floor((timey /1000) % 60);
		if (movingTab) {
			tab.setPosition(Math.round(FlxG.mouse.getScreenPosition().x - justMousePos.x) + justTaskBarPos.x, Math.round(FlxG.mouse.getScreenPosition().y - justMousePos.y) + justTaskBarPos.y);
			tabBar.setPosition(tab.x, tab.y);
			for (button=>i in [backward=>"backwards", forward=>"forward", pause=>"pause", voices=>"voice", play=>"play", timer=>"timer", militimer=>"militimer", dropDown=>"dropdown", exit=>"exit"]) {
				var offsets = ["backwards"=>[175, 54], "forward"=>[199, 54], "pause"=>[223, 27], "voice"=>[247, 27], "play"=>[175, 27], "timer"=>[61, 38], "militimer"=>[17, 38], "dropdown"=>[47, 135], "exit"=>[283, 5]];
				button.setPosition(tab.x + offsets[i][0], tab.y + offsets[i][1]);
			}
		}
		ronmusicvox.volume = voices.toggled ? 1 : 0;
	}
}