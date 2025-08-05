package lime.media;

import haxe.io.Bytes;
import haxe.io.Path;
import lime._internal.backend.native.NativeCFFI;
import lime._internal.format.Base64;
import lime.app.Future;
import lime.app.Promise;
import lime.media.openal.AL;
import lime.media.openal.ALBuffer;
import lime.media.vorbis.VorbisFile;
import lime.net.HTTPRequest;
import lime.utils.Log;
import lime.utils.UInt8Array;
#if lime_howlerjs
import lime.media.howlerjs.Howl;
#end
#if (js && html5)
import js.html.Audio;
#elseif flash
import flash.media.Sound;
import flash.net.URLRequest;
#end

@:access(lime._internal.backend.native.NativeCFFI)
@:access(lime.utils.Assets)
#if hl
@:keep
#end
#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

/**
	The `AudioBuffer` class represents a buffer of audio data that can be played back using an `AudioSource`. 
	It supports a variety of audio formats and platforms, providing a consistent API for loading and managing audio data.

	Depending on the platform, the audio backend may differ, but the class provides a unified interface for accessing 
	audio data, whether it's stored in memory, loaded from a file, or streamed.

	@see lime.media.AudioSource
**/
class AudioBuffer
{
	/**
		The number of bits per sample in the audio data.
	**/
	public var bitsPerSample:Int;

	/**
		The number of audio channels (e.g., 1 for mono, 2 for stereo).
	**/
	public var channels:Int;

	/**
		The raw audio data stored as a `UInt8Array`.
	**/
	public var data:UInt8Array;

	/**
		The sample rate of the audio data, in Hz.
	**/
	public var sampleRate:Int;

	/**
		The source of the audio data. This can be an `Audio`, `Sound`, `Howl`, or other platform-specific object.
	**/
	public var src(get, set):Dynamic;

	@:noCompletion private var __srcAudio:#if (js && html5) Audio #else Dynamic #end;
	@:noCompletion private var __srcBuffer:#if lime_cffi ALBuffer #else Dynamic #end;
	@:noCompletion private var __srcCustom:Dynamic;
	@:noCompletion private var __srcHowl:#if lime_howlerjs Howl #else Dynamic #end;
	@:noCompletion private var __srcSound:#if flash Sound #else Dynamic #end;
	@:noCompletion private var __srcVorbisFile:#if lime_vorbis VorbisFile #else Dynamic #end;

	#if commonjs
	private static function __init__()
	{
		var p = untyped AudioBuffer.prototype;
		untyped Object.defineProperties(p,
			{
				"src": {get: p.get_src, set: p.set_src}
			});
	}
	#end

	/**
		Creates a new, empty `AudioBuffer` instance.
	**/
	public function new() {}

	/**
		Disposes of the resources used by this `AudioBuffer`, such as unloading any associated audio data.
	**/
	public function dispose():Void
	{
		#if (js && html5 && lime_howlerjs)
		if (__srcHowl != null) __srcHowl.unload();
		__srcHowl = null;
		#end
		#if lime_cffi
		if (__srcBuffer != null) AL.deleteBuffer(__srcBuffer);
		__srcBuffer = null;
		#end
		#if lime_vorbis
		if (__srcVorbisFile != null) __srcVorbisFile.clear();
		__srcVorbisFile = null;
		#end
	}

	/**
		Creates an `AudioBuffer` from a Base64-encoded string.

		@param base64String The Base64-encoded audio data.
		@return An `AudioBuffer` instance with the decoded audio data.
	**/
	public static function fromBase64(base64String:String):AudioBuffer
	{
		if (base64String == null) return null;

		#if (js && html5 && lime_howlerjs)
		// if base64String doesn't contain codec data, add it.
		if (base64String.indexOf(",") == -1)
		{
			base64String = "data:" + __getCodec(Base64.decode(base64String)) + ";base64," + base64String;
		}

		var audioBuffer = new AudioBuffer();
		audioBuffer.src = new Howl({src: [base64String], preload: false});
		return audioBuffer;
		#elseif (lime_cffi && !macro)
		#if !cs
		// if base64String contains codec data, strip it then decode it.
		var base64StringSplit = base64String.split(",");
		var base64StringNoEncoding = base64StringSplit[base64StringSplit.length - 1];
		var bytes:Bytes = Base64.decode(base64StringNoEncoding);
		var audioBuffer = new AudioBuffer();
		audioBuffer.data = new UInt8Array(Bytes.alloc(0));

		return NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
		#else
		// if base64String contains codec data, strip it then decode it.
		var base64StringSplit = base64String.split(",");
		var base64StringNoEncoding = base64StringSplit[base64StringSplit.length - 1];
		var bytes:Bytes = Base64.decode(base64StringNoEncoding);
		var data:Dynamic = NativeCFFI.lime_audio_load_bytes(bytes, null);

		if (data != null)
		{
			var audioBuffer = new AudioBuffer();
			audioBuffer.bitsPerSample = data.bitsPerSample;
			audioBuffer.channels = data.channels;
			audioBuffer.data = new UInt8Array(@:privateAccess new Bytes(data.data.length, data.data.b));
			audioBuffer.sampleRate = data.sampleRate;
			return audioBuffer;
		}
		#end
		#end

		return null;
	}

