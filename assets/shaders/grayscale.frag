void main()
{
    vec2 uv = openfl_TextureCoordv;

    //made my own grayscale shader cuz the current one is dogshit
    gl_FragColor = texture2D(bitmap, uv);
    gl_FragColor.rgb = vec3(float(gl_FragColor.rgb), float(gl_FragColor.rgb), float(gl_FragColor.rgb));
}