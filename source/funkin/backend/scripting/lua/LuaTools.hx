package funkin.backend.scripting.lua;

import flixel.util.FlxColor;
import flixel.tweens.FlxTween.FlxTweenType;

class LuaTools {
	#if ENABLE_LUA
	public static function getCurrentSystem():String {
		#if linux
		return 'linux';
		#else
		return lime.system.System.platformName;
		#end
	}

	public static function getCamera(camera:String, ?instance:MusicBeatState):FlxCamera {
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
			var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
			for (i in 1...fields.length)
			{
				_var = Reflect.getProperty(_var, fields[i]);
			}
			value = _var;
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
			var _var:Dynamic = Reflect.getProperty(obj, fields[0]);
			for (i in 1...fields.length - 1)
			{
				_var = Reflect.getProperty(_var, fields[i]);
			}
			Reflect.setProperty(_var, fields[fields.length - 1], value);
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

	public static function getObject(instance:MusicBeatState, objectName:String):Dynamic
	{
		var varSplit = objectName.split('.');

		var object = getLuaObject(instance, varSplit[0]);

		return object;
	}

	public static function getLuaObject(instance:MusicBeatState, name:String):Dynamic {
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
			object = Reflect.getProperty(instance, name);
		}

		return object;
	}

	public static function removeLuaObject(instance:MusicBeatState, name:String) {
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

	public static function getEase(?ease:String = '')
	{
		return switch(ease.toLowerCase().trim()) {
			case 'backin': FlxEase.backIn;
			case 'backinout': FlxEase.backInOut;
			case 'backout': FlxEase.backOut;
			case 'bouncein': FlxEase.bounceIn;
			case 'bounceinout': FlxEase.bounceInOut;
			case 'bounceout': FlxEase.bounceOut;
			case 'circin': FlxEase.circIn;
			case 'circinout': FlxEase.circInOut;
			case 'circout': FlxEase.circOut;
			case 'cubein': FlxEase.cubeIn;
			case 'cubeinout': FlxEase.cubeInOut;
			case 'cubeout': FlxEase.cubeOut;
			case 'elasticin': FlxEase.elasticIn;
			case 'elasticinout': FlxEase.elasticInOut;
			case 'elasticout': FlxEase.elasticOut;
			case 'expoin': FlxEase.expoIn;
			case 'expoinout': FlxEase.expoInOut;
			case 'expoout': FlxEase.expoOut;
			case 'quadin': FlxEase.quadIn;
			case 'quadinout': FlxEase.quadInOut;
			case 'quadout': FlxEase.quadOut;
			case 'quartin': FlxEase.quartIn;
			case 'quartinout': FlxEase.quartInOut;
			case 'quartout': FlxEase.quartOut;
			case 'quintin': FlxEase.quintIn;
			case 'quintinout': FlxEase.quintInOut;
			case 'quintout': FlxEase.quintOut;
			case 'sinein': FlxEase.sineIn;
			case 'sineinout': FlxEase.sineInOut;
			case 'sineout': FlxEase.sineOut;
			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepinout': FlxEase.smoothStepInOut;
			case 'smoothstepout': FlxEase.smoothStepInOut;
			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'smootherstepout': FlxEase.smootherStepOut;
			default: FlxEase.linear;
		}
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
