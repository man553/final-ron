package;

import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var GrayScale:ShaderFilter = new ShaderFilter(new GrayScale());
	public static var CrtEffect:ShaderFilter = new ShaderFilter(new CrtEffect());
	public static var MosaicShader:ShaderFilter = new ShaderFilter(new MosaicShader());

	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}
}