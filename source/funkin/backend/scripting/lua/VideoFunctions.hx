package funkin.backend.scripting.lua;

import flixel.util.FlxTimer;
import hxvlc.flixel.FlxVideoSprite;

class VideoFunctions {
	public static function getVideoFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic> {
		return [
			"createVideo" => function(name:String, ?videoPath:String = null, ?ext:String = "mp4", ?x:Float = 0, ?y:Float = 0) {
				if(instance.luaObjects["VIDEOS"].exists(name))
					return;

				var theVideo:FlxVideoSprite = new FlxVideoSprite(x, y);
				if(videoPath != null && videoPath.length > 0) {
					if(!theVideo.load(Paths.video(videoPath, ext))) return;
				}

				instance.luaObjects["VIDEOS"].set(name, theVideo);
				cast(script, LuaScript).set(name, theVideo);
			},
			"loadVideo" => function(name:String, ?videoPath:String = null, ?ext:String = "mp4") {
				var video:FlxVideoSprite = LuaTools.getObject(instance, name);

				if(video != null) {
					if(videoPath != null && videoPath.length > 0) {
						if(!video.load(Paths.video(videoPath, ext))) return;
					}
				}
			},
			"playVideo" => function(name:String, ?volume:Int) {
				var video:FlxVideoSprite = LuaTools.getObject(instance, name);

				if(video != null) {
					if(volume != null) {
						video.autoVolumeHandle = false;
						video.bitmap.volume = Std.int(FlxMath.bound(volume, 0, 100));
					}
					new FlxTimer().start(0.001, (_) -> video.play());
				}
			},
			"pauseVideo" => function(name:String) {
				var video:FlxVideoSprite = LuaTools.getObject(instance, name);

				if(video != null) 
					video.pause();
			},
			"resumeVideo" => function(name:String) {
				var video:FlxVideoSprite = LuaTools.getObject(instance, name);

				if(video != null) 
					video.resume();
			},
			"stopVideo" => function(name:String) {
				var video:FlxVideoSprite = LuaTools.getObject(instance, name);

				if(video != null) 
					video.stop();
			}
		];
	}
}