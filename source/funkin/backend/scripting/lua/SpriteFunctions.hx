package funkin.backend.scripting.lua;

import flixel.util.FlxColor;
import flixel.text.FlxText;

import funkin.backend.scripting.lua.utils.ILuaScriptable;
import funkin.backend.scripting.events.PlayAnimEvent.PlayAnimContext;
import funkin.game.Character;

final class SpriteFunctions {
	
	public static function getSpriteFunctions(instance:ILuaScriptable, ?script:Script):Map<String, Dynamic> {
		return [
			"createSprite" => function(name:String, ?imagePath:String = null, ?x:Float = 0, ?y:Float = 0)
			{
				if(instance.luaObjects["SPRITE"].exists(name))
					return null;
				
				var theSprite:FunkinSprite = new FunkinSprite(x, y);
				if(imagePath != null && imagePath.length > 0)
					theSprite.loadGraphic(Paths.image(imagePath));
				instance.luaObjects["SPRITE"].set(name, theSprite);
				//cast(script, LuaScript).set(name, theSprite);
				return theSprite;
			},
			"createText" => function(name:String, text:String = '', ?x:Float = 0, ?y:Float = 0, ?width:Float = 0, ?size:Int = 16, ?camera:String = 'default') {
				if(instance.luaObjects["TEXT"].exists(name))
					return null;
				
				var yourText:FunkinText = new FunkinText(x, y, width, text, size);
				yourText.scrollFactor.set();
				yourText.cameras = [LuaTools.getCamera(camera, instance)];
				instance.luaObjects["TEXT"].set(name, yourText);
				//cast(script, LuaScript).set(name, yourText);
				return yourText;
			},
			"setText" => function(name:String, text:String = '') {
				var yourText:FunkinText = LuaTools.getObject(instance, name);
				if(yourText != null && yourText is FlxText){
					yourText.text = text;
				}
			},
			"setTextStyle" => function(name:String, borderStyle:String = 'none', ?size:Float = 1, ?color:Dynamic) {
				var borderStyle:FlxTextBorderStyle = switch(borderStyle.toLowerCase().trim()) {
					case "shadow":
						SHADOW;
					case "outline":
						OUTLINE;
					case "outline fast" | "outline2" | "outlinefast" | "outline_fast" | "outline-fast":
						OUTLINE_FAST;
					case "none" | null:
						NONE;
					default:
						null;
				};

				if(borderStyle == null) {
					borderStyle = NONE;
				}

				var text = LuaTools.getObject(instance, name);
				if(text != null && text is FlxText) {
					cast(text, FlxText).setBorderStyle(borderStyle, LuaTools.getColor(color), size);
				}
			},
			"addSprite" => function(name:String, ?camera:String = "default") {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					if(!sprite.alive && !sprite.exists) //Check if it was removed, but not destroyed
						sprite.revive();
					instance.add(sprite);
					sprite.cameras = [LuaTools.getCamera(camera, instance)];
				}
			},
			"removeSprite" => function(name:String, destroy:Bool = true) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);

