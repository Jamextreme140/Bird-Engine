# Gameplay Functions

Functions to manage the current gameplay.

##

### `startCutscene(prefix, cutsceneScriptPath)`

Starts a cutscene. Calls `onStartCutscene(prefix)`.

- prefix: Custom prefix. Using `midsong-` will require you to for example rename your video cutscene to `songs/song/midsong-cutscene.mp4` instead of `songs/song/cutscene.mp4`.
- cutsceneScriptPath (opt.): Custom script path.

### `callFunction(func, args)`

Calls the function `func` on every script (Lua and Hscript), including the script that called that function.

Can Return any value depending of the called function.

Example:

#### script.lua

```lua
local a

function postCreate()
  local b = callFunction('myFunc', {1, 2, 3})

  if(b ~= nil) then
    a = b
  end
end
```

#### otherScript.hx

```haxe
function myFunc(a:Int, b:Int, c:Int) {
  return a + b + c;
}
```

**Caution**: This can be used recursively (calls itself infinitely) that can crash your game if isn't used wisely.

- func: Function name
- args (opt.): Function arguments.

### `executeEvent(event, args)`

Triggers the specified event at any time of the song.

Example:

```lua
function beatHit(curBeat)
  executeEvent('Add Camera Zoom', {0.05, 'camHUD'})
end
```

- event: Name of the event
- args: Event's arguments

### `shake(camera, amount, time)`

Shakes the specified camera

- camera = 'default': the camera to shake. Example: camGame, camHUD or any camera created from `createCamera`
- amount (opt.) = 0.05: Percentage of how much the camera shakes.
- time (opt.) = 0.5: The length in seconds that the shaking effect should last.
