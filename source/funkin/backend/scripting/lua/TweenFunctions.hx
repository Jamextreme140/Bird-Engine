package funkin.backend.scripting.lua;
#if ENABLE_LUA
import flixel.tweens.*;
import flixel.tweens.FlxTween.FlxTweenType;

import funkin.backend.scripting.lua.utils.ILuaScriptable;

final class TweenFunctions {
	
	public static function getTweenFunctions(instance:ILuaScriptable, ?script:Script):Map<String, Dynamic> {
		return [
			"tween" 	=> function(tweenName:String, object:String, property:String, value:Dynamic, duration:Float, ?ease:String = 'linear', ?type:String = 'oneshot', ?timeDelayed:Float = 0.0) {
				var obj = object.split(".");
				var objectToTween:Dynamic = LuaTools.getObject(instance, obj[0]);
				// Ex: tween("invert", "camHUD.flashSprite", "scaleX", getField("camHUD", "flashSprite.scaleX") * -1, 0.5)
				if(obj.length > 1) {
					var objectVars = object.substring(object.indexOf(".") + 1);
					objectToTween = LuaTools.getValueFromVariable(objectToTween, objectVars);
				}
				var propertyToUse = {};
				if(objectToTween == null) return;
				switch(property){ //most common property uses
					case 'x': propertyToUse = {x: value};
					case 'y': propertyToUse = {y: value};
					case 'alpha' : propertyToUse = {alpha: value};
					case 'angle' : propertyToUse = {angle: value};
					default: Reflect.setField(propertyToUse, property, value);
				};
				// cancels the current tween of the selected object
				if(instance.luaObjects["TWEEN"].exists(tweenName)){
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName); // Redundant since Map.set() overwrite the value of the same key
				}

				instance.luaObjects["TWEEN"].set(tweenName, FlxTween.tween(objectToTween, propertyToUse, duration, 
				{
					ease: LuaTools.getEase(ease), 
					type: LuaTools.getTweenType(type), 
					startDelay: timeDelayed,
					onUpdate: (_) -> {
						script.call('onTweenUpdate', [tweenName, _.executions]);
					},
					onComplete: (_) -> {
						script.call('onTweenFinished', [tweenName]);
						// Prevents removing itself on "Loop" tween type (LOOPING, PINGPONG or PERSIST)
						if(_.type == FlxTweenType.ONESHOT || _.type == FlxTweenType.BACKWARD)
							instance.luaObjects["TWEEN"].remove(tweenName);
					}
				}));
			},
			"valueTween" => function(tweenName:String, startValue:Float, endValue:Float, duration:Float, ?ease:String = 'linear', ?type:String = 'oneshot', ?timeDelayed:Float = 0.0) {
				instance.luaObjects["TWEEN"].set(tweenName, FlxTween.num(startValue, endValue, duration, 
				{
					ease: LuaTools.getEase(ease), 
					type: LuaTools.getTweenType(type), 
					startDelay: timeDelayed,
					onUpdate: (_) -> {
						script.call('onTweenUpdate', [tweenName, _.executions]);
					},
					onComplete: (_) -> {
						script.call('onTweenFinished', [tweenName]);
						// Prevents removing itself on "Loop" tween type (LOOPING, PINGPONG or PERSIST)
						if(_.type == FlxTweenType.ONESHOT || _.type == FlxTweenType.BACKWARD)
							instance.luaObjects["TWEEN"].remove(tweenName);
					}
				},
				function(value:Float) {
					script.call('onValueTween', [tweenName, value]);
				}));
			},
			"cancelTween" => function(tweenName:String) {
				// cancels the current specified tween and remove it from the map
				if(instance.luaObjects["TWEEN"].exists(tweenName)) {
					cast(instance.luaObjects["TWEEN"].get(tweenName), FlxTween).cancel();
					instance.luaObjects["TWEEN"].remove(tweenName);
				}
			}
		];
	}
}
#end
