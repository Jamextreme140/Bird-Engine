package funkin.backend.scripting.lua;

import flixel.sound.FlxSound;

final class SoundFunctions {
	public static function getSoundFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"playSound" => function(name:String, file:String, ?volume:Float = 100, ?looped:Bool = false, ?destroy:Bool = true) {
				var finalVolume:Float = FlxMath.bound(volume, 0, 100) / 100;
				if(name.trim().length == 0) {
					FlxG.sound.play(Paths.sound(file), finalVolume);
					return;
				}
				
				if(instance.luaObjects["SOUNDS"].exists(name)) {
					var sound:FlxSound = instance.luaObjects["SOUNDS"].get(name);
					sound.play(true);
				}
				else{
					instance.luaObjects["SOUNDS"].set(name, FlxG.sound.play(Paths.sound(file), finalVolume, looped, null, destroy, () -> {
						if(!looped && destroy) {
							instance.luaObjects["SOUNDS"].remove(name);
						}
						script.call("onSoundFinish", [name]);
					}));
				}
			},
			"stopSound" => function(name:String, ?destroy:Bool = true) {
				if(instance.luaObjects["SOUNDS"].exists(name)) {
					var sound:FlxSound = instance.luaObjects["SOUNDS"].get(name);
					sound.stop();
					if(destroy) {
						instance.luaObjects["SOUNDS"].remove(name);
						sound.destroy();
					}
				}
			},
			"pauseSound" => function(name:String) {
				if(name.trim().length == 0) return;
				if(instance.luaObjects["SOUNDS"].exists(name)) {
					var sound:FlxSound = instance.luaObjects["SOUNDS"].get(name);
					sound.pause();
				}
			},
			"resumeSound" => function(name:String) {
				if(name.trim().length == 0) return;
				if(instance.luaObjects["SOUNDS"].exists(name)) {
					var sound:FlxSound = instance.luaObjects["SOUNDS"].get(name);
					sound.resume();
				}
			}
		];
	}
}