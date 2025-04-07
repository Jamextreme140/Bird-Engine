local tweenLogo
function postCreate()
	tweenLogo = createScript('tweenLogo', [[
		var theLogo:FunkinSprite;
		for(spr in titleScreenSprites) {
			if(spr.name == "logo"){
				theLogo = spr;
			}
		}
		if(theLogo != null)
			FlxTween.tween(theLogo, {y: theLogo.y + 50}, (Conductor.bpm / 60)/2, {ease: FlxEase.sineInOut, type: FlxTween.PINGPONG});
	
		function sayHi() {
			trace("Hi!");
		}
		
		function sum(a:Int, b:Int) {
			return a + b;
		}
	]])

	tweenLogo.sayHi()
	local num = tweenLogo.sum(10, 15)
	print(num)
	print(FlxSprite.defaultAntialiasing)
end