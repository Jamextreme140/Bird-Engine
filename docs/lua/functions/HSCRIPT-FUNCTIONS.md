# HScript Functions

Functions that allows you to execute Haxe (hscript) code from Lua.

##

### `runScript(code)`

Runs Haxe (HScript) code inside of the script. Unlike `createScript(name, code)`, this returns a value and can be used multiple times.
Works like `runHaxeCode()` from Psych Engine, but for big scripts it's recommended to use `createScript(name, code)`.

- code: The actual code.

### `createScript(name, code)`

Uses (or creates) the specified HScript instance name and executes the typed code. You can create multiple HScript instances to execute different scripts.

Example:

```lua
function postCreate()
  createScript('test1','trace("Test 1");')
  createScript('test2', [[
    var a = 2;
    var b = 2;
    var c = a + b;
    trace(c);
  ]])
end
```

- name: The HScript instance alias.
- code: The actual code.

**Returns the created script.**

### `callScriptFunction(name, func, args)`

Calls a function inside the code from the previous created HScript instance with `createScript()`. This is useful since you won't need to use `createScript()` every time, improving performance.

Example:

```lua
function postCreate()
  createScript('beatScript', [[
    var counter = 0;
    function beatFunction(name:String, beat:Int) {
      var newBeat = beat * 2;
      trace(name);
      trace(counter++);
      return newBeat;
    }
  ]])
end

function beatHit(curBeat)
  local a = callScriptFunction('beatScript', 'beatFunction', {"beat!", curBeat})
  print(a)
end
```

NOTE: you can call directly the function by assigning it to a local variable, like this:

```lua
local beatScript
function postCreate()
  beatScript = createScript('beatScript', [[
    var counter = 0;
    function beatFunction(name:String, beat:Int) {
      var newBeat = beat * 2;
      trace(name);
      trace(counter++);
      return newBeat;
    }
  ]])
end

function beatHit(curBeat)
  local a = beatScript.beatFunction("Beat!", curBeat)
  print(a)
end
```

- name: The HScript instance alias.
- func: The function to call.
- args (opt.): The function arguments.

### `stopScript(name)`

Stops and removes the specified HScript instance name.

- name: The HScript instance alias.

### `pushVar(name, varName, variable)`

Sets a variable from Lua to use it in a HScript instance. **This function is not for imports**, instead you can use imports directly on the HScript code since it's already supported:

```lua
local a = 100
local b = 100
function postCreate()
  pushVar('scriptImport', posX, a)
  pushVar('scriptImport', posY, b)
  createScript('scriptImports', [[
    import flixel.FlxObject;
    
    function addObject() {
      add(new FlxObject(posX, posY, 2, 2));
    }
  ]])
end
```

- name: The HScript instance alias.
- varName: Variable Alias.
- variable: The value to push.
