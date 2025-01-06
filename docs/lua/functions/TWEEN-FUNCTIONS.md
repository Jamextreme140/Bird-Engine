# Tween functions

Functions to use tweens for visual effects.

## General Tween functions

### `tween(tweenName, object, property, value, duration, ease, type, timeDelayed)`

Starts a simple tween to change the given object property and calls "onTweenFinished" once the tween ends (or every time if the "type" is set on 'loop', 'pingpong').

Also calls `onTweenUpdate(tweenName, times)`

[Tween Examples Here](https://haxeflixel.com/demos/FlxTween/)

- tweenName: Tween Alias
- object: Referenced object
- property: Object field to tween. Example: 'x', 'y', 'angle', 'alpha', etc.
- value: The new value to the field.
- duration: Duration of the tween in seconds.
- ease (opt.) = 'linear': Optional easer function. Example: 'sinein', 'circout', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxEase.html)
- type (opt.) = 'oneshot': The Tween Type: 'loop', 'pingpong', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxTweenType.html)
- timeDelayed (opt.) = 0.0: Seconds to wait until starting the tween.

### `valueTween(tweenName, startValue, endValue, duration, ease, type, timeDelayed)`

Starts a simple numeric tween that increases or decreases a value and calls "onTweenFinished" once the tween ends (or every time if the "type" is set on 'loop', 'pingpong').

Also calls `onTweenUpdate(tweenName, times)` and `onValueTween(tweenName, value)` with the current value until finishes.

- tweenName: Tween Alias
- startValue: Initial value (from)
- endValue: Final value (to)
- duration: Duration of the tween in seconds.
- ease (opt.) = 'linear': Optional easer function. Example: 'sinein', 'circout', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxEase.html)
- type (opt.) = 'oneshot': The Tween Type: 'loop', 'pingpong', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxTweenType.html)
- timeDelayed (opt.) = 0.0: Seconds to wait until starting the tween.

## Tween management

### `cancelTween(tweenName)`

Cancels the current specified tween and remove it from memory

- tweenName: Tween Alias

## Modchart Tween functions

### `tweenNote(tweenName, strumLine, note, property, value, duration, ease, type, timeDelayed)`

Starts a simple tween to change the given strum property and calls "onTweenFinished" once the tween ends (or every time if the "type" is set on 'loop', 'pingpong').

- tweenName: Tween Alias
- strumLine: The strumline to reference. Example: `0` = opponent, `1` = player, `2` = girlfriend, etc.
- note: `1` = LEFT, `2` = DOWN, `3` = UP, `4` = RIGHT.
- property: Object field to tween. Example: 'x', 'y', 'angle', 'alpha', etc.
- value: The new value to the field.
- duration: Duration of the tween in seconds.
- ease (opt.) = 'linear': Optional easer function. Example: 'sinein', 'circout', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxEase.html)
- type (opt.) = 'oneshot': The Tween Type: 'loop', 'pingpong', [etc.](https://api.haxeflixel.com/flixel/tweens/FlxTweenType.html)
- timeDelayed (opt.) = 0.0: Seconds to wait until starting the tween.
