package options;

class RonSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Ron Settings';
		rpcTitle = 'Ron Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Website Opening', //Name
			'If checked, some songs may open websites in your browser.', //Description
			'siteenable', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('RGB Enabled', //Name
			'Enables a RGB shader in some songs.', //Description
			'rgbenable', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		var option:Option = new Option('RGB Intensity',
			'The intensity of the RGB shader. (only works if above is enabled)',
			'rgbintense',
			'float',
			1);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 2;
		option.changeValue = 0.1;
		option.decimals = 1;

		super();
	}
}