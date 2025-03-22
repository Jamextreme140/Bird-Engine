package funkin.backend.scripting.lua.events;

import funkin.backend.scripting.events.CancellableEvent;

final class TimerEvent extends CancellableEvent{
	/**
	 * Name of the timer
	 */
	public var name:String;
	/**
	 * How many loops are left on the timer
	 */
	public var loopsLeft:Int;
	/**
	 * How much time is left on the timer
	 */
	public var timeLeft:Float;
	/**
	 * How far along the timer is, on a scale of 0.0 to 1.0.
	 */
	public var progress:Float;
	/**
	 * The timer is finished
	 */
	public var finished:Bool;
}