package;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import FreeplayState;
import Controls;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class MasterFreeplayState extends MusicBeatState
{
	var bg:FlxSprite;
	var image:FlxSprite;
	var extraImage:FlxSprite;
	var curSelected:Int = 0;

	override function create()
	{
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
		image.antialiasing = ClientPrefs.globalAntialiasing;
		add(image);

		extraImage = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/extras'), false, 1, 1);
		extraImage.scrollFactor.set();
		extraImage.x = 1000;
		extraImage.y = 0;
		extraImage.scale.y = 0.50;
		extraImage.scale.x = 0.50;
		extraImage.antialiasing = ClientPrefs.globalAntialiasing;
		add(extraImage);
	}

	override function update(elapsed:Float)
	{
		if(controls.UI_RIGHT_P && curSelected == 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = 1;
			FlxTween.tween(image, {x: -1000}, 0.3);
			FlxTween.tween(extraImage, {x: 0}, 0.3);
		}

		if(controls.UI_LEFT_P && curSelected == 1)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = 0;
			FlxTween.tween(image, {x: 0}, 0.3);
			FlxTween.tween(extraImage, {x: 1000}, 0.3);
		}

		if(controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			switch(curSelected) {
				case 0:
					FreeplayState.mode = 'main';
					MusicBeatState.switchState(new FreeplayState());
				case 1:
					FreeplayState.mode = 'extras';
					MusicBeatState.switchState(new FreeplayState());
			}
		}

		if(controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

	}
}