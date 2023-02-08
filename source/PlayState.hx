package;

import flixel.graphics.FlxGraphic;
#if desktop
import important.Discord.DiscordClient;
#end
import important.Section.SwagSection;
import important.Song;
import important.Song.SwagSong;
import important.WeekData;
import important.Highscore;
import misc.WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import gameassets.Note.EventNote;
import gameassets.Note;
import gameassets.*;
import misc.*;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import animateatlas.AtlasFrameMaker;
import gameassets.Character;
import gameassets.Boyfriend;
import gameassets.Achievements;
import gameassets.StageData;
import substates.DialogueBoxRon;
import important.Conductor.Rating;
import substates.*;
#if sys
import sys.FileSystem;
#end
import lime.app.Application;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class PlayState extends MusicBeatState
{

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end
	public var introSoundsSuffix:String = '';
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public static var instance:PlayState;
	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 3000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', ':coolswag'];
	var dialogueJson:FuckingDialogue = null;

	var baro:FlxSprite;
	var bart:FlxSprite;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	/*Bloodshed Legacy Redux stuffs
	BLR = Bloodshed Legacy Redux*/
	var skyBLR:FlxSprite;
	var groundBLR:FlxSprite;
	//aight

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	var video:MP4Handler = new MP4Handler();

	var satan:BGSprite;
	var firebg:FlxSprite;
	var fx:FlxSprite;
	var Estatic:FlxSprite;
	var blackeffect:FlxSprite;
	var bgbleffect:FlxSprite;
	var snowemitter:FlxEmitter;
	var graadienter:FlxSprite;
	var wbg:FlxSprite;
	var heart:FlxSprite;
	
	var mountainsbackba:BGSprite;
	var mountainsba:BGSprite;
	var hillfrontba:BGSprite;
	var streetba:BGSprite;

	var hellbg:BGSprite;
	var mountainsbackbl:BGSprite;
	var mountainsbl:BGSprite;
	var hillfrontbl:BGSprite;
	var streetbl:BGSprite;

	var Estatic2:FlxSprite;

	var funnywindow:Bool = false;
	var funnywindowsmall:Bool = false;
	var NOMOREFUNNY:Bool = false;
	var strumy:Int = 50;
	var windowmove:Bool = false;
	var cameramove:Bool = false;

	var defaultStrumX:Array<Float> = [50,162,274,386,690,802,914,1026];
	var defaultStrumY:Float = 50;

	public static var SCREWYOU:Bool = false;

	var kadeEngineWatermark:FlxText;

	var witheredRa:BGSprite;
	var witheredClouds:FlxBackdrop;
	var fxtwo:FlxSprite;
	public var camOverlay:FlxCamera;
	public var camBg:FlxCamera;

	var WHATTHEFUCK:Bool = false;
	var WTFending:Bool = false;
	var intensecameramove:Bool = false;

	var moveing:Bool = false;

	var bgLol:BGSprite;
	var cloudsa:FlxSprite;

	var leBlack:FlxSprite;
	var shutTheFuckUp:Bool = false;
	var wastedGrp:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
	var ronGrp:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
	var bloodshedGrp:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
	// ok i dont care anymor
	var haemorrhageCallback:Void->Void;
	var bar1:FlxSprite;
	var bar2:FlxSprite;

	//ok ig

	override public function create()
	{
		//preventing duplicate shaders
		//MusicBeatState.allShaders = [];
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		FlxG.cameras.add(camOverlay);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);


		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		//trace('stage is: ' + curStage);
		if(SONG.stage == null || SONG.stage.length < 1) {
			switch (songName)
			{
				case 'cocoa':
					curStage = 'mall';
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		bar1 = new FlxSprite(0, -560).makeGraphic(1600 * 2, 560, 0xFF000000);
		bar2 = new FlxSprite(0, 720).makeGraphic(1600 * 2, 560, 0xFF000000);
		bar1.cameras=[camHUD];
		bar2.cameras=[camHUD];
		add(bar1);
		add(bar2);
		bar2.y=720;
		bar1.y=-560;
		switch (curStage)
		{ 	//all the stages here
			case 'farm':
				var bg:BGSprite = new BGSprite('bgs/newbgtest/slammed/sky', -600, -200,0.6, 0.6);
				add(bg);

				var flatgrass:BGSprite = new BGSprite('bgs/newbgtest/slammed/gm_flatgrass', 350, 75, 0.65, 0.65);
				flatgrass.setGraphicSize(Std.int(flatgrass.width * 0.34));
				flatgrass.updateHitbox();
				add(flatgrass);
				
				var hills:BGSprite = new BGSprite('bgs/newbgtest/slammed/orangey hills', -173, 100, 0.65, 0.65);
				add(hills);
				
				var farmHouse:BGSprite = new BGSprite('bgs/newbgtest/slammed/funfarmhouse', 100, 125, 0.7, 0.7);
				farmHouse.setGraphicSize(Std.int(farmHouse.width * 0.9));
				farmHouse.updateHitbox();
				add(farmHouse);

				var grassLand:BGSprite = new BGSprite('bgs/newbgtest/slammed/grass lands', -600, 500);
				add(grassLand);

				var cornFence:BGSprite = new BGSprite('bgs/newbgtest/slammed/cornFence', -400, 200);
				add(cornFence);
				
				var cornFence2:BGSprite = new BGSprite('bgs/newbgtest/slammed/cornFence2', 1100, 200);
				add(cornFence2);

				var bagType = FlxG.random.int(0, 1000) == 0 ? 'popeye' : 'cornbag';
				var cornBag:BGSprite = new BGSprite('bgs/newbgtest/slammed/cornbag', 1200, 550);
				add(cornBag);
				
				var sign:BGSprite = new BGSprite('bgs/newbgtest/slammed/sign', 0, 350);
				add(sign);
			case 'trouble':
				var bg:FlxSprite = new FlxSprite(-100,10).loadGraphic(Paths.image('bgs/nothappy_sky'));
				bg.scale.set(1.2, 1.2);
				bg.antialiasing = true;
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);
				
				var ground:FlxSprite = new FlxSprite(-537, -250).loadGraphic(Paths.image('bgs/nothappy_ground'));
				ground.antialiasing = true;
				add(ground);

				var deadbob:FlxSprite = new FlxSprite(-700, 600).loadGraphic(Paths.image('bgs/GoodHeDied'));
				deadbob.antialiasing = true;
				add(deadbob);
			case 'mad':
			{
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-100,10).loadGraphic(Paths.image('updateron/bg/pissedRon_sky'));
				bg.antialiasing = true;
				bg.screenCenter();
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);
				
				var clouds:FlxSprite = new FlxSprite(-100,10).loadGraphic(Paths.image('updateron/bg/pissedRon_clouds'));
				clouds.scale.set(0.7, 0.7);
				clouds.screenCenter();
				clouds.antialiasing = true;
				clouds.scrollFactor.set(0.2, 0.2);
				add(clouds);
				
				var ground:FlxSprite = new FlxSprite(-537, -250).loadGraphic(Paths.image('updateron/bg/pissedRon_ground'));
				ground.antialiasing = true;
				add(ground);
			}
			case 'fard':
			{
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(300,200).loadGraphic(Paths.image('updateron/bg/sonker_bg'));
				bg.updateHitbox();
				bg.active = false;
				bg.antialiasing = true;
				bg.scrollFactor.set(1,1);
				bg.screenCenter();
				bg.y -= 200;
				add(bg);
			}
			case 'triad':
			{
				defaultCamZoom = 0.7;
				var bg = new FlxBackdrop(Paths.image('bgs/newbgtest/triad/nomajin'), XY, 0, 0);
				bg.scale.set(2,2);
				var bgt = new FlxBackdrop(Paths.image('bgs/newbgtest/triad/majinother'), XY, 0, 0);
				bgt.scale.set(2,2);
				bg.scrollFactor.set(0.5,0.5);
				//bg.cameras = [camBg];
				bgt.scrollFactor.set(0.5,0.5);
				//bgt.cameras = [camBg];
				add(bg);
				wastedGrp.add(bgt);			
				add(wastedGrp);
				wastedGrp.visible = false;
				var chromeOffset = (ClientPrefs.rgbintense/350);
				addShader(FlxG.camera, "chromatic aberration");
				addShader(FlxG.camera, "fisheye");
				Shaders["fisheye"].shader.data.MAX_POWER.value = [0.2];
				Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset/2];
				Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1/2];
				
				var bruhgoing = new FlxTimer().start(0.005, function(tmr:FlxTimer)
				{
					bg.x += 2;
					bg.y += 1;
					bgt.x += 3;
					bgt.y += 2;
					tmr.reset(0.005);
				});
			}
			case 'ronPissed': //ron
				defaultCamZoom = 0.7;
				var sky:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_sky', -100, 20);
				sky.screenCenter();
				sky.scrollFactor.set(0.1, 0.1);
				add(sky);
				
				var mountainsback:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_mountainsback', -100, 20);
				mountainsback.screenCenter();
				mountainsback.scrollFactor.set(0.3, 0.3);
				mountainsback.y -= 60;
				add(mountainsback);
				
				var clouds:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_clouds', -100, 20);
				clouds.screenCenter();
				clouds.scrollFactor.set(0.1, 0.1);
				add(clouds);
				
				addShader(FlxG.camera, "rain");
				Shaders["rain"].shader.data.zoom.value = [35];
				Shaders["rain"].shader.data.raindropLength.value = [0.05];
				Shaders["rain"].shader.data.opacity.value = [0.2];
				
				var mountains:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_mountains', -100, 20);
				mountains.screenCenter();
				mountains.scrollFactor.set(0.3, 0.3);
				mountains.y -= 60;
				add(mountains);
			
				var hillfront:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_hillfront', -100, 20);
				hillfront.screenCenter();
				hillfront.scrollFactor.set(0.4, 0.4);
				hillfront.y -= 60;
				add(hillfront);
				
				var street:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_street', -100, 20);
				street.screenCenter();
				add(street);

			case 'ronMad': //ron
				var sky:BGSprite = new BGSprite('bgs/newbgtest/ayo/ayo_sky', -100, 20);
				sky.screenCenter();
				sky.scrollFactor.set(0.1, 0.1);
				add(sky);
				
				defaultCamZoom = 1.1;
				
				var mountainsback:BGSprite = new BGSprite('bgs/newbgtest/ayo/ayo_mountainsback', -100, 20);
				mountainsback.screenCenter();
				mountainsback.scrollFactor.set(0.3, 0.3);
				mountainsback.y -= 60;
				add(mountainsback);
				
				var mountains:BGSprite = new BGSprite('bgs/newbgtest/ayo/ayo_mountains', -100, 20);
				mountains.screenCenter();
				mountains.scrollFactor.set(0.3, 0.3);
				mountains.y -= 60;
				add(mountains);
			
				var hillfront:BGSprite = new BGSprite('bgs/newbgtest/ayo/ayo_hillfront', -100, 20);
				hillfront.screenCenter();
				hillfront.scrollFactor.set(0.4, 0.4);
				hillfront.y -= 60;
				add(hillfront);
				
				graadienter = new FlxSprite(-100,10).loadGraphic(Paths.image('bgs/ss_gradient'));
				graadienter.updateHitbox();
				graadienter.screenCenter();
				graadienter.active = false;
				graadienter.antialiasing = true;
				graadienter.visible = false;
				add(graadienter);				
				
				var street:BGSprite = new BGSprite('bgs/newbgtest/ayo/ayo_street', -100, 40);
				street.screenCenter();
				add(street);
				
				bgLol = new BGSprite('bgs/newbgtest/ayo/ayo_streetNoLight', -100, 40);
				bgLol.screenCenter();
				add(bgLol);
				
				addShader(FlxG.camera, "rain");
				Shaders["rain"].shader.data.zoom.value = [35];
				Shaders["rain"].shader.data.raindropLength.value = [0.075];
				Shaders["rain"].shader.data.opacity.value = [0.2];

			case 'ronNormal': //ron
				addCharacterToList("rontriggered", 1);
				Shaders["chromatic aberration"].shader.data.rOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.bOffset.value = [0.0]; // add 

				defaultCamZoom = 0.8;
				var sky:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_sky', -100, 20);
				sky.screenCenter();
				sky.scrollFactor.set(0.1, 0.1);
				add(sky);
				
				var cloudsbig = new FlxBackdrop(Paths.image('bgs/newbgtest/ron/ron_clouds'), X, 0, 0);
				cloudsbig.scrollFactor.set(0.1,0.1);
				cloudsbig.screenCenter(XY);
				add(cloudsbig);
				
				FlxTween.tween(cloudsbig, {x: cloudsbig.x + 6000}, 720, {type: LOOPING});
				
				var cloudssmall = new FlxBackdrop(Paths.image('bgs/newbgtest/ron/ron_clouds'), X, 0, 0);
				cloudssmall.scale.set(0.5,0.5);
				cloudssmall.updateHitbox();
				cloudssmall.scrollFactor.set(0.05,0.1);
				cloudssmall.screenCenter(XY);
				cloudssmall.y -= 120;
				add(cloudssmall);
				
				FlxTween.tween(cloudssmall, {x: cloudssmall.x + 3000}, 360, {type: LOOPING});
			
				var cityback:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_cityback', -100, 20);
				cityback.screenCenter();
				cityback.scrollFactor.set(0.2, 0.2);
				cityback.y -= 60;
				add(cityback);
				
				var cityj:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_city', -100, 20);
				cityj.screenCenter();
				cityj.scrollFactor.set(0.25, 0.25);
				cityj.y -= 60;
				add(cityj);
				
				var mountainsback:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_mountainsback', -100, 20);
				mountainsback.screenCenter();
				mountainsback.scrollFactor.set(0.3, 0.3);
				mountainsback.y += 120;
				add(mountainsback);
				
				var mountains:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_mountains', -100, 20);
				mountains.screenCenter();
				mountains.scrollFactor.set(0.3, 0.3);
				mountains.y -= 60;
				add(mountains);
			
				var hillfront:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_hillfront', -100, 20);
				hillfront.screenCenter();
				hillfront.scrollFactor.set(0.4, 0.4);
				hillfront.y -= 60;
				add(hillfront);
				
				var street:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_street', -100, 40);
				street.screenCenter();
				add(street);

				/*var skyo:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_sky', -100, 20);
				skyo.screenCenter();
				skyo.scrollFactor.set(0.1, 0.1);
				wastedGrp.add(skyo);

				var mountainsback:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_mountainsback', -100, 20);
				mountainsback.screenCenter();
				mountainsback.scrollFactor.set(0.3, 0.3);
				mountainsback.y -= 60;
				wastedGrp.add(mountainsback);

				var clouds:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_clouds', -100, 20);
				clouds.screenCenter();
				clouds.scrollFactor.set(0.1, 0.1);
				wastedGrp.add(clouds);

				var mountains:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_mountains', -100, 20);
				mountains.screenCenter();
				mountains.scrollFactor.set(0.3, 0.3);
				mountains.y -= 60;
				wastedGrp.add(mountains);

				var hillfront:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_hillfront', -100, 20);
				hillfront.screenCenter();
				hillfront.scrollFactor.set(0.4, 0.4);
				hillfront.y -= 60;
				wastedGrp.add(hillfront);

				var street:BGSprite = new BGSprite('bgs/newbgtest/wasted/wasted_street', -100, 20);
				street.screenCenter();
				wastedGrp.add(street);*/	

				blackeffect = new FlxSprite().makeGraphic(FlxG.width, FlxG.width, FlxColor.BLACK);
				blackeffect.scale.set(4,4);
				blackeffect.updateHitbox();
				blackeffect.antialiasing = true;
				blackeffect.screenCenter(XY);
				blackeffect.scrollFactor.set();
				blackeffect.alpha = 0;
				wastedGrp.add(blackeffect);			
				
				add(wastedGrp);
				wastedGrp.visible = false;
			case 'hell': //ron
				addCharacterToList("hellron-drippin", 1);
				defaultCamZoom = 0.8;
				hellbg = new BGSprite('bgs/hell_bg', -300, 140, 0.5, 0.1);
				hellbg.animation.addByPrefix('idle instance 1', 'idle instance 1', 48, true);
				hellbg.setGraphicSize(Std.int(hellbg.width * 5));
				hellbg.updateHitbox();
				hellbg.screenCenter(XY);
				hellbg.y += hellbg.height / 5;
				add(hellbg);
				hellbg.animation.play('idle instance 1');

				firebg = new FlxSprite();
				firebg.frames = Paths.getSparrowAtlas('bgs/escape_fire');
				firebg.scale.set(6,6);
				firebg.animation.addByPrefix('idle', 'fire instance 1', 24, true);
				firebg.animation.play('idle');
				firebg.scrollFactor.set();
				firebg.screenCenter();
				firebg.alpha = 0;
				add(firebg);

				satan = new BGSprite('bgs/hellRon_satan', -600, -500, 0.15, 0.15);
				satan.setGraphicSize(Std.int(satan.width * 1.2));
				satan.y -= 100;
				satan.updateHitbox();
				satan.screenCenter(XY);
				satan.x -= 60;
				add(satan);

				var ground:BGSprite = new BGSprite('bgs/hellRon_ground', -500, -500);
				ground.setGraphicSize(Std.int(ground.width * 1.2));
				ground.updateHitbox();
				add(ground);

				fx = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
				fx.setGraphicSize(Std.int(2560 * 1)); // i dont know why but this gets smol if i make it the same size as the kade ver
				fx.updateHitbox();
				fx.antialiasing = true;
				fx.screenCenter(XY);
				fx.scrollFactor.set(0, 0);
				fx.alpha = 0.3;

				blackeffect = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.width*3, FlxColor.BLACK);
				blackeffect.updateHitbox();
				blackeffect.antialiasing = true;
				blackeffect.screenCenter(XY);
				blackeffect.scrollFactor.set();
				blackeffect.alpha = 1;
				if (SONG.song != 'Bloodshed-b')
					blackeffect.alpha = 0;
				add(blackeffect);

				Estatic = new FlxSprite().loadGraphic(Paths.image('bgs/deadly'));
				Estatic.scrollFactor.set();
				Estatic.screenCenter();
				Estatic.alpha = 0;

				Estatic2 = new FlxSprite();
				Estatic2.frames = Paths.getSparrowAtlas('bgs/trojan_static');
				Estatic2.scale.set(4,4);
				Estatic2.animation.addByPrefix('idle', 'static instance 1', 24, true);
				Estatic2.animation.play('idle');
				Estatic2.scrollFactor.set();
				Estatic2.screenCenter();
				Estatic2.alpha = 0;

			case 'ronHell':
				defaultCamZoom = 0.8;
				precacheList.set('hellexplode', 'sound');
				witheredRa = new BGSprite('bgs/newbgtest/ron/ron_sky', 0, 0);
				witheredRa.screenCenter();
				witheredRa.scrollFactor.set(0.1, 0.1);
				add(witheredRa);
				hellbg = new BGSprite('bgs/hell_bg', -300, 140, 0.5, 0.1);
				hellbg.animation.addByPrefix('idle instance 1', 'idle instance 1', 48, true);
				hellbg.setGraphicSize(Std.int(hellbg.width * 5));
				hellbg.updateHitbox();
				hellbg.screenCenter(XY);
				hellbg.y += hellbg.height / 5;
				add(hellbg);
				hellbg.animation.play('idle instance 1');
				hellbg.alpha = 0.1;
				
				firebg = new FlxSprite();
				firebg.frames = Paths.getSparrowAtlas('bgs/escape_fire');
				firebg.scale.set(6,6);
				firebg.animation.addByPrefix('idle', 'fire instance 1', 24, true);
				firebg.animation.play('idle');
				firebg.scrollFactor.set();
				firebg.screenCenter();
				firebg.alpha = 0;
				add(firebg);

				var cloudsbig = new FlxBackdrop(Paths.image('bgs/newbgtest/ron/ron_clouds'), X, 0, 0);
				cloudsbig.scrollFactor.set(0.1,0.1);
				cloudsbig.screenCenter(XY);
				wastedGrp.add(cloudsbig);
				
				FlxTween.tween(cloudsbig, {x: cloudsbig.x + 6000}, 720, {type: LOOPING});
				
				var cloudssmall = new FlxBackdrop(Paths.image('bgs/newbgtest/ron/ron_clouds'), X, 0, 0);
				cloudssmall.scale.set(0.5,0.5);
				cloudssmall.updateHitbox();
				cloudssmall.scrollFactor.set(0.05,0.1);
				cloudssmall.screenCenter(XY);
				cloudssmall.y -= 120;
				wastedGrp.add(cloudssmall);
				
				FlxTween.tween(cloudssmall, {x: cloudssmall.x + 3000}, 360, {type: LOOPING});
				var mountainsback:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_mountainsback', -100, 20);
				mountainsback.screenCenter();
				mountainsback.scrollFactor.set(0.3, 0.3);
				mountainsback.y -= 60;
				ronGrp.add(mountainsback);
				
				var mountains:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_mountains', -100, 20);
				mountains.screenCenter();
				mountains.scrollFactor.set(0.3, 0.3);
				mountains.y -= 60;
				ronGrp.add(mountains);
			
				var hillfront:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_hillfront', -100, 20);
				hillfront.screenCenter();
				hillfront.scrollFactor.set(0.4, 0.4);
				hillfront.y -= 60;
				ronGrp.add(hillfront);
				
				var mountainsbackbl:BGSprite = new BGSprite('bgs/newbgtest/bloodshed/bloodshed_mountainsback', -100, 20);
				mountainsbackbl.screenCenter();
				mountainsbackbl.scrollFactor.set(0.3, 0.3);
				mountainsbackbl.y -= 60;
				bloodshedGrp.add(mountainsbackbl);
				
				mountainsbl = new BGSprite('bgs/newbgtest/bloodshed/bloodshed_mountains', -100, 20);
				mountainsbl.screenCenter();
				mountainsbl.scrollFactor.set(0.3, 0.3);
				mountainsbl.y -= 60;
				bloodshedGrp.add(mountainsbl);
			
				hillfrontbl = new BGSprite('bgs/newbgtest/bloodshed/bloodshed_hillfront', -100, 20);
				hillfrontbl.screenCenter();
				hillfrontbl.scrollFactor.set(0.4, 0.4);
				hillfrontbl.y -= 60;
				bloodshedGrp.add(hillfrontbl);
				
				satan = new BGSprite('bgs/hellRon_satan', -600, -500, 0.15, 0.15);
				satan.setGraphicSize(Std.int(satan.width * 1.2));
				satan.scrollFactor.set(0.2, 0.2);
				satan.screenCenter(XY);
				satan.y += 600;
				satan.x -= 100;
				satan.updateHitbox();
				add(satan);
				
				var street:BGSprite = new BGSprite('bgs/newbgtest/ron/ron_street', -100, 20);
				street.screenCenter();
				ronGrp.add(street);
				
				var streetbl:BGSprite = new BGSprite('bgs/newbgtest/bloodshed/bloodshed_street', -100, 20);
				streetbl.screenCenter();
				bloodshedGrp.add(streetbl);
				
				wbg = new FlxSprite();
				wbg.frames = Paths.getSparrowAtlas('bgs/newbgtest/bloodshed/lava');
			    wbg.animation.addByPrefix('lava', 'lava', 24, true);
				wbg.scale.set(2,2);
				wbg.updateHitbox();
				wbg.antialiasing = true;
				wbg.screenCenter(XY);
				wbg.scrollFactor.set(0.2, 0.05);
				wbg.alpha = 0;	
				add(wbg);
				wbg.animation.play('lava');
				
				satan = new BGSprite('bgs/hellRon_satan', -600, -500, 0.15, 0.15);
				satan.setGraphicSize(Std.int(satan.width * 1.2));
				satan.scrollFactor.set(0.2, 0.05);
				satan.screenCenter(XY);
				satan.y += 600;
				satan.x -= 100;
				satan.updateHitbox();
				add(satan);
				
				fx = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
				fx.setGraphicSize(Std.int(2560 * 1)); // i dont know why but this gets smol if i make it the same size as the kade ver
				fx.updateHitbox();
				fx.antialiasing = true;
				fx.screenCenter(XY);
				fx.scrollFactor.set(0, 0);
				fx.alpha = 0.3;

				blackeffect = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.width*3, FlxColor.BLACK);
				blackeffect.updateHitbox();
				blackeffect.antialiasing = true;
				blackeffect.screenCenter(XY);
				blackeffect.scrollFactor.set();
				blackeffect.alpha = 1;
				if (SONG.song != 'Bloodshed-b')
					blackeffect.alpha = 0;
				add(blackeffect);

				Estatic = new FlxSprite().loadGraphic(Paths.image('bgs/deadly'));
				Estatic.scrollFactor.set();
				Estatic.screenCenter();
				Estatic.alpha = 0;

				Estatic2 = new FlxSprite();
				Estatic2.frames = Paths.getSparrowAtlas('bgs/trojan_static');
				Estatic2.scale.set(4,4);
				Estatic2.animation.addByPrefix('idle', 'static instance 1', 24, true);
				Estatic2.animation.play('idle');
				Estatic2.scrollFactor.set();
				Estatic2.screenCenter();
				Estatic2.alpha = 0;
				
				add(bloodshedGrp);
				if (curSong.toLowerCase() == 'bloodshed')
					add(ronGrp);
				else	
					remove(witheredRa);

				addCharacterToList("hellron-drippin", 1);
				addCharacterToList("hellron", 1);
				addCharacterToList("BFrun", 0);
				addCharacterToList("GFrun", 2);
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -537, 100, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
			case 'daveHouse':
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bgs/sky'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.75, 0.75);
				bg.active = false;

				add(bg);

				/*var stageHills:FlxSprite = new FlxSprite(-225, -325).loadGraphic(Paths.image('bgs/hills'));
				stageHills.setGraphicSize(Std.int(stageHills.width * 1.25));
				stageHills.updateHitbox();
				stageHills.antialiasing = true;
				stageHills.scrollFactor.set(0.8, 0.8);
				stageHills.active = false;

				add(stageHills);*/

				var gate:FlxSprite = new FlxSprite(-200, -125).loadGraphic(Paths.image('bgs/gate'));
				gate.setGraphicSize(Std.int(gate.width * 1.2));
				gate.updateHitbox();
				gate.antialiasing = true;
				gate.scrollFactor.set(0.9, 0.9);
				gate.active = false;

				add(gate);

				var stageFront:FlxSprite = new FlxSprite(-300, 350).loadGraphic(Paths.image('bgs/grass'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.2));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.active = false;

				add(stageFront);
			case 'withered':
				var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgs/bobtwerked/annoyed_sky'));
				bg.setGraphicSize(Std.int(bg.width * 0.75));
				bg.scrollFactor.set(0.2,0.2);
				bg.updateHitbox();
				bg.screenCenter(XY);
				add(bg);
				var sun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgs/bobtwerked/annoyed_sun'));
				sun.setGraphicSize(Std.int(sun.width * 0.75));
				sun.scrollFactor.set(0.2,0.2);
				sun.updateHitbox();
				sun.screenCenter(XY);
				add(sun);
				var wBackground:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgs/bobtwerked/annoyed_back'));
				wBackground.setGraphicSize(Std.int(wBackground.width * 0.95));
				wBackground.scrollFactor.set(0.4,0.2);
				wBackground.updateHitbox();
				wBackground.screenCenter(XY);
				add(wBackground);
				witheredClouds = new FlxBackdrop(Paths.image('bgs/bobtwerked/annoyed_cloud'), X, 0, 0);
				witheredClouds.scrollFactor.set(0.2,0);
				witheredClouds.screenCenter(XY);
				witheredClouds.scale.set(0.5,0.5);
				witheredClouds.y -= 180;
				add(witheredClouds);
				var ground:FlxSprite = new FlxSprite(260, -375).loadGraphic(Paths.image('bgs/bobtwerked/annoyed_ground'));
				ground.scale.set(1.1,1.1);
				ground.scrollFactor.set(1,1);
				ground.updateHitbox();
				ground.screenCenter(X);
				add(ground);
			case 'walmart':
				var walmart = new FlxSprite().loadGraphic(Paths.image('bgs/wallmart'));
				walmart.antialiasing = false;
				walmart.setGraphicSize(Std.int(walmart.width * 1.2), Std.int(walmart.height * 1.2));
				walmart.updateHitbox();
				walmart.screenCenter(XY);
				add(walmart);
			case 'verymad': // trojan virus
				{
					defaultCamZoom = 0.9;
					curStage = 'verymad';
					var bg2:FlxSprite = new FlxSprite();
					bg2.frames = Paths.getSparrowAtlas('bgs/trojan_bg');
					bg2.scale.set(4, 4);
					bg2.animation.addByPrefix('idle', 'bg instance 1', 24, true);
					bg2.animation.play('idle');
					bg2.scrollFactor.set(0.05, 0.05);
					bg2.screenCenter();
					add(bg2);
					Estatic2 = new FlxSprite();
					Estatic2.frames = Paths.getSparrowAtlas('bgs/trojan_static');
					Estatic2.scale.set(4, 4);
					Estatic2.animation.addByPrefix('idle', 'static instance 1', 24, true);
					Estatic2.animation.play('idle');
					Estatic2.scrollFactor.set();
					Estatic2.screenCenter();
					add(Estatic2);
					var console:FlxSprite = new FlxSprite();
					console.frames = Paths.getSparrowAtlas('bgs/trojan_console');
					console.scale.set(4, 4);
					console.animation.addByPrefix('idle', 'ezgif.com-gif-maker (7)_gif instance 1', 24, true);
					console.animation.play('idle');
					console.scrollFactor.set(0.05, 0.05);
					console.screenCenter();
					console.alpha = 0.3;
					add(console);
					var popup:FlxSprite = new FlxSprite();
					popup.frames = Paths.getSparrowAtlas('bgs/atelo_popup_animated');
					popup.scale.set(4, 4);
					popup.animation.addByPrefix('idle', 'popups instance 1', 24, true);
					popup.animation.play('idle');
					popup.scrollFactor.set(0.05, 0.05);
					popup.screenCenter();
					add(popup);
					var bgs = new FlxSprite(-100, 10).loadGraphic(Paths.image('bgs/veryAngreRon_sky'));
					bgs.updateHitbox();
					bgs.screenCenter();
					bgs.scrollFactor.set(0.1, 0.1);
					add(bgs);

					cloudsa = new FlxSprite(-100, 10).loadGraphic(Paths.image('bgs/veryAngreRon_clouds'));
					cloudsa.updateHitbox();
					cloudsa.scale.x = 0.7;
					cloudsa.scale.y = 0.7;
					cloudsa.screenCenter();
					cloudsa.active = false;
					cloudsa.antialiasing = true;
					cloudsa.scrollFactor.set(0.2, 0.2);
					add(cloudsa);
					/*var glitchEffect = new FlxGlitchEffect(8,10,0.4,FlxGlitchDirection.HORIZONTAL);
						var glitchSprite = new FlxEffectSprite(bg, [glitchEffect]);
						add(glitchSprite); */

					var ground:FlxSprite = new FlxSprite(-537, -250).loadGraphic(Paths.image('bgs/veryAngreRon_ground'));
					ground.updateHitbox();
					ground.active = false;
					ground.antialiasing = true;
					add(ground);
				}
			case 'blr': {
				skyBLR = new FlxSprite().loadGraphic(Paths.image('bgs/madRonV1_sky'), false, 20);
				skyBLR.setGraphicSize(FlxG.width * 2, FlxG.height * 2); //this works every time. - Sword352
				skyBLR.updateHitbox();
				skyBLR.x = -500;
				skyBLR.y = 150;
				add(skyBLR);

				var groundBLR:BGSprite = new BGSprite('bgs/madRonV1_ground', -600, -100);
				groundBLR.setGraphicSize(FlxG.width * 2, FlxG.height * 2);
				groundBLR.updateHitbox();
				add(groundBLR);
			}
			case 'nothing':
			{
				wbg = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.height*3, FlxColor.WHITE);
				wbg.scale.set(5,5);
				wbg.updateHitbox();
				wbg.screenCenter(XY);
				wbg.scrollFactor.set();
				add(wbg);
				if (curSong.toLowerCase() == 'pretty-wacky')
				{
					addShader(FlxG.camera, "mosaic");
					addShader(camHUD, "mosaic");
					Shaders["mosaic"].shader.data.uBlocksize.value = [0];
					fx = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
					fx.setGraphicSize(Std.int(2560 * 0.75));
					fx.updateHitbox();
					fx.antialiasing = true;
					fx.screenCenter(XY);
					fx.scrollFactor.set(0, 0);
					fx.alpha = 0.75;		
					wbg.color = FlxColor.BLACK;
				}
				snowemitter = new FlxEmitter(9999, 0, 300);
				for (i in 0...150)
				{
					var p = new FlxParticle();
					var p2 = new FlxParticle();
					p.makeGraphic(12,12,FlxColor.GRAY);
					p2.makeGraphic(24,24,FlxColor.GRAY);
					
					snowemitter.add(p);
					snowemitter.add(p2);
				}
				snowemitter.width = FlxG.width*1.5;
				snowemitter.launchMode = SQUARE;
				snowemitter.velocity.set(-10, -240, 10, -320);
				snowemitter.lifespan.set(5);
				add(snowemitter);
				snowemitter.start(false, 0.05);
			}
			case 'awesome':
			{
				var bg:BGSprite = new BGSprite('bgs/newbgtest/awesomeron/bg');
				bg.scale.set(4,4);
				bg.screenCenter();
				bg.antialiasing = false;
				add(bg);
			}
			default:
			{
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-100,10).loadGraphic(Paths.image('updateron/bg/happyRon_sky'));
				bg.updateHitbox();
				bg.scale.x = 1.2;
				bg.scale.y = 1.2;
				bg.active = false;
				bg.antialiasing = true;
				bg.scrollFactor.set(1,1);
				add(bg);
				/*var glitchEffect = new FlxGlitchEffect(8,10,0.4,FlxGlitchDirection.HORIZONTAL);
				var glitchSprite = new FlxEffectSprite(bg, [glitchEffect]);
				add(glitchSprite);*/
				
				var ground:FlxSprite = new FlxSprite(-537, -290).loadGraphic(Paths.image('updateron/bg/happyRon_ground'));
				ground.updateHitbox();
				ground.active = false;
				ground.antialiasing = true;
				add(ground);
			}
		}
		//add(wastedGrp);
		wastedGrp.visible = false;
		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		leBlack = new FlxSprite(0, 0).makeGraphic(FlxG.width*3, FlxG.height*3, FlxColor.BLACK);
		leBlack.alpha = 0;
		add(leBlack);

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL

		add(dadGroup);
		add(boyfriendGroup);

		if(SONG.gfVersion == null || SONG.gfVersion.length < 1)
			SONG.gfVersion = 'gf';

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);

		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		boyfriendGroup.add(boyfriend);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}


		switch(curStage)
		{
			case 'hell':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				addBehindDad(evilTrail);
				if (SONG.song.toLowerCase() == 'bleeding')
					remove(evilTrail);
			case 'nothing':
				if (SONG.song.toLowerCase() == 'oh-my-god-hes-ballin')
				{
					//maybe bob will sing idk
					camGame.alpha = 0;
					cameraSpeed = 3;
					gf.visible = false;
					boyfriend.scrollFactor.set(0.2,0.2); //what
					boyfriend.alpha = 0;
					defaultCamZoom += 0.2;
				}
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = Json.parse(Assets.getText(file));
		}

		var doof:DialogueBoxRon = new DialogueBoxRon(dialogueJson, startCountdown);
		doof.scrollFactor.set();


		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("w95.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;
		
		baro = new FlxSprite().makeGraphic(150, FlxG.height*3, FlxColor.BLACK);
		bart = new FlxSprite().makeGraphic(150, FlxG.height*3, FlxColor.BLACK);
		add(baro);
		add(bart);
			
		baro.x = 0;
		baro.scrollFactor.set();
		baro.cameras = [camOverlay];
					
		bart.x = FlxG.width-150;
		bart.scrollFactor.set();
		bart.cameras = [camOverlay];
		
		baro.alpha = 0;
		bart.alpha = 0;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, cameraSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		if (SONG.stage == 'daveHouse' || SONG.stage == 'farm')
		{
			var songName = SONG.song;
			if (songName == 'Holy-Shit-Dave-Fnf')
				songName = 'Dave-Fnf';

			var swordEngine = FlxG.random.getObject(['Tristan', 'Dave', 'Bambi']);
			kadeEngineWatermark = new FlxText(4, 0, 0, '$songName - ${CoolUtil.difficulties[storyDifficulty]} | $swordEngine Engine (KE 1.2)', 16);
			kadeEngineWatermark.cameras = [camHUD];
			kadeEngineWatermark.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			kadeEngineWatermark.scrollFactor.set();
			add(kadeEngineWatermark);
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		if (SONG.stage == 'daveHouse' || SONG.stage == 'farm')
			scoreTxt.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		else
			scoreTxt.setFormat(Paths.font("w95.otf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		if(kadeEngineWatermark != null)
		{
			//can someone please fix that im busy   - Sword352
			if (ClientPrefs.downScroll)
				kadeEngineWatermark.y = FlxG.height * 0.9 + 45;
			else scoreTxt.y + 10;
		}

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		if (SONG.stage == 'daveHouse' || SONG.stage == 'farm')
			botplayTxt.setFormat(Paths.font("comic.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		else
			botplayTxt.setFormat(Paths.font("w95.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}
		boyfriend.y += 300;
		switch(SONG.player2)
		{
			case 'dave':
				gf.visible = false;
				boyfriend.y -= 120;
			case 'ron':
				boyfriend.x += 160;
				gf.x += 50;
			case 'ronthreedee':
				gf.visible = false;
			default:
				//stop fucking flying you dipshit
				boyfriend.y += 40;
		}

		if (curSong == 'Withered-Tweaked')
		{
			fxtwo = new FlxSprite().loadGraphic(Paths.image('bgs/bobtwerked/effect'));
			fxtwo.scale.set(0.55, 0.55);
			fxtwo.updateHitbox();
			fxtwo.antialiasing = true;
			fxtwo.screenCenter();
			fxtwo.alpha = 0.2;
			fxtwo.scrollFactor.set(0, 0);
			add(fxtwo);
			fxtwo.cameras = [camOverlay];

			dad.x += 500;
			dad.y += 50;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (curSong.toLowerCase() == 'holy-shit-dave-fnf')
			kadeEngineWatermark.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		addShader(FlxG.camera, "chromatic aberration");

		var daSong:String = Paths.formatToSongPath(curSong);
		if (!seenCutscene)
		{
			switch (daSong)
			{
				case "ron" | 'trojan-virus':
					schoolIntro(doof);
				case 'pretty-wacky':
					graadienter = new FlxSprite(-100,10).loadGraphic(Paths.image('bgs/ss_gradient'));
					graadienter.updateHitbox();
					graadienter.screenCenter();
					graadienter.active = false;
					graadienter.antialiasing = true;
					graadienter.scrollFactor.set(0.2, 0.2);
					add(graadienter);				
					graadienter.color = FlxColor.BLACK;
					add(fx);
					camHUD.alpha = 0.5;
					startCountdown();
				case 'triad':
					dad.x -= 375;
					boyfriend.scrollFactor.set(0.3,0.1);
					startCountdown();
				case 'ayo':
					camGame.color = 0xFFAAAAAA;
					fxtwo = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
					fxtwo.scale.set(1.5, 1.5);
					fxtwo.updateHitbox();
					fxtwo.antialiasing = true;
					fxtwo.screenCenter();
					fxtwo.alpha = 0.25;
					fxtwo.scrollFactor.set(0, 0);
					add(fxtwo);
					startCountdown();
				case 'bloodshed-legacy-redux':
					addShader(camGame, "fake CRT");
					startCountdown();
				case 'bloodshed':
					wastedGrp.visible = true;
					startCountdown();
				case 'haemorrhage':
					camHUD.alpha = 0;
					blackeffect = new FlxSprite().makeGraphic(FlxG.width*3, FlxG.height*3, FlxColor.BLACK);
					blackeffect.updateHitbox();
					blackeffect.antialiasing = true;
					blackeffect.screenCenter(XY);
					blackeffect.scrollFactor.set();
					blackeffect.alpha = 1;
					add(blackeffect);
					heart = new FlxSprite();
					heart.frames = Paths.getSparrowAtlas('characters/newcharstest/utHeart');
					heart.animation.addByPrefix('idle', 'idle', 24, false);
					heart.animation.play('idle');
					heart.scrollFactor.set(1,1);
					heart.screenCenter();
					heart.alpha = 0;
					heart.scale.set(0.75,0.75);
					add(heart);
					fx = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
					fx.setGraphicSize(Std.int(2560 * 1)); // i dont know why but this gets smol if i make it the same size as the kade ver
					fx.updateHitbox();
					fx.antialiasing = true;
					fx.screenCenter(XY);
					fx.scrollFactor.set(0, 0);
					fx.alpha = 0.5;
					add(fx);
					dad.x -= 60;
					boyfriend.x += 20;
					boyfriend.y += 30;
					startCountdown();
				default:
					startCountdown();
			}
			seenCutscene = false;
		}
		else
			startCountdown();

		if (daSong == 'bloodshed' || daSong == 'bleeding')
		{
			add(fx);
			add(Estatic);
			FlxTween.tween(Estatic, {"scale.x":0.8,"scale.y":0.8}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG});
			var chromeOffset = (ClientPrefs.rgbintense/350);
			Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
			Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
			Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1]; // add chrome option later // HI PAST ME I ADDED GGOLE CHROME OPTION
		}

		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		super.create();
		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;
		addShader(FlxG.camera, "8bitcolor");
		Shaders["8bitcolor"].shader.data.enablethisbitch.value = [0.];
		addShader(camHUD, "8bitcolor");
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	function schoolIntro(?dialogueBox:DialogueBoxRon):Void
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			// too slow
			{
				if (dialogueBox != null && dialogueBox.dialogueWorks)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdown();
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			return;
		}

		inCutscene = false;
		if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;


		if(startOnTime < 0) startOnTime = 0;

		if (startOnTime > 0) {
			clearNotesBefore(startOnTime);
			setSongTime(startOnTime - 350);
			return;
		}
		else if (skipCountdown)
		{
			setSongTime(0);
			return;
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
			{
				gf.dance();
			}
			if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
			{
				boyfriend.dance();
			}
			if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
			{
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			if(isPixelStage) {
				introAlts = introAssets.get('pixel');
				antialias = false;
			}

			// head bopping for bg characters on Mall

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
				case 1:
					countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					countdownReady.scrollFactor.set();
					countdownReady.updateHitbox();

					if (PlayState.isPixelStage)
						countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

					countdownReady.screenCenter();
					countdownReady.antialiasing = antialias;
					add(countdownReady);
					FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownReady);
							countdownReady.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
				case 2:
					countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					countdownSet.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

					countdownSet.screenCenter();
					countdownSet.antialiasing = antialias;
					add(countdownSet);
					FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownSet);
							countdownSet.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
				case 3:
					countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					countdownGo.scrollFactor.set();

					if (PlayState.isPixelStage)
						countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

					countdownGo.updateHitbox();

					countdownGo.screenCenter();
					countdownGo.antialiasing = antialias;
					add(countdownGo);
					FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							remove(countdownGo);
							countdownGo.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
				case 4:
			}

			if(ClientPrefs.opponentStrums)
			{
				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.35;
					}
				});
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			FlxTween.globalManager.forEach(function(i:FlxTween) {
				i.active = false;
			});
			Shaders["8bitcolor"].shader.data.enablethisbitch.value = [1.];
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		
		//better credits system
		if (OpenFlAssets.exists(Paths.txt(SONG.song.toLowerCase()  + "/credits")))
		{
			var creditsText:String = Assets.getText(Paths.txt(SONG.song.toLowerCase()  + "/credits"));
			var credits:FlxText = new FlxText(0, 0, 0, creditsText, 28);
			var creditsblack:FlxSprite = new FlxSprite().makeGraphic(600, FlxG.height*3, FlxColor.BLACK);
			var targety:Int = 0;
			
			credits.setFormat(Paths.font("w95.otf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK); 
			add(creditsblack);
			add(credits);
			credits.scrollFactor.set();
			credits.screenCenter();
			targety = Std.int(credits.y);
			credits.y = FlxG.camera.scroll.y+FlxG.height+40;
			
			creditsblack.scrollFactor.set();
			creditsblack.alpha = 0;
			creditsblack.screenCenter();
			
			creditsblack.cameras = [camHUD];
			credits.cameras = [camHUD];
			
			FlxTween.tween(creditsblack, {alpha: 0.5}, 0.5);
			FlxTween.tween(credits, {y: targety}, 0.5);
			
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxTween.tween(credits, {alpha: 0}, 3, {
					onComplete: function(tween:FlxTween)
					{
						credits.destroy();
					}
				});		
				FlxTween.tween(creditsblack, {alpha: 0}, 3, {
					onComplete: function(tween:FlxTween)
					{
						creditsblack.destroy();
					}
				});						
			});
		}
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		if (curSong != "Haemorrhage") add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				var skin = 'NOTE_assets';
				if (isPixelStage)
					skin = 'noteskins/PIXELNOTE_assets';

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, (gottaHitNote ? boyfriend.noteskin : dad.noteskin));
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				swagNote.ID = unspawnNotes.length;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, (gottaHitNote ? boyfriend.noteskin : dad.noteskin), true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.ID = unspawnNotes.length;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player, dad.curCharacter);
			babyArrow.downScroll = ClientPrefs.downScroll;
			babyArrow.texture = "noteskins/" + (player == 0 ? dad.noteskin : boyfriend.noteskin);
			babyArrow.reloadNote();
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;


			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{	
			Shaders["8bitcolor"].shader.data.enablethisbitch.value = [1.];
			FlxTween.globalManager.forEach(function(i:FlxTween) {
				i.active = false;
			});

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			Shaders["8bitcolor"].shader.data.enablethisbitch.value = [0.];
			FlxTween.globalManager.forEach(function(i:FlxTween) {
				i.active = true;
			});
			paused = false;

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var sinSpeed:Float = 0;
	var noteSinSpeed:Float = 0;
	override public function update(elapsed:Float)
	{		
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/

		var currentBeat:Float = (Conductor.songPosition / 1000)*(Conductor.bpm/60);

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
		camFollowPos.acceleration.set(((camFollow.x - camFollowPos.x) - (camFollowPos.velocity.x * 0.8)) / lerpVal, ((camFollow.y - camFollowPos.y) - (camFollowPos.velocity.y * 0.8)) / lerpVal);
		if(!inCutscene)
		{
			/* who fucking cares
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
			} else
			*/
			boyfriendIdleTime = 0;
		}

		if (curSong.toLowerCase() == 'bloodbath')
		{
			if (windowmove)
				setWindowPos(Math.round(24 * Math.sin(currentBeat * Math.PI) + 327), Math.round(24 * Math.sin(currentBeat * 3) + 160));
			if (cameramove)
			{
				camHUD.angle = 10 * Math.sin((currentBeat/6) * Math.PI);
				FlxG.camera.angle = 2 * Math.sin((currentBeat/6) * Math.PI);
			}
		}

		if (curSong.toLowerCase() == 'bleeding')
		{
			if (windowmove)
				setWindowPos(Math.round(24 * Math.sin(currentBeat * Math.PI) + 327), Math.round(24 * Math.sin(currentBeat * 3) + 160));
			if (cameramove)
			{
				camHUD.angle = 22 * Math.sin((currentBeat/4) * Math.PI);
				FlxG.camera.angle = 4 * Math.sin((currentBeat/4) * Math.PI);
			}
			if (intensecameramove)
			{
				camHUD.angle = 45 * Math.sin((currentBeat/2) * Math.PI);
				FlxG.camera.angle = 9 * Math.sin((currentBeat/2) * Math.PI);
			}
			if (WHATTHEFUCK)
			{
				camHUD.angle = 90 * Math.sin((currentBeat / 2) * Math.PI);
				FlxG.camera.angle = 18 * Math.sin((currentBeat / 2) * Math.PI);
			}
			if (WTFending)
			{
				camHUD.angle = 360 * Math.sin((currentBeat / 8) * Math.PI);
				FlxG.camera.angle = 27 * Math.sin((currentBeat / 2) * Math.PI);
			}
		}

		if (curSong.toLowerCase() == 'trojan-virus' && startedCountdown)
		{
			if (moveing)
			{
				for (i in 0...8)
					strumLineNotes.members[i].x = defaultStrumX[i]+ 32 * Math.sin((currentBeat + i*0.25) * Math.PI);
			} else
			{
				for (i in 0...8)
					strumLineNotes.members[i].x = defaultStrumX[i]+ 16 * Math.sin((currentBeat/4 + i*0.25) * Math.PI);
			}
		}

		if ((curSong == 'Atelophobia') || (curSong == 'Factory-Reset') || (curSong == 'Bloodshed') || (curSong == 'Bloodshed-b') || (curSong == 'Bloodshed-old') || (curSong == 'BLOODSHED-TWO') || (curSong == 'Factory-Reset-b') || (curSong == 'Atelophobia-b') || (curSong == 'Trojan-Virus') || (curSong == 'Trojan-Virus-b') || (curSong == 'File-Manipulation') || (curSong == 'File Manipulation-b')) 
		{

			if (2 - health <= 0)
			{
				Shaders["chromatic aberration"].shader.data.rOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.bOffset.value = [0.0];
			}
			else
			{
				if (ClientPrefs.rgbenable)
				{
					switch (curSong)
					{
						case 'File-Manipulation':
							var chromeOffset = (ClientPrefs.rgbintense/350);
							Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
							Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
							Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
							FlxG.watch.addQuick("chroma", chromeOffset);
						default:
							var sinus = 1;
							if (curStep >= 538)
								sinus = 2 * Std.int(Math.sin((curStep - 538) / 3));
							var chromeOffset = (FlxMath.lerp(2 - health, 2, 0.5)*ClientPrefs.rgbintense*sinus/350) / 10;
							Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
							Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
							Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
							FlxG.watch.addQuick("chroma", chromeOffset);
					}
				}
				else
				{
					Shaders["chromatic aberration"].shader.data.rOffset.value = [0.0];
					Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
					Shaders["chromatic aberration"].shader.data.bOffset.value = [0.0];
				}
			}
		}
		else
		{
			if ((curSong == 'Withered-Tweaked') && (curStep >= 1152))
			{
				var chromeOffset = (FlxMath.lerp(2 - health, 2, 0.5)*ClientPrefs.rgbintense/350);
				Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
				Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
				Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
			}
		}

		super.update(elapsed);
		camHUD.x = FlxMath.lerp(camHUD.x, 0, 0.2 / (60 / ClientPrefs.framerate));
		camHUD.y = FlxMath.lerp(camHUD.y, 0, 0.2 / (60 / ClientPrefs.framerate));
		if (bar1.y <= -520) bar1.visible = false;
		if (bar2.y >= 720) bar2.visible = false;
		if (haemorrhageCallback != null) haemorrhageCallback();
		scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		if(ratingName != '?')
			scoreTxt.text += ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			Shaders["8bitcolor"].shader.data.enablethisbitch.value = [1.];
			FlxTween.globalManager.forEach(function(i:FlxTween) {
				i.active = false;
			});
			// 1 / 1000 chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				cancelMusicFadeTween();
				MusicBeatState.switchState(new GitarooPause());
			}
			else {*/
			if(FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new substates.PauseSubState());
			//}

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
			
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			Shaders["8bitcolor"].shader.data.enablethisbitch.value = [1.];
			FlxTween.globalManager.forEach(function(i:FlxTween) {
				i.active = false;
			});
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					opponentNoteHit(daNote);

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		//#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		//#end

		//camera movement cuz the current one is quite fucky
		var section = (SONG.notes[Math.floor(curStep / 16)] != null ? SONG.notes[Math.floor(curStep / 16)].mustHitSection : null);
		if (!isCameraOnForcedPos)
		{
			if (section != null && section) {
				if (curSong == 'Triad')	defaultCamZoom = 0.7;
				camFollow.set(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y-75);
				camFollow.x -= boyfriend.cameraPosition[0] + boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
				if (boyfriend.animation.curAnim.name == "singLEFT") camFollow.x -= 30;
				if (boyfriend.animation.curAnim.name == "singRIGHT") camFollow.x += 30;
					
				if (boyfriend.animation.curAnim.name == "singUP") camFollow.y -= 30;
				if (boyfriend.animation.curAnim.name == "singDOWN") camFollow.y += 30;
			}
			else {
				if (curSong == 'Triad')	defaultCamZoom = 0.9;
				camFollow.set(dad.getMidpoint().x, dad.getMidpoint().y-75);
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
				if (dad.animation.curAnim.name == "singLEFT") camFollow.x -= 30;
				if (dad.animation.curAnim.name == "singRIGHT") camFollow.x += 30;
				if (dad.animation.curAnim.name == "singUP") camFollow.y -= 50;
				if (dad.animation.curAnim.name == "singDOWN") camFollow.y += 50;
			}
		}
		//if ((SONG.song.toLowerCase() == 'oh-my-god-hes-ballin') && (boyfriend.animation.curAnim.curFrame == 0))
		//{
		//	FlxTween.globalManager.cancelTweensOf(FlxG.camera);
		//	if (boyfriend.animation.curAnim.name == "singLEFT") FlxG.camera.angle = -5;
		//	if (boyfriend.animation.curAnim.name == "singRIGHT") FlxG.camera.angle = 5;
		//	FlxTween.tween(FlxG.camera, {angle: 0}, 0.5, {ease: FlxEase.circOut});
		//}
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			Shaders["chromatic aberration"].shader.data.rOffset.value = [0.0];
			Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
			Shaders["chromatic aberration"].shader.data.bOffset.value = [0.0];

			boyfriend.stunned = true;
			deathCounter++;

			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			persistentUpdate = false;
			persistentDraw = false;
			openSubState(new substates.GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

			// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
			isDead = true;
			return true;
			
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
						}
				}
				reloadHealthBarColors();
				for (i in 0...unspawnNotes.length)
				{
					unspawnNotes[i].texture = "noteskins/" + (unspawnNotes[i].mustPress ? boyfriend.noteskin : dad.noteskin);
				}
				for (n in notes.members)
				{
					n.texture = "noteskins/" + (n.mustPress ? boyfriend.noteskin : dad.noteskin);
				}
				for (i in strumLineNotes.members)
					i.texture = "noteskins/" + (i.player == 0 ? dad.noteskin : boyfriend.noteskin);

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
			case 'Change Bar Size':
				var val1 = Std.parseFloat(value1);
				var val2 = Std.parseFloat(value2);
				FlxTween.tween(bar1, {y: -560 + (val1 * 10)}, val2, {ease: FlxEase.quintOut});
				FlxTween.tween(bar2, {y: 720 + -(val1 * 10)}, val2, {ease: FlxEase.quintOut});
		}
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			return;
		}
	}
