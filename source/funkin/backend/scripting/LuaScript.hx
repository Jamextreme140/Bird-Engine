package funkin.backend.scripting;

import flixel.util.typeLimit.OneOfTwo;
#if ENABLE_LUA
import funkin.backend.scripting.lua.utils.ILuaScriptable;
import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.lua.*;

import haxe.DynamicAccess;

import openfl.utils.Assets;

import hscript.IHScriptCustomBehaviour;

import llua.State;
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
class LuaScript extends Script{
	public var state(default, null):State = null;
	public var luaCallbacks(default, null):Map<String, Dynamic> = [];
	public var stack(default, null):Map<Int, Dynamic> = [];

	public var parent(default, null):ParentObject;

	private var lastStackID:Int = 0;

	public static var curLuaScript:LuaScript = null;

	#if MODCHARTING_FEATURES
	@:allow(funkin.backend.scripting.lua.ModchartFunctions)
	var modchartManager:modchart.Manager;
	#end

	// hscript
	public var hscript(default, null):LuaHScript;
	
	public function new(path:String, ?parent:ParentObject) {
		this.parent = parent;

		super(path);
		
		if(parent.instance != null) {
			setCallbacks(); // Sets all the callbacks

			set('this', parent.instance);
		}
		
		funkin.backend.system.framerate.LuaInfo.luaCount += 1;
	}
	
	public override function onCreate(path:String) {
		super.onCreate(path);

		state = LuaL.newstate();
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(callback_handler)); // TODO: move this since the callbacks function is static
		state.openlibs();
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		state.register_hxtrace_lib();

		onPointerCall = Reflect.makeVarArgs(pointerCall);

		luaCallbacks["__onPointerIndex"] = onPointerIndex;
		luaCallbacks["__onPointerNewIndex"] = onPointerNewIndex;
		luaCallbacks["__onPointerCall"] = onPointerCall;
		luaCallbacks["__gc"] = onGarbageCollection;

		state.newmetatable("__funkinMetaTable");

		state.pushstring('__index');
		state.pushcfunction(cpp.Callable.fromStaticFunction(__index));
		state.settable(-3);

		state.pushstring('__newindex');
		state.pushcfunction(cpp.Callable.fromStaticFunction(__newindex));
		state.settable(-3);

		state.pushstring('__call');
		state.pushcfunction(cpp.Callable.fromStaticFunction(__call));
		state.settable(-3);
		state.setglobal("__funkinMetaTable");

