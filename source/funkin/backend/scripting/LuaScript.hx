package funkin.backend.scripting;

#if ENABLE_LUA

import cpp.Callable;
import cpp.Pointer;

import flixel.util.typeLimit.OneOfTwo;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.DynamicAccess;

import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;

using llua.Lua;
using llua.LuaL;
using llua.Convert;
using Lambda;

/**
 * Based on code from Codename Engine "lua-test" branch
 * 
 * Thank you yosh :333 -jamextreme140
 * 
 * @see https://github.com/CodenameCrew/CodenameEngine/blob/lua-test/source/funkin/scripting/LuaScript.hx
 */
class LuaScript extends Script {

	public static function init() {
		Lua.set_callbacks_function(Callable.fromStaticFunction(callbackHandler));
		Lua.register_hxtrace_func(Callable.fromStaticFunction(printFunction));
	}

	static var callbackPreventAutoConvert:Bool = false;
	static var callbackReturnVariables = [];
	static function callbackHandler(l:State, fname:String):Int {
		if (!(Script.curScript is LuaScript))
			return 0;
		var curLua:LuaScript = cast Script.curScript;

		var cbf = curLua.resolveCallback(fname);
		callbackReturnVariables = [];

		if (cbf == null || !Reflect.isFunction(cbf)) 
			return 0;

		final nparams:Int = Lua.gettop(l);
		final args:Array<Dynamic> = [
			for (i in 0...nparams)
				callbackPreventAutoConvert ? l.fromLua(-nparams + i) : curLua.fromLua(-nparams + i)
		];

		var ret:Dynamic = null;

		try {
			ret = (nparams > 0) ? Reflect.callMethod(null, cbf, args) : cbf();
		}
		catch (e) {
			curLua.error(e.details()); // for super cool mega logging!!!
			throw e;
		}
		Lua.settop(l, 0);

		if (callbackReturnVariables.length <= 0)
			callbackReturnVariables.push(ret);
		for (e in callbackReturnVariables)
			curLua.pushArg(e);

		/* return the number of results */
		return callbackReturnVariables.length;
	}

	static function printFunction(s:String):Int {
		if (Script.curScript != null)
			Script.curScript.trace(s);
		return 0;
	}

	static function __index(state:StatePointer):Int {
		return callbackHandler(cast Pointer.fromRaw(state).ref, "__onPointerIndex");
	}

	static function __newindex(state:StatePointer):Int {
		return callbackHandler(cast Pointer.fromRaw(state).ref, "__onPointerNewIndex");
	}

	static function __call(state:StatePointer):Int {
		return callbackHandler(cast Pointer.fromRaw(state).ref, "__onPointerCall");
	}

	static function __gc(state:StatePointer):Int {
		// callbackPreventAutoConvert = true;
		var v = callbackHandler(cast Pointer.fromRaw(state).ref, "__gc");
		// callbackPreventAutoConvert = false;
		return v;
	}

	public static function getDefaultCallbacks(script:LuaScript):Map<String, Dynamic> {
		return [
			"translate" => funkin.backend.utils.TranslationUtil.get,
			// HSCRIPT
			"runScript" => function(code:String) {
				script.initHScript();

				return script.hscript.execute(code);
			},
			"parseFunction" => function(args:Null<Array<Dynamic>>, body:String) {
				script.initHScript();
				if(args == null) args = [];
				var fullExpr = 'function(${args.join(',')}) {$body}';
				var fn = script.hscript.execute(fullExpr);
				return fn;
			}
		];
	}

	public var state(default, null):State;
	/**
	 * Do not edit directly, use `addCallback` and `removeCallback` instead.
	 */
	public var callbacks:StringMap<Dynamic> = new StringMap();

	var lastStackID:Int = 0;
	var stack:IntMap<Dynamic> = new IntMap();

	public var scriptObject(default, set):Dynamic;
	var __instanceFields:Array<String> = [];
	function set_scriptObject(v:Dynamic):Dynamic {
		var fieldMap:Map<String, String> = [];
		switch(Type.typeof(v)) {
			case TClass(c):
				for(field in Reflect.fields(v).concat(Type.getInstanceFields(c))) 
					fieldMap[field] = field;
				
				__instanceFields = fieldMap.array();
			case TObject:
				var cls = Type.getClass(v);
				switch(Type.typeof(cls)) {
					case TClass(c):
						for(field in Reflect.fields(v).concat(Type.getInstanceFields(c))) 
							fieldMap[field] = field;
						
						__instanceFields = fieldMap.array();
					default:
						__instanceFields = Reflect.fields(v);
				}
			default:
		}

		if(v != null && __instanceFields.length > 0) {
			for(field in __instanceFields) {
				var f:Dynamic = Reflect.field(v, field);
				if(!Reflect.isFunction(f))
					set(field, f);
			}
		}

		return scriptObject = v;
	}

