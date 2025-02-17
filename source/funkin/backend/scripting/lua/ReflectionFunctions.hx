package funkin.backend.scripting.lua;

import funkin.backend.scripting.lua.utils.ILuaScriptable;

#if ENABLE_LUA
final class ReflectionFunctions
{
	public static function getReflectFunctions(instance:ILuaScriptable, ?script:LuaScript):Map<String, Dynamic>
	{
		return [
			"getField" => function(field:String) {
				var obj = instance.getInstance();
				
				if(obj == null) return null;

				return LuaTools.getValueFromVariable(obj, field);
			},
			"getParentField" => function(field:String) {
				var obj = script.parent.parent;

				if(obj == null) return null;

				return LuaTools.getValueFromVariable(obj, field);
			},
			"getArrayField" => function(field:String, index:Int, arrayField:String) {
				var obj = instance.getInstance();
				var arr:Dynamic = null;
				var fieldIndex:Null<Int> = null;
				if(obj == null) return null;
				// In case you want to get the value of an array from another array
				// Ex: getArrayField(strumLines.members[0], 0, x)
				if(field.contains("[") || field.contains("members[")) {
					fieldIndex = Std.parseInt(field.substring(field.indexOf("["), field.indexOf("]")));
				}

				arr = LuaTools.getValueFromVariable(obj, field.split(".")[0]);

				return LuaTools.getValueFromArray((fieldIndex != null) ? (arr is FlxTypedGroup) ? arr.members[fieldIndex] : arr[fieldIndex] : arr, index,
					arrayField);
			},
			"getParentArrayField" => function(field:String, index:Int, arrayField:String) {
				var obj = script.parent.parent;
				var arr:Dynamic = null;

				if(obj == null) return null;

				arr = LuaTools.getValueFromVariable(obj, field.split(".")[0]);

				return (arr is Array) ? arr[index] : arr;
			},
			"getObjectField" => function(object:String, field:String) {
				var obj:Dynamic = LuaTools.getObject(instance, object);

				if(obj == null) return null;

				return LuaTools.getValueFromVariable(obj, field);
			},
			"getClassField" => function(className:String, field:String) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				var value:Dynamic = null;

				if (cl != null)
				{
					value = LuaTools.getValueFromVariable(cl, field);
				}
				else
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
				}
				return value;
			},
			"setField" => function(field:String, value:Dynamic) {
				var obj:Dynamic = instance.getInstance();

				if (obj == null) return null;

				return LuaTools.setValueToVariable(obj, field, value);
			},
			"setParentField" => function(field:String, value:Dynamic) {
				var obj = script.parent.parent;

				if(obj == null) return null;

				return LuaTools.setValueToVariable(obj, field, value);
			},
			"setArrayField" => function(field:String, index:Int, arrayField:String, value:Dynamic) {
				var obj:Dynamic = instance.getInstance();
				var arr:Dynamic = null;
				var fieldIndex:Null<Int> = null;
				if(obj == null) return null;
				// In case you want to get the value of an array from another array
				// Ex: setArrayField(strumLines.members[0], 0, "x", 40)
				if(field.contains("[") || field.contains("members[")) {
					fieldIndex = Std.parseInt(field.substring(field.indexOf("["), field.indexOf("]")));
				}
			
				arr = LuaTools.getValueFromVariable(obj, field.split(".")[0]);

				return LuaTools.setValueToArray(fieldIndex != null ? arr is FlxTypedGroup ? arr.members[fieldIndex] : arr[fieldIndex] : arr, index,
					arrayField, value);
			},
			"setParentArrayField" => function(field:String, index:Int, value:Dynamic) {
				var obj:Dynamic = script.parent.parent;
				var arr:Dynamic = null;

				if(obj == null) return null;

				arr = LuaTools.getValueFromVariable(obj, field);

				return (arr is Array) ? arr[index] = value : arr = value;
			},
			"setObjectField" => function(object:String, field:String, value:Dynamic) {
				var obj:Dynamic = LuaTools.getObject(instance, object);

				if(obj == null) return null;

				return LuaTools.setValueToVariable(obj, field, value);
			},
			"setClassField" => function(className:String, field:String, value:Dynamic) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if (cl == null)
				{
					Logs.trace('getClassField: Invalid Class', ERROR);
					return null;
				}
				return LuaTools.setValueToVariable(cl, field, value);
			},
			"callMethod" => function(func:String, ?args:Array<Dynamic>) {
				var obj = instance.getInstance();
				if(obj == null) return null;
				var func = LuaTools.getValueFromVariable(obj, func);
				if(!Reflect.isFunction(func)) return null;

				return Reflect.callMethod(obj, func, args ?? []);
			},
			"callObjectMethod" => function(object:String, func:String, ?args:Array<Dynamic>) {
				var obj:Dynamic = LuaTools.getObject(instance, object);
				if(obj == null) return null;
				var func = LuaTools.getValueFromVariable(obj, func);
				if(!Reflect.isFunction(func)) return null;

				return Reflect.callMethod(obj, func, args ?? []);
			},
			"callClassMethod" => function(className:String, func:String, ?args:Array<Dynamic>) {
				var cl:Class<Dynamic> = Type.resolveClass(className);
				if(cl == null) return null;

				var func = LuaTools.getValueFromVariable(cl, func);
				if(!Reflect.isFunction(func)) return null;

				return Reflect.callMethod(cl, func, args ?? []);
			}
		];
	}
}
#end
