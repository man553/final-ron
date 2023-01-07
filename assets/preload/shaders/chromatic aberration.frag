uniform float rOffset;
uniform float gOffset;
uniform float bOffset;
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    // Output to screen
    fragColor.rgb = vec3(texture(iChannel0,vec2(uv.x-rOffset,uv.y)).r,texture(iChannel0,vec2(uv.x-gOffset,uv.y)).g,texture(iChannel0,vec2(uv.x - bOffset,uv.y)).b);
}