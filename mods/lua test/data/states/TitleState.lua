
function postCreate()
	executeScript('tweenLogo', [[
		var theLogo:FunkinSprite;
		for(spr in titleScreenSprites) {
			if(spr.name == "logo"){
				theLogo = spr;
			}
		}
		FlxTween.tween(theLogo, {y: theLogo.y + 50}, (Conductor.bpm / 60)/2, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
	]])
end