				if(sprite != null) {
					sprite.kill();
					instance.remove(sprite, true);
					if(destroy) {
						sprite.destroy();
						LuaTools.removeLuaObject(instance, name);
					}
				}
			},
			"setSpriteCamera" => function(name:String, ?camera:String = 'default') {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.cameras = [LuaTools.getCamera(camera, instance)];
				}
			},
			"setSpriteScale" => function(name:String, ?scaleX:Float = 1, ?scaleY:Float = 1, ?updateHitbox:Bool = true) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.scale.set(scaleX, scaleY);
					if(updateHitbox) sprite.updateHitbox();
				}
			},
			"setSpriteSize" => function(name:String, ?width:Int = 0, ?height:Int = 0, ?updateHitbox:Bool = true) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				/*
				if(PlayState.instance.luaObjects["SPRITE"].exists(name))
					sprite = PlayState.instance.luaObjects["SPRITE"].get(name);
				*/
				if(sprite != null) {
					sprite.setGraphicSize(width, height);
					if(updateHitbox) sprite.updateHitbox();
				}
			},
			"setSpriteScroll" => function(name:String, ?scrollX:Int = 0, ?scrollY:Int = 0) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);

				if(sprite != null) {
					sprite.scrollFactor.set(scrollX, scrollY);
				}
			},
			"setSpriteColor" => function(name:String, color:Dynamic) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);
				var newColor:FlxColor = LuaTools.getColor(color);

				if(sprite != null) {
					/*
					sprite.colorTransform.redMultiplier = r;
					sprite.colorTransform.greenMultiplier = g;
					sprite.colorTransform.blueMultiplier = b;
					*/
					sprite.color = newColor;
				}
			},
			"setSpriteColorOffset" => function(name:String, ?r:Float = 0, ?g:Float = 0, ?b:Float = 0) {
				var sprite:FlxSprite = LuaTools.getObject(instance, name);

				if(sprite != null) {
					sprite.colorTransform.redOffset = r;
					sprite.colorTransform.greenOffset = g;
					sprite.colorTransform.blueOffset = b;
				}
			}
		];
	}

	public static function getAnimatedSpriteFunctions(instance:MusicBeatState, ?script:Script):Map<String, Dynamic>
	{
		return [
			"createAnimatedSprite" => function(name:String, ?imagePath:String, ?x:Float = 0, ?y:Float = 0) {
				if (instance.luaObjects["SPRITE"].exists(name))
					return null;

				var theSprite:FunkinSprite = new FunkinSprite(x, y);
				if (imagePath != null && imagePath.length > 0)
					theSprite.loadSprite(imagePath);
				instance.luaObjects["SPRITE"].set(name, theSprite);
				//cast(script, LuaScript).set(name, theSprite);
				return theSprite;
			},
			"addAnimationByPrefix" => function(name:String, anim:String, prefix:String, framerate:Int = 24, forced:Bool = false, type:String = 'none') {
				if (instance.luaObjects["SPRITE"].exists(name))
				{
					var sprite:FunkinSprite = LuaTools.getObject(instance, name);

					var animType:XMLAnimType = switch (type.toLowerCase())
					{
						case 'beat': XMLAnimType.BEAT;
						case 'loop' | 'looped': XMLAnimType.LOOP;
						default: XMLAnimType.NONE;
					}

					sprite.addAnim(anim, prefix, framerate, null, forced, animType);
				}
			},
			"addAnimationByIndices" => function(name:String, anim:String, prefix:String, indices:String, framerate:Int = 24, forced:Bool = false, type:String = 'none') {
				if (instance.luaObjects["SPRITE"].exists(name))
				{
					var sprite:FunkinSprite = LuaTools.getObject(instance, name);

					var animType:XMLAnimType = switch (type.toLowerCase())
					{
						case 'beat': XMLAnimType.BEAT;
						case 'loop' | 'looped': XMLAnimType.LOOP;
						default: XMLAnimType.NONE;
					}

					sprite.addAnim(anim, prefix, framerate, null, forced, CoolUtil.parseNumberRange(indices), animType);
				}
			},
			"addOffset" => function(name:String, anim:String, x:Float = 0.0, y:Float = 0.0) {
				if (instance.luaObjects["SPRITE"].exists(name)) {
					var sprite:FunkinSprite = LuaTools.getObject(instance, name);

					sprite.addOffset(anim, x, y);
				}
				else {
					var sprite:FlxSprite = LuaTools.getObject(instance, name);

					if (sprite != null) {
						if (sprite is FunkinSprite)
						{
							cast(sprite, FunkinSprite).addOffset(anim, x, y);
						}
					}
				}
			},
			"playAnim" => function(name:String, anim:String, forced:Bool = false, reverse:Bool = false, initFrame:Int = 0, context:String = 'none') {
				var animContext:PlayAnimContext = switch (context.toLowerCase())
				{
					case 'sing' | 'singing': SING;
					case 'dance' | 'dancing': DANCE;
					case 'miss' | 'missed': MISS;
					case 'lock' | 'locked': LOCK;
					default: NONE;
				}

				if (instance.luaObjects["SPRITE"].exists(name))
				{
					var sprite:FunkinSprite = LuaTools.getObject(instance, name);

					if (sprite.hasAnim(anim))
						sprite.playAnim(anim, forced, animContext, reverse, initFrame);
				}
				else
				{
					var sprite:FlxSprite = LuaTools.getObject(instance, name);

					if (sprite != null)
					{
						if (sprite is Character)
						{
							cast(sprite, Character).playAnim(anim, forced, animContext, reverse, initFrame);
						}
						else if (sprite.animation.exists(anim))
							sprite.animation.play(anim, forced, reverse, initFrame);
					}
				}
			}
		];
	}
}