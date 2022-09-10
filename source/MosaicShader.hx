package;

import flixel.system.FlxAssets.FlxShader;

class MosaicShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float uBlocksize;

		void main()
		{
			vec2 blocks = openfl_TextureSize / (uBlocksize + 1);
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')
	public function new()
	{
		super();
	}
}