var cameraTwn:FlxTween;
	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		if (SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		if (chartingMode)
		{
			openChartEditor();
			return;
		}

		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn)
					CustomFadeTransition.nextCamera = null;
				MusicBeatState.switchState(new menus.StoryMenuState());

				// if ()
				if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
					menus.StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
					}

					FlxG.save.data.weekCompleted = menus.StoryMenuState.weekCompleted;
					FlxG.save.flush();
				}
				changedDifficulty = false;
			}
			else
			{
				var difficulty:String = CoolUtil.getDifficultyFilePath();

				trace('LOADING NEXT SONG');
				trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);


				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				prevCamFollow = camFollow;
				prevCamFollowPos = camFollowPos;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				cancelMusicFadeTween();
				if (SONG.song.toLowerCase() == 'bloodshed')
				{
					video.playMP4(Paths.video('bloodshed'), new PlayState(), false, false, false);
				}
				else
				{
					menus.LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			cancelMusicFadeTween();
			if(FlxTransitionableState.skipNextTransIn) {
				CustomFadeTransition.nextCamera = null;
			}
			MusicBeatState.switchState(new menus.FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			changedDifficulty = false;
		}
		transitioning = true;
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff);
		var ratingNum:Int = 0;

		if (SCREWYOU)
		{
			switch(daRating.name)
			{
				// i should nerf unforgiving input its too hard
				// skill issue
				case 'shit':
					health -= 0.15;
				case 'bad':
					health -= 0.045;
				case 'good' | 'sick':
					health += 0.05;
			}
		}

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];


		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
		//trace('pressed: ' + controlArray);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			// lol
			health -= 0.2 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		//shakes the fuck out of your screen and hud -ekical
		// now it drains your health because fuck you -ekical
		if ((dad.curCharacter == 'hellron') || (dad.curCharacter == 'devilron'))
		{
			var multiplier:Float = 1;
			if (health >= 1)
				multiplier = 1;
			else
				multiplier = multiplier + ((1 - health));

			camHUD.shake(0.0055 * multiplier / 4, 0.15);
			if (curSong == 'Withered-Tweaked')
			{
				// he doesn't give a fuck in withered
				if (health > 0.03)
					health -= 0.0135;
			}
			else
			{
				FlxG.camera.shake(0.025 * multiplier / 4, 0.1);
				if (health > 0.06)
					health -= 0.04;
				else
					health = 0.05;
			}
		}
		if (dad.curCharacter == 'ron-usb' || dad.curCharacter == 'ateloron')
		{
			if (health > 0.03)
				health -= 0.014;
			else
				health = 0.02;
		}
		// NO MERE MORTAL CAN HANDLE THE POWERFUL DRIP RON
		if (dad.curCharacter == 'hellron-drippin')
		{
			var multiplier:Float = 1;
			if (health >= 1)
				multiplier = 1;
			else
				multiplier = multiplier + ((1 - health));
			FlxG.camera.shake(0.025 * multiplier / 4, 0.1);
			camHUD.shake(0.0055 * multiplier / 4, 0.15);
			if (health > 0.03)
				health -= 0.007;
			else
				health = 0.02;
			Lib.application.window.move(Lib.application.window.x + FlxG.random.int(-4, 4), Lib.application.window.y + FlxG.random.int(-4, 4));
		}

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			if (!SCREWYOU)
			{
				// i just dont like how psych engine's health mechanics work
				if (note.isSustainNote)
					health += note.hitHealth * healthGain / 2;
				else
					health += note.hitHealth * healthGain * 4;
			}

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}
	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var daNoteMove:Bool =false;
	var daNoteMoveH:Bool =false;
	var daNoteMoveH2:Bool =false;
	var daNoteMoveH3:Bool =false;
	var daNoteMoveH4:Bool =false;
	var daNoteMoveH5:Bool =false;

	var lastStepHit:Int = -1;
	var undertaleStep:Int = 0;
	var undertaleGotHit:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		if (curSong == 'Ayo')
		{
			switch (curStep)
			{
				case 892:
					bruh();
				case 1148:
					FlxTween.tween(FlxG.camera, {zoom: 1.5}, 0.4, {ease: FlxEase.expoOut,});
			}
		}
		
		if (curSong == 'Triad')
		{
			//boyfriend.scale.set(defaultCamZoom+1.3,defaultCamZoom+1.3);
			if ((curStep >= 256) && (curStep <= 512))
			{
				var chromeOffset = ClientPrefs.rgbintense/350;
				if (curStep % 8 == 0)
				{
					for (i in 4...8)
					{ 
						var member = strumLineNotes.members[i];
						FlxTween.globalManager.completeTweensOf(member);
						if(ClientPrefs.downScroll)
							member.y -= 10;
						else
							member.y += 10;
						FlxTween.tween(member, {y: defaultStrumY}, 0.3, {ease: FlxEase.backOut});
					}
				}
			}
			switch (curStep)
			{
				case 256:
					wastedGrp.visible = true;
					FlxG.camera.flash(FlxColor.WHITE, 1);
			}
		}
		
		if (curSong == 'blizzard')
		{
			healthBarBG.alpha = 0;
			healthBar.alpha = 0;
			iconP1.visible = true;
			iconP2.visible = true;
			if (!shutTheFuckUp)
				iconP2.alpha = (2 - (health) - 0.25) / 2 + 0.2;
			iconP1.alpha = (health - 0.25) / 2 + 0.2;
			if (!shutTheFuckUp)
				Estatic.alpha = (((2 - health) / 3) + 0.2);
			if ((curStep >= 256))
			{
				snowemitter.x = FlxG.camera.scroll.x;
				snowemitter.y = FlxG.camera.scroll.y - 40;
			}
			else
				snowemitter.x = 9999;
			switch (curStep)
			{
				case 240:
					defaultCamZoom += 0.1;
				case 256:
					FlxG.camera.flash(FlxColor.WHITE, 0.5);
					blackeffect.alpha = 0;
					bgbleffect.alpha = 0;
					fx.alpha = 0;
					defaultCamZoom += 0.1;
			}
			if ((curStep >= 256) && (curStep <= 512))
			{
				FlxG.camera.shake(0.01, 0.1);
				camHUD.shake(0.001, 0.15);
				if (curStep == 256)
				{
					FlxTween.angle(satan, 0, 359.99, 1.5, {
						ease: FlxEase.quadIn,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.angle(satan, 0, 359.99, 0.75, {type: cast 2});
						}
					});
				}
				if (health > 0.2)
					health -= 0.05;
			} else
			{
				if ((curStep == 1297) || (curStep == 614))
					FlxTween.cancelTweensOf(satan);
				if (satan.angle != 0)
					FlxTween.angle(satan, satan.angle, 359.99, 0.5, {ease: FlxEase.quadIn});
				if (fx.alpha > 0.3)
					fx.alpha -= 0.05;
			}

			if (curStep == 768)
			{
				FlxTween.tween(leBlack, {alpha: 1}, 1);
				FlxTween.tween(dad, {alpha: 0}, 1);
				snowemitter.emitting = false;
				shutTheFuckUp = true;
				FlxTween.tween(iconP2, {alpha: 0}, 1);
				FlxTween.tween(fx, {alpha: 0}, 1);
			}
		}

		if 	(curSong == 'pretty-wacky')
		{	
			switch (curStep)
			{
				case 250:
					defaultCamZoom += 0.2;
				case 256:
					defaultCamZoom -= 0.1;
					camHUD.alpha = 1;
					graadienter.color = FlxColor.WHITE;
					wbg.color = FlxColor.WHITE;
					FlxG.camera.flash(FlxColor.WHITE, 1);
					//fx.alpha = 0;
				case 752:
					defaultCamZoom += 0.1;
				case 761: Shaders["mosaic"].shader.data.uBlocksize.value = [1];
				case 762: Shaders["mosaic"].shader.data.uBlocksize.value = [2];
				case 763: Shaders["mosaic"].shader.data.uBlocksize.value = [3];
				case 764: Shaders["mosaic"].shader.data.uBlocksize.value = [6];
				case 765: Shaders["mosaic"].shader.data.uBlocksize.value = [9];
				case 766: Shaders["mosaic"].shader.data.uBlocksize.value = [13];
				case 767: Shaders["mosaic"].shader.data.uBlocksize.value = [20];
				case 768:
					Shaders["mosaic"].shader.data.uBlocksize.value = [0];
					cameraSpeed = 3;
					graadienter.color = FlxColor.fromRGB(224,224,224);
					wbg.color = FlxColor.fromRGB(224,224,224);
					var chromeOffset = (ClientPrefs.rgbintense/350);
					Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
					Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
					Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
					//isPixelStage = true;
					baro.alpha = 1;
					bart.alpha = 1;
					defaultCamZoom -= 0.1;
					FlxG.camera.flash(FlxColor.fromRGB(224, 224, 224), 3);
					triggerEventNote('Change Character', 'dad', 'doyneSprited');
					triggerEventNote('Change Character', 'bf', 'bfSprited');
					dad.y -= 120;
					dad.x -= 60;
					var bruh:FlxSprite = new FlxSprite();
					bruh.loadGraphic(Paths.image('bgs/scanlines'));
					bruh.antialiasing = false;
					bruh.active = false;
					bruh.scrollFactor.set();
					bruh.screenCenter();
					bruh.scale.set(4,4);
					add(bruh);
					FlxTween.tween(bruh, {alpha: 0.5}, 0.5, {ease: FlxEase.circInOut, type: PINGPONG});
					FlxTween.cancelTweensOf(camFollowPos);
					FlxTween.tween(camFollowPos, {x: camFollow.x, y: camFollow.y}, 0.01);
			}
			if (curStep >= 256)
			{
				snowemitter.x = FlxG.camera.scroll.x;
				snowemitter.y = FlxG.camera.scroll.y+FlxG.height+40;
				if ((curStep <= 512) && (curStep % 4 == 0))
				{
					if (curStep % 8 == 0)
					{
						camGame.angle = -2;
						camHUD.angle = -4;
					}
					else
					{
						camGame.angle = 2;
						camHUD.angle = 4;
					}
					FlxTween.tween(camGame, {angle: 0}, 0.4, {ease: FlxEase.circOut});
					FlxTween.tween(camHUD, {angle: 0}, 0.4, {ease: FlxEase.circOut});
				}
			}
			else
			{
				if (snowemitter != null) snowemitter.x = 9999;
			}
		}
		
		if (curSong == 'oh-my-god-hes-ballin') 
		{
			switch (curStep) {
				case 0:
					dad.playAnim('hey');
				case 1:
					camGame.alpha = 1;
				case 12:
					dad.playAnim('bye');
				case 16:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					addShader(camGame, "bloom");
			}
		}
		
		if (curSong == 'Haemorrhage')
		{
			healthBarBG.alpha = 0;
			healthBar.alpha = 0;
			iconP1.visible = true;
			iconP2.visible = true;
			iconP2.alpha = 0;
			iconP1.alpha = 0;
			switch (curStep) {
				case 0:
					camHUD.alpha = 0;
				case 1:
					heart.x = boyfriend.x+boyfriend.width/2;
					heart.y = boyfriend.y+boyfriend.height/2;
					heart.alpha = 0;
					heart.antialiasing = false;
					FlxTween.tween(blackeffect, {alpha: 0}, 10);
				case 128:
					defaultCamZoom += 0.1;
				case 240:
					defaultCamZoom += 0.1;
				case 248 | 250:
					blackeffect.alpha = 1;
					heart.alpha = 1;
				case 249| 251:
					blackeffect.alpha = 0;
					heart.alpha = 0;
				case 252:
					heart.alpha = 1;
					blackeffect.alpha = 1;
					FlxTween.tween(heart, { x: FlxG.camera.scroll.x+((FlxG.width / 2) - (heart.width / 2)), y: FlxG.camera.scroll.y+((FlxG.height / 1.5) - (heart.height / 2))}, 0.25, {ease: FlxEase.quartOut});
				case 256:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					triggerEventNote('Change Character', 'dad', 'utRon');
					triggerEventNote('Change Character', 'bf', 'heartlo');
					FlxG.camera.follow(null);// using this instead of scroll factor for physics and collision
					FlxG.camera.scroll.set();
					remove(dad);
					remove(boyfriend);
					add(dad);
					add(boyfriend);
					dad.scale.set(5,5);
					boyfriend.scale.set(0.75,0.75);
					boyfriend.screenCenter();
					dad.screenCenter();
					boyfriend.y = heart.y-180;
					dad.x += 92;
					heart.alpha = 0;
					var bg:BGSprite = new BGSprite('bgs/newbgtest/undertale/buttons', 0, 0, 1, 1);
					bg.antialiasing = false;
					bg.screenCenter();
					bg.scale.set(0.66,0.66);
					add(bg);	
					for (i in unspawnNotes) {
						i.cameras = [camGame];
					}	
					for (i in strumLineNotes.members) {
						if (i.player == 0) { i.cameras = [camGame];
							remove(i);
							add(i);
							i.x += 290;
							i.alpha = 0;
						}
					}
					haemorrhageCallback = function() {
						if (FlxG.keys.pressed.UP) boyfriend.y -= 15;
						if (FlxG.keys.pressed.DOWN) boyfriend.y += 15;
						if (FlxG.keys.pressed.LEFT) boyfriend.x -= 15;
						if (FlxG.keys.pressed.RIGHT) boyfriend.x += 15;
						if (curStep > undertaleStep + 20) {undertaleGotHit = false; boyfriend.alpha = 1;}
						else boyfriend.alpha = 0.3;
						FlxG.overlap(notes, boyfriend, function(note, bf){
							if (!undertaleGotHit) {
								FlxG.sound.play(Paths.sound("damage"));
								health -= 0.2;
								undertaleStep = curStep;
								undertaleGotHit = true;
							}
						});
					}
					remove(notes);
					notes = new FlxTypedGroup<Note>();
					add(notes);
				case 480:
					var ogY = strumLineNotes.members[1].y;
					for (i in strumLineNotes.members) {
						if (i.player == 0) { 
							i.y = 0;
							FlxTween.tween(i, {y: ogY, alpha:1}, 3, {ease: FlxEase.quintOut});
						}
					}
			}
		}

		if (curSong == 'Bloodshed') 
		{
			healthBarBG.alpha = 0;
			healthBar.alpha = 0;
			iconP1.visible = true;
			iconP2.visible = true;
			iconP2.alpha = (2-(health)-0.25)/2+0.2;
			iconP1.alpha = (health-0.25)/2+0.2;
			if (curStep >= 128)
				Estatic.alpha = (((2-health)/3)+0.2);
			else
				Estatic.alpha = 0;
			switch (curStep) {
				case 128:
					FlxG.camera.flash(FlxColor.WHITE, 1);
					hellbg.alpha = 1;
					//triggerEventNote('Change Character', 'dad', 'hellron');
					//triggerEventNote('Change Character', 'bf', 'BFrun');
					//triggerEventNote('Change Character', 'gf', 'GFrun');
					triggerEventNote('Change Scroll Speed', '1.3', '1');
					witheredRa.color = 0xFF660000;
					wastedGrp.forEachAlive(function(spr:FlxBackdrop) {
						spr.alpha = 0;
					});	
					bloodshedGrp.visible = true;
					ronGrp.visible = false;
					addShader(camGame, "chromatic aberration");
					addShader(camGame, "bloom");
					cameraSpeed = 1.5;
				case 256:
					cameraSpeed = 3;
					for (i in 0...4)
					{ 
						var member = strumLineNotes.members[i];
						FlxTween.tween(strumLineNotes.members[i], { x: defaultStrumX[i]+ 1250 ,angle: 360}, 1, {ease: FlxEase.quintInOut});
						defaultStrumX[i] += 1250;
					}
					for (i in 4...8)
					{ 
						var member = strumLineNotes.members[i];
						FlxTween.tween(strumLineNotes.members[i], { x: defaultStrumX[i] - 275,angle: 360}, 1, {ease: FlxEase.backOut});
						defaultStrumX[i] -= 275;
					}
				case 320:
					FlxTween.tween(satan, {y: satan.y - 700, angle: 359.99}, 3, {ease: FlxEase.circInOut});
				case 368:
					defaultCamZoom = 1;
				case 376:
					FlxG.camera.shake(0.03, 1);
				case 384:
					defaultCamZoom = 0.6;
					cameraSpeed = 3;
					FlxTween.color(witheredRa, 1, 0xFF660000, 0xFF000000);
					FlxG.sound.play(Paths.sound('hellexplode'), 0.7);
					FlxG.camera.flash(FlxColor.WHITE, 1);
					camFollow.y -= 5600;
					boyfriend.y -= 5600;
					dad.y -= 5600;
					FlxTween.tween(firebg, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					FlxTween.tween(boyfriend, {x: boyfriend.x + 300}, 0.5, {ease: FlxEase.circOut});
					FlxTween.tween(dad, {x: dad.x - 300}, 0.5, {ease: FlxEase.circOut});
					FlxTween.tween(dad, {y: dad.y + 5600}, 23, {ease: FlxEase.quartIn});
					FlxTween.tween(boyfriend, {y: boyfriend.y + 5600}, 23, {ease: FlxEase.quartIn});
					FlxTween.tween(boyfriend, {angle: 359.99 * 4}, 23);
					FlxTween.angle(satan, 0, 359.99, 0.75, { type: FlxTweenType.LOOPING } );
					wbg.alpha = 1;
				case 512:
					defaultCamZoom = 0.75;
					cameraSpeed = 2.5;
				case 576:
					FlxTween.tween(dad, {y: dad.y + 5600}, 5.4, {ease: FlxEase.quartIn});
					FlxTween.tween(boyfriend, {y: boyfriend.y + 5600}, 5.4, {ease: FlxEase.quartIn});
					defaultCamZoom = 0.85;
					cameraSpeed = 2;
				case 632:
					defaultCamZoom = 1.1;
				case 640:
					cameraSpeed = 1.5;
					defaultCamZoom = 0.7;
					FlxG.sound.play(Paths.sound('hellexplode'), 0.7);
					FlxG.camera.flash(FlxColor.WHITE, 1);			
			}
		}

		if (curSong == 'bloodbath') // hi it me chromasen and im proud of this code because i made it:)
		{
			SCREWYOU = true;
			botplayTxt.visible = true;
			if (!ClientPrefs.gameplaySettings['botplay'])
			{
				botplayTxt.text = "UNFORGIVING INPUT ENABLED!";
				botplayTxt.screenCenter(X);
				botplayTxt.y = scoreTxt.y - 100;
			}
            healthBarBG.alpha = 0;
            healthBar.alpha = 0;
            scoreTxt.alpha = 0;
            iconP1.visible = true;
            iconP2.visible = true;
            iconP2.alpha = (2-(health)-0.25)/2+0.2;
            iconP1.alpha = (health-0.25)/2+0.2;
            switch (curStep)
            {
                case 1: defaultCamZoom = 0.9;
                case 253: defaultCamZoom = 1.2;
                case 409: defaultCamZoom = 1.1;
                case 413: defaultCamZoom = 0.95;    
                case 513: defaultCamZoom = 0.85;
                case 518: defaultCamZoom = 0.9;
                case 528: defaultCamZoom = 0.95;
                case 535: defaultCamZoom = 1;
                case 540: defaultCamZoom = 0.9;
                case 575: defaultCamZoom = 1.1;
                case 582: defaultCamZoom = 1.05;
                case 592: defaultCamZoom = 0.98;
                case 599: defaultCamZoom = 1.15;
                case 639: defaultCamZoom = 0.85;
                case 768:
                     defaultCamZoom = 1.1;
                     FlxTween.tween(firebg, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
			case 1039: defaultCamZoom = 0.85; // shit ton of code because yeah
		}
		if ((curStep >= 254) && (curStep <= 518))
		{
			if (fx.alpha < 0.6)
				fx.alpha += 0.05;            
			if (curStep == 256)
			{
				FlxTween.angle(satan, 0, 359.99, 1.5, { 
					ease: FlxEase.quadIn, 
					onComplete: function(twn:FlxTween) 
					{
						FlxTween.angle(satan, 0, 359.99, 0.75, { type: FlxTweenType.LOOPING } );
					}} 
				);
			}
			FlxG.camera.shake(0.01, 0.1);
			camHUD.shake(0.001, 0.15);
		}
		else if ((curStep >= 768) && (curStep <= 1040))
			{
				if (fx.alpha > 0)
					fx.alpha -= 0.05;
				if (curStep == 768)
				{
					FlxTween.angle(satan, 0, 359.99, 0.75, { 
						ease: FlxEase.quadIn, 
						onComplete: function(twn:FlxTween) 
						{
							FlxTween.angle(satan, 0, 359.99, 0.35, { type: FlxTweenType.LOOPING } );
						}} 
					);
				}
				FlxG.camera.shake(0.015, 0.1);
				camHUD.shake(0.0015, 0.15);
			}
		else
			{
				if ((curStep == 519) || (curStep == 1041))
					FlxTween.cancelTweensOf(satan);
				if (satan.angle != 0)
					FlxTween.angle(satan, satan.angle, 359.99, 0.5, {ease: FlxEase.quadIn});
				if (fx.alpha > 0.3)
					fx.alpha -= 0.05;
			}
			Estatic.alpha = (((2-health)/3)+0.2);
		}

		if (curSong == 'Bleeding') {
			healthBarBG.alpha = 0;
			healthBar.alpha = 0;
			iconP1.visible = true;
			iconP2.visible = true;
			iconP2.alpha = (2-(health)-0.25)/2+0.2;
			iconP1.alpha = (health-0.25)/2+0.2;
			switch (curStep)
			{
				case 256:
					var xx = dad.x;
					var yy = dad.y;
					triggerEventNote('Change Character', 'dad', 'hellron-drippin');
					dad.x = xx-80;
					dad.y = yy-200;
					defaultCamZoom += 0.1;
					SCREWYOU = true;
					botplayTxt.visible = true;
					botplayTxt.y = scoreTxt.y - 100;
					if (!ClientPrefs.gameplaySettings['botplay'])
					{
						botplayTxt.text = "UNFORGIVING INPUT ENABLED!";
						botplayTxt.screenCenter(X);
					}
				case 384:
					defaultCamZoom += 0.15;
				case 512:
					SCREWYOU = false;
					if (!ClientPrefs.gameplaySettings['botplay'])
						botplayTxt.visible = false;
					var xx = dad.x;
					var yy = dad.y;
					triggerEventNote('Change Character', 'dad', 'hellron');
					dad.x = xx+80;
					dad.y = yy+200;
					defaultCamZoom -= 0.25;
				case 664:
					defaultCamZoom += 0.3;
				case 672:
					defaultCamZoom -= 0.3;
				case 768:
					SCREWYOU = true;
					botplayTxt.visible = true;
					if (!ClientPrefs.gameplaySettings['botplay'])
						botplayTxt.text = "UNFORGIVING INPUT ENABLED!";
					var xx = dad.x;
					var yy = dad.y;
					triggerEventNote('Change Character', 'dad', 'hellron-drippin');
					dad.x = xx-80;
					dad.y = yy-200;
					FlxTween.tween(firebg, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
					defaultCamZoom += 0.1;
				case 832:
					defaultCamZoom += 0.1;
				case 896:
					defaultCamZoom += 0.1;
				case 1024:
					defaultCamZoom += 0.1;
				case 1040:
					defaultCamZoom -= 0.2;
				case 1168:
					defaultCamZoom -= 0.1;
				case 1296:
					FlxTween.tween(firebg, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
					defaultCamZoom -= 0.1;
					SCREWYOU = false;
					if (!ClientPrefs.gameplaySettings['botplay'])
						botplayTxt.visible = false;
			}
			if ((curStep >= 256) && (curStep <= 512))
			{
				if (fx.alpha < 0.6)
					fx.alpha += 0.05;			
				if (curStep == 256)
				{
					FlxTween.angle(satan, 0, 359.99, 1.5, { 
						ease: FlxEase.quadIn, 
						onComplete: function(twn:FlxTween) 
						{
							FlxTween.angle(satan, 0, 359.99, 0.75, { type: FlxTweenType.LOOPING } );
						}} 
					);
				}
				FlxG.camera.shake(0.01, 0.1);
				camHUD.shake(0.001, 0.15);
			}
			else if ((curStep >= 768) && (curStep <= 1296))
			{
				if (fx.alpha > 0)
					fx.alpha -= 0.05;
				if (curStep == 768)
				{
					FlxTween.angle(satan, 0, 359.99, 0.75, { 
						ease: FlxEase.quadIn, 
						onComplete: function(twn:FlxTween) 
						{
							FlxTween.angle(satan, 0, 359.99, 0.35, { type: FlxTweenType.LOOPING } );
						}} 
					);
				}
				FlxG.camera.shake(0.015, 0.1);
				camHUD.shake(0.0015, 0.15);
			}
			else
			{
				if ((curStep == 1297) || (curStep == 614))
					FlxTween.cancelTweensOf(satan);
				if (satan.angle != 0)
					FlxTween.angle(satan, satan.angle, 359.99, 0.5, {ease: FlxEase.quadIn});
				if (fx.alpha > 0.3)
					fx.alpha -= 0.05;
			}
			Estatic.alpha = (((2-health)/3)+0.2);
		}

		/*switch(SONG.song.toLowerCase())
		{
			case 'bloodshed': 
				if(curStep == 129)
				{
					funnywindowsmall = true;
				}
				if(curStep == 258)
				{
					daNoteMoveH2 = true;
					funnywindowsmall = false;
					funnywindow = true;
				}
				if(curStep == 389)
				{
					daNoteMoveH2 = false;
					daNoteMoveH3 = true;
				}
				if(curStep == 518)
				{
					daNoteMoveH3 = false;
					daNoteMoveH4 = true;
					funnywindow = false;
					funnywindowsmall = true;
				}
				if(curStep == 776)
				{
					funnywindowsmall = false;
					funnywindow = true;
					daNoteMoveH4 = false;
					daNoteMoveH5 = true;
				}
				if(curStep >= 1053)
				{
					NOMOREFUNNY = true;
					funnywindow = false;
					funnywindowsmall = false;
					if(PlayState.instance.camHUD.alpha > 0 ){
						PlayState.instance.camHUD.alpha  -= 0.05;
					}
				}
		}*/

		if (curSong == 'Holy-Shit-Dave-Fnf')
		{
			switch (curStep)
			{
				case 352:
					defaultCamZoom = 1;
				case 368:
					defaultCamZoom = 1.2;
				case 384:
					FlxG.camera.flash(FlxColor.WHITE, 0.2);
				case 400:
					defaultCamZoom = 1.5;
				case 448:
					defaultCamZoom = 0.9;
			}

			if (curStep >= 384 && curStep < 400)
				dad.playAnim('um');
			else if (curStep >= 400 && curStep < 448)
				dad.playAnim('err');
		}

		if (curSong.toLowerCase() == 'bloodshed-legacy-redux')
		{
				switch(curStep){
					case 228:
						FlxTween.tween(skyBLR, {angle : 360}, 0.5, {type: LOOPING});
					case 544:
						FlxTween.cancelTweensOf(skyBLR);
					case 800:
						FlxTween.tween(skyBLR, {angle : 360}, 0.5, {type: LOOPING});
					case 1312:
						FlxTween.cancelTweensOf(skyBLR);
				}
		}
		
		if (curSong.toLowerCase() == 'ayo')
		{
			if (curStep % 8 == 0)
			{
				FlxTween.globalManager.completeTweensOf(graadienter);
				graadienter.y += 40;
				FlxTween.tween(graadienter, {y: graadienter.y - 40}, 0.4, {ease: FlxEase.backOut});
			}
			switch(curStep){
				case 128:
					defaultCamZoom = 0.8;
					camGame.color = FlxColor.WHITE;
					graadienter.alpha = 0.5;
					graadienter.visible = true;
					fxtwo.visible = false;
					bgLol.visible = false;
					triggerEventNote('Change Bars Size', '12', '1');
					FlxG.camera.flash(FlxColor.WHITE, 1);
			}
		}

		if (curSong == 'Trojan-Virus')
		{
			switch (curStep)
			{
				case 384:
					FlxTween.tween(cloudsa, {alpha: 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(witheredRa, {alpha: 0}, 1, {ease: FlxEase.quadIn});
					FlxTween.tween(bgLol, {alpha: 0}, 1, {ease: FlxEase.quadIn});
					camHUD.shake(0.002);
					defaultCamZoom += 0.2;
				case 640:
					defaultCamZoom -= 0.2;
				case 1584:
					var budjet = new FlxSprite(0, 0);
					budjet.loadGraphic(Paths.image('ron/budjet'));
					budjet.screenCenter();
					budjet.cameras = [camHUD];
					add(budjet);
					dad.visible = false;
					defaultCamZoom = 1;
					FlxTween.tween(FlxG.camera, {zoom: 1}, 0.4, {ease: FlxEase.expoOut,});
			}
			if ((curStep >= 384) && (curStep <= 640))
				FlxG.camera.shake(0.00625, 0.1);

			camHUD.shake(0.00125, 0.15);
		}

		if (curSong == 'Withered-Tweaked')
		{
			witheredClouds.x += 2;
			switch (curStep)
			{
				case 16 | 32 | 48 | 64 | 80 | 96 | 112:
					FlxG.camera.zoom += 0.02;
					defaultCamZoom -= 0.02;
				case 127:
					defaultCamZoom = 0.75;
				case 128 | 260 | 320 | 336 | 368:
					defaultCamZoom += 0.1;
				case 383:
					defaultCamZoom -= 0.5;
				case 448 | 464 | 480 | 496:
					defaultCamZoom += 0.12;
				case 512:
					defaultCamZoom -= 0.5;
				// drop
				case 576 | 592 | 608 | 624:
					defaultCamZoom += 0.12;
				case 640:
					defaultCamZoom -= 0.5;
				case 688:
					defaultCamZoom += 0.5;
				case 704:
					defaultCamZoom -= 0.5;
				case 720 | 736 | 752 | 760:
					defaultCamZoom += 0.12;
				case 768:
					defaultCamZoom -= 0.5;
					FlxTween.tween(fxtwo, {alpha: 0.5}, 1, {ease: FlxEase.expoOut,});
				case 880:
					defaultCamZoom += 0.5;
				case 896:
					defaultCamZoom -= 0.4;
				case 1024:
					defaultCamZoom += 0.1;
				case 1120:
					var chromeOffset = (ClientPrefs.rgbintense/350);
					Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset];
					Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
					Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
					dad.x += 80;
					dad.y += 80;
					defaultCamZoom += 0.3;
					FlxTween.tween(fxtwo, {alpha: 1}, 8, {ease: FlxEase.expoOut,});
					for (i in 0...4)
					{
						var member = strumLineNotes.members[i];
						FlxTween.tween(strumLineNotes.members[i], {x: defaultStrumX[i] + 1250, angle: 360}, 2);
						defaultStrumX[i] += 1250;
					}
					for (i in 4...8)
					{
						var member = strumLineNotes.members[i];
						FlxTween.tween(strumLineNotes.members[i], {x: defaultStrumX[i] - 275, angle: 360}, 2);
						defaultStrumX[i] -= 275;
					}
				case 1216 | 1232 | 1248 | 1280:
					defaultCamZoom += 0.05;
				case 1344 | 1376:
					defaultCamZoom -= 0.2;
				case 1408:
					defaultCamZoom = 0.75;
					FlxTween.tween(fxtwo, {alpha: 0}, 1, {ease: FlxEase.expoOut,});
			}
		}

		if (curSong == 'Ron') 
		{
			if ((curStep >= 272) && (curStep <= 1304))
			{
				var chromeOffset = ClientPrefs.rgbintense/350;
				if (curStep % 8 == 0)
				{
					for (i in 0...8)
					{ 
						var member = strumLineNotes.members[i];
						FlxTween.globalManager.completeTweensOf(member);
						if(ClientPrefs.downScroll)
							member.y -= 20;
						else
							member.y += 20;
						FlxTween.tween(member, {y: defaultStrumY}, 0.65, {ease: FlxEase.backOut});
					}
				}
				//might be just me but its way too laggy
				//trace(FlxG.camera.zoom);
				//Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset*(FlxG.camera.zoom*1000/700)];
				//Shaders["chromatic aberration"].shader.data.bOffset.value = [-chromeOffset *(FlxG.camera.zoom*1000/700)];
			}
			if (curStep == 540 || curStep == 604 || curStep == 668 || curStep == 732 || curStep == 1304)
				FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.4, {ease: FlxEase.backOut,});
			switch (curStep)
			{
				case 208:
					defaultCamZoom = 0.9;
				case 264:
					defaultCamZoom = 1.1;
				case 272:
					defaultCamZoom = 0.7;
					//addShader(camGame, "bloom");
					FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
				case 540 | 668:
					dad.playAnim('hey');
				case 604 | 732:
					boyfriend.playAnim('hey');
				case 1304:
					//frak can you make it so wasted bg appears
					//going to spawn the wasted bg in the shittiest way possible
					wastedGrp.visible = true;
					addShader(FlxG.camera, "rain");
					addShader(camGame, "wasting");
					Shaders["rain"].shader.data.zoom.value = [35];
					Shaders["rain"].shader.data.raindropLength.value = [0.05];
					Shaders["rain"].shader.data.opacity.value = [0.2];
					fxtwo = new FlxSprite().loadGraphic(Paths.image('bgs/effect'));
					fxtwo.scale.set(0.55, 0.55);
					fxtwo.updateHitbox();
					fxtwo.antialiasing = true;
					fxtwo.screenCenter();
					fxtwo.alpha = 0.2;
					fxtwo.scrollFactor.set(0, 0);
					add(fxtwo);
					fxtwo.cameras = [camOverlay];
					FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
				case 1568:
					FlxTween.tween(blackeffect, {alpha: 1}, 0.5, {ease: FlxEase.circInOut,});
					defaultCamZoom += 0.2;
				case 1600:
					FlxTween.tween(blackeffect, {alpha: 0}, 0.5, {ease: FlxEase.circOut,});
					defaultCamZoom -= 0.2;
			}
		}

		lastStepHit = curStep;

		if (curSong.toLowerCase() == 'bloodbath')
		{
			if (curStep == 258)
			{
				windowmove = true;
				for (i in 0...4)
				{
					FlxTween.tween(strumLineNotes.members[i], {x: strumLineNotes.members[i].x + 1250, angle: strumLineNotes.members[i].angle + 359}, 1, {ease: FlxEase.linear, onComplete: function(w:FlxTween)
						setDefault(i)});
				}
				for (i in 4...8)
				{
					FlxTween.tween(strumLineNotes.members[i], {x: strumLineNotes.members[i].x - 275, angle: strumLineNotes.members[i].angle}, 1, {
						ease: FlxEase.linear,
						onComplete: function(w:FlxTween) setDefault(i)
					});
				}
				cameramove = true;
			}
			if (curStep == 518)
			{
				windowmove = false;
				cameramove = false;
			}
			if (curStep == 768)
			{
				windowmove = true;
				cameramove = true;
			}
		}

		if (curSong.toLowerCase() == 'bleeding')
		{
			if (curStep == 256)
			{
				windowmove = true;
				cameramove = true;
			}
			if (curStep == 512)
			{
				windowmove = false;
				cameramove = false;
			}
			if (curStep == 768)
			{
				for (i in 0...4)
				{
					FlxTween.tween(strumLineNotes.members[i], {x: strumLineNotes.members[i].x - 1250, angle: strumLineNotes.members[i].angle + 359}, 1, {ease: FlxEase.linear, onComplete: function(w:FlxTween)
						setDefault(i)});
				}
				for (i in 4...8)
				{
					FlxTween.tween(strumLineNotes.members[i], {x: strumLineNotes.members[i].x - 300, angle: strumLineNotes.members[i].angle}, 1, {
						ease: FlxEase.linear,
						onComplete: function(w:FlxTween) setDefault(i)
					});
				}
				windowmove = true;
				cameramove = false;
				intensecameramove = true;
			}
			if (curStep == 896)
			{
				intensecameramove = false;
				WHATTHEFUCK = true;
			}
			if (curStep == 1024)
			{
				WHATTHEFUCK = false;
				WTFending = true;
			}
			if (curStep == 1040)
				WTFending = false;
			if (curStep == 1296)
			{
				windowmove = false;
				cameramove = false;
				intensecameramove = false;
			}
		}

		if (curSong.toLowerCase() == 'trojan-virus')
		{
			if (curStep == 384)
				moveing = true;
			if (curStep == 640)
				moveing = false;
		}

	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}
		if (curBeat >= 36 && SONG.song.toLowerCase() == 'oh-my-god-hes-ballin') {
			for (i=>cam in [camHUD, camGame]) {
				FlxTween.cancelTweensOf(cam);
				var offset = 1;
				cam.angle = curBeat % 2 == 0 ? -3 + (offset * 0.5) : 3 - (offset * 0.5);
				cam.zoom += 0.1;
				camHUD.x = curBeat % 2 == 0 ? 10 - (20 * offset) : -10 + (20 * offset);
				camHUD.y += 10 - (20 * offset);
				FlxTween.tween(cam, {angle: 0}, Conductor.crochet / 1000, {ease: FlxEase.circOut});
			}

			for(note in strumLineNotes.members) {
				note.y += 25;
				FlxTween.tween(note, {y: note.y - 25}, 0.3, {ease: FlxEase.quartOut});
			}
		}
		

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}

		lastBeatHit = curBeat;
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {

		if(totalPlayed < 1) //Prevent divide by 0
			ratingName = '?';
		else
		{
			// Rating Percent
			ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
			//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

			// Rating Name
			if(ratingPercent >= 1)
			{
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
			}
			else
			{
				for (i in 0...ratingStuff.length-1)
				{
					if(ratingPercent < ratingStuff[i][1])
					{
						ratingName = ratingStuff[i][0];
						break;
					}
				}
			}
		}

		// Rating FC
		ratingFC = "";
		if (sicks > 0) ratingFC = "SFC";
		if (goods > 0) ratingFC = "GFC";
		if (bads > 0 || shits > 0) ratingFC = "FC";
		if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
		else if (songMisses >= 10) ratingFC = "Clear";
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	function bruh()
	{
		var bruh:FlxSprite = new FlxSprite();
		bruh.loadGraphic(Paths.image('ron/longbob'));
		bruh.antialiasing = true;
		bruh.active = false;
		bruh.scrollFactor.set();
		bruh.screenCenter();
		add(bruh);
		FlxTween.tween(bruh, {alpha: 0}, 1, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				bruh.destroy();
			}
		});
	}

	function setWindowPos(x:Int,y:Int)
	{
		Application.current.window.x = x;
		Application.current.window.y = y;
	}

	function setDefault(id)
		defaultStrumX[id] = strumLineNotes.members[id].x;

	var curLight:Int = -1;
	var curLightEvent:Int = -1;
}
