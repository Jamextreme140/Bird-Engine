# Gameplay Scripting

You can run Gameplay Lua Scripts in a song, by putting the scripts in `./song/YOUR SONG/scripts`, or run them in every song, by putting them in the `./songs` folder itself.

Gameplay Scripts can change the gameplay in various ways, for example, this is how you can hide the player character:

```lua
function postCreate()
  boyfriend.visible = false
end
```

```lua
function postCreate()
  setField("boyfriend.visible", false)
end
```

Or how to create and add a normal sprite:

```lua
function postCreate()
  createSprite('fabi', 'fabi', 500, 500); -- the 2nd parameter picks the png image from the ./images folder
  addSprite('fabi', 'camGame'); -- the 2nd parameter sets the camera view of the sprite. Can be camHUD to show it into the HUD.
end
```
