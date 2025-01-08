package funkin.backend.scripting.lua;

import funkin.menus.credits.CreditsMain;
import funkin.menus.*;

final class StateFunctions {
	public static function getStateFunctions(?script:Script):Map<String, Dynamic> {
		return [
			"switchState" => function(state:String, ?data:Dynamic) {
				switch(state.toLowerCase()) {
					case "playstate" | "play":
						FlxG.switchState(new PlayState());
					case "mainmenustate" | "mainmenu":
						FlxG.switchState(new MainMenuState());
					case "freeplaystate" | "freeplay":
						FlxG.switchState(new FreeplayState());
					case "storymenustate" | "storymenu":
						FlxG.switchState(new StoryMenuState());
					case "betawarningstate" | "betawarning":
						FlxG.switchState(new BetaWarningState());
					case "creditsstate" | "creditsmain" | "credits":
						FlxG.switchState(new CreditsMain());
					default:
						FlxG.switchState(new ModState(state, data ?? null));
				}
			},
			"resetState" => function() {
				FlxG.resetState();
			}
		];
	}
}