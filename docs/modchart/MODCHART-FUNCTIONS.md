# Modchart Functions

Applies for HScript and Lua

In HScript, refer to the manager instance (Example: `manager.addModifier(...)`). For HScript specific functions, [check the docs here](https://github.com/TheoDevelops/FunkinModchart/blob/main/DOC.md)

## Manager functions

### `initFM(addManager, alias)`

Initializes the modchart manager. Mandatory to call this before using the rest of functions, otherwise will not take effect.

- addManager (opt.) = true: Tells if add the manager upon creation.
- alias (opt.): Modchart Manager alias. Giving an alias will allow you to use directly some functions from the manager, like `addModifier(mod, field)`, `setPercent(mod, value, player, field)`, `getPercent(mod, player, field)` and `set(mod, beat, value, player, field)` (other functions requires "non-Lua" arguments).

### `addFM()`

Adds the modchart manager to the current game. Doesn't take effect if the manager is already added or not initialized.

## Modifier functions

### `addModifier(mod, field)`

Search a modifier by `mod` and adds it.

- mod:String   The modifier name string
- field:Int    The playfield number  (-1 by default)

### `setPercent(mod, value, player, field)`

Adds or rewrites the percent of `mod` and sets it to `value`.

- mod:String   The modifier name string
- value:Float  The value to be assigned to the modifier.
- player:Int   The player/strumline number (-1 by default)
- field:Int    The playfield number  (-1 by default)

### `getPercent(mod, player, field)`

Returns the percent of `mod`.

- mod:String   The modifier name string
- player:Int   The player/strumline number (-1 by default)
- field:Int    The playfield number  (-1 by default)

returns a Float value

## Event functions

### `set(mod, beat, value, player, field)`

Adds or rewrites the percentage of `mod` and sets it to `value` when the specified beat is reached.

- mod:String   The modifier name string
- beat:Float   The beat number where the event will be executed.
- value:Float  The value to be assigned to the modifier.
- player:Int   The player/strumline number (-1 by default)
- field:Int    The playfield number  (-1 by default)

### `ease(mod, beat, length, value, ease, player, field)`

Tweens the percentage of `mod` from its current value to `value` over the specified duration, using the provided easing function.

- mod:String   The modifier name string
- beat:Float   The beat number where the event will be executed.
- length:Float The tween duration in beats.
- ease:String  The ease function.
- value:Float  The value to be assigned to the modifier.
- player:Int   The player/strumline number (-1 by default)
- field:Int    The playfield number  (-1 by default)

### `callback(beat, func, field)`

Execute the callback function when the specified beat is reached.

- beat:Float   The beat number where the event will be executed.
- func:String  The function name.
- field:Int    The playfield number  (-1 by default).

This calls `onModchartCallback(event)`.
Example:

```lua
function onModchartCallback(event)
  if event.name == 'onTheBeat' then
    -- do something
  end
end
```

### `repeater(beat, length, func, field)`

Repeats the execution of the callback function for the specified duration, starting at the given beat.

- beat:Float   The beat number where the event will be executed.
- length:Float The repeater duration in beats.
- func:String  The function name.
- field:Int    The playfield number  (-1 by default).

This calls `onRepeaterCallback(event, length)`, just like `onModchartCallback(event)`
