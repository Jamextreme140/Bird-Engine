package funkin.backend.scripting.lua;
#if ENABLE_LUA

final class NdllFunctions {
	public static var ndllFunctions(default, null):Map<String, Dynamic> = new Map<String, Dynamic>();
	//No tested yet
	public static function getNdllFunctions(?script:Script):Map<String, Dynamic> {
		return [
			#if NDLLS_SUPPORTED
			"setNativeFunction" => function(funcName:String, ndll:String, func:String, nArgs:Int) {
				var func:Dynamic = NdllUtil.getFunction(ndll, func, Std.int(FlxMath.bound(nArgs, 0, 25)));
				ndllFunctions.set(funcName, func);
				//cast(script, LuaScript).addCallback(funcName, func);
				return func;
			},
			"callNativeFunction" => function(funcName:String, args:Array<Dynamic>) {
				var func:Dynamic = ndllFunctions.get(funcName);
				if(func != null)
					Reflect.callMethod(null, func, args);
			}
			#end
		];
	}
}
#end