package funkin.menus;

import haxe.Json;
import funkin.backend.FunkinText;
import funkin.menus.credits.CreditsMain;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import funkin.backend.scripting.events.*;

import funkin.options.OptionsMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = CoolUtil.coolTextFile(Paths.txt("config/menuItems"));

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public var canAccessDebugMenus:Bool = true;

	override function create()
	{
		super.create();

		DiscordUtil.changePresence("In the Menus", null);

		CoolUtil.playMenuSong();

		var bg:FlxSprite = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuBG'));
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadAnimatedGraphic(Paths.image('menus/menuDesat'));
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		for(bg in [bg, magenta]) {
			bg.scrollFactor.set(0, 0.18);
			bg.scale.set(1.15, 1.15);
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = true;
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i=>option in optionShit)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = Paths.getFrames('menus/mainmenu/${option}');
			menuItem.animation.addByPrefix('idle', option + " basic", 24);
			menuItem.animation.addByPrefix('selected', option + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FunkinText = new FunkinText(5, FlxG.height - 2, 0, 'Codename Engine v${Application.current.meta.get('version')}\nCommit ${funkin.backend.system.macros.GitCommitMacro.commitNumber} (${funkin.backend.system.macros.GitCommitMacro.commitHash})\n[TAB] Open Mods menu\n');
		versionShit.y -= versionShit.height;
		versionShit.scrollFactor.set();
		add(versionShit);

		changeItem();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!selectedSomethin)
		{
			if (canAccessDebugMenus) {
				if (FlxG.keys.justPressed.SEVEN) {
					persistentUpdate = false;
					persistentDraw = true;
					openSubState(new funkin.editors.EditorPicker());
				}
				/*
				if (FlxG.keys.justPressed.SEVEN)
					FlxG.switchState(new funkin.desktop.DesktopMain());
				if (FlxG.keys.justPressed.EIGHT) {
					#if sys
					sys.io.File.saveContent("chart.json", Json.stringify(funkin.backend.chart.Chart.parse("dadbattle", "hard")));
					#end
				}
				*/
			}

			if (controls.UP_P)
				changeItem(-1);

			if (controls.DOWN_P)
				changeItem(1);

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			#if MOD_SUPPORT
			// make it customisable
			if (controls.SWITCHMOD) {
				openSubState(new ModSwitchMenu());
				persistentUpdate = false;
				persistentDraw = true;
			}
			#end

			if (controls.ACCEPT)
			{
				selectItem();
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	public override function switchTo(nextState:FlxState):Bool {
		try {
			menuItems.forEach(function(spr:FlxSprite) {
				FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.quintOut});
			});
		}
		return super.switchTo(nextState);
	}

	function selectItem() {
		selectedSomethin = true;
		CoolUtil.playMenuSFX(CONFIRM);

		if (Options.flashingMenu) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		FlxFlicker.flicker(menuItems.members[curSelected], 1, Options.flashingMenu ? 0.06 : 0.15, false, false, function(flick:FlxFlicker)
		{
			var daChoice:String = optionShit[curSelected];

			var event = event("onSelectItem", EventManager.get(NameEvent).recycle(daChoice));
			if (event.cancelled) return;
			switch (daChoice)
			{
				case 'story mode': FlxG.switchState(new StoryMenuState());
				case 'freeplay': FlxG.switchState(new FreeplayState());
				case 'donate': FlxG.switchState(new CreditsMain());
				case 'options': FlxG.switchState(new OptionsMenu());
			}
		});
	}
	function changeItem(huh:Int = 0)
	{
		var event = event("onChangeItem", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + huh, 0, menuItems.length-1), huh, huh != 0));
		if (event.cancelled) return;

		curSelected = event.value;

		if (event.playMenuSFX)
			CoolUtil.playMenuSFX(SCROLL, 0.7);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var mid = spr.getGraphicMidpoint();
				camFollow.setPosition(mid.x, mid.y);
				mid.put();
			}

			spr.updateHitbox();
			spr.centerOffsets();
		});
	}
}
