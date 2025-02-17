# Miscellaneous Functions

## Timer functions

### `setTimer(name, delay, times)`

Creates a timer.

- name: Timer Alias.
- delay (opt.) = 1: How many seconds it takes for the timer to execute (once or each time).
- times: How many times the timer will execute. 0 means "looping forever".

### `startTimer(name)`

Starts the specified timer. It calls `onTimer(event)` once or every time.

- name: Timer Alias.

### `cancelTimer(name, destroy)`

Stops the timer.

- name: Timer Alias.
- destroy (opt.) = true: Removes and destroys the timer to save memory.

## State/Substate functions

### `switchState(state, data)`

Attempts to switch from the current game state to the specified `state`. If isn't a real state like MainMenuState, PlayState, etc., it will create a Custom State if the state script file exists.

- state: Name of the state:
  - "playstate"
  - "mainmenustate"
  - "freeplaystate"
  - "storymenustate"
  - "betawarningstate"
  - "creditsstate"
  - "any/other" = Custom State
- data: Optional extra Dynamic data passed from a previous state. Only works for Custom States.

### `resetState()`

Request a reset of the current game state.

### `openSubState(substate, data)`

Attempts to open a substate from the current game state to the specified `substate`.
A SubState is a special state that can be opened from within a State or another SubState.

To close it: `callMethod('close')`

- substate: Name of the substate:
  - "pausemenu"
  - "any/other" = Custom Substate
- data: Optional extra Dynamic data passed from a previous state. Only works for Custom SubStates.
