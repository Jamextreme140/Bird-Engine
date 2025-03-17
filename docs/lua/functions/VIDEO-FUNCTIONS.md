# Video Functions

Functions to play and manage sprite videos.
This videos can be managed with the same Sprite Management functions like `addSprite()`, `removeSprite()`, etc.

## Video creation

### `createVideo(name, videoPath, ext, x, y)`

Creates a video sprite with the specified file path. It calls "onVideoFinished" once the video ends.

- name: Video Alias
- videoPath (opt.) = null: The file path to the sound. Don't include the extension. Leave it empty to load the video later (not recommended).
- ext (opt.) = '.mp4': The video file extension.
- x (opt.) = 0: Position on X (horizontal).
- y (opt.) = 0: Position on Y (vertical).

Returns the video reference.

### `loadVideo(name, videoPath, ext)`

Loads the video sprite with the given file path.

- name: Video Alias
- videoPath (opt.) = null: The file path to the sound. Don't include the extension. Leave it empty to load the video later (not recommended).
- ext (opt.) = '.mp4': The video file extension.

## Video Management

### `playVideo(name, volume)`

Starts the video sprite playback.

- name: Video Alias.
- volume (opt.): The volume level (0 to 100).

### `pauseVideo(name)`

Pauses the video sprite playback.

- name: Video Alias.

### `resumeVideo(name)`

Resumes the video sprite playback.

- name: Video Alias.

### `stopVideo(name)`

Stops completely the video sprite playback.

- name: Video Alias.