	/**
		Creates an `AudioBuffer` from a `Bytes` object.

		@param bytes The `Bytes` object containing the audio data.
		@return An `AudioBuffer` instance with the decoded audio data.
	**/
	public static function fromBytes(bytes:Bytes):AudioBuffer
	{
		if (bytes == null) return null;

		#if (js && html5 && lime_howlerjs)
		var audioBuffer = new AudioBuffer();
		audioBuffer.src = new Howl({src: ["data:" + __getCodec(bytes) + ";base64," + Base64.encode(bytes)], preload: false});

		return audioBuffer;
		#elseif (lime_cffi && !macro)
		#if lime_vorbis // CNE
		if (funkin.options.Options.streamedMusic) {
			var vorbisFile = VorbisFile.fromBytes(bytes);
			if (vorbisFile != null) return fromVorbisFile(vorbisFile);
		}
		#end
		#if !cs
		var audioBuffer = new AudioBuffer();
		audioBuffer.data = new UInt8Array(Bytes.alloc(0));

		return NativeCFFI.lime_audio_load_bytes(bytes, audioBuffer);
		#else
		var data:Dynamic = NativeCFFI.lime_audio_load_bytes(bytes, null);

		if (data != null)
		{
			var audioBuffer = new AudioBuffer();
			audioBuffer.bitsPerSample = data.bitsPerSample;
			audioBuffer.channels = data.channels;
			audioBuffer.data = new UInt8Array(@:privateAccess new Bytes(data.data.length, data.data.b));
			audioBuffer.sampleRate = data.sampleRate;
			return audioBuffer;
		}
		#end
		#end

		return null;
	}

