#define hue(v)  ( .6 + .6 * cos( 6.3*(v)  + vec4(0,23,21,0)  ) )  // https://www.shadertoy.com/view/ll2cDc

void mainImage( out vec4 O, vec2 u )
{
    vec2  R = iResolution.xy, P,
          U = ( 2.*u - R ) / R.y;
    
    float t = iTime;
    O-=O;
    for(float i=0.; i<1.; i+=.1) {                                // --- drawing balls
       t *= 1.2;
       P = vec2( 1.2*cos(2.*t), .8*sin(3.1*t) );     
       O += smoothstep(3./R.y, 0., length(P-U) - .15 ) * hue(i);
   }
}
