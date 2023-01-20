uniform float rOffset;
uniform float gOffset;
uniform float bOffset;
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv=openfl_TextureCoordv;
    // Output to screen
	gl_FragColor = texture2D(bitmap,uv);
    gl_FragColor.rgb = vec3(texture2D(bitmap,vec2(uv.x-rOffset,uv.y)).r,texture2D(bitmap,vec2(uv.x-gOffset,uv.y)).g,texture2D(bitmap,vec2(uv.x - bOffset,uv.y)).b);
}