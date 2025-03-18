# Bird Engine - Lua Scripting System

This page covers up the new Lua Scripting System, and how to use it.
The system is based on Codename's Lua System from [lua-test](https://github.com/CodenameCrew/CodenameEngine/blob/lua-test/source/funkin/scripting/LuaScript.hx) branch.

## How to use it

It's basically works almost the same way as the Codename's scripting system; It can change not only gameplay, but also menus and other engine functions (but may be limited).

**NOTE: be aware that it doesn't have the same functions as Psych Engine Lua.**

Just like in hscript you have to create a script, the filename has to end with an `.lua`.

And like in hscript, scripting relies heavily on having a console opened at all times in order to track down error and bugs with your script. To access to it, press F2 to open the console or start the game in a CMD or powershell window (or in terminal for linux/mac users) making sure that you are in the correct working folder (open the terminal by doing right click and pressing `Open with Terminal` or directly opening the terminal and typing `cd C:\Users\you\Documents\Bird Engine` depending on wherever you have the engine folder placed on).

## This Lua system can access to sprites/shaders variables through "dot-like" syntax

Doing things like `sprite.x`, `shader.iTime = time`, `sprite.scrollFactor.x = 0` and `sprite.setPosition(10, 10)` are possible in this Lua System.
Using those is beneficial as they prove to be an alternative to using callbacks for calling functions and changing their values, also it helps programmers to become familiar with hscript syntax.

Example usage:

```lua
local hasTween = false
local posX = 10

local fabi

function postCreate()
  fabi = createSprite('fabi', 'fabi')
  fabi.setPosition(posX, 200)
  fabi.scrollFactor.x = 0
  fabi.scrollFactor.y = 0

  initShader('chrom','chromaticAberration')
  addShader('default', 'chrom')
end

function beatHit(curBeat)
  if(math.fmod(curBeat, 2) == 0 and not hasTween) then
    chrom.redOff = {ab1, 0}
    chrom.blueOff = {-ab1, 0}
    hasTween = true
  elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
    chrom.redOff = {ab, 0}
    chrom.blueOff = {-ab, 0}
    hasTween = false
  end
end
```

A very useful alternative than this:

```lua
local hasTween = false
local posX = 10

function postCreate()
  createSprite('fabi', 'fabi')
  callObjectMethod('fabi', 'setPosition', {posX, 200})
  setSpriteScroll('fabi', 0, 0)

  initShader('chrom','chromaticAberration')
  addShader('default', 'chrom')
end

function beatHit(curBeat)
  if(math.fmod(curBeat, 2) == 0 and not hasTween) then
    setShaderField('chrom', 'redOff', {ab1, 0})
    setShaderField('chrom', 'blueOff', {-ab1, 0})
    hasTween = true
  elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
    setShaderField('chrom', 'redOff', {ab, 0})
    setShaderField('chrom', 'blueOff', {-ab, 0})
    hasTween = false
  end
end
```

But you are free to use any of this ways (or even mix them)

## Events

Scripting relies heavily on Events, which triggers callbacks and returns a struct of parameters, basically unclogging the parameter list of functions.
Which means, handling a state switch looks something like this:

```lua
-- for MainMenuState
function onChangeItem(event)
  playSound('', 'dialogue/text-pixel', 0.7)
  event.cancelled = true -- cancels out any other handling (useful if you want to override the selection pressing)
end
```

There's a lot of other events that will be soon documented...

Despite all of that, functions like `update`, `beatHit`, `stepHit` still receive one parameter (`elapsed`, `curBeat` and `curStep`)
