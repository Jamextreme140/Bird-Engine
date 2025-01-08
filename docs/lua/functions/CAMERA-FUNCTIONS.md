# Camera Functions

Functions to create/manage cameras.

## Camera creation

### `createCamera(name, x, y, width, height)`

Creates a camera.

- name: Camera Alias.
- x (opt.) = 0
- y (opt.) = 0
- width (opt.) = 0
- height (opt.) = 0

### `addCamera(name, defaultDrawTarget)`

Add an specified camera to the game. Handy for PiP, split-screen, etc.

- name: Camera Alias.
- defaultDrawTarget (opt.) = false: Whether to add the camera to the list of default draw targets. If false, Sprites will not render to it unless you add it to their cameras list.

### `setCameraLerp(name, value)`

Sets how smooth the camera tracks the target. The maximum value (1) means no camera easing. A value of 0 means the camera does not move.

- name: Camera Alias.
- value (opt.) = 1: Smooth value.

### `setScrollCamera(name, x, y)`

Move the specified camera focus to the specified `x` and `y` position.

- name: Camera Alias.
- x (opt.) = 0
- y (opt.) = 0

### `setCameraTarget(name, object)`

Tells the camera to follow an specified object around.

- name: Camera Alias.
- object: The Object to follow.
