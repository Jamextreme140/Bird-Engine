import('funkin.backend.MusicBeatState')

local hasTween = false
local posX = 10
local ab = 0.005
local ab1 = 0.0008
local bpm

local spr -- FlxSprite
local chrom -- CustomShader
local sprTween

local vars

function new()
	print('"new" constructor')
end

function postCreate()
	bpm = Conductor.bpm

	spr = FlxSprite.new(0, 0)
	spr.loadGraphic(Paths.image('credits/credit icon example'))
	spr.setPosition(posX, 400)
	spr.scrollFactor.set(0, 0)
	spr.scale.set(0.5, 0.5)
	spr.updateHitbox()
	add(spr)

	sprTween = FlxTween.tween(spr, {x = posX + 100}, (60/bpm), {
		ease = FlxEase.circInOut,
		type = FlxTween.PINGPONG
	})

	chrom = CustomShader.new('chromaticAberration')
	FlxG.camera.addShader(chrom)
end

function beatHit(curBeat)
	if(math.fmod(curBeat, 2) == 0 and not hasTween) then
		chrom.redOff = {ab1, 0}
		chrom.blueOff = {-ab1, 0}
		hasTween = true
	elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
		chrom.redOff = {ab, 0}
		chrom.blueOff = {-ab, 0}
		hasTween = false
	end
end

function onStateSwitch(event)
	MusicBeatState.skipTransOut = true
	MusicBeatState.skipTransIn = true
end
