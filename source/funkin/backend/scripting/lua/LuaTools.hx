package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.utils.ILuaScriptable;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween.FlxTweenType;

using Lambda;
class LuaTools {
	public static function printFuncMsg(func:String, msg:String, type:Level, ?hint:String) {
		Logs.trace('${func}(): ${msg}. ${hint.getDefault('')}', type);
	}

	#if ENABLE_LUA
	public static function getCurrentSystem():String {
		#if linux
		return 'linux';
		#else
		return lime.system.System.platformName.toLowerCase();
		#end
	}

	public static function getCamera(camera:String, ?instance:ILuaScriptable):FlxCamera {
		return switch(camera.trim().toLowerCase()) {
			case "camgame" | "game": PlayState.instance.camGame;
			case "camhud" | "hud": PlayState.instance.camHUD;
			default: 
				if(instance != null) {
					var aCamera:FlxCamera = instance.luaObjects["CAMERA"].get(camera);
					if(aCamera != null)
						return aCamera
					else
						return Reflect.field(instance, camera) ?? FlxG.cameras.list[FlxG.cameras.list.length - 1];
				}
				else {
					return FlxG.cameras.list[FlxG.cameras.list.length - 1];
				}
		}
	}

	public static function getValueFromVariable(obj:Dynamic, variable:String):Dynamic {
		var fields = variable.trim().split('.');
		var value:Dynamic = null;

		if (fields.length > 1)
		{
			var nextField:Dynamic = Reflect.getProperty(obj, fields[0]);
			for (i in 1...fields.length)
			{
				nextField = Reflect.getProperty(nextField, fields[i]);
			}
			value = nextField;
		}
		else
		{
			value = Reflect.getProperty(obj, fields[0]);
		}
		return value;
	}

	public static function getValueFromArray(array:Dynamic, index:Int, variable:String):Dynamic {
		//var fields = variable.trim().split('.');
		var arrayValue:Dynamic = null; // The value of the given array on "index" position

		if(array is FlxTypedGroup) {
			arrayValue = cast array.members[index];
		}
		else {
			arrayValue = array[index];
		}
		if(arrayValue == null) return null;

		return LuaTools.getValueFromVariable(arrayValue, variable);
	}

	public static function setValueToVariable(obj:Dynamic, variable:String, value:Dynamic):Dynamic {
		var fields = variable.trim().split('.');

		if (fields.length > 1)
		{
			var nextField:Dynamic = Reflect.getProperty(obj, fields[0]);
			for (i in 1...fields.length - 1)
			{
				nextField = Reflect.getProperty(nextField, fields[i]);
			}
			Reflect.setProperty(nextField, fields[fields.length - 1], value);
		}
		else
		{
			Reflect.setProperty(obj, fields[0], value);
		}

		return value;
	}

	public static function setValueToArray(array:Dynamic, index:Int, variable:String, value:Dynamic):Dynamic {
		var arrayValue:Dynamic = null; // The value of the given array on "index" position

		if(array is FlxTypedGroup) {
			arrayValue = cast array.members[index];
		}
		else {
			arrayValue = array[index];
		}
		if(arrayValue == null) return null;

		return LuaTools.setValueToVariable(arrayValue, variable, value);
	}

	public static function getObject(instance:ILuaScriptable, objectName:String):Dynamic
	{
		var varSplit = objectName.split('.');

		var object = getLuaObject(instance, varSplit[0]);

		return object;
	}

	public static function getLuaObject(instance:ILuaScriptable, name:String):Dynamic {
		var object:Dynamic = null;

		if(instance.luaObjects["SPRITE"].exists(name)) {
			object = instance.luaObjects["SPRITE"].get(name);
		}
		else if(instance.luaObjects["TEXT"].exists(name)) {
			object = instance.luaObjects["TEXT"].get(name);
		}
		else if(instance.luaObjects["VIDEOS"].exists(name)) {
			object = instance.luaObjects["VIDEOS"].get(name);
		}
		else if(object == null) {
			object = Reflect.getProperty(instance.getInstance(), name);
		}

		return object;
	}

	public static function removeLuaObject(instance:ILuaScriptable, name:String) {
		if(instance.luaObjects["SPRITE"].exists(name)) {
			instance.luaObjects["SPRITE"].remove(name);
		}
		else if(instance.luaObjects["TEXT"].exists(name)) {
			instance.luaObjects["TEXT"].remove(name);
		}
		else if(instance.luaObjects["VIDEOS"].exists(name)) {
			instance.luaObjects["VIDEOS"].remove(name);
		}
	}

	// Uses a cache to improve performance
	private static var easeFunctions = Type.getClassFields(FlxEase).filter((field:String) -> return Reflect.isFunction(Reflect.field(FlxEase, field)));

	public static function getEase(ease:String):EaseFunction
	{
		var realEase = easeFunctions.find((e:String) -> return e.toLowerCase() == ease.toLowerCase().trim()).getDefault('linear');
		var easeToUse:EaseFunction = Reflect.field(FlxEase, realEase);
		return easeToUse;
	}

	public static function getTweenType(type:String):Int {
		return switch (type.trim().toLowerCase()) {
			case 'backward' | 'reverse' : FlxTweenType.BACKWARD;
			case 'looping' | 'loop' | 'repeat' : FlxTweenType.LOOPING;
			case 'persist' : FlxTweenType.PERSIST;
			case 'pingpong' | 'boomerang' : FlxTweenType.PINGPONG;
			default: FlxTweenType.ONESHOT;
		}
	}

	public static function getColor(color:Dynamic):FlxColor {
		return CoolUtil.getColorFromDynamic(color).getDefault(FlxColor.BLACK);
	}
	#end
}
