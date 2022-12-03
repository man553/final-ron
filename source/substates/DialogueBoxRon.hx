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
	var character:String;
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
	var preloadPortraits:Map<String, DialogueCharacter> = new Map<String, DialogueCharacter>();
	var curDialogue:Int;
	var tempPortrait = [];
	var preloadBoxes:Map<String, FlxAtlasFrames> = new Map<String, FlxAtlasFrames>();
	var dialoguebox:FlxSprite;
	var bg:FlxSprite = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), [0xFFB3DFd8, 0xFF6572c2]);
	var STOP:Bool = false;
	var dialogText:FlxTypeText;
	var dialogHand:FlxSprite = new FlxSprite(950, 575).loadGraphic(Paths.image('hand'));
	public function new(dialogueJson:Dynamic, callback:Void->Void) {
		super();
		FlxG.sound.list.add(music);
		finishCallback = callback;
		if (dialogueJson == null)
		{
			dialogueWorks = false;
			return;
		}
		add(bg);
		dialogueJSON = cast dialogueJson;
		//portrait loading
		for (a in dialogueJSON)
			if (!tempPortrait.contains(a.character))
				tempPortrait.push(a.character);

		for (character in tempPortrait)
		{
			var char:DialogueCharacter = new DialogueCharacter(0, 0, character);
			char.setGraphicSize(Std.int(char.width * DialogueCharacter.DEFAULT_SCALE * char.jsonFile.scale));
			char.setPosition(FlxG.width - char.width + (char.jsonFile.dialogue_pos == "left" ? -60 : -100) + char.jsonFile.position[0], 60 + char.jsonFile.position[1]);
			char.updateHitbox();
			add(char);
			char.visible = false;
			preloadPortraits[character] = char;
		}


		//box loading
		dialoguebox = new FlxSprite(70, 370);
		dialoguebox.frames = Paths.getSparrowAtlas('speech_bubble');
		preloadBoxes['speech_bubble'] = Paths.getSparrowAtlas('speech_bubble');
		dialoguebox.scrollFactor.set();
		dialoguebox.antialiasing = ClientPrefs.globalAntialiasing;
		dialoguebox.animation.addByPrefix('normal', 'speech bubble normal', 24);
		dialoguebox.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		dialoguebox.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		dialoguebox.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		dialoguebox.animation.addByPrefix('center-normal', 'speech bubble middle', 24);
		dialoguebox.animation.addByPrefix('center-normalOpen', 'Speech Bubble Middle Open', 24, false);
		dialoguebox.animation.addByPrefix('center-angry', 'AHH Speech Bubble middle', 24);
		dialoguebox.animation.addByPrefix('center-angryOpen', 'speech bubble Middle loud open', 24, false);
		dialoguebox.animation.finishCallback = function(name:String) {dialoguebox.animation.play(name.replace("Open", ""));};
		dialoguebox.setGraphicSize(Std.int(dialoguebox.width * 0.9));
		dialoguebox.updateHitbox();
		dialoguebox.visible = false;
		add(dialoguebox);
		for (a in dialogueJSON)
			if (a.dialogueBox != null && preloadBoxes[a.dialogueBox] == null)
				preloadBoxes[a.dialogueBox] = Paths.getSparrowAtlas(a.dialogueBox);

		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.8}, 1, {startDelay: 1, ease: FlxEase.quintOut, onComplete: function(twn:FlxTween) {nextDialogue(0);		music.play();
			music.fadeIn(0.5);
			music.looped = true;}});
		dialogText = new FlxTypeText(200, 500, 955, "", 32);
		dialogText.sounds = [new FlxSound().loadEmbedded(Paths.sound('Metronome_Tick'))];
		dialogText.font = 'Pixel Arial 11 Bold';
		curTextDelay = 0.05;
		dialogText.color = 0xFF000000;
		add(dialogText);
		add(dialogHand);
		dialogHand.visible = false;
	}
	var time:Float = 0;
	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.K && !STOP) 
			if (!finishedTyping) dialogText.skip() else nextDialogue(1);
		super.update(elapsed);
		time += elapsed;
		dialogHand.x = 950 + (Math.abs(Math.sin(3.5 * time)) * 10);
	}
	var expression:String = '';
	var curPortrait:Dynamic = "";
	var curText:String;
	var curTextDelay:Float;
	var finishedTyping:Bool = false;
	function nextDialogue(e:Int) {
		dialoguebox.visible = true;
		dialogHand.visible = false;
		curDialogue += e;
		if (curDialogue == dialogueJSON.length) {
			STOP = true;
			music.fadeOut(2,0,function(twn:FlxTween) {
				music.destroy();
			});
			for (a in [bg, curPortrait, dialoguebox, dialogText, dialogHand])
				FlxTween.tween(a, {alpha: 0}, 1, {ease: FlxEase.quintOut, onComplete: function(twn:FlxTween) {finishCallback();kill();
				}});
			return;
		}
		var d = dialogueJSON[curDialogue];

		if (d.text != null) curText = d.text;
		if (d.clickSound != null)
		{
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
		if (d.textColor != null) dialogText.color = Std.parseInt(d.textColor);

		if (d.expression != null) expression = d.expression;

		if (preloadBoxes[d.dialogueBox] != null) {
			dialoguebox.frames = preloadBoxes[d.dialogueBox];
			reloadBoxAnims(dialoguebox);
		}
		if (d.character != null && curPortrait != preloadPortraits[d.character]) {
			curPortrait = preloadPortraits[d.character];
			curPortrait.visible = true;
			dialoguebox.animation.play((d.boxState != null ? d.boxState : "normal") + "Open", true);
		}
		curPortrait.playAnim(expression, false);

		
		for (c in tempPortrait) {
			if (preloadPortraits[c] != curPortrait)
				preloadPortraits[c].visible = false;
		}
		
		if (dialoguebox.animation.curAnim != null && !dialoguebox.animation.curAnim.name.contains(d.boxState))
			dialoguebox.animation.play((d.boxState != null ? d.boxState : "normal"), true);
		dialoguebox.flipX = (curPortrait.jsonFile.dialogue_pos == "left" ? true : false);
		updateBoxOffsets(dialoguebox);

		if (d.events != null)
			for (i in 0...d.events.length)
				Reflect.callMethod(this, Reflect.field(this, d.events[i][0]), d.events[i][1]);
		finishedTyping = false;
		dialogText.resetText(curText);
		dialogText.start(curTextDelay, true);
		dialogText.completeCallback = function() {curPortrait.playAnim(expression, true);finishedTyping = true;dialogHand.visible = true;}
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