#pragma header
uniform float uTime;
uniform float uSpeed;
uniform float uFrequency;
uniform float uWaveAmplitude;

void main()
{
	// Get the UV Coordinate of your texture or Screen Texture, yo!
	vec2 uv = openfl_TextureCoordv;
	
    uv.x += sin(uv.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / uv.x * uv.y);
	uv.y += sin(uv.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / uv.y * uv.x);
	
	// Get the pixel color at the index.
	vec4 color = flixel_texture2D(bitmap, uv);
	
	gl_FragColor = color;
}