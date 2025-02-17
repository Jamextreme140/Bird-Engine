package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.utils.ILuaScriptable;

class HScriptFunctions {
	public static function getHScriptFunctions(?instance:ILuaScriptable, ?script:Script):Map<String, Dynamic> {
		#if ENABLE_LUA
		return [
			"executeScript"	=> function(name:String, code:String) {
				var _script:Script;
				if(instance.luaObjects["SCRIPTS"].exists(name))
					_script = instance.luaObjects["SCRIPTS"].get(name);
				else {
					_script = Script.fromString(code, '${haxe.io.Path.withoutExtension(script.path)}_${name}.hx', false);
					_script.setParent(instance);
					instance.luaObjects["SCRIPTS"].set(name, _script);
				}
				if(_script != null)
					_script.load();
			},
			"callScriptFunction" => function(name:String, func:String, ?args:Array<Dynamic>):Dynamic {
				if(instance.luaObjects["SCRIPTS"].exists(name)){
					var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
					var r:Dynamic = _script.call(func, args != null ? args : []);
					return r;
				}

				return null;
			},
			"pushVar" => function(name:String, varName:String, variable:Dynamic) { //TODO: remove this
				if(instance.luaObjects["SCRIPTS"].exists(name)) {
					var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
					_script.set(varName, variable);
				}
			},
			"stopScript" => function(name:String) {
				if(instance.luaObjects["SCRIPTS"].exists(name)) {
					var _script:HScript = instance.luaObjects["SCRIPTS"].get(name);
					_script.active = false;
					instance.luaObjects["SCRIPTS"].remove(name);
					_script.destroy();
				}
			}
		];
		#else
		return null;
		#end
	}
}