	public var hscript(default, null):LuaHScript;

	override function onCreate(path:String) {
		super.onCreate(path);

		state = LuaL.newstate();
		state.openlibs();
		state.register_hxtrace_lib();

		onPointerCall = Reflect.makeVarArgs(pointerCall);

		callbacks.set("__onPointerIndex", onPointerIndex);
		callbacks.set("__onPointerNewIndex", onPointerNewIndex);
		callbacks.set("__onPointerCall", onPointerCall);
		callbacks.set("__gc", onGarbageCollection);

		state.newmetatable("__funkinMetaTable");

		state.pushstring('__index');
		state.pushcfunction(Callable.fromStaticFunction(__index));
		state.settable(-3);

		state.pushstring('__newindex');
		state.pushcfunction(Callable.fromStaticFunction(__newindex));
		state.settable(-3);

		state.pushstring('__call');
		state.pushcfunction(Callable.fromStaticFunction(__call));
		state.settable(-3);

		state.setglobal("__funkinMetaTable");

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptCreated", [this, "lua"]);
		#end
	}

	function setDefaultCallbacks() {
		for(n => f in getDefaultCallbacks(this)) {
			addCallback(n, f);
		}
		addCallback("import", function(n:String, ?as:String) {
			var splitName:Array<String> = [for(e in n.split(".")) e.trim()];
			var realName:String = splitName.join(".");
			var clsName:String = splitName[splitName.length - 1];
			var toSet = as != null ? as : clsName;
			var oldName = realName;
			var oldSplitName = splitName.copy();

			// TODO: variable exists check

			var cl = Type.resolveClass(realName);
			if (cl == null)
				cl = Type.resolveClass('${realName}_HSC'); //It's an Abstract

			// TODO: Enums 

			if (cl == null) {
				if(splitName.length > 1) {
					splitName.splice(-2, 1); // Remove the last last item
					realName = splitName.join(".");

					cl = Type.resolveClass(realName);
					if (cl == null)
						cl = Type.resolveClass('${realName}_HSC');
				}
			}

			if (cl == null) {
				error('Unknown Class $oldName');
				return null;
			}

			set(toSet, cl);

			return null;
		});
	}

	override function onLoad() {
		var code = Assets.getText(path);
		if(code != null && code.trim() != "") {
			if (state.dostring(code) != 0) {
				this.error('${state.tostring(-1)}');
				return;
			}
			else
				this.call('new', []);
		}

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptSetup", [this, "lua"]);
		#end
	}

	override function onCall(func:String, args:Array<Dynamic>):Dynamic {
		state.settop(0);
		state.getglobal(func);

		if (state.type(-1) != Lua.LUA_TFUNCTION)
			return null;

		for (k => val in args)
			pushArg(val);

		if (state.pcall(args.length, 1, 0) != 0) {
			this.error('${state.tostring(-1)}');
			return null;
		}
		var v = fromLua(state.gettop());
        state.settop(0);
        return v;
	}

	override function get(variable:String):Dynamic {
		/*
		if (state == null)
			return super.get(variable);
		state.getglobal(variable);
		var r = fromLua(-1);
		state.pop(1);
		return r;
		*/
		return null;
	}

	override function set(variable:String, value:Dynamic) {
		if (state == null)
			return;

		if(Reflect.isFunction(value)) 
			return;

		if(value is Class) 
			setClassPointer(value);
		/*
		else if(value is Enum)
			setEnumPointer(value);
		*/
		else
			pushArg(value);
		state.setglobal(variable);
	}

	override function setParent(parent:Dynamic) {
		this.scriptObject = parent;
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
		if(map.empty()) return;
		for(k => v in map)
			if(!Reflect.isFunction(v))
				set(k, v);
	}

	override function reload() {
		Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
	}

	override function destroy() {
		close();
		super.destroy();
	}

