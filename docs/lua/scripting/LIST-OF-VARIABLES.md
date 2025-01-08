# List of Variables

## Gameplay

- `chartingMode`: Whenever Charting Mode has been enabled for this song.
- `startedCountdown`: Whenever the countdown has started or not.
- `seenCutscene`: Whenever the game has already played a specific cutscene for the current song.
- `botPlay`: Whenever the player's strumline is controlled by cpu or not.
- `needVoices`

### Current Song Variables

- `SONG`: Song Data (Chart, Metadata)
- `songBpm`: Song BPM
- `scrollSpeed`: Song Scroll Speed
- `songLength`: The length of the song in milliseconds.
- `songName`
- `stage`: Name of the stage
- `storyMode`: Whenever the song is being played in Story Mode.
- `difficulty`: The selected difficulty name
- `week`: Current week name

### Game settings

- `gameWidth`: The width of the screen in game pixels.
- `gameHeigth`: The height of the screen in game pixels.

### Beat Variables

- `curBpm`: Current BPM
- `crochet`: Current Crochet (time per beat), in milliseconds.
- `stepCrochet`: Current StepCrochet (time per step), in milliseconds.
- `curStep`
- `curStepFloat`
- `curBeat`
- `curBeatFloat`

### Character positions

- `boyfriendName`
- `boyfriendX`
- `boyfriendY`
- `boyfriendRawX`
- `boyfriendRawY`
- `dadName`
- `dadX`
- `dadY`
- `dadRawX`
- `dadRawY`
- `girlfriendName`
- `girlfriendX`
- `girlfriendY`
- `girlfriendRawX`
- `girlfriendRawY`

## Options

- `downScroll`
- `framerate`
- `ghostTapping`
- `camZoomOnBeat`
- `lowMemoryMode`
- `antialiasing`
- `gameplayShaders`

## Miscellaneous

- `currentModDirectory`
- `currentSystem`

## The rest of variables like `camZoomingInterval`, `curSong`, etc., can be accessed since the Lua scripts are aliaded with their instance
