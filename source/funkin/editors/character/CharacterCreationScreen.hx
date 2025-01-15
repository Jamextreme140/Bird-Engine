package funkin.editors.character;

import funkin.game.Character;
import funkin.backend.utils.XMLUtil.AnimData;

typedef CharacterCreationData = {
	var anim:Array<AnimData>;
}

// TODO: choice between player and opponent type character
class CharacterCreationScreen extends UISubstateWindow {
	public static var instance:CharacterCreationScreen = null;
	
	public var character:Character;

	public var spriteTextBox:UITextBox;
	public var iconTextBox:UITextBox;
	public var iconSprite:FlxSprite;
	public var gameOverCharTextBox:UITextBox;
	public var antialiasingCheckbox:UICheckbox;
	public var flipXCheckbox:UICheckbox;
	public var iconColorWheel:UIColorwheel;
	public var positionXStepper:UINumericStepper;
	public var positionYStepper:UINumericStepper;
	public var cameraXStepper:UINumericStepper;
	public var cameraYStepper:UINumericStepper;
	public var scaleStepper:UINumericStepper;
	public var singTimeStepper:UINumericStepper;
	public var animationsButtonList:UIButtonList<CharacterAnimInfoButton>;
	public var isPlayerCheckbox:UICheckbox;
	public var isGFCheckbox:UICheckbox;
	public var scriptExtension:UITextBox;
	public var isShortLived:UICheckbox;
	public var loadBefore:UICheckbox;

	public var saveButton:UIButton;
	public var closeButton:UIButton;

	public var onSave:(xml:Xml) -> Void = null;

	var curData:CharacterCreationData;
	private var opponentTemplate:String = 
	'<character isPlayer="false" flipX="false" holdTime="4" color="#AF66CE">
		<anim name="idle"      anim="Dad idle dance"      fps="24" loop="false" x="0" y="0"/>
		<anim name="singUP"    anim="Dad Sing note UP"    fps="24" loop="false" x="-6" y="50"/>
		<anim name="singLEFT"  anim="dad sing note right"  fps="24" loop="false" x="-10" y="10"/>
		<anim name="singRIGHT" anim="Dad Sing Note LEFT" fps="24" loop="false" x="0" y="27"/>
		<anim name="singDOWN"  anim="Dad Sing Note DOWN"  fps="24" loop="false" x="0" y="-30"/>
	</character>';

	public function new(?character:Character, ?onSave:(xml:Xml) -> Void) {
		this.character = character;
		this.onSave = onSave;
		curData = {
			anim: []
		};
		CharacterCreationScreen.instance = this;
		super();
	}