		// set('chartingMode', PlayState.chartingMode);

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.call("onScriptCreated", [null, "luascript"]);
		#end
	}

	public override function onLoad() {
		var code = Assets.getText(path);
		if(code != null && code.trim() != "") {
			if (state.dostring(code) != 0)
				this.error('${state.tostring(-1)}');
			else
				this.call('new', []);
		}
	}

	public static var callbackReturnVariables = [];

	public override function onCall(funcName:String, args:Array<Dynamic>):Dynamic {
		state.settop(0);
		state.getglobal(funcName);

		if (state.type(-1) != Lua.LUA_TFUNCTION)
			return null;

		for (k => val in args)
			pushArg(val);

		if (state.pcall(args.length, 1, 0) != 0)
		{
			this.error('${state.tostring(-1)}');
			return null;
		}

		var v = fromLua(state.gettop());
		state.settop(0);
		return v;
	}

	public override function set(variable:String, value:Dynamic) {
		if (state == null)
			return;

		if(value is Class) 
			setClassPointer(value);
		else
			pushArg(value);
		state.setglobal(variable);
	}

	function setCallbacks() {
		if(parent.instance is PlayState) {
			for (k => e in LuaPlayState.getPlayStateVariables(this))
				set(k, e);
			for (k => e in LuaPlayState.getPlayStateFunctions(this))
				addCallback(k, e);
			for (k => e in ModchartFunctions.getModchartFunctions(this))
				addCallback(k, e);
			for (k => e in ModchartFunctions.getFunkinModchartFunctions(this))
				addCallback(k, e);
		}
		for (k => e in HScriptFunctions.getHScriptFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in SpriteFunctions.getSpriteFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in TweenFunctions.getTweenFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in ReflectionFunctions.getReflectFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in UtilFunctions.getUtilFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in ShaderFunctions.getShaderFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in SoundFunctions.getSoundFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in VideoFunctions.getVideoFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in CameraFunctions.getCameraFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in NdllFunctions.getNdllFunctions(this))
			addCallback(k, e);
		for (k => e in StateFunctions.getStateFunctions(parent.instance, this))
			addCallback(k, e);
		for (k => e in OptionsVariables.getOptionsVariables(this))
			set(k, e);
	}

	public function event<T:CancellableEvent>(func:String, event:T):T {
		this.call(func, [event]);
		return event;
	}

	public function addCallback(funcName:String, func:Dynamic) {
		luaCallbacks.set(funcName, func);
		state.add_callback_function(funcName);
	}

	public override function destroy() {
		close();
	}

	public override function reload() {
		Logs.trace('Hot-reloading is currently not supported on Lua.', WARNING);
	}

	public override function setParent(variable:Dynamic) {
		parent.parent = variable;
		var fields:Array<String> = switch(Type.typeof(variable)) {
			case TClass(c): Type.getInstanceFields(c);
			case TObject: 
				var cls = Type.getClass(variable);
				switch(Type.typeof(cls)) {
					case TClass(c): Type.getInstanceFields(c);
					default: Reflect.fields(variable);
				}
			default: [];
		};
		parent.parentFields = fields;
		for(field in fields) {
			var f:Dynamic = Reflect.field(variable, field);
			if(!Reflect.isFunction(f))
				set(field, f);
		}
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
		//Logs.trace('Set-Public-Map is currently not available on Lua.', WARNING);
	}

	public override function loadFromString(code:String):Script {
		if(this.state.dostring(code) != 0) {
			this.error('${state.tostring(-1)}');
			return null;
		}

		return this;
	}

	public function close()
	{
		if(state == null) {
			return;
		}
		this.active = false;
		state.close();
		state = null;
		funkin.backend.system.framerate.LuaInfo.luaCount -= 1;
	}

	static inline function print_function(s:String) : Int {
		if (Script.curScript != null)
			Script.curScript.trace(s);
		return 0;
	}

	public function fromLua(stackPos:Int):Dynamic {
		var ret:Any = null;
		switch (state.type(stackPos)) {
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
			case Lua.LUA_TFUNCTION: // From https://github.com/DragShot/linc_luajit/
				null; // This there something wrong with this???
			// ret = new LuaCallback(state, state.ref(Lua.LUA_REGISTRYINDEX));
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

		if (ret is Dynamic && Reflect.hasField(ret, "__stack_id"))
		{
			// A Stack Pointer is referenced.
			var pos:Int = Reflect.field(ret, "__stack_id");
			return stack[pos];
		}
		return ret;
	}

	public function pushArg(val:Dynamic) {
		switch (Type.typeof(val)) {
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
				state.objectToLua(val); // {}
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

	private function assignPointer(val:OneOfTwo<LuaClass, Dynamic>) {
		var p:StackPointer = {
			__stack_id: lastStackID++,
		};
		state.toLua(p);
		state.getmetatable("__funkinMetaTable");
		state.setmetatable(-2);

		state.pushstring('__gc');
		state.pushcfunction(cpp.Callable.fromStaticFunction(__gc));
		state.settable(-3);

		stack[p.__stack_id] = cast val;
	}

	public static function __index(state:StatePointer):Int {
		return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerIndex");
	}

	public static function __newindex(state:StatePointer):Int {
		return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerNewIndex");
	}

	public static function __call(state:StatePointer):Int {
		return callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__onPointerCall");
	}

	public static function __gc(state:StatePointer):Int {
		// callbackPreventAutoConvert = true;
		var v = callback_handler(cast cpp.Pointer.fromRaw(state).ref, "__gc");
		// callbackPreventAutoConvert = false;
		return v;
	}

	public function onPointerIndex(obj:Dynamic, key:String) {
		//trace("reference");
		if (obj != null)
		{
			if (obj is IHScriptCustomBehaviour)
				return cast(obj, IHScriptCustomBehaviour).hget(key);
			else
				return Reflect.getProperty(obj, key);
		}

		return null;
	}

	public var onPointerCall:Dynamic;

	private function pointerCall(args:Array<Dynamic>) {
		//trace("calling");
		var obj = args.shift(); // Retrieves the referenced object
		if (obj != null && Reflect.isFunction(obj))
			return Reflect.callMethod(null, obj, args);
		return null;
	}

	public function onPointerNewIndex(obj:Dynamic, key:String, val:Dynamic) {
		if (key == "__gc")
			return null;

		if (obj != null)
		{
			if (obj is IHScriptCustomBehaviour)
				cast(obj, IHScriptCustomBehaviour).hset(key, val);
			else
				Reflect.setProperty(obj, key, val);
		}

		return null;
	}

	public function onGarbageCollection(obj:Dynamic) {
		trace(obj);
		if (Reflect.hasField(obj, "__stack_id"))
		{
			trace('Clearing item ID: ${obj.__stack_id} from stack due to garbage collection');
			stack.remove(obj.__stack_id);
		}
	}

	private static var callbackPreventAutoConvert:Bool = false;
	
	public static function callback_handler(l:State, fname:String):Int {
		if (!(Script.curScript is LuaScript))
			return 0;
		var curLua:LuaScript = cast Script.curScript;

		var cbf = curLua.luaCallbacks.get(fname);
		callbackReturnVariables = [];

		if (cbf == null || !Reflect.isFunction(cbf))
		{
			return 0;
		}

		var nparams:Int = Lua.gettop(l);
		var args:Array<Dynamic> = [for (i in 0...nparams) callbackPreventAutoConvert ? l.fromLua(-nparams + i) : curLua.fromLua(-nparams + i) ];

		var ret:Dynamic = null;

		try
		{
			ret = (nparams > 0) ? Reflect.callMethod(null, cbf, args) : cbf();
		}
		catch (e)
		{
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

	public function toHaxeObj(i:Int):Any {
		var count = 0;
		var array = true;

		loopTable(state, i, {
			if(array) {
				if(Lua.type(state, -2) != Lua.LUA_TNUMBER) array = false;
				else {
					var index = Lua.tonumber(state, -2);
					if(index < 0 || Std.int(index) != index) array = false;
				}
			}
			count++;
		});

		return
		if(count == 0) {
			{};
		} else if(array) {
			var v = [];
			loopTable(state, i, {
				var index = Std.int(Lua.tonumber(state, -2)) - 1;
				v[index] = fromLua(-1);
			});
			cast v;
		} else {
			var v:DynamicAccess<Any> = {};
			loopTable(state, i, {
				switch Lua.type(state, -2) {
					case t if(t == Lua.LUA_TSTRING): v.set(Lua.tostring(state, -2), fromLua(-1));
					case t if(t == Lua.LUA_TNUMBER):v.set(Std.string(Lua.tonumber(state, -2)), fromLua(-1));
				}
			});
			cast v;
		}
	}

	public function initHScript() {
		if(hscript != null) return;

		hscript = new LuaHScript('${haxe.io.Path.withoutExtension(this.path)}_hscript.hx');
		hscript.setParent(parent.parent);
	}
}

final class LuaHScript extends HScript implements IHScriptCustomBehaviour{
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

// TODO: make enums too
final class LuaClass implements IHScriptCustomBehaviour {
	public var __class(default, null):Class<Dynamic>;

	var __constructor(default, null):haxe.Constraints.Function;
	var __fields(default, null):Array<String>;

	public function new(__class:Class<Dynamic>) {
		this.__class = __class;
		__fields = Type.getClassFields(__class);
		__constructor = Reflect.makeVarArgs((args) -> Type.createInstance(__class, args));
	}

	public function hget(name:String):Dynamic {
		if(name == 'new')
			return __constructor;
		
		return __fields.contains(name) ? Reflect.getProperty(__class, name) : null;
	}

	public function hset(name:String, val:Dynamic):Dynamic {
		if(__fields.contains(name)) {
			Reflect.setProperty(__class, name, val);
			return val;
		}
		return null;
	}
}

typedef ParentObject =
{
	var instance:ILuaScriptable;
	var parent:Dynamic;
	var ?parentFields:Array<String>;
}

typedef StackPointer =  {
	var __stack_id:Int;
}
#else
typedef LuaScript = DummyScript;
#end
