package funkin.backend.scripting.lua.events.modchart;

import modchart.events.Event;
import funkin.backend.scripting.events.CancellableEvent;

/**
 * NOTE: This event cannot be cancelled if "cancel" or "preventDefault" is called.
 */
final class CallbackEvent extends CancellableEvent{

	public var name:String;
	
	public var modchartEvent:Event;

	public var eventName:String;

	public var target:Float;

	public var beat:Float;

	public var fired:Bool = false;

	public var active:Bool = false;

	override function cancel(c:Bool = true) {
		Logs.trace('CallbackEvent: This event cannot be cancelled', WARNING);
	}

	override function preventDefault(c:Bool = false) {
		Logs.trace('CallbackEvent: This event cannot be cancelled', WARNING);
	}
}
