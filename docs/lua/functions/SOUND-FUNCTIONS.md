# Sound Functions

Functions to play and manage sounds.

## Sound creation

### `playSound(name, file, volume, looped, destroy)`

Plays the given sound file. It just plays the sound if an alias is not specified.

- name: Sound Alias. Leave it empty to use it once.
- file: The file path to the sound. Don't include the extension.
- volume (opt.) = 1: How loud to play it (0 to 100).
- looped (opt.) = false: Whether to loop this sound.

Returns the sound reference.

## Sound management

### `stopSound(name, destroy)`

Stops the given sound.

- name: Sound Alias.
- destroy (opt.) = true: Removes the sound from the memory

### `pauseSound(name)`

Pauses the given sound.

- name: Sound Alias.

### `resumeSound(name)`

Resumes the given sound.

- name: Sound Alias.