	public override function create() {
		winTitle = "Creating Character";
		winWidth = 1014;
		winHeight = 600;

		super.create();

		function addLabelOn(ui:UISprite, text:String)
			add(new UIText(ui.x, ui.y - 24, 0, text));

		var title:UIText;
		add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Sprite Data", 28));

		spriteTextBox = new UITextBox(title.x, title.y + title.height + 38, 'sprite', 200);
		spriteTextBox.onChange = (sprite:String) -> checkSpriteFile(sprite);
		add(spriteTextBox);
		addLabelOn(spriteTextBox, "Sprite");

		iconTextBox = new UITextBox(spriteTextBox.x + 200 + 26, spriteTextBox.y, 'sprite-icon', 150);
		iconTextBox.onChange = (newIcon:String) -> updateIcon(newIcon);
		add(iconTextBox);
		addLabelOn(iconTextBox, "Icon");

		updateIcon('face');

		gameOverCharTextBox = new UITextBox(iconTextBox.x + 150 + (75 + 12), iconTextBox.y, "bf-dead", 200);
		gameOverCharTextBox.onChange = (sprite:String) -> checkSpriteFile(sprite);
		add(gameOverCharTextBox);
		addLabelOn(gameOverCharTextBox, "Game Over Character");

		antialiasingCheckbox = new UICheckbox(spriteTextBox.x, spriteTextBox.y + 10 + 32 + 28, "Antialiasing", true);
		add(antialiasingCheckbox);
		addLabelOn(antialiasingCheckbox, "Antialiased");

		flipXCheckbox = new UICheckbox(antialiasingCheckbox.x + 172, spriteTextBox.y + 10 + 32 + 28, "FlipX", false);
		add(flipXCheckbox);
		addLabelOn(flipXCheckbox, "Flipped");

		iconColorWheel = new UIColorwheel(gameOverCharTextBox.x + 200 + 20, gameOverCharTextBox.y, 0xFFFFFFFF);
		add(iconColorWheel);
		addLabelOn(iconColorWheel, "Icon Color");

		add(title = new UIText(spriteTextBox.x, spriteTextBox.y + 10 + 46 + 84, 0, "Character Data", 28));

		positionXStepper = new UINumericStepper(title.x, title.y + title.height + 36, 0, 0.001, 2, null, null, 84);
		add(positionXStepper);
		addLabelOn(positionXStepper, "Position (X,Y)");

		add(new UIText(positionXStepper.x + 84 - 32 + 0, positionXStepper.y + 9, 0, ",", 22));

		positionYStepper = new UINumericStepper(positionXStepper.x + 84 - 32 + 26, positionXStepper.y, 0, 0.001, 2, null, null, 84);
		add(positionYStepper);

		cameraXStepper = new UINumericStepper(positionYStepper.x + 36 + 84 - 32, positionYStepper.y, 0, 0.001, 2, null, null, 84);
		add(cameraXStepper);
		addLabelOn(cameraXStepper, "Camera Position (X,Y)");

		add(new UIText(cameraXStepper.x + 84 - 32 + 0, cameraXStepper.y + 9, 0, ",", 22));

		cameraYStepper = new UINumericStepper(cameraXStepper.x + 84 - 32 + 26, cameraXStepper.y, 0, 0.001, 2, null, null, 84);
		add(cameraYStepper);

		scaleStepper = new UINumericStepper(cameraYStepper.x + 84 - 32 + 90, cameraYStepper.y, 1, 0.001, 2, null, null, 74);
		add(scaleStepper);
		addLabelOn(scaleStepper, "Scale");

		singTimeStepper = new UINumericStepper(scaleStepper.x + 74 - 32 + 36, scaleStepper.y, 4, 0.001, 2, null, null, 74);
		add(singTimeStepper);
		addLabelOn(singTimeStepper, "Sing Duration (Steps)");

		animationsButtonList = new UIButtonList<CharacterAnimInfoButton>(singTimeStepper.x + singTimeStepper.width + 200, singTimeStepper.y, 290, 200, '', FlxPoint.get(280, 35), null, 5);
		animationsButtonList.frames = Paths.getFrames('editors/ui/inputbox');
		animationsButtonList.cameraSpacing = 0;
		animationsButtonList.addButton.callback = function() {
			//customPropertiesButtonList.add(new PropertyButton("newProperty", "valueHere", customPropertiesButtonList));
			openSubState(new CharacterAnimScreen(null, (_) -> {
				if(_ != null) addAnim(_);
			}));
		}
		var tempXML = Xml.parse(opponentTemplate).firstElement();
		var c:Int = 0;
		for (i in tempXML.elements())
		{
			var animData = XMLUtil.extractAnimFromXML(new haxe.xml.Access(i));
			addAnim(animData, c);
			c++;
		}
		add(animationsButtonList);
		addLabelOn(animationsButtonList, "Animations");

		isPlayerCheckbox = new UICheckbox(positionXStepper.x, positionXStepper.y + 10 + 32 + 28, "isPlayer", false);
		add(isPlayerCheckbox);
		addLabelOn(isPlayerCheckbox, "Is Player");

		isGFCheckbox = new UICheckbox(isPlayerCheckbox.x + 128, positionXStepper.y + 10 + 32 + 28, "isGF", false);
		add(isGFCheckbox);
		addLabelOn(isGFCheckbox, "Is GF");

		for (checkbox in [isPlayerCheckbox, isGFCheckbox, antialiasingCheckbox, flipXCheckbox])
			{checkbox.y += 4; checkbox.x += 6;}

		scriptExtension = new UITextBox(250, 388, "", 200);
		add(scriptExtension);
		addLabelOn(scriptExtension, "Script Extension");

		isShortLived = new UICheckbox(scriptExtension.x, (scriptExtension.y + scriptExtension.bHeight) + 15, "isShortLived", true);
		add(isShortLived);

		loadBefore = new UICheckbox(isShortLived.x, isShortLived.y + 30, "loadBefore", false);
		add(loadBefore);

		saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20, windowSpr.y + windowSpr.bHeight- 20, "Save & Close", function() {
			buildCharacter();
			CharacterCreationScreen.instance = null;
			close();
		}, 125);
		saveButton.x -= saveButton.bWidth;
		saveButton.y -= saveButton.bHeight;

		closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Close", function() {
			if (onSave != null) onSave(null);
			CharacterCreationScreen.instance = null;
			close();
		}, 125);
		closeButton.x -= closeButton.bWidth;
		closeButton.color = 0xFFFF0000;
		add(closeButton);
		add(saveButton);
	}

	function checkSpriteFile(sprite:String) {
		var fileExists:Bool = false;
		if(sprite != null && sprite.trim().length > 0) {
			var spriteFile = Paths.image("characters/" + sprite); // Common spritesheet file
        	var spriteAtlas = haxe.io.Path.withoutExtension(spriteFile) + "/Animation.json"; // Texture Atlas
        	var spriteMulti = haxe.io.Path.withoutExtension(spriteFile) + "/1.xml"; // Multiple Spritesheets
			for(sf in [spriteFile, spriteAtlas, spriteMulti]) {
				if(Assets.exists(sf))
					fileExists = true;
			}
			if(!fileExists) {
				openSubState(new UIWarningSubstate("Missing Sprite file!", "The provided filename/folder doesn't exist or is inaccessible. Try again.", [
					{label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
				]));
			}
		}
	}

	function updateIcon(icon:String) {
		if (iconSprite == null) add(iconSprite = new FlxSprite());

		if (iconSprite.animation.exists(icon)) return;
		@:privateAccess iconSprite.animation.clearAnimations();

		var path:String = Paths.image('icons/$icon');
		if (!Assets.exists(path)) path = Paths.image('icons/face');

		iconSprite.loadGraphic(path, true, 150, 150);
		iconSprite.animation.add(icon, [0], 0, false);
		iconSprite.antialiasing = true;
		iconSprite.animation.play(icon);

		iconSprite.scale.set(0.5, 0.5);
		iconSprite.updateHitbox();
		iconSprite.setPosition(iconTextBox.x + 150 + 8, (iconTextBox.y + 16) - (iconSprite.height/2));
	}

	function saveCharacterInfo() {
		for (stepper in [positionXStepper, positionYStepper, cameraXStepper, cameraYStepper, singTimeStepper, scaleStepper])
			@:privateAccess stepper.__onChange(stepper.label.text);

		var xml = Xml.createElement("character");
		// Avoids redundant default values
		if(positionXStepper.value != 0) xml.set("x", Std.string(positionXStepper.value));
		if(positionYStepper.value != 0) xml.set("y", Std.string(positionYStepper.value));
		if(gameOverCharTextBox.label.text != Character.FALLBACK_DEAD_CHARACTER) xml.set("gameOverChar", gameOverCharTextBox.label.text);
		if(cameraXStepper.value != 0) xml.set("camx", Std.string(cameraXStepper.value));
		if(cameraXStepper.value != 0) xml.set("camy", Std.string(cameraYStepper.value));
		if(singTimeStepper.value != 4) xml.set("holdTime", Std.string(singTimeStepper.value));
		if(flipXCheckbox.checked) xml.set("flipX", Std.string(flipXCheckbox.checked));
		if(scaleStepper.value != 1) xml.set("scale", Std.string(scaleStepper.value));
		if (iconColorWheel.colorChanged)
			xml.set("color", iconColorWheel.curColor.toWebString());

		xml.set("isPlayer", isPlayerCheckbox.checked ? "true" : "false");
		xml.set("icon", iconTextBox.label.text);
		xml.set("antialiasing", antialiasingCheckbox.checked ? "true" : "false");
		xml.set("sprite", spriteTextBox.label.text);

		for (anim in curData.anim)
		{
			var animXml:Xml = Xml.createElement('anim');
			animXml.set("name", anim.name);
			animXml.set("anim", anim.anim);
			animXml.set("loop", Std.string(anim.loop));
			animXml.set("fps", Std.string(anim.fps));
			//var offset:FlxPoint = character.getAnimOffset(anim.name);
			var offset:FlxPoint = FlxPoint.get(anim.x, anim.y);
			animXml.set("x", Std.string(offset.x));
			animXml.set("y", Std.string(offset.y));
			offset.put();

			if (anim.indices.length > 0)
				animXml.set("indices", CoolUtil.formatNumberRange(anim.indices));
			xml.addChild(animXml);
		}

		if(scriptExtension.label.text.trim() != "") {
			var extXml:Xml = Xml.createElement('extension');
			var _scriptFile:String = scriptExtension.label.text.trim();
			var _scriptFolder:String = null;
			var _scriptPath:Array<String> = _scriptFile.split("/");
			if(_scriptPath.length > 1) {
				_scriptFile = _scriptPath.pop();
				_scriptFolder = _scriptPath.join("/") + "/";
			}

			extXml.set("script", _scriptFile);
			if(_scriptFolder != null) extXml.set("folder", _scriptFolder);
			if(isShortLived.checked) extXml.set("isShortLived", Std.string(isShortLived.checked));
			if(!loadBefore.checked) extXml.set("loadBefore", Std.string(loadBefore.checked));

			xml.addChild(extXml);
		}

		// End of writing XML, time to save it
		var data:String = "<!DOCTYPE codename-engine-character>\n" + haxe.xml.Printer.print(xml, true);
		var fileDialog = new lime.ui.FileDialog();
		fileDialog.onCancel.add(function() close());
		fileDialog.onSelect.add(function(str)
		{
			CoolUtil.safeSaveFile(str, data);
			close();
			FlxG.resetState();
		});
		var fullPath = sys.FileSystem.fullPath(Paths.xml('characters/character'));
		fileDialog.browse(lime.ui.FileDialogType.SAVE, "*.xml", fullPath);
		if (onSave != null) onSave(xml);
	}

	public function addAnim(animData:AnimData, animID:Int = -1) {
		var newButton = new CharacterAnimInfoButton(0, 0, animData.name, FlxPoint.get(animData.x,animData.y));
		if (animID == -1){ 
			animationsButtonList.add(newButton);
			curData.anim.push(animData);
		}
		else {
			animationsButtonList.insert(newButton, animID);
			curData.anim.insert(animID, animData);
		}
	}

	public function editAnim(name:String) {
		var _anim:AnimData = null;
		for(anim in curData.anim) {
			if(anim.name == name) {
				_anim = anim;
				break;
			}
		}
		openSubState(new CharacterAnimScreen(_anim, (_) -> {
			if(_ != null) _edit_anim(name, _anim, _);
		}));
	}

	function _edit_anim(name:String, oldAnimData:AnimData, animData:AnimData) {
		var buttoner:CharacterAnimInfoButton = null;
		for (button in animationsButtonList.buttons.members)
			if (button.anim == name) buttoner = button;
		buttoner.updateInfo(animData.name);

		//Replace the old data
		var index = curData.anim.indexOf(oldAnimData);
		curData.anim[index] = animData;
	}

	public function deleteAnim(name:String) {
		for(button in animationsButtonList.buttons.members)
		{
			if(button.anim == name)
				animationsButtonList.remove(button);
		}
		for (anim in curData.anim)
		{
			if (anim.name == name)
			{
				curData.anim.remove(anim);
				break;
			}
		}
	}
	// ???
	function buildCharacter() {
		saveCharacterInfo();
	}
}