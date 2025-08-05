package funkin.game;

import flixel.math.FlxPoint;
import funkin.backend.system.Conductor;

class Strum extends FlxSprite {
	/**
	 * Extra data that can be added to the strum.
	**/
	public var extra:Map<String, Dynamic> = [];

	/**
	 * Which animation suffix on characters that should be used when hitting notes.
	 */
	public var animSuffix:String = "";

	/**
	 * Whenever the strum should act as a CPU strum.
	 * WARNING: Unused.
	**/
	@:dox(hide) public var cpu:Bool = false; // Unused
	/**
	 * The last time the note/confirm animation was hit.
	**/
	public var lastHit:Float = -5000;

	/**
	 * The strum line that this strum belongs to.
	**/
	public var strumLine:StrumLine = null;

	/**
	 * The scroll speed of the notes.
	**/
	public var scrollSpeed:Null<Float> = null; // custom scroll speed per strum
	/**
	 * The direction of the notes.
	 * If you don't want angle of the strum to interfere with the direction the notes are going,
	 * you can set noteAngle to = 0, and then you can use the angle of the strum without it affecting the direction of the notes.
	**/
	public var noteAngle:Null<Float> = null;

	public var lastDrawCameras(default, null):Array<FlxCamera> = [];

	// Copy fields
	public var copyStrumCamera:Bool = true;
	public var copyStrumScrollX:Bool = true;
	public var copyStrumScrollY:Bool = true;
	public var copyStrumAngle:Bool = true;
	public var updateNotesPosX:Bool = true;
	public var updateNotesPosY:Bool = true;
	public var extraCopyFields(default, set):Array<String> = [];

	private inline function set_extraCopyFields(val:Array<String>)
		return extraCopyFields = val == null ? [] : val;

	/**
	 * Whenever the strum is pressed.
	**/
	public var getPressed:StrumLine->Bool = null;
	/**
	 * Whenever the strum was just pressed.
	**/
	public var getJustPressed:StrumLine->Bool = null;
	/**
	 * Whenever the strum was just released.
	**/
	public var getJustReleased:StrumLine->Bool = null;

	@:dox(hide) public inline function __getPressed(strumLine:StrumLine):Bool {
		return getPressed != null ? getPressed(strumLine) : strumLine.members.length != 4 ? ControlsUtil.getPressed(strumLine.controls, strumLine.members.length+"k"+ID) : switch(ID) {
			case 0: strumLine.controls.NOTE_LEFT;
			case 1: strumLine.controls.NOTE_DOWN;
			case 2: strumLine.controls.NOTE_UP;
			case 3: strumLine.controls.NOTE_RIGHT;
			default: false;
		}
	}
	@:dox(hide) public inline function __getJustPressed(strumLine:StrumLine) {
		return getJustPressed != null ? getJustPressed(strumLine) : strumLine.members.length != 4 ? ControlsUtil.getJustPressed(strumLine.controls, strumLine.members.length+"k"+ID) : switch(ID) {
			case 0: strumLine.controls.NOTE_LEFT_P;
			case 1: strumLine.controls.NOTE_DOWN_P;
			case 2: strumLine.controls.NOTE_UP_P;
			case 3: strumLine.controls.NOTE_RIGHT_P;
			default: false;
		}
	}
	@:dox(hide) public inline function __getJustReleased(strumLine:StrumLine) {
		return getJustReleased != null ? getJustReleased(strumLine) : strumLine.members.length != 4 ? ControlsUtil.getJustReleased(strumLine.controls, strumLine.members.length+"k"+ID) : switch(ID) {
			case 0: strumLine.controls.NOTE_LEFT_R;
			case 1: strumLine.controls.NOTE_DOWN_R;
			case 2: strumLine.controls.NOTE_UP_R;
			case 3: strumLine.controls.NOTE_RIGHT_R;
			default: false;
		}
	}

	/**
	 * Gets the scroll speed of the notes.
	 * @param note (Optional) The note
	**/
	public inline function getScrollSpeed(?note:Note):Float {
		if (note != null && note.scrollSpeed != null) return note.scrollSpeed;
		if (scrollSpeed != null) return scrollSpeed;
		if (PlayState.instance != null) return PlayState.instance.scrollSpeed;
		return 1;
	}

	/**
	 * Gets the angle of the notes.
	 * If you don't want angle of the strum to interfere with the direction the notes are going,
	 * you can set noteAngle to = 0, and then you can use the angle of the strum without it affecting the direction of the notes.
	 * @param note (Optional) The note
	**/
	public inline function getNotesAngle(?note:Note):Float {
		if (note != null && note.noteAngle != null) return note.noteAngle;
		if (noteAngle != null) return noteAngle;
		return angle;
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (cpu) {
			if (lastHit + (Conductor.crochet / 2) < Conductor.songPosition && getAnim() == "confirm") {
				playAnim("static");
			}
		}
	}

