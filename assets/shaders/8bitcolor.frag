#define color_bits vec3( 2, 2, 2 )
#define color_values exp2( color_bits )
#define color_rvalues (1. / color_values)
#define color_maxValues (color_values - 1.)
#define color_rmaxValues (1. / color_maxValues)
#define color_positions vec3( 1., color_values.x, color_values.x*color_values.y )
#define color_rpositions (65535. / color_positions)
uniform float enablethisbitch;
float encodeColor(vec3 a){
	const vec3 maxValues  = color_maxValues;
	const vec3 constant1  = color_positions / 65535.;

	return dot( floor( a * color_maxValues + .5 ), constant1 );
}
vec3 decodeColor(float a){
	const vec3 constant1 = color_rpositions / color_values;
	const vec3 constant2 = color_values * color_rmaxValues;

	return fract( a * constant1 ) * constant2;
}

void main(){
	vec2 uv = openfl_TextureCoordv;
	if (enablethisbitch == 1.) {
		gl_FragColor = texture2D(bitmap,uv);
		gl_FragColor.r = encodeColor(texture2D(bitmap,uv).rgb);
		gl_FragColor.rgb = decodeColor(gl_FragColor.r);
	}
	else gl_FragColor = texture2D(bitmap,uv);
}