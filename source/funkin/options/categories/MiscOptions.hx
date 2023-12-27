package funkin.options.categories;


class MiscOptions extends OptionsScreen {
	public override function new() {
		super("Miscellaneous", "Use this menu to reset save data or engine settings.");
		#if UPDATE_CHECKING
		add(new Checkbox(
			"Enable Nightly Updates",
			"If checked, will also include nightly builds as updates.",
			"betaUpdates"));,
		add(new TextOption(
			"Check for Updates",
			"Select this option to check for new updates to the engine.",
			function() {
				var report = funkin.backend.system.updating.UpdateUtil.checkForUpdates();
				if (report.newUpdate) {
					FlxG.switchState(new funkin.backend.system.updating.UpdateAvailableScreen(report));
				} else {
					CoolUtil.playMenuSFX(CANCEL);
					updateDescText("No updates found, try again later.");
				}
		}));,
		#end
		add(new TextOption(
			"Reset Save Data",
			"Select this option to reset save data. This will remove all of your highscores",
			function() {
				updateDescText("SAVE DATA RESETTING COMING SOON!!!");
				// TODO: SAVE DATA RESETTING
		}));
	}
}
