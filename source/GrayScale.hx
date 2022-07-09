package;

import flixel.system.FlxAssets.FlxShader;

class GrayScale extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st);
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st);
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st);
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.r;
			toUse.b = col3.r;

			gl_FragColor = toUse;
		}')
	public function new()
	{
		super();
	}
}