uniform sampler2D bitmap;

void main()
{

    vec2 uv = openfl_TextureCoordv;
    gl_FragColor = texture2D(bitmap, uv) / 1.5;
    vec2 Radius = 15./openfl_TextureSize.xy;
    for( float d=0.0; d<6.28318530718; d+=6.28318530718/16.)
    {
        for(float i=1.0; i<=1.0; i+=1.0/3.)
        {
            gl_FragColor += (texture2D(bitmap, uv+vec2(cos(d),sin(d))*Radius*i) / 100) * 2;        
        }
    }
    gl_FragColor.rgb = vec3(sin(gl_FragColor.r) * 0.5, sin(gl_FragColor.g) * 0.3, sin(gl_FragColor.b) * 0.1) * 4.;
    gl_FragColor.rgb *= float(gl_FragColor.rgb) * 0.5;
    gl_FragColor.rgb *= cos(texture2D(bitmap, vec2(uv.x, uv.y + 0.005)).rgb);
    gl_FragColor = texture2D(bitmap, uv) / 1.5;
}
