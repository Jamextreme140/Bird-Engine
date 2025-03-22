package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.utils.ILuaScriptable;
import funkin.backend.scripting.LuaScript.LuaHScript;

final class HScriptFunctions {
	public static function getHScriptFunctions(?instance:ILuaScriptable, ?script:LuaScript):Map<String, Dynamic> {
		return [
			#if ENABLE_LUA
			"executeScript" => function(name:String, code:String) {
				LuaTools.printFuncMsg('executeScript', 'Deprecated. Marked for removal', WARNING, 'Refer to "createScript"');
				var _script:LuaHScript = initHScriptInstance(name, instance, script);
				if(_script != null) {
					_script.parser.line = 1;
					_script.loadFromString(code);
					_script.load();
				}
				return _script;
			},
			"createScript"	=> function(name:String, code:String) {
				var _script:LuaHScript = initHScriptInstance(name, instance, script);
				/*
				if(instance.luaObjects["SCRIPTS"].exists(name)) {
					_script = instance.luaObjects["SCRIPTS"].get(name);
					_script.parser.line = 1;
					_script.loadFromString(code);
				}
				else {
					_script = cast Script.fromString(code, '${haxe.io.Path.withoutExtension(script.path)}_${name}.hx', false);
					_script.setParent(instance);
					instance.luaObjects["SCRIPTS"].set(name, _script);
				}
				*/
				if(_script != null) {
					_script.parser.line = 1;
					_script.loadFromString(code);
					_script.load();
				}

				return _script;
			},
			"callScriptFunction" => function(name:String, func:String, ?args:Array<Dynamic>):Dynamic {
				var r:Dynamic = null;
				if(instance.luaObjects["SCRIPTS"].exists(name)){
					var _script:LuaHScript = instance.luaObjects["SCRIPTS"].get(name);
					r = _script.call(func, args != null ? args : []);
				}

				return r;
			},
			"pushVar" => function(name:String, varName:String, variable:Dynamic) { //Is this even useful?
				var _script:LuaHScript = initHScriptInstance(name, instance, script);
				if(_script != null) {
					//var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
					_script.set(varName, variable);
				}
			},
			"stopScript" => function(name:String) {
				if(instance.luaObjects["SCRIPTS"].exists(name)) {
					var _script:LuaHScript = instance.luaObjects["SCRIPTS"].get(name);
					_script.active = false;
					instance.luaObjects["SCRIPTS"].remove(name);
					_script.destroy();
				}
			},
			"runScript" => function(code:String) {
				script.initHScript();

				return script.hscript.execute(code);
			}
			#end
		];
	}

	private static function initHScriptInstance(name:String, instance:ILuaScriptable, script:LuaScript) {
		var _script:LuaHScript = null;
		#if ENABLE_LUA
		if (instance.luaObjects["SCRIPTS"].exists(name)) {
			_script = instance.luaObjects["SCRIPTS"].get(name);
		}
		else {
			_script = new LuaHScript('${haxe.io.Path.withoutExtension(script.path)}_${name}.hx');//cast Script.create('${haxe.io.Path.withoutExtension(script.path)}_${name}.hx', false);
			_script.setParent(instance);
			instance.luaObjects["SCRIPTS"].set(name, _script);
		}
		#end
		return _script;
	}
}