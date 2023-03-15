#pragma header

const int NumSamples = 10;
uniform float Density = 0.1f;
uniform float Weight = 0.02f;
uniform float illuminationDecay = 0.9f;

void main()
{
    vec2 uv = getCamPos(openfl_TextureCoordv);

    //delta between current pixel and light position
    vec2 delta = uv - vec2(0.5);
    
    //define sampling step
    delta *= 1.0f / float(NumSamples) * Density;
    
    //initial color
    vec3 color = textureCam(bitmap, uv).rgb;
    
    float illuminationDecay = 0.9f;
    
    for(int i = 0; i < NumSamples; i++)
    {
        //peform sampling step
        uv -= delta;
        
        //decay the ray
        vec3 color_sample = textureCam(bitmap, uv).rgb;
        
        color_sample *= illuminationDecay * Weight;
        
        //original color + ray sample
        color += color_sample;
    }

    // Output to screen
    gl_FragColor = vec4(color, 1);
}