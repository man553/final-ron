package misc;

import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var GrayScale:ShaderFilter = new ShaderFilter(new GrayScale());
	public static var CrtEffect:ShaderFilter = new ShaderFilter(new CrtEffect());
	public static var Rain:ShaderFilter = new ShaderFilter(new RainShader());
	public static var MotionShader:ShaderFilter = new ShaderFilter(new MotionBlur());

	
}