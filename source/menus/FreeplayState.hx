package menus;

import misc.CustomFadeTransition;
#if desktop
import important.Discord.DiscordClient;
#end
import important.Highscore;
import important.Song;
import gameassets.HealthIcon;
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import lime.utils.Assets;
import flixel.sound.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import important.WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var portrait:FlxSprite;
	var portraitOverlay:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var time:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var camWhat:FlxCamera;
	var camText:FlxCamera;
	var chromeOffset = (ClientPrefs.rgbintense/350);
	var hasAccepted:Bool = false;
	public static var mode:String = 'main';

	override function create()
	{
		Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		persistentUpdate = persistentDraw = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		camText = new FlxCamera();
		camText.bgColor = 0;
		camWhat = new FlxCamera();
		FlxG.cameras.reset(camWhat);
		FlxG.cameras.add(camText);
		FlxCamera.defaultCameras = [camWhat];
		CustomFadeTransition.nextCamera = camText;
		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			if (mode == 'main' && WeekData.weeksList[i] != 'mainweek' && WeekData.weeksList[i] != 'week2') continue;
			else if (mode == 'extras' && WeekData.weeksList[i] != 'freeplayshit') continue;
			else if (mode == 'classic' && WeekData.weeksList[i] != 'classic') continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('freeplaymenu/mainbgAnimate');
		if (FreeplayState.mode.toLowerCase() == 'classic')
			bg.frames = Paths.getSparrowAtlas('freeplaymenu/classicbgAnimate');
		bg.animation.addByPrefix('animate', 'animate', 24, true);
		bg.animation.play('animate');
		bg.scale.set(2,2);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var darkportrait:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplayportraits/ron'));
		darkportrait.scale.set(0.5,0.5);
		darkportrait.updateHitbox();
		darkportrait.antialiasing = ClientPrefs.globalAntialiasing;
		add(darkportrait);
		darkportrait.screenCenter(XY);
		darkportrait.color = FlxColor.BLACK;

		portrait = new FlxSprite().loadGraphic(Paths.image('freeplayportraits/ron'));
		portrait.scale.set(0.5,0.5);
		portrait.updateHitbox();
		portrait.antialiasing = ClientPrefs.globalAntialiasing;
		add(portrait);
		portrait.screenCenter(XY);
		
		var bar:FlxSprite = new FlxSprite();
		bar.frames = Paths.getSparrowAtlas('freeplayportraits/bar');
		bar.animation.addByPrefix('bar', 'bar', 24, true);
		bar.animation.play('bar');
		bar.screenCenter();
		add(bar);
		bar.x += 30;
		
		portraitOverlay = new FlxSprite().loadGraphic(Paths.image('freeplayportraits/ron'));
		portraitOverlay.scale.set(0.5,0.5);
		portraitOverlay.updateHitbox();
		portraitOverlay.antialiasing = ClientPrefs.globalAntialiasing;
		add(portraitOverlay);
		portraitOverlay.screenCenter(XY);
		portraitOverlay.visible = false;
		
		var coolemitter:FlxEmitter = new FlxEmitter();
		coolemitter.width = FlxG.width*1.5;
		coolemitter.launchMode = SQUARE;
		coolemitter.velocity.set(0, -5, 0, -10);
		coolemitter.angularVelocity.set(-10, 10);
		coolemitter.lifespan.set(5);
		coolemitter.y = FlxG.height;
		
		var coolzemitter:FlxEmitter = new FlxEmitter();
		coolzemitter.width = FlxG.width*1.5;
		coolzemitter.launchMode = SQUARE;
		coolzemitter.velocity.set(0, 5, 0, 10);
		coolzemitter.angularVelocity.set(-10, 10);
		coolzemitter.lifespan.set(5);
		
		for (i in 0...150)
		{
			var p = new FlxParticle();
			var p2 = new FlxParticle();
			p.makeGraphic(6,6,FlxColor.BLACK);
			p2.makeGraphic(12,12,FlxColor.BLACK);

			coolemitter.add(p);
			coolemitter.add(p2);					
			coolzemitter.add(p);
			coolzemitter.add(p2);
		}

		add(coolzemitter);
		coolzemitter.start(false, 0.05);
		add(coolemitter);
		coolemitter.start(false, 0.05);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.replace("-"," "), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.ID = i;
			songText.cameras = [camText];
			grpSongs.add(songText);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
				//songText.updateHitbox();
				//trace(songs[i].songName + ' new scale: ' + textScale);
			}

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.trackerOffset.y = -25;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
			portrait.loadGraphic(Paths.image('freeplayportraits/'+songs[i].songName.toLowerCase()));// it would be funny if this actually worked
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("w95.otf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		changeSelection();
		changeDiff();
		updateportrait();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("w95.otf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		
		var chromeOffset = (ClientPrefs.rgbintense/350);
		shadering();
		
		var modeText = new FlxText(10, 10, 0, FreeplayState.mode.toUpperCase(), 48);
		modeText.setFormat(Paths.font("w95.otf"), 48, FlxColor.WHITE, LEFT);
		add(modeText);
		super.create();

	}

	override function closeSubState() {
		changeSelection(0, false);
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		portraitOverlay.y = portrait.y;
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		for (song in grpSongs.members)
		{
			song.forceX = FlxMath.lerp(song.x, 125 + (65 * (song.ID - curSelected)), CoolUtil.lerpFix(0.1));
			for (i in 0...songs.length)
				song.y += (Math.sin(i+time)/2);
		}

		time += elapsed;
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset*Math.sin(time)];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [-chromeOffset*Math.sin(time)];

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff(0, true);
				}
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff(0, true);

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new menus.MasterFreeplayState());
		}

		if(ctrl)
		{
			openSubState(new substates.GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				var songName:String = songs[curSelected].songName.toLowerCase();
					
				var poop:String = Highscore.formatSong(songName, curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songName);
				// i only want the instrumental to play
				//if (PlayState.SONG.needsVoices)
				//	vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				//else
				//	vocals = new FlxSound();

				//FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				//vocals.play();
				//vocals.persist = true;
				//vocals.looped = true;
				//vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if ((accepted) && !(hasAccepted))
		{
			//lol
			hasAccepted = true;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if ((songLowercase == 'trojan-virus') && !(FlxG.keys.pressed.ALT))
			{
				var video:misc.MP4Handler = new misc.MP4Handler();
				video.playMP4(Paths.videoRon('trojan-virus'), new PlayState(), false, false, false);
			}
			else
				{
				if (FlxG.keys.pressed.SHIFT){
					LoadingState.loadAndSwitchState(new ChartingState());
				}else{
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			
			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			var songName:String = songs[curSelected].songName;
			openSubState(new substates.ResetScoreSubState(songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		switch(songs[curSelected].songName.toLowerCase())
		{
			case 'bleeding':
				//camWhat.zoom = 1.2;
			case 'bleeding-classic':
				//camWhat.zoom = 1.2;
			default:
				camWhat.zoom = 1;
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0, isMuda:Bool = false)
	{
		var lastDiff = curDifficulty;

		curDifficulty += change;


		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		var songName:String = songs[curSelected].songName;
		intendedScore = Highscore.getScore(songName, curDifficulty);
		intendedRating = Highscore.getRating(songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '  ' + CoolUtil.difficultyString() + '  ';
		diffText.color = FlxColor.WHITE;
		if (songs[curSelected].songName.toLowerCase() == 'bleeding')
		{
			diffText.color = FlxColor.RED;
			diffText.text = '  ' + 'COOL' + '  ';
		}
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		var max:Int = songs.length;

		if (curSelected < 0)
			curSelected = max - 1;
		if (curSelected >= max)
			curSelected = 0;	
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		var songName:String = songs[curSelected].songName;
		intendedScore = Highscore.getScore(songName, curDifficulty);
		intendedRating = Highscore.getRating(songName, curDifficulty);
		#end
		shadering();

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		if (time >= 1)
		{
			FlxTween.globalManager.completeTweensOf(portrait);
			portrait.screenCenter(Y);

			FlxTween.tween(portrait, {y: portrait.y + 45}, 0.2, {ease: FlxEase.quintIn, onComplete: function(twn:FlxTween) {
				updateportrait();
				var mfwY = portrait.y;
				portrait.y -= 20;
				FlxTween.tween(portrait, {y: mfwY}, 0.4, {ease: FlxEase.elasticOut});
			}});
		}
		else
			updateportrait();
			

	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
	
	private function updateportrait() {
		portrait.loadGraphic(Paths.image('freeplayportraits/'+songs[curSelected].songName.toLowerCase()));
		portrait.scale.set(0.5,0.5);
		portrait.updateHitbox();
		portrait.screenCenter(XY);
		
		if ((songs[curSelected].songName.toLowerCase() == 'slammed') || (songs[curSelected].songName.toLowerCase() == 'oh-my-god-hes-ballin'))
		{
			portraitOverlay.loadGraphic(Paths.image('freeplayportraits/'+songs[curSelected].songName.toLowerCase()+'-over'));
			portraitOverlay.scale.set(0.5,0.5);
			portraitOverlay.updateHitbox();
			portraitOverlay.screenCenter(XY);
			portraitOverlay.visible = true;
		}
		else
			portraitOverlay.visible = false;
	}
	
	private function shadering() {
		clearShader(camWhat);
		clearShader(camText);
		addShader(camWhat, "chromatic aberration");
		addShader(camWhat, "fake CRT");
		addShader(camText, "fisheye");
		Shaders["fisheye"].shader.data.MAX_POWER.value = [0.2];
		Shaders["chromatic aberration"].shader.data.rOffset.value = [chromeOffset/2];
		Shaders["chromatic aberration"].shader.data.gOffset.value = [0.0];
		Shaders["chromatic aberration"].shader.data.bOffset.value = [chromeOffset * -1];
		
		if (mode == 'classic')
			addShader(camWhat, "vhs");
		switch (songs[curSelected].songName.toLowerCase())
		{
			case "trojan virus" | "bleeding":
				addShader(camWhat,"glitchsmh");
				Shaders["glitchsmh"].shader.data.on.value = [1.];		
			case "gron":
				//grayscale looks better unless a cooler paper shader is found
				//addShader(camWhat,"paper");
				addShader(camWhat,"grayscale");
		}
	}
	
	
	override function beatHit()
	{
		if (curBeat % 2 == 1)
			FlxG.camera.zoom = 1.05;
		else
			FlxG.camera.zoom = 0.95;
					
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.2, {ease: FlxEase.quadInOut});
		super.beatHit();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		if(this.folder == null) this.folder = '';
	}
}