package menus;

import flixel.addons.display.FlxBackdrop;
#if desktop
import important.Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{

	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:FlxText;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var time:Float = 0;
	var chromeOffset = (ClientPrefs.rgbintense/350);
	var curWacky:Array<String> = [];

	var logoBl:FlxSprite;
	var logoBi:FlxSprite;
	var gfDance:FlxSprite;
	var animScreen:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var animbarScrt:FlxBackdrop;
	var animbarScrb:FlxBackdrop;
	var swagShader:ColorSwap = null;

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/


		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		//FlxG.keys.preventDefaultKeys = [TAB];

		important.PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadPrefs();

		important.Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new menus.FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
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

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
		addShader(FlxG.camera, "chromatic aberration");
		addShader(FlxG.camera, "colorizer");
		var chromeOffset = (ClientPrefs.rgbintense/350);
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset/2];
		Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
	}

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.loadGraphic(Paths.image('bg'));
			bg.setGraphicSize(Std.int(bg.width * 4));
			bg.setGraphicSize(Std.int(bg.height * 4));
			bg.antialiasing = true;
			bg.scrollFactor.set();
			bg.screenCenter(XY);
			bg.active = false;
			add(bg);
		}

		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		swagShader = new ColorSwap();
		gfDance = new FlxSprite();

		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByPrefix('idle', "GF Dancing Beat", 24);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		gfDance.scale.set(0.5,0.5);
		gfDance.x += 320;
		gfDance.y -= 200;
		gfDance.shader = swagShader.shader;
		add(gfDance);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});
		
		animScreen = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		animScreen.scale.set(2,2);
		animScreen.frames = Paths.getSparrowAtlas('trueTitleBgAnimated');
		animScreen.animation.addByPrefix('animate', 'animate', 30, true);
		animScreen.animation.play('animate');
		animScreen.updateHitbox();
		animScreen.screenCenter(XY);
		animbarScrt = new FlxBackdrop(Paths.image('trueTitleBarTop'), X, 0, 0);
		animbarScrb = new FlxBackdrop(Paths.image('trueTitleBarBottom'), X, 0, 0);
		animbarScrt.screenCenter(XY);
		animbarScrb.screenCenter(XY);
		new FlxTimer().start(0.005, function(tmr:FlxTimer)
		{
			animbarScrb.x -= 2;
			animbarScrt.x += 2;
			tmr.reset(0.005);
		});
		add(animScreen);
		add(animbarScrt);
		add(animbarScrb);
	
		logoBi = new FlxSprite().loadGraphic(Paths.image('trueTitleBack'));
		logoBi.updateHitbox();
		logoBi.screenCenter(XY);	
		logoBl = new FlxSprite().loadGraphic(Paths.image('trueTitleLogo'));
		logoBl.updateHitbox();
		logoBl.screenCenter(XY);
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		titleText = new FlxSprite().loadGraphic(Paths.image('trueTitlePlay'));
		titleText.updateHitbox();
		titleText.screenCenter(XY);
		add(logoBi);
		add(logoBl);
		add(titleText);
		
		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);
		
		blackScreen = new FlxSprite();
		blackScreen.frames = Paths.getSparrowAtlas('titleThing');
		blackScreen.animation.addByPrefix('idle', 'idle', 24, true);
		blackScreen.animation.play('idle');
		blackScreen.scale.set(2.25,2.25);
		blackScreen.updateHitbox();
		blackScreen.screenCenter();
		blackScreen.scrollFactor.set(0.1,0.1);
		add(blackScreen);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		credTextShit = new FlxText(0, 0, "", true);
		credTextShit.setFormat(Paths.font("w95.otf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		credTextShit.bold = true;
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		var blackeffect:FlxSprite = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.height*3, FlxColor.BLACK);
		blackeffect.updateHitbox();
		blackeffect.antialiasing = true;
		blackeffect.screenCenter(XY);
		blackeffect.scrollFactor.set();
		add(blackeffect);

		FlxTween.tween(blackeffect, {alpha: 0}, 1, {ease: FlxEase.quadInOut});

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	override function update(elapsed:Float)
	{
		time += elapsed;
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset*Math.sin(time)];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [-chromeOffset*Math.sin(time)];
		if (skippedIntro) {
			logoBl.angle = Math.sin(-time*5)/8;
			logoBi.angle = logoBl.angle;
			logoBl.screenCenter(XY);
			titleText.angle += Math.sin(-time*8)/16;
			Shaders["colorizer"].shader.data.colors.value = time/2;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		var pressedSkip:Bool = false;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				FlxTween.tween(titleText, {y: titleText.y - 500}, 2, {ease: FlxEase.backIn});

				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				
				FlxTween.cancelTweensOf(FlxG.camera);
				blackScreen.color = FlxColor.BLACK;
				blackScreen.scale.set(10,10);
				blackScreen.screenCenter(XY);
				FlxTween.tween(blackScreen, {alpha: 1}, 1.1, {ease: FlxEase.circIn});
				FlxTween.tween(FlxG.camera, {zoom: 3, angle: 22}, 1.5, {ease: FlxEase.quartIn});
				FlxTween.tween(animbarScrt, {y: animbarScrt.y - 200}, 0.5, {ease: FlxEase.quadIn});
				FlxTween.tween(animbarScrb, {y: animbarScrb.y + 200}, 0.5, {ease: FlxEase.quadIn});
				FlxG.camera.fade(0xFF000000, 0.8, true);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					//MusicBeatState.switchState((ClientPrefs.warnings ? new substates.WarningSubState() : new menus.DesktopMenu()));
					MusicBeatState.switchState(new menus.DesktopMenu());
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		if (!pressedEnter && !pressedSkip && !transitioning && skippedIntro)
		{
			if (FlxG.keys.justPressed.S)
			{
				// im too tired to keep waiting for the stupid Other states so im just putting a skip button
				pressedSkip = true;
				FlxG.switchState(new menus.DesktopMenu());
			}
		}

		super.update(elapsed);
	}

	function fuckyou(){
		#if desktop
		MusicBeatState.switchState(new menus.MainMenuState());
		#else
		MusicBeatState.switchState(new menus.PiracyScreen());
		#end
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:FlxText = new FlxText(0, 0, textArray[i]);
			money.setFormat(Paths.font("w95.otf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			money.bold = true;
			money.y += (i * 60) + 200 + offset;
			money.screenCenter(X);
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:FlxText = new FlxText(0, 0, text);
			coolText.setFormat(Paths.font("w95.otf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			coolText.bold = true;
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();
		if (transitioning == false)
		{
			FlxG.camera.zoom = 1.03;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {ease: FlxEase.circOut});
			animScreen.animation.play('animate', true);
		}

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			gfDance.animation.play('idle');
		}

		if(!closedState) {
			sickBeats++;
			switch (curBeat)
			{
				case 1:
					createCoolText(['A', 'FUCKTON', 'OF', 'PEOPLE']);
				// credTextShit.visible = true;
				case 3:
					addMoreText('PRESENT');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['in association with']);
				case 7:
					addMoreText('not patrick');
					ngSpr.visible = true;

				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('LITERALLY EVERY');
				// credTextShit.visible = true;
				case 14:
					addMoreText('FANMADE FNF MOD');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('EVER'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{

			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			addShader(FlxG.camera, "godray");
			var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
			if (easteregg == null) easteregg = '';
			easteregg = easteregg.toUpperCase();
			blackScreen.alpha = 0;

			skippedIntro = true;
		}
	}
}
