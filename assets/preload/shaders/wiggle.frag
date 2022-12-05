#pragma header
uniform float length = 35.;
uniform float intensityReversed = 50. * 10.;
uniform float speed = 15.;
uniform float iTime;
void main()
{

    vec2 uv = getCamPos(openfl_TextureCoordv);
    uv.x += sin( uv.y * length + (speed * iTime)) / intensityReversed * uv.y;
    uv.y += sin( uv.x * length + (speed * iTime)) / intensityReversed * 0.5 * uv.y;

    gl_FragColor = textureCam(bitmap, uv);
}