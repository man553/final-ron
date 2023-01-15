package menus;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;
import flixel.FlxG;
import haxe.Json;
import openfl.Assets;
import gameassets.Alphabet;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.text.FlxText;    
import openfl.display.BitmapData; 
import flixel.tweens.FlxTween; 
import flixel.tweens.FlxEase;
using Type;                     
class CreditMenu extends MusicBeatState {
	var creditJSON:Dynamic;
	var nameGroup = [];
	var curSelected:Int = 0;
	var largePortrait:FlxSprite;
	var dividingBar:FlxSprite = new FlxSprite(775, 400).makeGraphic(400, 5);
	var descText:FlxText;
	var socialMediaText:FlxText;
	var socialMediaFavicon:FlxSprite;
	var time:Float = 0;

	override function create() {
		var bg = new FlxBackdrop(Paths.image('scroll'));
		bg.velocity.set(100, 100);
		add(bg);
		creditJSON = Json.parse(Assets.getText(Paths.json("credit")));
		for (i in 0...creditJSON.length){
			var j = new Alphabet(0, 100 + (150 * i), creditJSON[i].handle,true);
			j.ID = i;
			j.forceX = 100;
			nameGroup.push(j);
			add(j);
			var e = new FlxSprite().loadGraphic(Paths.image("roncredits/" + creditJSON[i].name));
			e.setGraphicSize(50, 50);
			e.updateHitbox();
			e.antialiasing = true;
			j.trackingSpr = e;
			add(e);
		}
		largePortrait = new FlxSprite(800, 20).loadGraphic(Paths.image("roncredits/seezee"));
		largePortrait.setGraphicSize(350, 350);
		largePortrait.updateHitbox();
		largePortrait.antialiasing = true;
		descText = new FlxText(780, 425, 490, "seezee", 20);
		socialMediaText = new FlxText(675,675,0,"Press enter to open social media link", 20);
		socialMediaFavicon = new FlxSprite(1165, 673);
		add(socialMediaFavicon);
		socialMediaFavicon.visible = false;
		add(socialMediaText);
		add(largePortrait);
		add(descText);
		add(dividingBar);
		super.create();

		changeSelection(0);
	}
	var keyCount:Int = 0;
	var antiSpam:Bool = false;
	override function update(elapsed:Float) {
		time += elapsed;	
		if (time > 1) keyCount = 0;
		if (!antiSpam) {
			if (controls.BACK) MusicBeatState.switchState(new DesktopMenu());
			if (controls.UI_UP_P) {changeSelection(-1);keyCount=0;}
			if (controls.UI_DOWN_P) changeSelection(1);
			if (controls.UI_DOWN_P || controls.UI_UP_P) {dividingBar.scale.x += 0.2; time = 0;}
		}
		dividingBar.scale.x = FlxMath.lerp(dividingBar.scale.x, 1, 0.1 / (60 / ClientPrefs.framerate));
		if (controls.ACCEPT && creditJSON[curSelected].social_link != null) CoolUtil.browserLoad(creditJSON[curSelected].social_link);
		for (j in nameGroup) {
			j.y = FlxMath.lerp(j.y, 360 + (150 * (j.ID - curSelected)), 0.1 / (60 / ClientPrefs.framerate));
			if (j.text != null)
				if (!antiSpam) j.scale.set(FlxMath.lerp(j.scale.x, (4 - Math.abs(j.ID - curSelected)) * (0.3 - (j.text.length * 0.01)), 0.2 / (60 / ClientPrefs.framerate)), FlxMath.lerp(j.scale.y, (4 - Math.abs(j.ID - curSelected)) * (0.3 - (j.text.length * 0.01)), 0.05 / (60 / ClientPrefs.framerate)));
			j.forceX = FlxMath.lerp(j.forceX, 100 + -Math.abs(25 * (j.ID - curSelected)), 0.2 / (60 / ClientPrefs.framerate));
		}
		super.update(elapsed);
	}
	function changeSelection(e) {
		curSelected += e;
		if (curSelected > nameGroup.length - 1) keyCount += 1;
		if (curSelected == 7 && keyCount > 4 && time < 3 && !antiSpam) {
			FlxG.camera.shake(0.05, 3, function() {
				FlxG.camera.flash();
				FlxG.sound.play(Paths.sound("boom"));
				for (i in nameGroup) {i.autoOffset = false;
					for (j in i) {j.offset.set(0,0); j.scale.set(new FlxRandom().float(0.4,2),new FlxRandom().float(0.4,2));
						FlxTween.tween(j, {x: j.x + new FlxRandom().int(-1750, 1750), y: j.y + new FlxRandom().int(-1750, 1750), angle: new FlxRandom().int(360, -360)}, 5, {ease: FlxEase.quadOut});}}
				new FlxTimer().start(5.1, function(tmr:FlxTimer) {
					FlxG.sound.play(Paths.sound("rumble"));
					FlxG.sound.play(Paths.sound("piecedTogether"));
					FlxG.camera.fade(0xFFFFFF, 3.8, false, function() {#if windows Sys.exit(0); #end});
					for (i in nameGroup) 
						for (j in i) FlxTween.tween(j, {x: new FlxRandom().float(495, 515), y: new FlxRandom().float(275, 300)}, new FlxRandom().float(1, 3), {ease: FlxEase.quintInOut});
				});
			});
			FlxG.sound.play(Paths.sound("rumble"));	
			antiSpam = true;
			for (j in nameGroup)
					j.scale.set(FlxMath.lerp(j.scale.x, (4 - Math.abs(j.ID - curSelected)) * (0.3 - (j.text.length * 0.01)), 1), FlxMath.lerp(j.scale.y, (4 - Math.abs(j.ID - curSelected)) * (0.3 - (j.text.length * 0.01)), 1));
		}
		if (new FlxRandom().bool(20 * keyCount)) FlxG.sound.play(Paths.sound("thud"));
		curSelected = (curSelected > nameGroup.length - 1 ? 0 : (curSelected < 0 ? nameGroup.length - 1 : curSelected));
		FlxG.sound.music.volume = 0.2 * (5-keyCount);
		largePortrait.loadGraphic(Paths.image("roncredits/" + creditJSON[curSelected].name));
		largePortrait.setGraphicSize(350, 350);
		largePortrait.updateHitbox();
		descText.text = (creditJSON[curSelected].name==new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("frak")).decodeString("rkfkrkrkrakkrkfararf")?new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("sz")).decodeString("szzszsszszzszzszsszsssssszzzsszzszzzszssszzzszszszzzssssszzszsszszzsszsssszsssssszzsssszszzsszzssszsssssszzsssszszzszzssszzzsszzszzszzzzsszsssssszzsszzsszzzsszsszzsssszszzszszzszzszsszszzzszssszzzsszzsszsssssszzszsszszzzsszzsszsssssszzsszzzszzszzzzszzsssszszzzszssszzsszszszzsszss"):creditJSON[curSelected].description);
		if (creditJSON[curSelected].social_link != null) {
			var bitmap = BitmapData.loadFromFile('http://www.google.com/s2/favicons?domain=${creditJSON[curSelected].social_link}&sz=32');
			bitmap.onComplete(function(bitmap) {
				socialMediaFavicon.loadGraphic(bitmap);
				socialMediaFavicon.visible = true;
			});
			socialMediaText.text = "Press enter to open social media link";
		}
		else {
			socialMediaText.text = "Theres no social media link";
			socialMediaFavicon.visible = false;
		}
			
	}
}