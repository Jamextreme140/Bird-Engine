# NDLL Functions

Functions to load functions from ndlls.

NDLLs must be in your mod's "ndlls" folder, and must follow this name scheme:

- `name-windows.ndll` for Windows targeted ndlls
- `name-linux.ndll` for Linux targeted ndlls
- `name-mac.ndll` for Mac targeted ndlls

##

### `setNativeFunction(funcName, ndll, func, nArgs)`

Sets a native function from a Haxe NDLL. Limited to 25 argument due to a limitation.

- funcName: Native Function Alias.
- ndll: Name of the NDLL. Don't include the final prefix ('-windows', '-linux', '-mac').
- func: Name of the function.
- nArgs: Number of arguments of that function.

Returns the native function.

### `callNativeFunction(funcName, args)`

Calls an specified native function.

- funcName: Native Function Alias.
- args: Function Arguments.

## Usage Example

```lua
function create()
  -- Place ndlls in mods/yourmodname/ndlls/
  setNativeFunction('transparent', "ndllexample", "ndllexample_set_windows_transparent", 4)
  -- args: active:Bool, r:Int, g:Int, b:Int
  -- transparent(true, 255, 255, 255)
  callNativeFunction('transparent', {true, 255, 255, 255})
end
```
