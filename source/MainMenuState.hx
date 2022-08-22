package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import openfl.display.BlendMode;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h (ron eidition)'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var code:String = "";
	var codeInt = 0;
	var codeInt2 = 0;
	var neededCode:Array<String> = ['B', 'R', 'O'];
	var therock:FlxSprite;

	var cloud:FlxBackdrop;
	var city:FlxBackdrop;
	var city2:FlxBackdrop;

	var leOld:Float;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		var bgTex = 'menuSunset';
		var sunTex = 'menuSun';
		var alphaTex = 1;
		var cityTex = 'menuCity';
		var cityBTex = 'menuCityBack';

		if ((Date.now().getHours() < 6) || (Date.now().getHours() > 20))
		{
			bgTex = 'menuNight';
			sunTex = 'menuMoon';
			alphaTex = 2;
			cityTex = 'menuCityNight';
			cityBTex = 'menuCityBackNight';
		}

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(bgTex));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var sun:FlxSprite = new FlxSprite();
		sun.frames = Paths.getSparrowAtlas(sunTex);
		sun.scrollFactor.set();
		sun.animation.addByPrefix('sun', 'sun', 2, true);
		sun.antialiasing = true;
		sun.screenCenter();
		sun.x -= 80;
		sun.y -= 80;
		add(sun);
		sun.animation.play('sun');

		cloud = new FlxBackdrop(Paths.image('menuClouds'), 32, 0, true, true, 0, -250);
		cloud.alpha = 0.8/alphaTex;
		cloud.scrollFactor.set(0.1);
		add(cloud);

		city2 = new FlxBackdrop(Paths.image(cityBTex), 32, 0, true, true, 0, -250);
		city2.scrollFactor.set(0.125);
		add(city2);

		city = new FlxBackdrop(Paths.image(cityTex), 32, 0, true, true, 0, -250);
		city.scrollFactor.set(0.2);
		add(city);

		var road:FlxSprite = new FlxSprite();
		road.frames = Paths.getSparrowAtlas('menuRoad');
		road.scrollFactor.set();
		road.animation.addByPrefix('road instance 1', 'road instance 1', 24, true);
		road.antialiasing = true;
		road.screenCenter(X);
		road.x += 130;
		add(road);
		road.animation.play('road instance 1');

		var car:FlxSprite = new FlxSprite(597.5, 289);
		car.frames = Paths.getSparrowAtlas('menuCar');
		car.animation.addByPrefix('car instance 1', 'car instance 1', 24, true);
		car.antialiasing = true;
		add(car);
		car.scrollFactor.set();
		car.animation.play('car instance 1');

		therock = new FlxSprite().loadGraphic(Paths.image('therock', 'shared'));
		therock.x += 0;
		therock.y += 0;
		therock.alpha = 0;
		add(therock);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var logoBl:FlxSprite = new FlxSprite(car.x + 200, car.y - 330);
		logoBl.scale.set(0.5, 0.5);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logoBl.updateHitbox();
		add(logoBl);
		logoBl.animation.play('bump');
		logoBl.scrollFactor.set();

		var lines:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuLines'));
		lines.scale.set(0.5, 0.5);
		lines.scrollFactor.set();
		lines.screenCenter();
		lines.alpha = 0.5;
		lines.blend = BlendMode.OVERLAY;
		add(lines);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(40, FlxG.height * 1.6);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.95));
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.y = 60 + (i * 130);
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
		{
			var curKey = FlxG.keys.getIsDown()[0].ID.toString();

			if (neededCode.contains(curKey) && neededCode[codeInt] == curKey)
			{
				code += curKey;
				codeInt++;
				codeInt2++;
			}
			else
			{
				code = '';
				codeInt = 0;
			}
		}
			
		if (code == 'BRO')
		{
			therock.alpha = 1;
			FlxTween.tween(therock, {alpha: 0}, 1);
			FlxG.sound.play(Paths.sound('hi'), false); // hi ekic cal i think i fix it but im not sure:( -chromasen
			// no i did not fix but it still appears - chromasen
		}
		if (codeInt == 10)
		{
			code = 'BRO';
			codeInt = 0;
		}

		cloud.x += 0.33;
		city.x += 2;
		city2.x += 1;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				spr.x += 80;
				leOld = spr.ID;
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			} else spr.x = 40;
		});
	}
}
