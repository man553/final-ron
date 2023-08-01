package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxRect;
import flixel.input.keyboard.FlxKey;
import flixel.FlxCamera;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.math.FlxPoint;

import lime.ui.WindowAttributes;
import lime.ui.Window;

import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;

class WindowShit extends Sprite{
    public var window:Window;
	private var inputContainer:Sprite;
	public static var cameras(default, null):CameraFrontEnd;
	public var camera:FlxCamera;
    public var isNull:Bool = true;

	public function new(x:Int, y:Int, width:Int, height:Int, title:String = "Debug", frameRate:Int = 0)
	{
		super();
		inputContainer = new Sprite();
		var attributes:WindowAttributes = {
			allowHighDPI: false,
            alwaysOnTop: false,
            borderless: false,
            element: null,
            frameRate: frameRate == 0 ? ClientPrefs.framerate : 60,
            fullscreen: false,
            height: height,
            hidden: false,
            maximized: false,
            minimized: false,
            parameters: {},
            resizable: true,
            title: title,
            width: width,
            x: null,
            y: null
		};
		attributes.context = {
			antialiasing: 0,
			background: 0,
			colorDepth: 32,
			depth: true,
			hardware: true,
			stencil: true,
			type: null,
			vsync: false
		};
		window = FlxG.stage.application.createWindow(attributes);
		window.stage.color = FlxColor.ORANGE;
		camera = new FlxCamera(0, 0, width, height);
		addEventListener(Event.ADDED_TO_STAGE, create);
        isNull = false;
        addEventListener(Event.REMOVED_FROM_STAGE, (_) -> {
            window = null;
            inputContainer = null;
            cameras = null;
            camera = null;
            isNull = true;
            trace("closed");
        });
	}
	private function create(_):Void
	{
		trace('create called stage=${stage}');
		removeEventListener(Event.ADDED_TO_STAGE, create);
		if (stage == null)
		{
			trace('stage is null');
            isNull = true;
			return;
		}
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = FlxG.drawFramerate;
		addChild(inputContainer);
		addChildAt(camera.flashSprite, getChildIndex(inputContainer));
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(_):Void
	{
		camera.update(FlxG.elapsed);
		draw();
	}

	@:access(flixel.FlxCamera.render)
	private function draw():Void
	{
		camera.update(FlxG.elapsed);
		FlxDrawBaseItem.drawCalls = 0;
        camera.canvas.graphics.clear();
		camera.flashSprite.graphics.clear();
		camera.fill(camera.bgColor.to24Bit(), camera.useBgAlphaBlending, camera.bgColor.alphaFloat);
		camera.render();
	}

    //our midpoint to writing to this is the camera
    public function addObject<Type>(sprite:Type):Void {
        //either an flxsprite or a child of it
        if (Type is FlxSprite)
            cast(sprite, FlxSprite).cameras = [camera];
        else trace("Doesn't extend FlxSprite.");
    }
}