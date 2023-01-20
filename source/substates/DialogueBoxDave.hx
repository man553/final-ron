package substates;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import haxe.Log;
import flixel.input.gamepad.lists.FlxBaseGamepadList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBoxDave extends FlxSpriteGroup
{
	var box:FlxSprite;

	var blackScreen:FlxSprite;

	var curCharacter:String = '';
	var curMod:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bfPortraitSizeMultiplier:Float = 1.5;
	var textBoxSizeFix:Float = 7;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var debug:Bool = false;

	public static var randomNumber:Int;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
	
		randomNumber = FlxG.random.int(0, 50);
		if ((PlayState.SONG.stage == 'bambiFarm') || (PlayState.SONG.stage == 'daveHouse'))
		{
			if(randomNumber == 50)
			{
				FlxG.sound.playMusic(Paths.music('secret'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('DaveDialogue'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			}
		}
	
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		FlxTween.tween(bgFade, {alpha: 0.7}, 4.15);
		box = new FlxSprite(-20, 400);

		blackScreen = new FlxSprite(0, 0).makeGraphic(5000, 5000, FlxColor.BLACK);
		blackScreen.screenCenter();
		blackScreen.alpha = 0;
		add(blackScreen);
		
		var hasDialog = true;
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.setGraphicSize(Std.int(box.width / textBoxSizeFix));
		box.updateHitbox();
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
		box.antialiasing = true;
		

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
		var portraitLeftCharacter:String = '';
		var portraitRightCharacter:String = 'ron';

		portraitLeft = new FlxSprite();
		portraitRight = new FlxSprite();
		portraitLeftCharacter = 'bambi';

		if (PlayState.SONG.song.toLowerCase() == 'holy-shit-dave-fnf')
			portraitLeftCharacter = 'dave';

		var leftPortrait:Portrait = getPortrait(portraitLeftCharacter);

		portraitLeft.frames = Paths.getSparrowAtlas(leftPortrait.portraitPath);
		portraitLeft.animation.addByPrefix('enter', leftPortrait.portraitPrefix, 24, false);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();

		var rightPortrait:Portrait = getPortrait(portraitRightCharacter);
		
		portraitRight.frames = Paths.getSparrowAtlas(rightPortrait.portraitPath);
		portraitRight.animation.addByPrefix('enter', rightPortrait.portraitPrefix, 24, false);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		
		portraitRight.visible = false;
		portraitLeft.setPosition(276.95, 170);
		portraitLeft.visible = true;
		add(portraitLeft);
		add(portraitRight);

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Comic Sans MS Bold';
		dropText.color = 0xFF00137F;
		add(dropText);
		
		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Comic Sans MS Bold';
		swagDialogue.color = 0xFF000000;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);
		

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY  && dialogueStarted)
		{
			remove(dialogue);
			FlxG.sound.play(Paths.sound('textclickmodern'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
						
					FlxG.sound.music.fadeOut(2.2, 0);
					FlxTween.tween(box, {alpha: 0}, 1.2);
					FlxTween.tween(bgFade, {alpha: 0}, 1.2);
					FlxTween.tween(portraitLeft, {alpha: 0}, 1.2);
					FlxTween.tween(portraitRight, {alpha: 0}, 1.2);
					FlxTween.tween(swagDialogue, {alpha: 0}, 1.2);
					FlxTween.tween(dropText, {alpha: 0}, 1.2);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
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
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		if (curCharacter != 'generic')
		{
			var portrait:Portrait = getPortrait(curCharacter);
			if (portrait.left)
			{
				portraitLeft.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitLeft.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
				}
			}
			else
			{
				portraitRight.frames = Paths.getSparrowAtlas(portrait.portraitPath);
				portraitRight.animation.addByPrefix('enter', portrait.portraitPrefix, 24, false);
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
				}
			}
			switch (curCharacter)
			{
				case 'dave' | 'bambi': //guys its the funny bambi character
						portraitLeft.setPosition(220, 220);
				case 'ron': //create boyfriend & genderbent boyfriend
					portraitRight.setPosition(770, 220);
			}
			box.flipX = portraitLeft.visible;
			portraitLeft.x -= 150;
			//portraitRight.x += 100;
			portraitRight.antialiasing = true;
			portraitLeft.animation.play('enter',true);
			portraitRight.animation.play('enter',true);
		}
		else
		{
			portraitLeft.visible = false;
			portraitRight.visible = false;
		}
	}
	function getPortrait(character:String):Portrait
	{
		// just as a backup crash something idk
		var portrait:Portrait = new Portrait('dialogue/ron/dave_house', '', 'dave house portrait', true);
		switch (character)
		{
			case 'dave':
				portrait.portraitPath = 'dialogue/ron/dave_house';
				portrait.portraitPrefix = 'dave house portrait';
			case 'bambi':
				portrait.portraitPath = 'dialogue/ron/bambi_maze';
				portrait.portraitPrefix = 'bambi maze portrait';
			case 'ron':
				portrait.portraitPath = 'dialogue/ron/ron_house';
				portrait.portraitPrefix = 'ron house';
				portrait.left = false;
		}
		return portrait;
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curMod = splitName[0];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[0].length + 2).trim();
	}
}
class Portrait
{
	public var portraitPath:String;
	public var portraitLibraryPath:String = '';
	public var portraitPrefix:String;
	public var left:Bool;
	public function new (portraitPath:String, portraitLibraryPath:String = '', portraitPrefix:String, left:Bool)
	{
		this.portraitPath = portraitPath;
		this.portraitLibraryPath = portraitLibraryPath;
		this.portraitPrefix = portraitPrefix;
		this.left = left;
	}
}