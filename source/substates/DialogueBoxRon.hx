package substates;
import Std;
import Reflect;
import Math;
import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import substates.DialogueBoxPsych;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxGradient;
import flixel.FlxSprite;
import haxe.Json;

using StringTools;
typedef FuckingDialogue = {
	var text:String;
	var alias:String;
	var character:String;
	var retroes:String;
	var isLeftSide:Bool;
	var expression:String;
	var events:Array<Dynamic>;
	var dialogueBox:String;
	var boxState:String;
	var textDelay:Float;
	var clickSound:Dynamic;
	var textColor:String;
}
class DialogueBoxRon extends FlxSpriteGroup { //same method cuz im lazy 
	public var dialogueWorks:Bool = true;
	var music:FlxSound = new FlxSound().loadEmbedded(Paths.music("talking-in-a-cool-way"));
	public var finishCallback:Void->Void;
	var dialogueJSON:Array<FuckingDialogue>;
	var preloadPortraits:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	var curDialogue:Int;
	var backdropThingy:Dynamic;
	var targetGoer = 1;
	var goer:Float = 1;
	var tempPortrait:Array<Dynamic> = [];
	var preloadBoxes:Map<String, flixel.graphics.FlxGraphic> = new Map<String, flixel.graphics.FlxGraphic>();
	var dialoguebox:FlxSprite;
	var bg:FlxSprite;
	var STOP:Bool = false;
	var dialogText:FlxTypeText;
	var dialogHand:FlxSprite = new FlxSprite(1075, 625).loadGraphic(Paths.image('hand'));
	var aliases:Array<Array<String>> = [];
	var retroes:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public function new(dialogueJson:Dynamic, callback:Void->Void) {
		super();
		FlxG.sound.list.add(music);
		finishCallback = callback;
		if (dialogueJson == null)
		{
			dialogueWorks = false;
			return;
		}
		backdropThingy = new flixel.addons.display.FlxBackdrop(Paths.image("rondialogue/barsLoopable"), X);
		bg = new FlxSprite().loadGraphic(Paths.image("rondialogue/bg"));
		add(bg);
		add(backdropThingy);
		dialogueJSON = cast dialogueJson;
		var portraiter = [];
		var alieasesesae = [];
		//portrait loading
		for (i=>a in dialogueJSON){
			if (a.textColor != null && !alieasesesae.contains(a.alias)) {
				aliases.push([a.alias, a.textColor, ["%","#","^","*"][aliases.length]]);
				alieasesesae.push(a.alias);
			}
			if (a.character != null && !portraiter.contains(a.character)) {
				tempPortrait.push([a.character, a.isLeftSide]);
				portraiter.push(a.character);
			}
			if (a.retroes != null) {
				var retroer = new FlxSprite(104 + 147 * i, 668);
				retroer.frames = Paths.getSparrowAtlas('rondialogue/retroIcons');
				retroer.animation.addByPrefix("idle", a.retroes + "0", 24, true);
				retroer.animation.play("idle");
				retroer.updateHitbox();
				retroer.y -= retroer.height;
				retroes[a.retroes] = retroer;
			}
		}
		trace(aliases);
		trace(tempPortrait);
		for (character in tempPortrait)
		{
			var char:FlxSprite = new FlxSprite().loadGraphic(Paths.image('rondialogue/' + character[0]));
			add(char);
			char.alpha = 0.5;
			char.updateHitbox();
			char.x = character[1] ? 100 : FlxG.width - 40 - char.width;
			char.y = 517 - char.height;
			char.scale.set(0.9,0.9);
			char.origin.set(char.width / 2, char.height);
			preloadPortraits[character[0]] = char;
			char.antialiasing = ClientPrefs.globalAntialiasing;
		}
		trace(preloadPortraits);

		//box loading
		dialoguebox = new FlxSprite().loadGraphic(Paths.image('rondialogue/window'));
		preloadBoxes['speech_bubble'] = Paths.image('rondialogue/window');
		dialoguebox.scrollFactor.set();
		dialoguebox.antialiasing = ClientPrefs.globalAntialiasing;
		dialoguebox.visible = false;
		add(dialoguebox);
		for (a in dialogueJSON)
			if (a.dialogueBox != null && preloadBoxes[a.dialogueBox] == null)
				preloadBoxes[a.dialogueBox] = Paths.image('rondialogue/${a.dialogueBox}');

		bg.alpha = 0;
		var blackBox = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
		FlxTween.tween(bg, {alpha: 0.8}, 1, {startDelay: 1, ease: FlxEase.quintOut, onComplete: function(twn:FlxTween) {nextDialogue(0);		music.play();
			music.fadeIn(0.5);
			FlxTween.tween(blackBox, {alpha:0}, 1, {ease: FlxEase.quartOut});
			music.looped = true;}});
		var textRect = new flixel.math.FlxRect(0, 0, 816, 119);
		dialogText = new FlxTypeText(385, 543, 810, "", 14);
		dialogText.font = Paths.font("w95.otf");
		dialogText.sounds = [new FlxSound().loadEmbedded(Paths.sound('Metronome_Tick'))];
		dialogText.font = 'Pixel Arial 11 Bold';
		dialogText.clipRect = textRect;
		dialogText.clipRect = dialogText.clipRect;
		dialogText.start(0.05);
		curTextDelay = 0.05;
		dialogText.color = 0xFF000000;
		add(dialogText);
		add(dialogHand);
		dialogHand.visible = false;
		for (i in retroes) add(i);

		add(blackBox);
	}
	var time:Float = 0;
	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.K && !STOP) 
			if (!finishedTyping) dialogText.skip() else nextDialogue(1);
		super.update(elapsed);
		time += elapsed;
		dialogHand.x = 1075 + (Math.abs(Math.sin(3.5 * time)) * 10);
		if (dialogText.height + 14 > 129) {
			dialogText.y = 664 - dialogText.height;
			dialogText.clipRect.y = dialogText.height - 119;
			dialogText.clipRect = dialogText.clipRect;
		}
		goer = flixel.math.FlxMath.lerp(goer,targetGoer, 0.01);
		backdropThingy.velocity.x = goer * 15;
	}
	var expression:String = '';
	var curPortrait:Dynamic = "";
	var curText:String;
	var curTextDelay:Float;
	var finishedTyping:Bool = false;
	var aliasColor:flixel.util.FlxColor;
	function nextDialogue(e:Int) {
		dialoguebox.visible = true;
		dialogHand.visible = false;
		curDialogue += e;
		if (curDialogue == dialogueJSON.length) {
			STOP = true;
			music.fadeOut(2,0,function(twn:FlxTween) {
				music.destroy();
			});
			for (i in retroes) FlxTween.tween(i, {alpha:0}, 1, {ease: FlxEase.quintOut});
			for (i in preloadPortraits) FlxTween.tween(i, {alpha:0}, 1, {ease: FlxEase.quintOut});
			for (a in [bg, curPortrait, dialoguebox, dialogText, dialogHand, backdropThingy])
				FlxTween.tween(a, {alpha: 0}, 1, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween) {finishCallback();kill();
				}});
			return;
		}
		var d = dialogueJSON[curDialogue];

		if (d.text != null) curText = d.text;
		if (d.clickSound != null) {
			dialogText.sounds = [];
			if (d.clickSound[0] != null)
			{
				for (i in 0...d.clickSound.length)
					dialogText.sounds.push(new FlxSound().loadEmbedded(Paths.sound(d.clickSound[i])));
			}
			else
				dialogText.sounds = [new FlxSound().loadEmbedded(Paths.sound(d.clickSound))];
		}
		if (!Math.isNaN(d.textDelay)) dialogText.delay = d.textDelay;
		if (d.textColor != null) aliasColor = flixel.util.FlxColor.fromString(d.textColor);

		if (d.expression != null) expression = d.expression;

		if (preloadBoxes[d.dialogueBox] != null) {
			dialoguebox.loadGraphic(preloadBoxes[d.dialogueBox]);
		}
		targetGoer = d.isLeftSide ? -1 : 1;
		if (d.character != null && curPortrait != preloadPortraits[d.character]) {
			curPortrait = preloadPortraits[d.character];
			FlxTween.completeTweensOf(curPortrait);
			FlxTween.tween(curPortrait.scale, {x: 1, y: 1}, 0.4, {ease: FlxEase.circOut});
			FlxTween.tween(curPortrait, {alpha: 1}, 0.3, {ease: FlxEase.circOut});
		}
		
		for (c in tempPortrait) {
			if (preloadPortraits[c[0]] != curPortrait){
				FlxTween.completeTweensOf(preloadPortraits[c[0]]);
				FlxTween.tween(preloadPortraits[c[0]].scale, {x: 0.9, y: 0.9}, 0.5, {ease: FlxEase.circOut});
				FlxTween.tween(preloadPortraits[c[0]], {alpha: 0.5}, 0.5, {ease: FlxEase.circOut});
			}
		}

		if (d.events != null)
			for (i in 0...d.events.length)
				Reflect.callMethod(this, Reflect.field(this, d.events[i][0]), d.events[i][1]);
		finishedTyping = false;
		@:privateAccess(dialogText._finalText) dialogText._finalText += '${d.alias}:\n';
		@:privateAccess(dialogText._finalText) for (i in aliases) dialogText._finalText = dialogText._finalText.replace(i[0], i[2] + i[0] + i[2]);
		@:privateAccess(dialogText._finalText) dialogText.applyMarkup(dialogText._finalText, [for (i in aliases) new flixel.text.FlxText.FlxTextFormatMarkerPair(
			new flixel.text.FlxText.FlxTextFormat(flixel.util.FlxColor.fromString(i[1]), true, true), i[2]
		)]);
		dialogText.start(curTextDelay);
		dialogText.skip();
		@:privateAccess(dialogText._finalText) dialogText._finalText += curText + '\n';
		dialogText.start(curTextDelay);
		dialogText.completeCallback = function() {finishedTyping = true;dialogHand.visible = true;}
	}
	function updateBoxOffsets(box:FlxSprite) { //Had to make it static because of the editors -- shadow mario's mid code
		box.centerOffsets();
		box.updateHitbox();
		if(box.animation.curAnim.name.startsWith('angry')) {
			box.offset.set(50, 65);
		} else if(box.animation.curAnim.name.startsWith('center-angry')) {
			box.offset.set(50, 30);
		} else {
			box.offset.set(10, 0);
		}
		
		if(!box.flipX) box.offset.y += 10;
	}
	function reloadBoxAnims(box:FlxSprite) {
		box.animation.destroyAnimations();
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
		box.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
		box.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		box.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
	}
	function cameraFlash(color:String, duration:Float) {
		PlayState.instance.camHUD.flash(Std.parseInt(color), duration, null, true);
	}
	function playSound(sound:String) {
		FlxG.sound.play(Paths.sound(sound));
	}
}