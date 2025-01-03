package funkin.backend.scripting.lua;
#if ENABLE_LUA
import funkin.backend.system.Conductor;
import funkin.backend.scripting.lua.LuaTools;
import funkin.backend.chart.ChartData.ChartEvent;
import funkin.game.PlayState;
import flixel.FlxG;

final class LuaPlayState {

	public static function getPlayStateVariables(?script:Script):Map<String, Dynamic> {
		return [
			// PlayState property things 
			"chartingMode"		=> PlayState.chartingMode,
			"curBpm" 			=> Conductor.bpm,
			"songBpm" 			=> PlayState.SONG.meta.bpm,
			"scrollSpeed" 		=> PlayState.SONG.scrollSpeed,
			"crochet" 			=> Conductor.crochet,
			"stepCrochet" 		=> Conductor.stepCrochet,
			"songLength" 		=> FlxG.sound.music?.length ?? 0.0,
			"songName" 			=> PlayState.SONG.meta.name,
			"startedCountdown" 	=> PlayState.instance.startedCountdown,
			"stage" 			=> PlayState.SONG.stage,
			"storyMode" 		=> PlayState.isStoryMode,
			"difficulty" 		=> PlayState.difficulty,
			"week" 				=> PlayState.storyWeek?.name ?? "",
			"seenCutscene" 		=> PlayState.seenCutscene,
			"needVoices" 		=> PlayState.SONG.meta.needsVoices,
			// Camera
			"camX" 			=> 0,
			"camY" 			=> 0,
			// Game Screen
			"gameWidth" 	=> FlxG.width,
			"gameHeight" 	=> FlxG.height,

			// Variables
			"curBeat" 		=> 0,
			"curBeatFloat" 	=> 0.0,
			"curStep" 		=> 0,
			"curStepFloat" 	=> 0.0,

			"score" 		=> 0,
			"misses" 		=> 0,
			"hits" 			=> 0,
			"combo" 		=> 0,

			"rating" 		=> '',

			"inGameOver" 	=> false,
			
			"healthGainMulti" => 1.0,
			"healthLossMulti" => 1.0,

			"botPlay" 		=> PlayState.instance.playerStrums?.cpu ?? false,
			
			// TODO: playerStrum/opponentStrum position
			// Haxe 4.3.0+ null checks
			"boyfriendName" => PlayState.SONG.strumLines[1]?.characters[0],
			"boyfriendX" 	=> PlayState.instance.stage.characterPoses['boyfriend'].x,
			"boyfriendY" 	=> PlayState.instance.stage.characterPoses['boyfriend'].y,
			"boyfriendRawX" => PlayState.instance.boyfriend?.x ?? 0,
			"boyfriendRawY" => PlayState.instance.boyfriend?.y ?? 0,
			"dadName" 		=> PlayState.SONG.strumLines[0]?.characters[0],
			"dadX" 			=> PlayState.instance.stage.characterPoses['dad'].x,
			"dadY" 			=> PlayState.instance.stage.characterPoses['dad'].y,
			"dadRawX" 		=> PlayState.instance.dad?.x ?? 0,
			"dadRawY" 		=> PlayState.instance.dad?.y ?? 0,
			"girlfriendName" => PlayState.SONG.strumLines[2]?.characters[0] ?? "",
			"girlfriendX" 	=> PlayState.instance.stage.characterPoses['girlfriend']?.x ?? 0,
			"girlfriendY" 	=> PlayState.instance.stage.characterPoses['girlfriend']?.y ?? 0,
			"girlfriendRawX" => PlayState.instance.gf?.x ?? 0,
			"girlfriendRawY" => PlayState.instance.gf?.y ?? 0
		];
	}

	public static function getPlayStateFunctions(?script:Script):Map<String, Dynamic> {
		return [
			"startCutscene" => function(prefix:String, ?cutsceneScriptPath:String) {
				PlayState.instance.startCutscene(prefix, cutsceneScriptPath, () -> {
					PlayState.instance.scripts.luaCall("onStartCutscene", [prefix]);
				});
			},
			"callFunction" => function(func:String, ?args:Array<Dynamic>) {
				PlayState.instance.scripts.call(func, args);
				return;
			},
			"executeEvent" => function(event:String, args:Array<String>){
				var event:ChartEvent = {name: event, time: Conductor.songPosition, params: args};
				PlayState.instance.executeEvent(event);
			},
			"shake" => function(camera:String, ?amount:Float = 0.05, ?time:Float = 0.5) {
				LuaTools.getCamera(camera.toLowerCase()).shake(amount, time);
			}
		];
	}
}
#end
