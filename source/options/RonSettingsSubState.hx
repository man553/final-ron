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

		super();
	}
}