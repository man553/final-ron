package menus;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import menus.FreeplayState;
import important.Controls;

using StringTools;

#if desktop
import important.Discord.DiscordClient;
#end

class MasterFreeplayState extends MusicBeatState
{
	var bg:FlxSprite;
	var image:FlxSprite;
	var extraImage:FlxSprite;
	var classicImage:FlxSprite;
	var curSelected:Int = 0;
	var cooltext:FlxText;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		image = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/main'), false, 1, 1);
		image.scrollFactor.set();
		image.x = 0;
		image.y = 0;
		image.scale.y = 0.50;
		image.scale.x = 0.50;
		image.ID = 0;
		image.antialiasing = ClientPrefs.globalAntialiasing;
		add(image);

		classicImage = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/classic'), false, 1, 1);
		classicImage.scrollFactor.set();
		classicImage.x = 1000;
		classicImage.y = 100;
		classicImage.scale.y = 0.50;
		classicImage.scale.x = 0.50;
		classicImage.ID = 1;
		classicImage.antialiasing = ClientPrefs.globalAntialiasing;
		add(classicImage);
		
		extraImage = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/extras'), false, 1, 1);
		extraImage.scrollFactor.set();
		extraImage.x = 2000;
		extraImage.y = 200;
		extraImage.scale.y = 0.50;
		extraImage.scale.x = 0.50;
		extraImage.ID = 2;
		extraImage.antialiasing = ClientPrefs.globalAntialiasing;
		add(extraImage);
		changeSelection(0);
		
		cooltext = new FlxText(0, 5, 0, "", 96);
		cooltext.setFormat(Paths.font("vcr.ttf"), 96, FlxColor.WHITE, CENTER);
		cooltext.scrollFactor.set(0,0);
		cooltext.screenCenter(XY);
		add(cooltext);
		cooltext.y += 200;
	}

	override function update(elapsed:Float)
	{
	
		switch(curSelected) {
			case 0:
				cooltext.text = "MAIN";
				FreeplayState.mode = 'main';
			case 1:
				cooltext.text = "CLASSIC";
				FreeplayState.mode = 'classic';
			case 2:
				cooltext.text = "EXTRAS";
				FreeplayState.mode = 'extras';
		}
		if(controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}

		if(controls.UI_LEFT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
		}
		
		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			MusicBeatState.switchState(new menus.FreeplayState());
		}

		if(controls.BACK)
		{
			MusicBeatState.switchState(new menus.MainMenuState());
		}

	}
	function changeSelection(p)
	{
		curSelected += p;
		if (curSelected < 0)
			curSelected = 2;
		if (curSelected >= 3)
			curSelected = 0;
		FlxTween.globalManager.cancelTweensOf(image);
		FlxTween.globalManager.cancelTweensOf(classicImage);
		FlxTween.globalManager.cancelTweensOf(extraImage);
	
		FlxTween.tween(image, {x:  1000*(image.ID - curSelected), y: 100*(image.ID - curSelected)}, 0.8, {ease: FlxEase.elasticOut});
		FlxTween.tween(extraImage, {x: 1000*(extraImage.ID - curSelected), y: 100*(extraImage.ID - curSelected)}, 0.8, {ease: FlxEase.elasticOut});
		FlxTween.tween(classicImage, {x: 1000*(classicImage.ID - curSelected), y: 100*(classicImage.ID - curSelected)}, 0.8, {ease: FlxEase.elasticOut});
	}
}