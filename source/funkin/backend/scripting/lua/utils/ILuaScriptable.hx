package funkin.backend.scripting.lua.utils;

import flixel.FlxSubState;

/**
 * Special Interface to handle states and substates.
 */
interface ILuaScriptable {
	#if ENABLE_LUA
	public var luaScriptsAllowed:Bool;
	public var luaObjects(default, never):Map<String, Map<String, Dynamic>>;
	public function add(Object:FlxBasic):FlxBasic;
	public function insert(position:Int, object:FlxBasic):FlxBasic;
	public function remove(Object:FlxBasic, Splice:Bool = false):FlxBasic;

	public function call(name:String, ?args:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic;
	public function lerp(v1:Float, v2:Float, ratio:Float, fpsSensitive:Bool = false):Float;

	public function openSubState(subState:FlxSubState):Void;

	public function getInstance():Dynamic;
	#end
}