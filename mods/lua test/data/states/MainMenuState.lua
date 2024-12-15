local hasTween = false
local posX = 10
local ab = 0.005
local ab1 = 0.0008
local bpm

function new()
	print('"new" constructor :3')
end

function postCreate()
	print("prePost")

	bpm = getClassField('funkin.backend.system.Conductor', 'bpm')

	createSprite('fabi', 'fabi');
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
	initShader('chromaticAberration')
	addShader('default', 'chromaticAberration')

	print("created");

	executeScript('testScript', [[
		trace("Hello from Lua through HScript ");
		trace(">:3");
	]]);
end

function beatHit(curBeat)
	-- body
	-- For now, Shader variables can be only modified through "setShaderField" callback
	if(math.fmod(curBeat, 2) == 0 and not hasTween) then
		--print(curBeat)
		--shake('camHUD', 0.01, 0.1)
		setShaderField('chromaticAberration', 'redOff', {ab1, 0})
		setShaderField('chromaticAberration', 'blueOff', {-ab1, 0})
		--chromaticAberration.shaderData.redOff = {ab1, 0}
		--chromaticAberration.shaderData.blueOff = {-ab1, 0}
		hasTween = true
	elseif(math.fmod(curBeat, 4) == 0 and hasTween) then
		setShaderField('chromaticAberration', 'redOff', {ab, 0})
		setShaderField('chromaticAberration', 'blueOff', {-ab, 0})
		--chromaticAberration.shaderData.redOff = {ab, 0}
		--chromaticAberration.shaderData.blueOff = {-ab, 0}
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