package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.events.modchart.CallbackEvent;
import modchart.Manager;
import flixel.tweens.*;
import flixel.tweens.FlxTween.FlxTweenType;

final class ModchartFunctions {
	public static function getModchartFunctions(?script:Script):Map<String, Dynamic> {
		var instance = PlayState.instance;
		return [
			"tweenNote" => function(tweenName:String, strumLine:Int, note:Int, property:String, value:Dynamic, duration:Float, ?ease:String = 'linear', ?type:String = 'oneshot', ?timeDelayed:Float = 0.0) {
				var strumlineToUse:funkin.game.StrumLine = instance.strumLines.members[strumLine];
				var propertyToUse = {};
				if(strumlineToUse == null) return;
				if(note < 1 || note > 4) return; // Only note index between 1 - 4
				switch(property){
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					default: Reflect.setField(propertyToUse, property, value);
				};

				if(instance.luaObjects["TWEEN"].exists(tweenName)){
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName); // Redundant since Map.set() overwrite the value of the same key
				}

				instance.luaObjects["TWEEN"].set(tweenName, FlxTween.tween(strumlineToUse.members[note - 1], propertyToUse, duration, 
				{
					ease: LuaTools.getEase(ease),
					type: LuaTools.getTweenType(type),
					startDelay: timeDelayed,
					onUpdate: (_) -> {
						script.call('onTweenUpdate', [tweenName, _.executions]);
					},
					onComplete: (_) ->
					{
						script.call('onTweenFinished', [tweenName]);
						// Prevents removing itself on "Loop" tween type (LOOPING, PINGPONG or PERSIST)
						if (_.type == FlxTweenType.ONESHOT || _.type == FlxTweenType.BACKWARD)
							instance.luaObjects["TWEEN"].remove(tweenName);
					}
				}));
			}
		];
	}

	private static function onError(fn:String) 
		LuaTools.printFuncMsg(fn, 'FunkinModchart not initialized', ERROR);
	
	public static function getFunkinModchartFunctions(?script:LuaScript):Map<String, Dynamic> {
		#if MODCHARTING_FEATURES
		var instance = PlayState.instance;

		return [
			"initFM" => function(?addManager:Bool = true, ?alias:String) {
				if(script.modchartManager == null) {
					script.modchartManager = new Manager();
					if(addManager) instance.add(script.modchartManager);
					if(alias != null) script.set(alias, script.modchartManager);
				}
				else 
					LuaTools.printFuncMsg('initFM', 'FunkinModchart already initialized', ERROR);
			},
			"addFM" => function(?forceAdd:Bool = false) {
				if(script.modchartManager == null) {
					LuaTools.printFuncMsg('addFM', 'FunkinModchart not initialized', ERROR, 'Call "initFM()" first.');
					return;
				}
				// FM created but not added
				if(script.modchartManager != null) {
					if(instance.members.indexOf(script.modchartManager) == -1)
						instance.add(script.modchartManager);
					else if (forceAdd) {
						//Logs.trace("You are not supposed to add the manager again! Why??", WARNING);
						LuaTools.printFuncMsg('addFM', "You are not supposed to add the manager again! Why??", WARNING);
						instance.add(script.modchartManager);
					}
					else 
						LuaTools.printFuncMsg('addFM', 'FunkinModchart already added to PlayState', ERROR);
				}
				
			},
			"addModifier" => function(mod:String, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.addModifier(mod, field);
				}
				else
					onError('addModifier');
			},
			"setPercent" => function(mod:String, value:Float, ?player:Int = -1, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.setPercent(mod, value, player, field);
				}
				else
					onError('setPercent');
			},
			"getPercent" => function(mod:String, ?player:Int = 0, ?field:Int = 0) {
				if(script.modchartManager != null) {
					script.modchartManager.getPercent(mod, player, field);
				}
				else
					onError('getPercent');
			},
			"set" => function(mod:String, beat:Float, value:Float, ?player:Int = -1, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.set(mod, beat, value, player, field);
				}
				else
					onError('set');
			},
			"ease" => function(mod:String, beat:Float, length:Float, value:Float, ease:String, ?player:Int = -1, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.ease(mod, beat, length, value, LuaTools.getEase(ease), player, field);
				}
				else
					onError('ease');
			},
			"callback" => function(beat:Float, func:String, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.callback(beat, function(event) {
						var callbackEvent = EventManager.get(CallbackEvent).recycle(func, event, event.name, event.target, event.beat, event.fired, event.active);
						script.call('onModchartCallback', [callbackEvent]);
					}, field);
				}
				else
					onError('callback');
			},
			"repeater" => function(beat:Float, length:Float, func:String, ?field:Int = -1) {
				if(script.modchartManager != null) {
					script.modchartManager.repeater(beat, length, function(event) {
						// TODO: make this cancellable
						var callbackEvent = EventManager.get(CallbackEvent).recycle(func, event, event.name, event.target, event.beat, event.fired, event.active);
						script.call('onRepeaterCallback', [callbackEvent, length]);
					}, field);
				}
				else
					onError('repeater');
			}
		];
		#else
		return [];
		#end
	}
}