	// checks for a local callback and then it look-up for a parent function
	public function resolveCallback(id:String):haxe.Constraints.Function {
		if (id == null)
			return null;
		id = StringTools.trim(id);

		if(callbacks.exists(id))
			return callbacks.get(id);

		if(scriptObject != null) {
			var instanceHasField:Bool = __instanceFields.contains(id);

			if(instanceHasField)
				return Reflect.getProperty(scriptObject, id);
		}

		return null;
	}

	public function addCallback(funcName:String, func:Dynamic) {
		callbacks.set(funcName, func);
		state.add_callback_function(funcName);
	}

	public function removeCallback(funcName:String) {
		if(callbacks.remove(funcName))
			state.remove_callback_function(funcName);
	}

	public function fromLua(stackPos:Int):Dynamic {
		var ret:Any = null;

		switch (state.type(stackPos))
		{
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = state.toboolean(stackPos);
			case Lua.LUA_TNUMBER:
				ret = state.tonumber(stackPos);
			case Lua.LUA_TSTRING:
				ret = state.tostring(stackPos);
			case Lua.LUA_TTABLE:
				ret = toHaxeObj(stackPos);
			case Lua.LUA_TFUNCTION:
				null; // no support for functions yet
			// case Lua.LUA_TUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("userdata\n");
			// case Lua.LUA_TLIGHTUSERDATA:
			// 	ret = LuaL.ref(l, Lua.LUA_REGISTRYINDEX);
			// 	trace("lightuserdata\n");
			// case Lua.LUA_TTHREAD:
			// 	ret = null;
			// 	trace("thread\n");
			case idk:
				ret = null;
				trace("return value not supported\n" + Std.string(idk) + " - " + stackPos);
		}

		// Stack Pointer
		if (ret is Dynamic && Reflect.hasField(ret, "__stack_id")) {
			var pos:Int = Reflect.field(ret, "__stack_id");
			return stack.get(pos);
		}
		return ret;
	}

	public function pushArg(val:Dynamic) {
		switch (Type.typeof(val))
		{
			case Type.ValueType.TNull:
				state.pushnil();
			case Type.ValueType.TBool:
				state.pushboolean(val);
			case Type.ValueType.TInt:
				state.pushinteger(cast(val, Int));
			case Type.ValueType.TFloat:
				state.pushnumber(val);
			case Type.ValueType.TClass(String):
				state.pushstring(cast(val, String));
			case Type.ValueType.TClass(Array):
				var arr:Array<Any> = cast val;
				var size:Int = arr.length;
				state.createtable(size, 0);

				for (i in 0...size)
				{
					state.pushnumber(i + 1);
					pushArg(arr[i]);
					state.settable(-3);
				}
			case Type.ValueType.TObject:
				@:privateAccess
				state.anonToLua(val); // {}
			default:
				setStackPointer(val);
		}
	}

	private function setStackPointer(val:Dynamic) {
		assignPointer(val);
	}

	private function setClassPointer(val:Class<Dynamic>) {
		assignPointer(new LuaClass(val));
	}

	private function setEnumPointer(val:Enum<Dynamic>) {
		//assignPointer(new LuaClass(val));
	}

	private function assignPointer(val:OneOfTwo<LuaClass, Dynamic>) {
		var p:StackPointer = {
			__stack_id: lastStackID++,
		};
		state.toLua(p);
		state.getmetatable("__funkinMetaTable");
		state.setmetatable(-2);

		state.pushstring('__gc');
		state.pushcfunction(Callable.fromStaticFunction(__gc));
		state.settable(-3);

		stack.set(p.__stack_id, cast val);
	}

	public function onPointerIndex(obj:Dynamic, key:String) {
		if (obj != null) {
			if (obj is LuaAccess)
				return cast(obj, LuaAccess).get(key);
			else if (obj is hscript.IHScriptCustomBehaviour)
				return cast(obj, hscript.IHScriptCustomBehaviour).hget(key);
			else
				return Reflect.getProperty(obj, key);
		}

		return null;
	}

	public function onPointerNewIndex(obj:Dynamic, key:String, val:Dynamic) {
		if (key == "__gc")
			return null;

		if (obj != null) {
			if (obj is LuaAccess)
				return cast(obj, LuaAccess).set(key, val);
			else if (obj is hscript.IHScriptCustomBehaviour)
				cast(obj, hscript.IHScriptCustomBehaviour).hset(key, val);
			else
				Reflect.setProperty(obj, key, val);
		}

		return null;
	}

