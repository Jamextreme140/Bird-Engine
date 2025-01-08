# List of function calls

## Tween Functions calls

### `onTweenUpdate(tweenName, times)`

Works like `update(elasped)` but tween specific.

- tweenName: Tween Alias.
- times: The amount of times the tween executed. It can be more than one if the tween type is set on 'loop' or 'pingpong'.

### `onValueTween(tweenName, value)`

- tweenName: Tween Alias.
- value: The updated value from the numeric tween.

### `onTweenFinished(tweenName)`

- tweenName: Tween Alias.

## Video Functions calls

### `onVideoFinished(name)`

- name: Video Alias.

## Timer Functions calls

### `onTimer(event)`

- event (cancellable):
  - name: Timer Alias
  - loopsLeft: How many loops are left on the timer
  - timeLeft: How much time is left on the timer
  - progress: How far along the timer is, on a scale of 0.0 to 1.0.
  - finished: The timer is finished

## Cutscene Functions calls

### `onStartCutscene(prefix)`

- prefix: Custom prefix.

## States/substates(not yet)

### `create()`

### `postCreate()`

### `preUpdate(elapsed)`

### `update(elapsed)`

### `postUpdate(elapsed)`

### `stepHit(curStep)`

### `beatHit(curBeat)`

### `measureHit(curMeasure)`

### `onFocus()`

### `onFocusLost()`

### `draw(event)`

`event.cancelled = true` to cancel the event

### `postDraw(event)`

`event.cancelled = true` to cancel the event

### `onStateSwitch(event)`

The event has the following parameter:

- substate: represents the state/substate it's about to open (not very useful in Lua I guess).

### `onResize(event)`

The event has the following parameters:

- width represents the new width of the game.
- height: represents the new height of the game.
- oldWidth represents the old width of the game.
- oldHeight: represents the old height of the game.

### `destroy()`

## PlayState (the basics)

### `onStartCountdown(event)`

### `onPostStartCountdown()`

### `onCountdown(event)`

Refer to `event.swagCounter` for the current countdown.

### `onPostCountdown(event)`

### `onSongStart()`

### `onStartSong()`

### `onSongEnd()`

### `onCameraMove(event)`

### `onEvent(event)`

### `onSubstateOpen(event)`

### `onSubstateClose(event)`

### `onGamePause(event)`

### `onGameOver(event)`

### `onPostGameOver(event)`

### `onVocalsResync()`

## [Check the rest here](https://codename-engine.com/wiki/modding/scripting/script-calls). These are the same calls from Codename Engine

## [Check the events API here](https://codename-engine.com/api-docs/funkin/backend/scripting/events/)
