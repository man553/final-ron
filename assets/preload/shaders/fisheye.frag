
#define MAX_POWER 0.2 // negative : anti fish eye. positive = fisheye

//Inspired by http://stackoverflow.com/questions/6030814/add-fisheye-effect-to-images-at-runtime-using-opengl-es
void main()//Drag mouse over rendering area
{
	vec2 p = (openfl_TextureCoordv * openfl_TextureSize.xy) / openfl_TextureSize.x;//normalized coords with some cheat
	                                                         //(assume 1:1 prop)
	float prop = openfl_TextureSize.x / openfl_TextureSize.y;//screen proroption
	vec2 m = vec2(0.5, 0.5 / prop);//center coords
	vec2 d = p - m;//vector from center to current fragment
	float r = sqrt(dot(d, d)); // distance of pixel from center

	float power = MAX_POWER * -1.3;

	float bind;//radius of 1:1 effect
	if (power > 0.0) 
        bind = sqrt(dot(m, m));//stick to corners
	else {if (prop < 1.0) 
        bind = m.x; 
    else 
        bind = m.y;}//stick to borders

	//Weird formulas
	vec2 uv;
	if (power > 0.0)//fisheye
		uv = m + normalize(d) * tan(r * power) * bind / tan( bind * power);
	else if (power < 0.0)//antifisheye
		uv = m + normalize(d) * atan(r * -power * 10.0) * bind / atan(-power * bind * 10.0);
	else uv = p;//no effect for power = 1.0
        
    uv.y *= prop;

	vec4 col = texture2D(bitmap, uv);
    
    // inverted
	//vec3 col = texture(iChannel0, vec2(uv.x, 1.0 - uv.y)).rgb;//Second part of cheat
	                                                  //for round effect, not elliptical
	gl_FragColor = col;
}