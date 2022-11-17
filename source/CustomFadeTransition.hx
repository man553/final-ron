package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.TransitionStatus;
import flixel.addons.transition.TransitionData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		transGradient = new FlxSprite().makeGraphic(width, height, FlxColor.BLACK);
		transGradient.scrollFactor.set();
		//add(transGradient);

		transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		//add(transBlack);

		transGradient.x -= (width - FlxG.width) / 2;
		transBlack.x = transGradient.x;

		//if(isTransIn) {
		//	transGradient.y = transBlack.y - transBlack.height;
		//	FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
		//		onComplete: function(twn:FlxTween) {
		//			close();
		//		},
		//	ease: FlxEase.linear});
		//} else {
		//	transGradient.y = -transGradient.height;
		//	transBlack.y = transGradient.y - transBlack.height + 50;
		//	leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
		//		onComplete: function(twn:FlxTween) {
		//			if(finishCallback != null) {
		//				finishCallback();
		//			}
		//		},
		//	ease: FlxEase.linear});
		//}
		var transData = new TransitionData(cast "tiles", 0xFF000000, duration, new FlxPoint(0,1));
		transData.tileData = {width: 32, height: 32, asset: FlxGraphic.fromBitmapData(new GraphicTransTileCircle(0, 0, true, 0xFF000000))};
		var transitional = new Transition(transData);
		add(transitional);
		new FlxTimer().start(duration, function(tmr:FlxTimer) {if(!isTransIn && finishCallback != null)finishCallback(); else close();});
		//transitional.setStatus(isTransIn?TransitionStatus.OUT:TransitionStatus.IN);
		transitional.start(isTransIn?TransitionStatus.OUT:TransitionStatus.IN);

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transGradient.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		if(isTransIn) {
			transBlack.y = transGradient.y + transGradient.height;
		} else {
			transBlack.y = transGradient.y - transBlack.height;
		}
		super.update(elapsed);
		if(isTransIn) {
			transBlack.y = transGradient.y + transGradient.height;
		} else {
			transBlack.y = transGradient.y - transBlack.height;
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}