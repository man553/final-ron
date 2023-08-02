package substates;

import important.Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var optionArray = ["resume song", "restart song", "shut down", "log off"];
	var optionButtons = [];
	var curSelected = 0;
	var pauseMusic:FlxSound = new FlxSound();
	override function create() {
		var songName:String = ClientPrefs.pauseMusic;
		pauseMusic = new FlxSound();
		if (songName != 'None' && songName != null) {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic).toLowerCase()), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2))); // idk why it starts at a random point i just stole it from psych
		FlxG.sound.list.add(pauseMusic);
		
		var startMenu = new FlxSprite(0, 720).loadGraphic(Paths.image("windowsUi/start menu"));
		startMenu.y -= startMenu.height;
		add(startMenu);
		for (i in 0...optionArray.length) {
			var button = new FlxSprite(25, (723 - startMenu.height) + (34 * i) + (i > 1 ? 270 : 0));
			button.frames = Paths.getSparrowAtlas("windowsUi/win98buttons");
			button.animation.addByPrefix("unselect", optionArray[i] + " unselect");
			button.animation.addByPrefix("select", optionArray[i] + " select");
			button.ID = i;
			add(button);
			button.animation.play("unselect");
			optionButtons.push(button);
		}
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		trace(cameras);
		super.create();
	}
	override function update(elapsed:Float) {
		if (pauseMusic.volume < .5) {
			pauseMusic.volume += elapsed * .01;
		}
		for (i in optionButtons) {
			if (i.ID == curSelected) {i.animation.play("select");
				if (FlxG.keys.justPressed.ENTER) {
					var choice = optionArray[i.ID];
					switch (choice) {
						case "resume song": close();
						case "restart song": 	
							PlayState.instance.paused = true; // For lua
							FlxG.sound.music.volume = 0;
							PlayState.instance.vocals.volume = 0;
							//but why though
							//FlxTransitionableState.skipNextTransOut = true;
							FlxG.resetState();
							MusicBeatState.animatedShaders["8bitcolor"].shader.data.enablethisbitch.value = [0.];
						case "log off":
							PlayState.deathCounter = 0;
							PlayState.seenCutscene = false;
							if(PlayState.isStoryMode) {
								MusicBeatState.switchState(new menus.DesktopMenu());
							} else {
								MusicBeatState.switchState(new menus.FreeplayState());
							}
							PlayState.cancelMusicFadeTween();
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							PlayState.changedDifficulty = false;
							PlayState.chartingMode = false;
						case "shut down": #if windows Sys.exit(0); #end
					}
				}
			}
			else i.animation.play("unselect");
		}
		if (controls.UI_DOWN_P) { curSelected += 1; FlxG.sound.play(Paths.sound('scrollFunny'), 0.6); }
		if (controls.UI_UP_P) { curSelected -= 1; FlxG.sound.play(Paths.sound('scrollFunny'), 0.6); }
		curSelected = (curSelected > optionArray.length - 1 ? 0 : (curSelected < 0 ? optionArray.length - 1 : curSelected));
		super.update(elapsed);
	}
	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
}
