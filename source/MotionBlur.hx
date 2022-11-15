package;

import flixel.system.FlxAssets.FlxShader;

class MotionBlur extends FlxShader
{
	@:glFragmentSource('
		#define PI 3.14159265359
		#define rot(a) mat2(cos(a + PI*0.5*vec4(0,1,3,0)))

		float hash13(vec3 p3) {
			p3  = fract(p3 * .1031);
			p3 += dot(p3, p3.yzx + 19.19);
			return fract((p3.x + p3.y) * p3.z);
		}
		
		vec3 scene(vec2 fragCoord, float time) {
			vec2 uv = fragCoord - iResolution.xy*0.5;
			uv /= iResolution.y;
			uv *= 3.0;
			uv *= rot(time*10.0 + (sin(time*2.0)*0.5+0.5)*10.0);
			uv = abs(uv);
			float sd = max(uv.x-0.5, uv.y-1.5);
			return vec3(smoothstep(0.0, 0.04, sd));
		}

		void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
			vec3 result = vec3(0);
			
			bool motionBlur = true; // change this
			if ( motionBlur ) {
				#define BLUR 30
				for (int i = 0 ; i < BLUR ; i++) {
					float rnd = hash13(vec3(fragCoord, iFrame*100+i));
					float time = iTime + rnd / 60.0;
					result += scene(fragCoord, time);
				}
				result /= float(BLUR);
			} else {
				result = scene(fragCoord, iTime);
			}
			
			fragColor.rgb = pow(result, vec3(1.0/2.2));
			fragColor.a = 1.0;
		}
	')
}

