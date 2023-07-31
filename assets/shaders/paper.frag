uniform float iTime;
float rand(float x)
{
    return fract(sin(x) * 43758.5453);
}
void main()
{
    float time = floor(iTime * 16.0) / 16.0;
    vec2 uv = openfl_TextureCoordv;
    // pixel position
    vec2 p = uv;    
    p += vec2(rand(p.x * 3.1 + p.y * 8.7) * 0.005,
              rand(p.x * 1.1 + p.y * 6.7) * 0.005);
    vec4 baseColor = texture2D(bitmap, uv);
    vec4 edges = 1.0 - baseColor / texture2D(bitmap,p);
    baseColor.rgb = vec3(baseColor.r);    
    gl_FragColor = baseColor / vec4(length(edges));
}