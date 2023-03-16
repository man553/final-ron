uniform float iTime;
float rayStrength(vec2 raySource, vec2 rayRefDirection, vec2 coord, float seedA, float seedB, float speed)
{
    vec2 sourceToCoord = coord - raySource;
    float cosAngle = dot(normalize(sourceToCoord), rayRefDirection);
    
    return clamp(
        (0.45 + 0.15 * sin(cosAngle * seedA + iTime * speed)) +
        (0.3 + 0.2 * cos(-cosAngle * seedB + iTime * speed)),
        0.0, 1.0) *
        clamp((openfl_TextureSize.x - length(sourceToCoord)) / openfl_TextureSize.x, 0.5, 1.0);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec2 coord = vec2(openfl_TextureCoordv.x*openfl_TextureSize.x,openfl_TextureCoordv.y*openfl_TextureSize.y);
    
    
    // Set the parameters of the sun rays
    vec2 rayPos1 = vec2(openfl_TextureSize.x * 0.7, openfl_TextureSize.y * -0.4);
    vec2 rayRefDir1 = normalize(vec2(1.0, -0.116));
    float raySeedA1 = 36.2214;
    float raySeedB1 = 21.11349;
    float raySpeed1 = 1.5;
    
    vec2 rayPos2 = vec2(openfl_TextureSize.x * 0.8, openfl_TextureSize.y * -0.6);
    vec2 rayRefDir2 = normalize(vec2(1.0, 0.241));
    const float raySeedA2 = 22.39910;
    const float raySeedB2 = 18.0234;
    const float raySpeed2 = 1.1;
    
    // Calculate the colour of the sun rays on the current fragment
    vec4 rays1 =
        vec4(1.0, 1.0, 1.0, 1.0) *
        rayStrength(rayPos1, rayRefDir1, coord, raySeedA1, raySeedB1, raySpeed1);
     
    vec4 rays2 =
        vec4(1.0, 1.0, 1.0, 1.0) *
        rayStrength(rayPos2, rayRefDir2, coord, raySeedA2, raySeedB2, raySpeed2);
    
    gl_FragColor = rays1 * 0.5 + rays2 * 0.4;
    
    // Attenuate brightness towards the bottom, simulating light-loss due to depth.
    // Give the whole thing a blue-green tinge as well.
    float brightness = 1.0 - (coord.y / openfl_TextureSize.y);
    gl_FragColor.x *= 0.1 + (brightness * 0.8);
    gl_FragColor.y *= 0.3 + (brightness * 0.6);
    gl_FragColor.z *= 0.5 + (brightness * 0.5);
    gl_FragColor.rgb += texture2D(bitmap,uv).rgb * (1. - float(gl_FragColor.rgb));
}