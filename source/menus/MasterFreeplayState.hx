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
	var curSelected:Int = 0;

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

		extraImage = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/extras'), false, 1, 1);
		extraImage.scrollFactor.set();
		extraImage.x = 1000;
		extraImage.y = 0;
		extraImage.scale.y = 0.50;
		extraImage.scale.x = 0.50;
		extraImage.ID = 1;
		extraImage.antialiasing = ClientPrefs.globalAntialiasing;
		add(extraImage);
		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
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
			
			switch(curSelected) {
				case 0:
					FreeplayState.mode = 'main';
					MusicBeatState.switchState(new menus.FreeplayState());
				case 1:
					FreeplayState.mode = 'extras';
					MusicBeatState.switchState(new menus.FreeplayState());
			}
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
			curSelected = 1;
		if (curSelected >= 2)
			curSelected = 0;
		FlxTween.globalManager.cancelTweensOf(image);
		FlxTween.globalManager.cancelTweensOf(extraImage);
	
		FlxTween.tween(image, {x:  1000*(image.ID - curSelected)}, 0.8, {ease: FlxEase.elasticOut});
		FlxTween.tween(extraImage, {x: 1000*(extraImage.ID - curSelected)}, 0.8, {ease: FlxEase.elasticOut});
	}
}