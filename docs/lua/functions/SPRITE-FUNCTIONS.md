# Sprite Functions

Functions to create sprites(images) on the game

## Normal sprites

### `createSprite(name, imagePath, x, y)`

Creates a Sprite with a specific image.

- name: Sprite alias.
- imagePath(optional): Image to load. The extension is omitted.
- x (opt.) = 0: Position on X (horizontal).
- y (opt.) = 0: Position on Y (vertical).

Returns the sprite reference.

## Animated sprites

### `createAnimatedSprite(name, imagePath, x, y)`

Creates an Animated Sprite with a specific path. Depending of the specified path it will load a Texture Atlas or a Spritesheet (if a texture atlas folder (Example: `image/Animation.json`) is not found, it will look for the spritesheet).

- name: Sprite alias.
- imagePath(optional): Image to load.
- x (opt.) = 0: Position on X (horizontal).
- y (opt.) = 0: Position on Y (vertical).

Returns the sprite reference.

### `addAnimationByPrefix(name, anim, prefix, framerate, forced, type)`

Adds an animation from a specified prefix.

- name: Sprite alias.
- anim: Animation alias
- prefix
- framerate = 24
- forced = false
- type = 'none': 'beat' = plays the animation every beat, 'loop' = the animation plays in loop.

### `addAnimationByndices(name, anim, prefix, indices, framerate, forced, type)`

Adds an animation from a specified prefix.

- name: Sprite alias.
- anim: Animation alias
- prefix
- indices: Example: '0, 1, 2, 3' or '1..12'
- framerate = 24
- forced = false
- type = 'none': 'beat' = plays the animation every beat, 'loop' = the animation plays in loop.

### `addOffset(name, anim, x, y)`

Adds an Offset for the specified animation. It's applied automatically on `playAnim`

- name: Sprite alias
- anim: Animation alias
- x = 0.0: X Offset
- y = 0.0: Y Offset

### `playAnim(name, anim, forced, reverse, initFrame, context)`

Plays the specified animation.

- name: Sprite alias
- anim: Animation alias
- forced = false: Forced to play the animation no matter if is finished or not.
- reverse = false: Plays the animation backwards
- initFrame = 0: The initial frame to play the animation.
- context = 'none':

'sing' = Whenever a note is hit and a sing animation will be played. The character will only dance after their holdTime is reached.

'dance' = Whenever a dance animation is played. The character's dancing wont be blocked.

'miss' = Whenever a note is missed and a miss animation will be played. Only for scripting, since it has the same effects as SING.

'lock' = Locks the character's animation. Prevents the character from dancing, even if the animation ended.

## Text sprite

### `createText(name, text, x, y, width, size, camera)`

Creates a Text.

- name: Sprite Alias
- text = '': Text to display
- x (opt.) = 0: Position on X (horizontal).
- y (opt.) = 0: Position on Y (vertical).
- width (opt.) = 0
- size (opt.) = 16
- camera (opt.) = 'default': the camera to be set. Example: camGame, camHUD or any camera created from `createCamera`

Returns the text reference.

### `setText(name, text)`

Changes a Text's string.

- name: Sprite Alias
- text = '': Text to change

### `setTextStyle(name, borderStyle, size, color)`

Changes a Text's style.

- name: Sprite Alias
- borderStyle = 'none': 'shadow', 'outline', 'outline fast'
- size = 1: Border Size
- color: Border Color

## Sprite management

### `addSprite(name, camera)`

Adds the sprite to the current state.

- name: Sprite alias
- camera = 'default': Sets the Sprites's Draw Camera (default uses the last camera).

### `removeSprite(name, destroy)`

Removes the sprite from the current state.

- name: Sprite alias
- destroy (opt.) = true: Clears the sprite from memory once removed. Set `false` if you are going to reuse it (use `addSprite` again)

### `setSpriteCamera(name, camera)`

Sets the Sprite's Draw Camera

- name: Sprite alias
- camera (opt.) = 'default': the camera to be set. Example: camGame, camHUD or any camera created from `createCamera`

### `setSpriteScale(name, scaleX, scaleY, updateHitbox)`

Sets the Sprite's scale
Change the size of your sprite's graphic.

- name: Sprite alias
- scaleX (opt.) = 1
- scaleY (opt.) = 1
- updateHitbox (opt.) = true: Updates the sprite's hitbox according to the current scale.

### `setSpriteSize(name, width, height, updateHitbox)`

Set's the Sprite's dimensions by using scale, allowing you to keep the current aspect ratio should one of the Integers be <= 0.

- name: Sprite alias
- width (opt.) = 0: If <= 0, and Height is set, the aspect ratio will be kept.
- height (opt.) = 0: If <= 0, and Width is set, the aspect ratio will be kept.
- updateHitbox (opt.) = true: Updates the sprite's hitbox according to the current scale.

### `setSpriteScroll(name, scrollX, scrollY)`

Controls how much the sprite is affected by camera scrolling. 0 = no movement (e.g. a background layer), 1 = same movement speed as the foreground.

- name: Sprite alias
- scrollX (opt.) = 0
- scrollY (opt.) = 0

### `setSpriteColor(name, color)`

Tints the whole sprite to a color.

- name: Sprite alias
- color: The color to use. Example: '#FFFFFF' or {255, 255, 255}

### `setSpriteColorOffset(name, r, g, b)`

- name: Sprite alias
- r (opt.) = 0
- g (opt.) = 0
- b (opt.) = 0
