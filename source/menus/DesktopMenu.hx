package menus;

import flixel.FlxG;
import flixel.ui.FlxButton;

class DesktopMenu extends MusicBeatState
{
	var icons:Map<String, Dynamic> = [
		"options" => new options.OptionsState(),
		"credits" => new CreditsState(),
		"freeplay" => new MasterFreeplayState(),
		"story menu" => new StoryMenuState()
	];
	var curClicked:String = "";
	var clickAmounts:Int = 0;
	var buttons:Array<FlxButton> = [];
	override function create() {
		persistentUpdate = persistentDraw = true;
		important.WeekData.loadTheFirstEnabledMod();
		FlxG.mouse.visible = true;
		var iconI:Int = 0;
		for (i in icons.keys()) {
			var button:FlxButton;
			button = new FlxButton(50, 100 + (100 * iconI), i, function() {
				if (curClicked != i) {
					clickAmounts = 0;
					curClicked = i;
				}
				if (curClicked == i) {
					clickAmounts++;
					button.color = 0xFF485EC2;
					if (clickAmounts == 2) 
						MusicBeatState.switchState(icons[i]);
				}
			});
			button.setGraphicSize(75, 55);
			add(button);
			buttons.push(button);
			iconI++;
		}
		super.create();
	}
	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		super.update(elapsed);
	}
}
