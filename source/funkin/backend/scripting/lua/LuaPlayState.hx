package funkin.backend.scripting.lua;
#if ENABLE_LUA
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.Conductor;
import funkin.backend.scripting.lua.LuaTools;
import funkin.backend.chart.ChartData.ChartEvent;
import funkin.game.PlayState;
import funkin.options.Options;
import flixel.util.typeLimit.OneOfThree;
import flixel.FlxG;

class LuaPlayState {

	public static function getPlayStateVariables(?script:Script):Map<String, Dynamic> {
		return [
			// PlayState property things 
			"curBpm" 			=> Conductor.bpm,
			"songBpm" 			=> PlayState.SONG.meta.bpm,
			"scrollSpeed" 		=> PlayState.SONG.scrollSpeed,
			"crochet" 			=> Conductor.crochet,
			"stepCrochet" 		=> Conductor.stepCrochet,
			"songLength" 		=> FlxG.sound.music.length,
			"songName" 			=> PlayState.SONG.meta.name,
			"startedCountdown" 	=> PlayState.instance.startedCountdown,
			"stage" 			=> PlayState.SONG.stage,
			"storyMode" 		=> PlayState.isStoryMode,
			"difficulty" 		=> PlayState.difficulty,
			//"week" 			=> PlayState.storyWeek.name,
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

			//"botPlay" 		=> PlayState.instance.playerStrums.cpu,
			
			// TODO: playerStrum/opponentStrum position

			"boyfriendName" => PlayState.SONG.strumLines[1].characters[0],
			"boyfriendX" 	=> PlayState.instance.stage.characterPoses['boyfriend'].x,
			"boyfriendY" 	=> PlayState.instance.stage.characterPoses['boyfriend'].y,
			//"boyfriendRawX" => PlayState.instance.boyfriend.x,
			//"boyfriendRawY" => PlayState.instance.boyfriend.y,
			"dadName" 		=> PlayState.SONG.strumLines[0].characters[0],
			"dadX" 			=> PlayState.instance.stage.characterPoses['dad'].x,
			"dadY" 			=> PlayState.instance.stage.characterPoses['dad'].y,
			//"dadRawX" 		=> PlayState.instance.dad.x,
			//"dadRawY" 		=> PlayState.instance.dad.y,
			"girlfriendName" => PlayState.SONG.strumLines[2].characters[0],
			"girlfriendX" 	=> PlayState.instance.stage.characterPoses['girlfriend'].x,
			"girlfriendY" 	=> PlayState.instance.stage.characterPoses['girlfriend'].y,
			//"girlfriendRawX" => PlayState.instance.gf.x,
			//"girlfriendRawY" => PlayState.instance.gf.y
		];
	}

	public static function getOptionsVariables(?script:Script):Map<String, Dynamic> {
		return [
			// Preferences
			"downScroll" => Options.downscroll,
			"framerate" => Options.framerate,
			"ghostTapping" => Options.ghostTapping,
			"camZoomOnBeat" => Options.camZoomOnBeat,
			"lowMemoryMode" => Options.lowMemoryMode,
			"antialiasing" => Options.antialiasing,
			"gameplayShaders" => Options.gameplayShaders,
			"currentModDirectory" => ModsFolder.currentModFolder,

			"currentSystem" => LuaTools.getCurrentSystem()
		];
	}

	public static function getPlayStateFunctions():Map<String, Dynamic> {
		return [
			"callFunction" => function(script:String, func:String, ?args:Array<OneOfThree<Int, Float, Bool>>) {
				if(args == null)
					args = [];

				PlayState.instance.scripts.call(func, args);
				return;
			},
			"executeEvent" => function(event:String, args:Array<String>){
				var event:ChartEvent = {name: event, time: Conductor.songPosition, params: args};
				PlayState.instance.executeEvent(event);
			},
			"shake" => function(camera:String, amount:Float, time:Float) {
				LuaTools.getCamera(camera.toLowerCase()).shake(amount, time);
			},
			"createFunkinSprite" => function(name:String, ?imagePath:String = null, ?x:Float = 0, ?y:Float = 0)
			{
				var theSprite:FunkinSprite = new FunkinSprite(x, y);
				if(imagePath != null && imagePath.length > 0)
					theSprite.loadGraphic(Paths.image(imagePath));
				PlayState.instance.luaObjects.set(name, theSprite);
				theSprite.active = true;
			},
			"addFunkinSprite" => function(name:String, ?camera:String = "camGame") {
				var sprite:FunkinSprite = null;
				if(PlayState.instance.luaObjects.exists(name))
					sprite = PlayState.instance.luaObjects.get(name);

				if(sprite == null) return;
				
				PlayState.instance.add(sprite);
				sprite.cameras = [LuaTools.getCamera(camera.toLowerCase())];
			}
		];
	}
}
#end