	public override function draw() {
		lastDrawCameras = cameras.copy();
		super.draw();
	}

	@:noCompletion public static inline final PIX180:Float = 565.4866776461628; // 180 * Math.PI
	@:noCompletion public static final N_WIDTHDIV2:Float = Note.swagWidth / 2;

	/**
	 * Updates the position of a note.
	 * @param daNote The note
	**/
	public function updateNotePosition(daNote:Note) {
		if (!daNote.exists) return;

		daNote.__strum = this;
		if (copyStrumCamera) daNote.__strumCameras = lastDrawCameras;
		if (copyStrumScrollX) daNote.scrollFactor.x = scrollFactor.x;
		if (copyStrumScrollY) daNote.scrollFactor.y = scrollFactor.y;
		if (copyStrumAngle && daNote.copyStrumAngle) {
			daNote.__noteAngle = getNotesAngle(daNote);
			daNote.angle = daNote.isSustainNote ? daNote.__noteAngle : angle;
		}

		updateNotePos(daNote);
		for (field in extraCopyFields)
			CoolUtil.cloneProperty(daNote, field, this); // TODO: make this cached to reduce the reflection calls - Neo
	}

	private inline function updateNotePos(daNote:Note) {
		var shouldX = updateNotesPosX && daNote.updateNotesPosX;
		var shouldY = updateNotesPosY && daNote.updateNotesPosY;

		if (shouldX || shouldY) {
			if (daNote.strumRelativePos) {
				if (shouldX) daNote.x = (this.width - daNote.width) / 2;
				if (shouldY) {
					daNote.y = (daNote.strumTime - Conductor.songPosition) * (0.45 * CoolUtil.quantize(getScrollSpeed(daNote), 100));
					if (daNote.isSustainNote) daNote.y += N_WIDTHDIV2;
				}
			} else {
				var offset = FlxPoint.get(0, (Conductor.songPosition - daNote.strumTime) * (0.45 * CoolUtil.quantize(getScrollSpeed(daNote), 100)));
				var realOffset = FlxPoint.get(0, 0);

				if (daNote.isSustainNote) offset.y -= N_WIDTHDIV2;

				if (Std.int(daNote.__noteAngle % 360) != 0) {
					var noteAngleCos = FlxMath.fastCos(daNote.__noteAngle / PIX180);
					var noteAngleSin = FlxMath.fastSin(daNote.__noteAngle / PIX180);

					var aOffset:FlxPoint = FlxPoint.get(
						(daNote.origin.x / daNote.scale.x) - daNote.offset.x,
						(daNote.origin.y / daNote.scale.y) - daNote.offset.y
					);
					realOffset.x = -aOffset.x + (noteAngleCos * (offset.x + aOffset.x)) + (noteAngleSin * (offset.y + aOffset.y));
					realOffset.y = -aOffset.y + (noteAngleSin * (offset.x + aOffset.x)) + (noteAngleCos * (offset.y + aOffset.y));

					aOffset.put();
				} else {
					realOffset.x = offset.x;
					realOffset.y = offset.y;
				}
				realOffset.y *= -1;

				if (shouldX) daNote.x = x + realOffset.x;
				if (shouldY) daNote.y = y + realOffset.y;

				offset.put();
				realOffset.put();
			}
		}
	}

	/**
	 * Updates a sustain note.
	 * @param daNote The note
	**/
	public inline function updateSustain(daNote:Note) {
		if (!daNote.isSustainNote) return;
		daNote.updateSustain(this);
	}

	/**
	 * Updates the animation state based on the player input.
	 * @param pressed Whenever the player is pressing the button
	 * @param justPressed Whenever the player just pressed the button
	 * @param justReleased Whenever the player just released the button
	**/
	public function updatePlayerInput(pressed:Bool, justPressed:Bool, justReleased:Bool) {
		switch(getAnim()) {
			case "confirm":
				if (justReleased || !pressed)
					playAnim("static");
			case "pressed":
				if (justReleased || !pressed)
					playAnim("static");
			case "static":
				if (justPressed || pressed)
					playAnim("pressed");
			case null:
				playAnim("static");
		}
	}

	/**
	 * Plays the confirm animation.
	 * @param time The time
	**/
	public inline function press(time:Float) {
		lastHit = time;
		playAnim("confirm");
	}

	/**
	 * Plays an animation.
	 * @param anim The animation name
	 * @param force Whenever the animation should be forced to play
	**/
	public function playAnim(anim:String, force:Bool = true) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
	}

	/**
	 * Gets the current animation name.
	**/
	public inline function getAnim() {
		return animation.name;
	}
}