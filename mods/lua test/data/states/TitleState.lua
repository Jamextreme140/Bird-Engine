
function postCreate()
	runScript([[
		var theLogo:FunkinSprite;
		for(spr in titleScreenSprites) {
			if(spr.name == "logo"){
				theLogo = spr;
			}
		}
		if(theLogo != null)
			FlxTween.tween(theLogo, {y: theLogo.y + 50}, (Conductor.bpm / 60)/2, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
	]])
end