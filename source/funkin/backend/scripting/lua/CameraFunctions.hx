package funkin.backend.scripting.lua;

import flixel.math.FlxPoint;
import flixel.FlxCamera;

import funkin.backend.scripting.lua.utils.ILuaScriptable;

final class CameraFunctions {
	public static function getCameraFunctions(instance:ILuaScriptable, ?script:Script):Map<String, Dynamic> {
		return [
			"createCamera" => function(name:String, ?x:Int = 0, ?y:Int = 0, ?width:Int = 0, ?height:Int = 0) {
				if(name.trim() != '' || !instance.luaObjects["CAMERA"].exists(name)) {
					instance.luaObjects["CAMERA"].set(name, new FlxCamera(x, y, width, height));
				}
			},
			"addCamera" => function(name:String, ?defaultDrawTarget:Bool = false) {
				if(name.trim() != '' && instance.luaObjects["CAMERA"].exists(name)) {
					var theCam:FlxCamera = instance.luaObjects["CAMERA"].get(name);
					FlxG.cameras.add(theCam, defaultDrawTarget);
				}
			},
			"setCameraLerp" => function(name:String, ?value:Float = 1.0) {
				if(name.trim() != '' && instance.luaObjects["CAMERA"].exists(name)) {
					var theCam:FlxCamera = instance.luaObjects["CAMERA"].get(name);
					theCam.followLerp = value;
				}
				else {
					FlxG.camera.followLerp = value;
				}
			},
			"setScrollCamera" => function(name:String, ?x:Float = 0, ?y:Float = 0) {
				if(name.trim() != '' && instance.luaObjects["CAMERA"].exists(name)) {
					var theCam:FlxCamera = instance.luaObjects["CAMERA"].get(name);
					theCam.focusOn(FlxPoint.weak(x, y));
				}
			},
			"setCameraTarget" => function(name:String, object:String) {
				if(name.trim() != '' && instance.luaObjects["CAMERA"].exists(name)) {
					var theCam:FlxCamera = instance.luaObjects["CAMERA"].get(name);
					var obj = LuaTools.getObject(instance, object);

					if(obj != null && obj is FlxObject) {
						theCam.target = cast obj;
					}
				}
				else {
					var obj = LuaTools.getObject(instance, object);

					if(obj != null && obj is FlxObject) {
						FlxG.camera.target = cast obj;
					}
				}
			}
		];
	}
}