	/**
		Creates an `AudioBuffer` from a file.

		@param path The file path to the audio data.
		@return An `AudioBuffer` instance with the audio data loaded from the file.
	**/
	public static function fromFile(path:String #if (js && html5 && lime_howlerjs), ?howlHtml5 = false #end):AudioBuffer
	{
		if (path == null) return null;

		#if (js && html5 && lime_howlerjs)
		var audioBuffer = new AudioBuffer();

		#if force_html5_audio
		audioBuffer.__srcHowl = new Howl({src: [path], html5: true, preload: false});
		#else
		audioBuffer.__srcHowl = new Howl({src: [path], html5: howlHtml5, preload: false});
		#end

		return audioBuffer;
		#elseif flash
		switch (Path.extension(path))
		{
			case "ogg", "wav":
				return null;
			default:
		}

		var audioBuffer = new AudioBuffer();
		audioBuffer.__srcSound = new Sound(new URLRequest(path));
		return audioBuffer;
		#elseif (lime_cffi && !macro)
		#if !cs
		var audioBuffer = new AudioBuffer();
		audioBuffer.data = new UInt8Array(Bytes.alloc(0));

		//audioBuffer = NativeCFFI.lime_audio_load_file(path, audioBuffer);
		//if (audioBuffer != null) audioBuffer.initBuffer();
		//return audioBuffer;
		return NativeCFFI.lime_audio_load_file(path, audioBuffer);
		#else
		var data:Dynamic = NativeCFFI.lime_audio_load_file(path, null);

		if (data != null)
		{
			var audioBuffer = new AudioBuffer();
			audioBuffer.bitsPerSample = data.bitsPerSample;
			audioBuffer.channels = data.channels;
			audioBuffer.data = new UInt8Array(@:privateAccess new Bytes(data.data.length, data.data.b));
			audioBuffer.sampleRate = data.sampleRate;
			//audioBuffer.initBuffer();
			return audioBuffer;
		}

		return null;
		#end
		#else
		return null;
		#end
	}

	/**
		Creates an `AudioBuffer` from an array of file paths.

		@param paths An array of file paths to search for audio data.
		@return An `AudioBuffer` instance with the audio data loaded from the first valid file found.
	**/
	public static function fromFiles(paths:Array<String> #if (js && html5 && lime_howlerjs), ?howlHtml5 = false #end):AudioBuffer
	{
		#if (js && html5 && lime_howlerjs)
		var audioBuffer = new AudioBuffer();

		#if force_html5_audio
		audioBuffer.__srcHowl = new Howl({src: paths, html5: true, preload: false});
		#else
		audioBuffer.__srcHowl = new Howl({src: paths, html5: howlHtml5, preload: false});
		#end

		return audioBuffer;
		#else
		var buffer = null;

		for (path in paths)
		{
			buffer = AudioBuffer.fromFile(path);
			if (buffer != null) break;
		}

		return buffer;
		#end
	}

	/**
		Creates an `AudioBuffer` from a `VorbisFile`.

		@param vorbisFile The `VorbisFile` object containing the audio data.
		@return An `AudioBuffer` instance with the decoded audio data.
	**/
	#if lime_vorbis
		
	public static function fromVorbisFile(vorbisFile:VorbisFile):AudioBuffer
	{
		if (vorbisFile == null) return null;

		var info = vorbisFile.info();

		var audioBuffer = new AudioBuffer();
		audioBuffer.channels = info.channels;
		audioBuffer.sampleRate = info.rate;
		audioBuffer.bitsPerSample = 16;
		audioBuffer.__srcVorbisFile = vorbisFile;

		return audioBuffer;
	}
	#else
	public static function fromVorbisFile(vorbisFile:Dynamic):AudioBuffer
	{
		return null;
	}
	#end

	/**
		Asynchronously loads an `AudioBuffer` from a file.

		@param path The file path to the audio data.
		@return A `Future` that resolves to the loaded `AudioBuffer`.
	**/
	public static function loadFromFile(path:String):Future<AudioBuffer>
	{
		#if (flash || (js && html5))
		var promise = new Promise<AudioBuffer>();

		var audioBuffer = AudioBuffer.fromFile(path);

		if (audioBuffer != null)
		{
			#if flash
			audioBuffer.__srcSound.addEventListener(flash.events.Event.COMPLETE, function(event)
			{
				promise.complete(audioBuffer);
			});

			audioBuffer.__srcSound.addEventListener(flash.events.ProgressEvent.PROGRESS, function(event)
			{
				promise.progress(Std.int(event.bytesLoaded), Std.int(event.bytesTotal));
			});

			audioBuffer.__srcSound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, promise.error);
			#elseif (js && html5 && lime_howlerjs)
			if (audioBuffer != null)
			{
				audioBuffer.__srcHowl.on("load", function()
				{
					promise.complete(audioBuffer);
				});

				audioBuffer.__srcHowl.on("loaderror", function(id, msg)
				{
					promise.error(msg);
				});

				audioBuffer.__srcHowl.load();
			}
			#else
			promise.complete(audioBuffer);
			#end
		}
		else
		{
			promise.error(null);
		}

		return promise.future;
		#else
		// TODO: Streaming

		var request = new HTTPRequest<AudioBuffer>();
		return request.load(path).then(function(buffer)
		{
			if (buffer != null)
			{
				return Future.withValue(buffer);
			}
			else
			{
				return cast Future.withError("");
			}
		});
		#end
	}

	/**
		Asynchronously loads an `AudioBuffer` from multiple files.

		@param paths An array of file paths to search for audio data.
		@return A `Future` that resolves to the loaded `AudioBuffer`.
	**/
	public static function loadFromFiles(paths:Array<String>):Future<AudioBuffer>
	{
		#if (js && html5 && lime_howlerjs)
		var promise = new Promise<AudioBuffer>();

		var audioBuffer = AudioBuffer.fromFiles(paths);

		if (audioBuffer != null)
		{
			audioBuffer.__srcHowl.on("load", function()
			{
				promise.complete(audioBuffer);
			});

			audioBuffer.__srcHowl.on("loaderror", function()
			{
				promise.error(null);
			});

			audioBuffer.__srcHowl.load();
		}
		else
		{
			promise.error(null);
		}

		return promise.future;
		#else
		return new Future(fromFiles.bind(paths), true);
		#end
	}

	private static function __getCodec(bytes:Bytes):String
	{
		var signature = bytes.getString(0, 4);

		switch (signature)
		{
			case "OggS":
				return "audio/ogg";
			case "fLaC":
				return "audio/flac";
			case "RIFF" if (bytes.getString(8, 4) == "WAVE"):
				return "audio/wav";
			default:
				switch ([bytes.get(0), bytes.get(1), bytes.get(2)])
				{
					case [73, 68, 51] | [255, 251, _] | [255, 250, _] | [255, 243, _]: return "audio/mp3";
					default:
				}
		}

		Log.error("Unsupported sound format");
		return null;
	}

	// Get & Set Methods
	@:noCompletion private function get_src():Dynamic
	{
		#if (js && html5)
		#if lime_howlerjs
		return __srcHowl;
		#else
		return __srcAudio;
		#end
		#elseif flash
		return __srcSound;
		#elseif lime_vorbis
		return __srcVorbisFile;
		#else
		return __srcCustom;
		#end
	}

	@:noCompletion private function set_src(value:Dynamic):Dynamic
	{
		#if (js && html5)
		#if lime_howlerjs
		return __srcHowl = value;
		#else
		return __srcAudio = value;
		#end
		#elseif flash
		return __srcSound = value;
		#elseif lime_vorbis
		return __srcVorbisFile = value;
		#else
		return __srcCustom = value;
		#end
	}
}