	public dynamic function onPointerCall(args:Array<Dynamic>):Dynamic
		return null;

	private function pointerCall(args:Array<Dynamic>) {
		//trace("calling");
		var obj = args.shift(); // Retrieves the referenced object
		if (obj != null && Reflect.isFunction(obj))
			return Reflect.callMethod(null, obj, args);
		return null;
	}

	public function onGarbageCollection(obj:Dynamic) {
		if (Reflect.hasField(obj, "__stack_id")) {
			trace('Clearing item ID: ${obj.__stack_id} from stack due to garbage collection');
			stack.remove(obj.__stack_id);
		}
	}

	public function toHaxeObj(i:Int):Any {
		var hasItems = false;
		var array = true;

		loopTable(state, i,{
			hasItems = true;
			if(Lua.type(state, -2) != Lua.LUA_TNUMBER){
				array = false; 
			}
			final index = Lua.tonumber(state, -2);
			if(index < 0 || Std.int(index) != index) {
				array = false; 
			}
		});
		if(!hasItems) return {}

		if(array) {
			final v:Array<Dynamic> = [];
			loopTable(state, i, {
				v[Std.int(Lua.tonumber(state, -2)) - 1] = fromLua(-1);
			});
			return cast v;
		}
		final v:DynamicAccess<Any> = {};
		loopTable(state, i, {
			switch Lua.type(state, -2) {
				case t if(t == Lua.LUA_TSTRING): v.set(Lua.tostring(state, -2), fromLua(-1));
				case t if(t == Lua.LUA_TNUMBER):v.set(Std.string(Lua.tonumber(state, -2)), fromLua(-1));
			}
		});
		return v;
	}

	public function close() {
		if (state == null)
			return;
		this.active = false;
		state.close();
		state = null;
	}

	public function initHScript() {
		if(hscript != null) return;

		hscript = new LuaHScript('${haxe.io.Path.withoutExtension(this.path)}_hscript.hx');
		hscript.setParent(scriptObject);
		hscript.set('__lua__', this);
	}
}

// same thing as IHScriptCustomBehaviour
interface LuaAccess {
	public function get(name:String):Dynamic;
	public function set(name:String, value:Dynamic):Dynamic;
}

final class LuaHScript extends HScript implements hscript.IHScriptCustomBehaviour{
	private var __variables:Array<String>;

	public function new(path:String) {
		super(path);

		__variables = Type.getInstanceFields(Type.getClass(this));
	}

	public function execute(code:String):Dynamic {
		var ret:Dynamic = null;
		if (code != null && code.trim().length > 0) {
			this.parser.line = 1;
			this.loadFromString(code);
			@:privateAccess
			this.interp.execute(parser.mk(EBlock([]), 0, 0));
			if (expr != null)
				ret = interp.execute(expr);
		}

		return ret;
	}

	public function hget(name:String):Dynamic {
		return __variables.contains(name) ? Reflect.getProperty(this, name) : this.get(name);
	}

	public function hset(name:String, val:Dynamic):Dynamic {
		if (__variables.contains(name))
			Reflect.setProperty(this, name, val);
		else
			this.set(name, val);
		return val;
	}
}

final class LuaClass implements LuaAccess {
	public var __class(default, null):Class<Dynamic>;

	var __constructor(default, null):haxe.Constraints.Function;
	var __fields(default, null):Array<String>;

	public function new(__class:Class<Dynamic>) {
		this.__class = __class;
		__fields = {
			var f = Reflect.fields(__class);
			var cf = Type.getClassFields(__class);
			var fieldMap:Map<String, String> = [for(field in f.concat(cf)) field => field];

			fieldMap.array();
		};
		__constructor = Reflect.makeVarArgs((args) -> Type.createInstance(__class, args));
	}

	public function get(name:String):Dynamic {
		if(name == 'new')
			return __constructor;
		
		return __fields.contains(name) ? Reflect.getProperty(__class, name) : null;
	}

	public function set(name:String, value:Dynamic):Dynamic {
		if(__fields.contains(name)) {
			Reflect.setProperty(__class, name, value);
			return value;
		}
		return null;
	}
}

typedef StackPointer =  {
	var __stack_id:Int;
}
#else
typedef LuaScript = DummyScript;
#end