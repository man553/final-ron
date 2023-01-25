uniform sampler2D bitmap;

void main()
{
	//put in the finished shader code here
    gl_FragColor = texture2D(bitmap, uv) / 1.5;
}