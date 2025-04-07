local hasTween = false
local posX = 10
local ab = 0.005
local ab1 = 0.0008
local bpm

local fabi
local chrom

local sprTween

function new()
	print('"new" constructor :3')
end

function postCreate()
	print("prePost")

	bpm = getClassField('funkin.backend.system.Conductor', 'bpm')

	fabi = createSprite('fabi', 'fabi');
	--fabi.x = posX
	--fabi.y = 200
	--callObjectMethod('fabi', 'setPosition', {posX, 200})
	fabi.setPosition(posX, 200);
	--setSpriteScroll('fabi')
	fabi.scrollFactor.x = 0
	fabi.scrollFactor.y = 0
	addSprite('fabi', 'default');
	setSpriteScale('fabi', 0.2, 0.2)
	tween('fabitween', 'fabi', 'x', posX + 100, (60/bpm), 'circinout', 'pingpong', 0)

	setTimer('cancelFabiTween', 5, 1)
	startTimer('cancelFabiTween')

	createText('luaText', 'Bird Engine', posX, 500, 0, 27, 'default')
	addSprite('luaText', 'default')

	chrom = initShader('chrom', 'chromaticAberration')
	addShader('default', 'chrom')

	print("created");

	createScript('testScript', [[
		trace("Hello from Lua through HScript ");
		trace(">:3");
	]]);

	local newSpr = FlxSprite.new(FlxG.width - 210, 5)
	newSpr.makeGraphic(200, 200, FlxColor.BLACK)
	newSpr.scrollFactor.x = 0
	newSpr.scrollFactor.y = 0
	add(newSpr)

	sprTween = FlxTween.tween(newSpr, {x = newSpr.x - 80}, (60/bpm), {
		ease = FlxEase.circInOut,
		startDelay = (60/bpm),
		type = FlxTween.PINGPONG}
	)
end

function beatHit(curBeat)
	-- body
	if(math.fmod(curBeat, 2) == 0 and not hasTween) then
		--print(curBeat)
		--shake('camHUD', 0.01, 0.1)
		--setShaderField('chrom', 'redOff', {ab1, 0})
		--setShaderField('chrom', 'blueOff', {-ab1, 0})
		chrom.redOff = {ab1, 0}
		chrom.blueOff = {-ab1, 0}
		hasTween = true
	elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
		--setShaderField('chrom', 'redOff', {ab, 0})
		--setShaderField('chrom', 'blueOff', {-ab, 0})
		chrom.redOff = {ab, 0}
		chrom.blueOff = {-ab, 0}
		hasTween = false
	end

	if curBeat == 32 then
		--cancelTween('fabitween')
	end
end

function callMe()
	print("Hi! :3")
	--createSprite('fish2', 'credits/credit icon example', posX + 700, 300);
	--addSprite('fish2');
end

function onTimer(event)
	if event.name == 'cancelFabiTween' then
		cancelTween('fabitween')
		sprTween.cancel()
		print('canceled! from '..event.name..' timer')
	end
end

function onChangeItem(event)
	--event.cancelled = true
	playSound('', 'dialogue/text-pixel', 0.7)
end

function onStateSwitch(nextState)
	setClassField('funkin.backend.MusicBeatState', 'skipTransOut', true)
	setClassField('funkin.backend.MusicBeatState', 'skipTransIn', true)
	-- This one not possible since MusicBeatState is not set on Script creation
	--MusicBeatState.skipTransOut = true
	--MusicBeatState.skipTransIn = true

	print(nextState.substate.persistentUpdate)
end