package funkin.backend.system.framerate;

class LuaInfo extends FramerateCategory {

	public static final luaVersion:String = llua.Lua.version();
	public static final luaJITVersion:String = llua.Lua.versionJIT();

	public function new() {
		super("Lua Info");
	}

	override function __enterFrame(t:Int) {
		if (alpha <= 0.05) return;

		_text = 'Version: $luaVersion';
		_text += 'Version (JIT): $luaJITVersion';

		this.text.text = _text;

		super.__enterFrame(t);
	}
}