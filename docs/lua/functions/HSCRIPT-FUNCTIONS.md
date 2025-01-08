# HScript Functions

Functions that allows you to execute Haxe (hscript) code from Lua.

##

### `executeScript(name, code)`

Uses (or creates) the specified HScript instance name and executes the typed code. You can create multiple HScript instances to execute different scripts.

NOTE: This function return nothing. For that, refer to `callScriptFunction()`.

Example:

```lua
function postCreate()
  executeScript('test1','trace("Test 1");')
  executeScript('test2', [[
    var a = 2;
    var b = 2;
    var c = a + b;
    trace(c);
  ]])
end
```

- name: The HScript instance alias.
- code: The actual code.

### `callScriptFunction(name, func, args)`

Calls a function inside the code from the previous created HScript instance with `executeScript()`. This is useful since you won't need to use `executeScript()` every time, improving performance.

Example:

```lua
function postCreate()
  executeScript('beatScript', [[
    function beatFunction(name:String, beat:Int) {
      var newBeat = beat * 2;
      trace(name);
      return newBeat;
    }
  ]])
end

function beatHit(curBeat)
  local a = callScriptFunction('beatScript', 'beatFunction', {"beat!", curBeat})
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

- name: The HScript instance alias.
- varName: Variable Alias.
- variable: The value to push.
