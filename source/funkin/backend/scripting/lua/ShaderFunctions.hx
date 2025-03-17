package funkin.backend.scripting.lua;
#if ENABLE_LUA
import funkin.backend.scripting.lua.shaders.LuaShader;
import funkin.backend.scripting.lua.utils.ILuaScriptable;

final class ShaderFunctions {
	public static function getShaderFunctions(instance:ILuaScriptable, ?script:Script):Map<String, Dynamic> {
		return [
			"initShader" => function(name:String, shader:String, ?glslVersion:Int = 120) {
				if(!Options.gameplayShaders) return null;

				if(instance.luaObjects["SHADER"].exists(name)) {
					Logs.trace('Shader ${name} already initialized', WARNING);
					return null;
				}

				var cShader = new LuaShader(shader, Std.string(glslVersion));

				instance.luaObjects["SHADER"].set(name, cShader);
				//cast(script, LuaScript).set(name, cShader);
				return cShader;
			},
			"addShader" => function(object:String, shader:String) {
				if(!Options.gameplayShaders) return;

				if(!instance.luaObjects["SHADER"].exists(shader)) {
					Logs.trace('Shader ${shader} not found', ERROR);
					return;
				}

				var object:Dynamic = LuaTools.getObject(instance, object);
				var cShader:LuaShader = instance.luaObjects["SHADER"].get(shader);

				if(object != null) {
					
					if(object is FlxSprite) {
						cast(object, FlxSprite).shader = cShader;
					}
					else if(object is FlxCamera) {
						cast(object, FlxCamera).addShader(cShader);
					}
				}
				else {
					LuaTools.getCamera(object, instance).addShader(cShader); //Adds the shader to the current state camera
					return;
				}
			},
			"removeShader" => function(object:String, shader:String) {
				if(!Options.gameplayShaders) return;

				var object:Dynamic = LuaTools.getObject(instance, object);

				if (object != null)
				{
					if (object is FlxSprite)
					{
						cast(object, FlxSprite).shader = null;
						instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
						instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
						return;
					}
					else if (object is FlxCamera) // TODO: optimize the remove from map
					{
						var cShader:LuaShader = instance.luaObjects["SHADER"].get(shader);
						if (cShader == null)
							return;
						cast(object, FlxCamera).removeShader(cShader);
						instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
						instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
						return;
					}
				}
				else {
					var cShader:LuaShader = instance.luaObjects["SHADER"].get(shader);
					if (cShader == null)
						return;
					LuaTools.getCamera(object, instance).removeShader(cShader); //Removes the shader to the current state camera
					instance.luaObjects["SHADER"].set(shader, null); // Sets the shader null
					instance.luaObjects["SHADER"].remove(shader); // Removes the shader from the map
					return;
				}
			},
			"getShaderField" => function(shader:String, field:String) {
				if(!Options.gameplayShaders) return null;

				var cShader:LuaShader = instance.luaObjects["SHADER"].get(shader);
				if (cShader != null)
					return cShader.hget(field);
				else
				{
					Logs.trace('Shader ${shader} not found', ERROR);
					return null;
				}
			},
			"setShaderField" => function(shader:String, field:String, value:Dynamic) {
				if(!Options.gameplayShaders) return;

				var cShader:LuaShader = instance.luaObjects["SHADER"].get(shader);
				if (cShader != null)
					cShader.hset(field, value);
				else
				{
					Logs.trace('Shader ${shader} not found', ERROR);
					return;
				}
			}
		];
	}
}
#end