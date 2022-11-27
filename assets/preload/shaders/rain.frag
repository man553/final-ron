#define PI 3.14159265358979
uniform float iTime;
uniform float opacity;
uniform float zoom;
uniform float raindropLength;
float rnd(float t) {
  return fract(sin(t*745.523)*7894.552);
}
float rain(vec3 p) {

  p.y += iTime*12.;
  p.xy *= zoom;
  
  p.y += rnd(floor(p.x))*1500.0;
  
  return clamp(1.0-length(vec2(cos(p.x * PI + (15. * iTime)), sin(p.y*raindropLength) - (2. - opacity))), 0.0, 1.0);
}
void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = openfl_TextureCoordv;

    // Time varying pixel color
    vec4 col = texture2D(bitmap, uv);
    //col = vec3(rain(vec3(-uv,5)));
    col += rain(vec3(-uv*2.3,5)) * 0.5;
    col += rain(vec3(-uv*4.7,5)) * 0.25;
    col += rain(vec3(-uv*4.7,5)) * 0.05;
    // Output to screen
    gl_FragColor = col;
}