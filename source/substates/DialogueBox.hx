package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var emote:Bool = false;

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];
	var preloadedPortraits:Map<String, Dynamic> = new Map<String, Dynamic>();

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{

		super();
		if (StringTools.contains(PlayState.SONG.song.toLowerCase(), 'bloodshed') || PlayState.SONG.song.toLowerCase() == 'bleeding')
			FlxG.sound.playMusic(Paths.music('bloodshed-dialogue-mus'), 0);
		else
			FlxG.sound.playMusic(Paths.music('talking-in-a-cool-way'), 0);
		
		FlxG.sound.music.fadeIn(1, 0, 0.8);
		bgFade = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), [0xFFB3DFd8, 0xFF6572c2]);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);
		bgFade.x = -200;
		bgFade.y = -200;

		FlxTween.tween(bgFade, {alpha: 0.7}, 1, {ease: FlxEase.quadInOut});
		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'ron' | 'ayo' | 'wasted' | 'trojan-virus' | 'file-manipulation' | 'atelophobia' | 'factory-reset' | 'bloodshed-old' | 'pretty-wacky' | 'bloodshed-b':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
				box.animation.addByPrefix('exaggerate', 'AHH speech bubble', 24, false);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
				hasDialog = true;
			case 'bloodshed' | 'bleeding':
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking_invert');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, false);
				box.animation.addByPrefix('exaggerate', 'AHH speech bubble', 24, false);
				box.width = 200;
				box.height = 200;
				box.x = -100;
				box.y = 375;
				hasDialog = true;
		}

		this.dialogueList = dialogueList;
		
		//portrait preloader
		for (i in 0...dialogueList.length)
		{
			preloadedPortraits[dialogueList[i].split(":")[1]] = Paths.getSparrowAtlas('dialogue/ron/' + dialogueList[i].split(":")[1]);
		}



		if (!hasDialog)
			return;
		
		portraitLeft = new FlxSprite();
		portraitLeft.frames = Paths.getSparrowAtlas('dialogue/ron/ronPortrait');
		portraitLeft.animation.addByPrefix('ron Portrait Enter', 'ron Portrait Enter', 24, false);
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width + PlayState.daPixelZoom * 0.175));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		portraitLeft.screenCenter();
		portraitLeft.x -= 80;
		portraitLeft.y += 100;
		portraitLeft.scale.set(0.8, 0.8);
		add(portraitLeft);
		portraitLeft.visible = true;

		portraitRight = new FlxSprite();
		portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf');
		portraitRight.animation.addByPrefix('bf', 'FTalk', 24, false);
		portraitRight.animation.addByPrefix('bside', 'BSIDE', 24, false);
		portraitRight.animation.addByPrefix('BTalk', 'BTalk', 24, false);
		portraitRight.animation.addByPrefix('FTalk', 'FTalk', 24, false);
		portraitRight.animation.addByPrefix('Fear', 'Fear', 24, false);
		portraitRight.animation.addByPrefix('Special', 'Special', 24, false);
		portraitRight.screenCenter();
		portraitRight.x += 250;
		portraitRight.y += 40;
		portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.8));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.alpha = 0.5;
		portraitRight.visible = true;
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		if ((PlayState.SONG.song.toLowerCase() == 'bloodshed') || (PlayState.SONG.song.toLowerCase() == 'bleeding'))
			handSelect = new FlxSprite(FlxG.width * 0.7, FlxG.height * 0.85).loadGraphic(Paths.image('handBlood'));
		else
			handSelect = new FlxSprite(FlxG.width * 0.7, FlxG.height * 0.85).loadGraphic(Paths.image('hand'));
		add(handSelect);
		FlxTween.tween(handSelect, {x: FlxG.width * 0.72}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG});


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				if (emote == true)
					box.animation.play('exaggerate');
				else
					box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (box.animation.curAnim.name != 'normalOpen' && box.animation.curAnim.finished)
		{
			if (emote == true)
				box.animation.play('exaggerate');
			else
				box.animation.play('normal');
		}
		
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if(PlayerSettings.player1.controls.ACCEPT)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;
						FlxG.sound.play(Paths.sound('clickText'), 0.8);	

						FlxTween.tween(box, {y: 960}, 1, {ease: FlxEase.backInOut});
						FlxTween.tween(handSelect, {y: 960}, 0.75, {ease: FlxEase.backInOut});
						FlxTween.tween(swagDialogue, {y: 960}, 0.5, {ease: FlxEase.circIn});
						FlxTween.tween(dropText, {y: 1080}, 0.5, {ease: FlxEase.circIn});
						FlxTween.tween(bgFade, {alpha: 0}, 1.2, {ease: FlxEase.quadInOut});
						FlxTween.tween(swagDialogue, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						FlxTween.tween(handSelect, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						FlxTween.tween(dropText, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
						portraitLeft.visible = false;
						portraitRight.visible = false;

						new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
				}
			}
			else if (dialogueStarted)
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.8);
				swagDialogue.skip();
				
				if(skipDialogueThing != null) {
					skipDialogueThing();
				}
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		trace('wo');
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		emote = false;
		if (StringTools.contains(dialogueList[0], 'exag'))
		{
			dialogueList[0] = dialogueList[0].substr(4).trim();
			emote = true;
			box.y = 315;
		}
		else
		{
			box.y = 375;
		}

		if (StringTools.contains(dialogueList[0], 'sussy'))
		{
			dialogueList[0] = dialogueList[0].substr(5).trim();
			FlxG.sound.play(Paths.sound('among'), 1);
		}
		if (StringTools.contains(dialogueList[0], 'static'))
		{
			dialogueList[0] = dialogueList[0].substr(6).trim();
			FlxG.sound.play(Paths.sound('static'), 1);
		}
		if (StringTools.contains(dialogueList[0], 'vine'))
		{
			dialogueList[0] = dialogueList[0].substr(4).trim();
			FlxG.sound.play(Paths.sound('vine'), 1);
		}
		trace('ah');

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			handSelect.visible = true;
			dialogueEnded = true;
		};

		handSelect.visible = false;
		dialogueEnded = false;
		if ((StringTools.contains(curCharacter, 'ron')) || (StringTools.contains(curCharacter, 'Ron')))
		{
			trace('ron pog...?');
			portraitLeft.frames = preloadedPortraits[curCharacter];
			portraitLeft.animation.addByPrefix('ron Portrait Enter', 'ron Portrait Enter', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width + PlayState.daPixelZoom * 0.175));
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			portraitLeft.screenCenter();
			portraitLeft.x -= 80;
			portraitLeft.y += 100;
			portraitLeft.scale.set(0.8, 0.8);
			portraitRight.alpha = 0.5;
			portraitLeft.alpha = 1;
			portraitLeft.animation.play('ron Portrait Enter');
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ronText'), 0.6)];
			dropText.font = Paths.font("w95.otf");
			dropText.color = 0xFFFFF4BB;
			swagDialogue.font = Paths.font("w95.otf");
			swagDialogue.color = 0xFFFFBF00;
			if ((PlayState.SONG.song.toLowerCase() == 'bloodshed') || (PlayState.SONG.song.toLowerCase() == 'bleeding'))
			{
				swagDialogue.color = 0xFFFFF4BB;
				dropText.color = 0xFF1A1A1A;
			}
			dropText.size = 48;
			swagDialogue.size = 48;
			box.flipX = true;
			trace('RON POG');
		}
		else
		{
			portraitLeft.alpha = 0.5;
			portraitRight.alpha = 1;
			trace('bf pog!!!');
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
			dropText.font = 'Pixel Arial 11 Bold';
			dropText.color = 0xFFB9E5FF;
			swagDialogue.font = 'Pixel Arial 11 Bold';
			swagDialogue.color = 0xFF00BADA;
			dropText.size = 32;
			swagDialogue.size = 32;
			box.flipX = false;
			if ((PlayState.SONG.song.toLowerCase() == 'bloodshed') || (PlayState.SONG.song.toLowerCase() == 'bleeding'))
				dropText.color = 0xFF1A1A1A;
			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				portraitRight.animation.play(curCharacter);
			}, dialogueList[0].length);
		}
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
