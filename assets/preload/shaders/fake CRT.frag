void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = openfl_TextureCoordv;
	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;	
	uv.x *= 1.0 + pow((abs(uv.y) / 10.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 8.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
    // Time varying pixel color
    vec4 col = texture2D(bitmap,uv);
    vec2 d = abs((uv - 0.5) * 1.2);
    d = pow(d, vec2(5., 1.3));
    col.rgb -= d.x + d.y;
    if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;
	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;
    // Output to screen
    gl_FragColor = col;
}